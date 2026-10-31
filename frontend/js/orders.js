/**
 * Module quản lý danh sách đơn hàng & thao tác nghiệp vụ cuộn film
 */

const OrdersModule = {
  currentOrder: null,
  currentRollId: null,

  async init() {
    this.bindEvents();
    await this.renderOrdersTable();
  },

  bindEvents() {
    const searchInput = document.getElementById('order-search');
    const statusSelect = document.getElementById('order-status-filter');

    if (searchInput) {
      searchInput.addEventListener('input', () => this.renderOrdersTable());
    }
    if (statusSelect) {
      statusSelect.addEventListener('change', () => this.renderOrdersTable());
    }
  },

  async renderOrdersTable() {
    const tbody = document.getElementById('orders-table-body');
    if (!tbody) return;

    const search = document.getElementById('order-search')?.value || '';
    const status = document.getElementById('order-status-filter')?.value || '';

    try {
      const response = await window.apiClient.getOrders({ search, status });
      const orders = response.data || [];

      if (orders.length === 0) {
        tbody.innerHTML = `<tr><td colspan="7" style="text-align:center; padding:2rem; color:var(--text-muted);">Không tìm thấy đơn hàng nào phù hợp.</td></tr>`;
        return;
      }

      tbody.innerHTML = orders.map(order => {
        const rollCount = order.rolls.length;
        const rollSummary = order.rolls.map(r => `[${r.rollId}] ${r.filmName}`).join(', ');
        
        let statusBadgeClass = 'badge-processing';
        if (order.status === 'SCANS_UPLOADED') statusBadgeClass = 'badge-scans-uploaded';
        if (order.status === 'CLOSED') statusBadgeClass = 'badge-active';

        return `
          <tr>
            <td><b style="color:var(--accent-cyan); cursor:pointer;" onclick="OrdersModule.viewOrderDetails('${order.id}')">${order.orderCode}</b></td>
            <td>
              <div><b>${order.customer.name}</b></div>
              <small style="color:var(--text-muted);">${order.customer.phone}</small>
            </td>
            <td>
              <span class="status-badge ${statusBadgeClass}">${order.status}</span>
            </td>
            <td>
              <div><b>${rollCount} cuộn</b></div>
              <small style="color:var(--text-muted);">${rollSummary}</small>
            </td>
            <td>
              <b>${order.totalAmount.toLocaleString()}đ</b>
              <br><small style="color:var(--accent-green);">${order.paymentStatus}</small>
            </td>
            <td>${new Date(order.createdAt).toLocaleDateString('vi-VN')}</td>
            <td>
              <button class="btn btn-secondary btn-sm" onclick="OrdersModule.viewOrderDetails('${order.id}')">Chi tiết đơn</button>
            </td>
          </tr>
        `;
      }).join('');
    } catch (err) {
      window.showToast('Lỗi tải danh sách đơn hàng: ' + err.message, 'danger');
    }
  },

  async viewOrderDetails(orderId) {
    try {
      const res = await window.apiClient.getOrder(orderId);
      const order = res.data;
      this.currentOrder = order;

      const modal = document.getElementById('order-detail-modal');
      const body = document.getElementById('order-detail-body');

      let rollsHtml = order.rolls.map(roll => {
        const snapshot = roll.priceSnapshot;
        return `
          <div style="background:var(--bg-card); border:1px solid var(--border-color); border-radius:8px; padding:1rem; margin-bottom:1rem;">
            <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:0.6rem;">
              <h4 style="color:var(--accent-cyan);">Cuộn: [${roll.rollId}] ${roll.filmName} (${roll.filmFormat})</h4>
              <span class="status-badge badge-processing">Công đoạn: ${roll.stage}</span>
            </div>

            <!-- Price Snapshotting Box -->
            <div class="snapshot-box" style="margin-bottom:0.75rem;">
              <div style="font-weight:700; margin-bottom:0.4rem; color:var(--text-muted);">PRICE SNAPSHOTTING (Cam kết tại thời điểm đặt đơn):</div>
              <div class="snapshot-row">
                <span>Dịch vụ áp dụng:</span>
                <span>${snapshot ? snapshot.serviceName : 'N/A'}</span>
              </div>
              <div class="snapshot-row">
                <span>Đơn giá cơ bản gốc:</span>
                <span>${snapshot ? snapshot.unitPriceAtOrder.toLocaleString() : 0}đ</span>
              </div>
              <div class="snapshot-row">
                <span>Phụ phí bù sáng (${snapshot?.pushPullOption || 'None'}):</span>
                <span>+${snapshot ? snapshot.pushPullSurcharge.toLocaleString() : 0}đ</span>
              </div>
              <div class="snapshot-row">
                <span>Phụ phí scan định dạng (${snapshot?.scanOption || 'Standard'}):</span>
                <span>+${snapshot ? snapshot.scanOptionSurcharge.toLocaleString() : 0}đ</span>
              </div>
              <div class="snapshot-row">
                <span>TỔNG TIỀN CUỘN NÀY:</span>
                <span>${snapshot ? snapshot.itemTotal.toLocaleString() : 0}đ</span>
              </div>
            </div>

            <!-- Negative Bin Code & Expiry -->
            <div style="font-size:0.85rem; margin-bottom:0.75rem; display:flex; gap:1.25rem; align-items:center;">
              <div>
                <b>Khay âm bản vật lý:</b> 
                <span class="tag tag-bin">${roll.binCode || 'Chưa gán'}</span>
              </div>
              ${roll.binExpiryDate ? `<div><b>Hạn giữ:</b> <span style="font-variant-numeric:tabular-nums;">${new Date(roll.binExpiryDate).toLocaleDateString('vi-VN')}</span></div>` : ''}
              <button class="btn btn-secondary btn-sm" onclick="OrdersModule.openBinModal('${order.id}', '${roll.rollId}', '${roll.binCode || ''}')">Gán khay</button>
            </div>

            <!-- Blank film alert if any -->
            ${roll.isBlankFilm ? `
              <div style="background:rgba(248,113,113,0.1); border:1px solid rgba(248,113,113,0.35); padding:0.85rem; border-radius:var(--radius-sm); margin-bottom:0.75rem; font-size:0.85rem;">
                <b style="color:var(--accent-red);">CUỘN PHIM TRẮNG (BLANK FILM):</b> ${roll.blankFilmReason}
                <div style="margin-top:0.35rem; color:var(--accent-amber);"><b>Chính sách hoàn tiền:</b> ${roll.refundRecommendation}</div>
              </div>
            ` : `
              <div style="margin-top:0.65rem;">
                <button class="btn btn-danger btn-sm" onclick="OrdersModule.openBlankFilmModal('${order.id}', '${roll.rollId}')">Báo phim trắng</button>
              </div>
            `}

            <!-- Scan metadata if any -->
            ${roll.scanMetadata ? `
              <div style="background:rgba(192,132,252,0.1); border:1px solid rgba(192,132,252,0.35); padding:0.85rem; border-radius:var(--radius-sm); margin-top:0.75rem; font-size:0.85rem;">
                <b style="color:var(--accent-purple);">THÔNG TIN FILE SCAN ĐÃ TRẢ KHÁCH:</b>
                <div style="margin-top:0.35rem;">Tên file: <code>${roll.scanMetadata.fileName}</code></div>
                <div>Độ phân giải: ${roll.scanMetadata.resolution} | Máy scan: ${roll.scanMetadata.scannerModel} | Tổng: ${roll.scanMetadata.totalFrames} frames (${roll.scanMetadata.fileSizeMb} MB)</div>
                <div style="font-size:0.775rem; color:var(--text-muted); margin-top:0.25rem;">Tải lên lúc: ${new Date(roll.scanMetadata.uploadedAt).toLocaleString('vi-VN')} bởi ${roll.scanMetadata.uploadedBy}</div>
                ${roll.scanMetadata.isRevoked ? `<div style="color:var(--accent-red); margin-top:0.35rem;"><b>ĐÃ THU HỒI:</b> ${roll.scanMetadata.revokeReason}</div>` : `
                  <div style="margin-top:0.65rem;">
                    <button class="btn btn-warning btn-sm" onclick="OrdersModule.openRevokeModal('${order.id}', '${roll.rollId}')">Thu hồi & nạp lại scan</button>
                  </div>
                `}
              </div>
            ` : `
              <div style="margin-top:0.65rem;">
                <button class="btn btn-primary btn-sm" onclick="OrdersModule.openUploadModal('${order.id}', '${roll.rollId}')">Nạp file scan</button>
              </div>
            `}
          </div>
        `;
      }).join('');

      let timelineHtml = order.timeline.map(t => `
        <li style="margin-bottom:0.4rem; font-size:0.85rem;">
          <span style="color:var(--accent-cyan); font-weight:600;">${new Date(t.time).toLocaleTimeString('vi-VN')}</span>: ${t.event}
        </li>
      `).join('');

      body.innerHTML = `
        <div style="display:flex; justify-content:space-between; border-bottom:1px solid var(--border-color); padding-bottom:1rem;">
          <div>
            <h3 style="color:var(--accent-primary);">${order.orderCode}</h3>
            <p style="color:var(--text-muted); font-size:0.85rem;">Khách hàng: <b>${order.customer.name}</b> (${order.customer.phone} - ${order.customer.email})</p>
            <p style="color:var(--text-muted); font-size:0.85rem;">Phương thức nhận trả âm bản: <b>${order.customer.returnMethod}</b></p>
          </div>
          <div style="text-align:right;">
            <div>Trạng thái đơn: <span class="status-badge badge-processing">${order.status}</span></div>
            <div style="margin-top:0.4rem;">Tổng tiền: <b style="font-size:1.1rem; color:var(--accent-yellow);">${order.totalAmount.toLocaleString()}đ</b></div>
          </div>
        </div>

        <div style="margin-top:1rem;">
          <h4 style="margin-bottom:0.75rem;">Danh sách cuộn film trong đơn:</h4>
          ${rollsHtml}
        </div>

        <div style="margin-top:1rem; background:var(--bg-card); border-radius:8px; padding:1rem;">
          <h4 style="margin-bottom:0.5rem;">Nhật ký quy trình (Audit Timeline):</h4>
          <ul style="list-style-type: none; padding-left: 0;">
            ${timelineHtml}
          </ul>
        </div>
      `;

      modal.classList.add('active');
    } catch (err) {
      window.showToast('Lỗi xem chi tiết đơn: ' + err.message, 'danger');
    }
  },

  // Modal gán khay âm bản (Bin code)
  openBinModal(orderId, rollId, currentBin = '') {
    this.currentOrder = { id: orderId };
    this.currentRollId = rollId;
    document.getElementById('bin-code-input').value = currentBin || 'BIN-A12';
    document.getElementById('bin-expiry-input').value = '15';
    document.getElementById('bin-modal').classList.add('active');
  },

  async submitBinCode() {
    const binCode = document.getElementById('bin-code-input').value;
    const expiryDays = document.getElementById('bin-expiry-input').value;
    if (!binCode) {
      window.showToast('Vui lòng nhập mã khay âm bản', 'warning');
      return;
    }

    try {
      await window.apiClient.assignRollBinCode(this.currentOrder.id, this.currentRollId, binCode, expiryDays);
      window.showToast(`Đã gán cuộn [${this.currentRollId}] vào khay ${binCode}`, 'success');
      document.getElementById('bin-modal').classList.remove('active');
      this.refreshAfterUpdate();
    } catch (err) {
      window.showToast('Lỗi gán khay âm bản: ' + err.message, 'danger');
    }
  },

  // Modal đánh dấu Blank Film
  openBlankFilmModal(orderId, rollId) {
    this.currentOrder = { id: orderId };
    this.currentRollId = rollId;
    document.getElementById('blank-reason-input').value = 'Phim trắng hoàn toàn, không có hình ảnh hiển thị (màn trập hỏng hoặc film không cuộn). Mép phim còn nguyên số frame chuẩn.';
    document.getElementById('blank-proof-input').value = 'assets/proofs/blank_film_evidence.jpg';
    document.getElementById('blank-modal').classList.add('active');
  },

  async submitBlankFilm() {
    const reason = document.getElementById('blank-reason-input').value;
    const proofUrl = document.getElementById('blank-proof-input').value;
    try {
      await window.apiClient.markBlankFilm(this.currentOrder.id, this.currentRollId, proofUrl, reason);
      window.showToast(`Đã ghi nhận cuộn [${this.currentRollId}] là Blank Film và chuyển tiếp hoàn phí scan`, 'warning');
      document.getElementById('blank-modal').classList.remove('active');
      this.refreshAfterUpdate();
    } catch (err) {
      window.showToast('Lỗi đánh dấu phim trắng: ' + err.message, 'danger');
    }
  },

  // Modal nạp scan metadata
  openUploadModal(orderId, rollId) {
    this.currentOrder = { id: orderId };
    this.currentRollId = rollId;
    document.getElementById('scan-filename-input').value = `${orderId}_${rollId}_scan_result.zip`;
    document.getElementById('scan-frames-input').value = '36';
    document.getElementById('scan-size-input').value = '125.8';
    document.getElementById('scan-modal').classList.add('active');
  },

  async submitScanMetadata() {
    const fileName = document.getElementById('scan-filename-input').value;
    const totalFrames = document.getElementById('scan-frames-input').value;
    const fileSizeMb = document.getElementById('scan-size-input').value;
    const scannerModel = document.getElementById('scan-model-input').value;
    const resolution = document.getElementById('scan-res-input').value;

    try {
      await window.apiClient.saveScanMetadata(this.currentOrder.id, this.currentRollId, {
        fileName,
        totalFrames,
        fileSizeMb,
        scannerModel,
        resolution
      });
      window.showToast(`Đã nạp file scan trả khách thành công cho cuộn [${this.currentRollId}]`, 'success');
      document.getElementById('scan-modal').classList.remove('active');
      this.refreshAfterUpdate();
    } catch (err) {
      window.showToast('Lỗi lưu metadata scan: ' + err.message, 'danger');
    }
  },

  // Modal thu hồi file scan (Revoke & Replace)
  openRevokeModal(orderId, rollId) {
    this.currentOrder = { id: orderId };
    this.currentRollId = rollId;
    document.getElementById('revoke-reason-input').value = 'Thu hồi do phát hiện lệch nửa khung hình frame 15, cần scan lại bằng khay kính phẳng.';
    document.getElementById('revoke-modal').classList.add('active');
  },

  async submitRevokeScan() {
    const reason = document.getElementById('revoke-reason-input').value;
    if (!reason) {
      window.showToast('Vui lòng nhập lý do thu hồi', 'warning');
      return;
    }

    try {
      await window.apiClient.revokeAndReplaceScan(this.currentOrder.id, this.currentRollId, reason);
      window.showToast(`Đã thu hồi file scan cũ của cuộn [${this.currentRollId}]. Đã chuyển lại SCANNING.`, 'warning');
      document.getElementById('revoke-modal').classList.remove('active');
      this.refreshAfterUpdate();
    } catch (err) {
      window.showToast('Lỗi thu hồi file scan: ' + err.message, 'danger');
    }
  },

  refreshAfterUpdate() {
    this.renderOrdersTable();
    if (window.KanbanModule) window.KanbanModule.renderKanban();
    if (this.currentOrder?.id) {
      this.viewOrderDetails(this.currentOrder.id);
    }
  }
};

window.OrdersModule = OrdersModule;
