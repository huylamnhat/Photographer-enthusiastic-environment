/**
 * Main Web Lab Application Controller
 */

document.addEventListener('DOMContentLoaded', async () => {
  initRoleSwitcher();
  initTabNavigation();
  initModalCloseEvents();

  // Khởi tạo các module
  if (window.KanbanModule) await window.KanbanModule.init();
  if (window.OrdersModule) await window.OrdersModule.init();
  if (window.ServicesModule) await window.ServicesModule.init();
  if (window.ProfileModule) await window.ProfileModule.init();
});

function initRoleSwitcher() {
  const roleSelect = document.getElementById('role-select');
  if (!roleSelect) return;

  const savedRole = localStorage.getItem('weblab_role') || 'LAB_OWNER';
  roleSelect.value = savedRole;
  window.apiClient.setRole(savedRole);

  roleSelect.addEventListener('change', (e) => {
    const newRole = e.target.value;
    window.apiClient.setRole(newRole);
    const roleText = newRole === 'LAB_OWNER' ? 'Chủ Lab (Toàn quyền đổi giá, pause)' : 'Nhân viên vận hành (Chỉ xử lý đơn)';
    window.showToast(`Đã chuyển vai trò: ${roleText}`, 'info');
  });
}

function initTabNavigation() {
  const tabBtns = document.querySelectorAll('.tab-btn');
  const tabPanes = document.querySelectorAll('.tab-pane');

  tabBtns.forEach(btn => {
    btn.addEventListener('click', () => {
      const targetId = btn.getAttribute('data-tab');

      tabBtns.forEach(b => b.classList.remove('active'));
      tabPanes.forEach(p => p.classList.remove('active'));

      btn.classList.add('active');
      const targetPane = document.getElementById(targetId);
      if (targetPane) {
        targetPane.classList.add('active');
      }

      // Refresh data khi chuyển tab
      if (targetId === 'tab-kanban' && window.KanbanModule) {
        window.KanbanModule.renderKanban();
      } else if (targetId === 'tab-orders' && window.OrdersModule) {
        window.OrdersModule.renderOrdersTable();
      } else if (targetId === 'tab-services' && window.ServicesModule) {
        window.ServicesModule.renderServices();
      } else if (targetId === 'tab-profile' && window.ProfileModule) {
        window.ProfileModule.loadProfile();
      }
    });
  });
}

function initModalCloseEvents() {
  document.querySelectorAll('.modal-close, .btn-modal-close').forEach(el => {
    el.addEventListener('click', () => {
      document.querySelectorAll('.modal-overlay').forEach(modal => {
        modal.classList.remove('active');
      });
    });
  });

  // Đóng modal khi bấm ra ngoài phần backdrop
  document.querySelectorAll('.modal-overlay').forEach(modal => {
    modal.addEventListener('click', (e) => {
      if (e.target === modal) {
        modal.classList.remove('active');
      }
    });
  });
}

window.showToast = function(message, type = 'info') {
  const container = document.getElementById('toast-container');
  if (!container) return;

  const toast = document.createElement('div');
  toast.className = 'toast';
  if (type === 'danger') toast.style.borderLeftColor = 'var(--accent-red)';
  if (type === 'success') toast.style.borderLeftColor = 'var(--accent-green)';
  if (type === 'warning') toast.style.borderLeftColor = 'var(--accent-yellow)';

  toast.innerHTML = `<div>${message}</div>`;
  container.appendChild(toast);

  setTimeout(() => {
    toast.remove();
  }, 4000);
};
