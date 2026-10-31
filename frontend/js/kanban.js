/**
 * Module Kanban sản xuất cho Web Lab
 */

const KanbanModule = {
  async init() {
    await this.renderKanban();
  },

  async renderKanban() {
    const kanbanContainer = document.getElementById('kanban-board');
    if (!kanbanContainer) return;

    try {
      const response = await window.apiClient.getOrders();
      const orders = response.data || [];

      // Phân loại cuộn film theo công đoạn sản xuất
      const columns = {
        RECEIVED: { title: '1. Tiếp nhận phim', rolls: [] },
        DEVELOPING: { title: '2. Đang tráng / Rửa', rolls: [] },
        SCANNING: { title: '3. Đang scan & QC', rolls: [] },
        SCANS_UPLOADED: { title: '4. Đã nạp scan trả khách', rolls: [] },
        BLANK_FILM: { title: '5. Phim trắng (Blank Film)', rolls: [] }
      };

      orders.forEach(order => {
        order.rolls.forEach(roll => {
          const stage = roll.stage || 'RECEIVED';
          if (columns[stage]) {
            columns[stage].rolls.push({ ...roll, order });
          } else {
            columns.RECEIVED.rolls.push({ ...roll, order });
          }
        });
      });

      let html = '';
      for (const [key, col] of Object.entries(columns)) {
        html += `
          <div class="kanban-col" data-stage="${key}">
            <div class="kanban-col-header">
              <span>${col.title}</span>
              <span class="badge-count">${col.rolls.length}</span>
            </div>
            <div class="kanban-cards">
              ${col.rolls.map(item => this.renderCard(item, key)).join('')}
              ${col.rolls.length === 0 ? '<p style="color:var(--text-muted); font-size:0.85rem; text-align:center; margin-top:2rem;">Chưa có cuộn phim</p>' : ''}
            </div>
          </div>
        `;
      }

      kanbanContainer.innerHTML = html;
      this.attachEvents();
    } catch (err) {
      window.showToast('Lỗi tải dữ liệu Kanban: ' + err.message, 'danger');
    }
  },

  renderCard(item, currentStage) {
    const { order, rollId, filmName, filmFormat, processType, binCode, isBlankFilm, priceSnapshot, scanMetadata } = item;
    const processClass = processType ? `tag-${processType.toLowerCase().replace(/[^a-z0-9]/g, '')}` : 'tag-c41';

    let actionButtons = '';
    if (currentStage === 'RECEIVED') {
      actionButtons = `
        <button class="btn btn-secondary btn-sm" onclick="event.stopPropagation(); KanbanModule.moveStage('${order.id}', '${rollId}', 'DEVELOPING')">Tráng phim ➔</button>
        <button class="btn btn-secondary btn-sm" onclick="event.stopPropagation(); window.OrdersModule.openBinModal('${order.id}', '${rollId}', '${binCode || ''}')">Gán khay</button>
      `;
    } else if (currentStage === 'DEVELOPING') {
      actionButtons = `
        <button class="btn btn-secondary btn-sm" onclick="event.stopPropagation(); KanbanModule.moveStage('${order.id}', '${rollId}', 'SCANNING')">Scan phim ➔</button>
        <button class="btn btn-danger btn-sm" onclick="event.stopPropagation(); window.OrdersModule.openBlankFilmModal('${order.id}', '${rollId}')">Báo phim trắng</button>
      `;
    } else if (currentStage === 'SCANNING') {
      actionButtons = `
        <button class="btn btn-primary btn-sm" onclick="event.stopPropagation(); window.OrdersModule.openUploadModal('${order.id}', '${rollId}')">Nạp file scan</button>
      `;
    } else if (currentStage === 'SCANS_UPLOADED') {
      actionButtons = `
        <button class="btn btn-secondary btn-sm" onclick="event.stopPropagation(); window.OrdersModule.openRevokeModal('${order.id}', '${rollId}')">Thu hồi / Scan lại</button>
      `;
    } else if (currentStage === 'BLANK_FILM') {
      actionButtons = `
        <span style="font-size:0.775rem; color:var(--accent-red); font-weight:600;">Đã ghi nhận hoàn phí scan</span>
      `;
    }

    return `
      <div class="kanban-card" onclick="window.OrdersModule.viewOrderDetails('${order.id}')">
        <div class="card-top">
          <span class="order-code">${order.orderCode} - [${rollId}]</span>
          <span class="customer-name">${order.customer.name}</span>
        </div>
        <div class="roll-title">${filmName}</div>
        <div class="roll-tags">
          <span class="tag ${processClass}">${processType}</span>
          <span class="tag" style="background:#2d3748; color:#cbd5e1;">${filmFormat}</span>
          ${binCode ? `<span class="tag tag-bin">Khay: ${binCode}</span>` : '<span class="tag" style="color:#e2e8f0; background:#334155;">Chưa gán khay</span>'}
          ${isBlankFilm ? `<span class="tag tag-blank">Blank Film</span>` : ''}
          ${scanMetadata ? `<span class="tag" style="background:rgba(147,51,234,0.25); color:#c084fc;">${scanMetadata.totalFrames} frames</span>` : ''}
        </div>
        <div style="font-size:0.8rem; color:var(--text-muted); margin-bottom:0.25rem;">
          Đơn giá snapshot: <b>${priceSnapshot ? priceSnapshot.itemTotal.toLocaleString() : 0}đ</b>
        </div>
        <div class="card-actions">
          ${actionButtons}
        </div>
      </div>
    `;
  },

  async moveStage(orderId, rollId, newStage) {
    try {
      await window.apiClient.updateRollStage(orderId, rollId, newStage);
      window.showToast(`Đã chuyển cuộn [${rollId}] sang công đoạn ${newStage}`, 'success');
      await this.renderKanban();
      if (window.OrdersModule) {
        window.OrdersModule.renderOrdersTable();
      }
    } catch (err) {
      window.showToast('Lỗi cập nhật công đoạn: ' + err.message, 'danger');
    }
  },

  attachEvents() {
    // Sẵn sàng mở rộng drag-drop nếu cần
  }
};

window.KanbanModule = KanbanModule;
