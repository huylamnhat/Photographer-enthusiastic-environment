/**
 * Module quản lý gói dịch vụ và nhật ký đổi giá (Audit Trail)
 */

const ServicesModule = {
  currentEditService: null,

  async init() {
    this.bindEvents();
    await this.renderServices();
  },

  bindEvents() {
    const addBtn = document.getElementById('add-service-btn');
    if (addBtn) {
      addBtn.addEventListener('click', () => this.openAddModal());
    }
  },

  async renderServices() {
    const tbody = document.getElementById('services-table-body');
    if (!tbody) return;

    try {
      const res = await window.apiClient.getServices();
      const services = res.data || [];

      tbody.innerHTML = services.map(svc => {
        const isPaused = svc.status === 'PAUSED';
        const statusBadge = isPaused
          ? `<span class="status-badge badge-paused">PAUSED (Tạm ẩn)</span>`
          : `<span class="status-badge badge-active">ACTIVE (Đang nhận)</span>`;

        const pauseBtnText = isPaused ? 'Kích hoạt lại' : 'Tạm dừng';
        const pauseBtnClass = isPaused ? 'btn-success' : 'btn-warning';

        return `
          <tr>
            <td>
              <b>${svc.name}</b>
              <br><small style="color:var(--text-muted);">${svc.description}</small>
            </td>
            <td><span class="tag">${svc.format}</span></td>
            <td><span class="tag tag-c41">${svc.process}</span></td>
            <td><b style="color:var(--accent-amber);">${svc.basePrice.toLocaleString()}đ</b></td>
            <td>${svc.sla}</td>
            <td>${statusBadge}</td>
            <td>
              <div style="display:flex; gap:0.4rem;">
                <button class="btn btn-secondary btn-sm" onclick="ServicesModule.openEditModal('${svc.id}')">Chỉnh sửa</button>
                <button class="btn ${pauseBtnClass} btn-sm" onclick="ServicesModule.togglePause('${svc.id}')">${pauseBtnText}</button>
                <button class="btn btn-secondary btn-sm" onclick="ServicesModule.viewAuditLogs('${svc.id}')">Lịch sử giá</button>
              </div>
            </td>
          </tr>
        `;
      }).join('');
    } catch (err) {
      window.showToast('Lỗi tải danh mục dịch vụ: ' + err.message, 'danger');
    }
  },

  async togglePause(serviceId) {
    try {
      const res = await window.apiClient.togglePauseService(serviceId);
      window.showToast(res.message, 'success');
      await this.renderServices();
    } catch (err) {
      window.showToast('Lỗi thay đổi trạng thái dịch vụ: ' + err.message, 'danger');
    }
  },

  openAddModal() {
    this.currentEditService = null;
    document.getElementById('service-modal-title').textContent = 'Thêm mới gói dịch vụ';
    document.getElementById('svc-name').value = '';
    document.getElementById('svc-format').value = '135 (35mm)';
    document.getElementById('svc-process').value = 'C-41';
    document.getElementById('svc-price').value = '80000';
    document.getElementById('svc-sla').value = 'Tối đa 48 - 72 giờ';
    document.getElementById('svc-desc').value = '';
    document.getElementById('svc-reason-group').style.display = 'none';
    document.getElementById('service-edit-modal').classList.add('active');
  },

  async openEditModal(serviceId) {
    try {
      const res = await window.apiClient.getService(serviceId);
      const svc = res.data;
      this.currentEditService = svc;

      document.getElementById('service-modal-title').textContent = `Chỉnh sửa gói: ${svc.name}`;
      document.getElementById('svc-name').value = svc.name;
      document.getElementById('svc-format').value = svc.format;
      document.getElementById('svc-process').value = svc.process;
      document.getElementById('svc-price').value = svc.basePrice;
      document.getElementById('svc-sla').value = svc.sla;
      document.getElementById('svc-desc').value = svc.description;

      // Khi sửa, nếu đổi giá thì bắt buộc nhập lý do
      const reasonGroup = document.getElementById('svc-reason-group');
      const reasonInput = document.getElementById('svc-reason');
      reasonGroup.style.display = 'block';
      reasonInput.value = '';

      document.getElementById('service-edit-modal').classList.add('active');
    } catch (err) {
      window.showToast('Lỗi mở gói dịch vụ: ' + err.message, 'danger');
    }
  },

  async saveService() {
    const name = document.getElementById('svc-name').value;
    const format = document.getElementById('svc-format').value;
    const process = document.getElementById('svc-process').value;
    const basePrice = Number(document.getElementById('svc-price').value);
    const sla = document.getElementById('svc-sla').value;
    const description = document.getElementById('svc-desc').value;
    const reason = document.getElementById('svc-reason').value;

    if (!name || !basePrice) {
      window.showToast('Tên dịch vụ và đơn giá là bắt buộc', 'warning');
      return;
    }

    try {
      if (this.currentEditService) {
        // Cập nhật dịch vụ
        if (this.currentEditService.basePrice !== basePrice && (!reason || reason.trim().length === 0)) {
          window.showToast('Bắt buộc nhập lý do thay đổi giá để lưu vào Audit Trail!', 'warning');
          return;
        }

        await window.apiClient.updateService(this.currentEditService.id, {
          name,
          format,
          process,
          basePrice,
          sla,
          description,
          reason
        });
        window.showToast('Cập nhật gói dịch vụ thành công!', 'success');
      } else {
        // Thêm mới
        await window.apiClient.createService({
          name,
          format,
          process,
          basePrice,
          sla,
          description
        });
        window.showToast('Đã thêm mới gói dịch vụ!', 'success');
      }

      document.getElementById('service-edit-modal').classList.remove('active');
      await this.renderServices();
    } catch (err) {
      window.showToast('Lỗi lưu dịch vụ: ' + err.message, 'danger');
    }
  },

  async viewAuditLogs(serviceId = null) {
    try {
      const res = await window.apiClient.getPriceAuditLogs(serviceId);
      const logs = res.data || [];

      const modal = document.getElementById('audit-log-modal');
      const container = document.getElementById('audit-log-content');

      if (logs.length === 0) {
        container.innerHTML = `<p style="color:var(--text-muted); text-align:center; padding:1.5rem;">Chưa có bản ghi thay đổi giá nào.</p>`;
      } else {
        container.innerHTML = logs.map(log => `
          <div style="background:var(--bg-card); border:1px solid var(--border-subtle); padding:1rem 1.25rem; border-radius:var(--radius-md); margin-bottom:0.75rem;">
            <div style="display:flex; justify-content:space-between; margin-bottom:0.4rem;">
              <b style="color:var(--text-main); font-size:0.95rem;">${log.serviceName}</b>
              <span style="font-size:0.8rem; color:var(--text-muted); font-variant-numeric:tabular-nums;">${new Date(log.updatedAt).toLocaleString('vi-VN')}</span>
            </div>
            <div style="font-size:0.9rem; margin-bottom:0.35rem; font-variant-numeric:tabular-nums;">
              Giá thay đổi: <del style="color:var(--accent-red);">${log.oldPrice.toLocaleString()}đ</del> ➔ <b style="color:var(--accent-green);">${log.newPrice.toLocaleString()}đ</b>
            </div>
            <div style="font-size:0.85rem; color:var(--accent-amber);">
              <b>Lý do ghi nhận:</b> "${log.reason}"
            </div>
            <div style="font-size:0.775rem; color:var(--text-muted); margin-top:0.35rem;">
              Người thực hiện: ${log.updatedBy} (${log.role})
            </div>
          </div>
        `).join('');
      }

      modal.classList.add('active');
    } catch (err) {
      window.showToast('Lỗi xem lịch sử thay đổi giá: ' + err.message, 'danger');
    }
  }
};

window.ServicesModule = ServicesModule;
