/**
 * Module cấu hình thông tin hồ sơ Film Lab (Lab Profile)
 */

const ProfileModule = {
  async init() {
    this.bindEvents();
    await this.loadProfile();
  },

  bindEvents() {
    const saveBtn = document.getElementById('save-profile-btn');
    if (saveBtn) {
      saveBtn.addEventListener('click', () => this.saveProfile());
    }
  },

  async loadProfile() {
    try {
      const res = await window.apiClient.getProfile();
      const profile = res.data;

      document.getElementById('lab-name').value = profile.name || '';
      document.getElementById('lab-tagline').value = profile.tagline || '';
      document.getElementById('lab-hotline').value = profile.hotline || '';
      document.getElementById('lab-email').value = profile.email || '';
      document.getElementById('lab-hours').value = profile.workingHours || '';
      document.getElementById('lab-addresses').value = (profile.addresses || []).join('\n');
      document.getElementById('policy-scan-days').value = profile.retentionPolicies?.scanFileRetentionDays || 60;
      document.getElementById('policy-negative-days').value = profile.retentionPolicies?.negativeRetentionDays || 15;
    } catch (err) {
      window.showToast('Lỗi tải hồ sơ Lab: ' + err.message, 'danger');
    }
  },

  async saveProfile() {
    const name = document.getElementById('lab-name').value;
    const tagline = document.getElementById('lab-tagline').value;
    const hotline = document.getElementById('lab-hotline').value;
    const email = document.getElementById('lab-email').value;
    const workingHours = document.getElementById('lab-hours').value;
    const addresses = document.getElementById('lab-addresses').value.split('\n').filter(a => a.trim().length > 0);
    const scanFileRetentionDays = Number(document.getElementById('policy-scan-days').value);
    const negativeRetentionDays = Number(document.getElementById('policy-negative-days').value);

    try {
      await window.apiClient.updateProfile({
        name,
        tagline,
        hotline,
        email,
        workingHours,
        addresses,
        retentionPolicies: {
          scanFileRetentionDays,
          negativeRetentionDays
        }
      });
      window.showToast('Đã lưu thông tin hồ sơ Film Lab thành công!', 'success');
    } catch (err) {
      window.showToast('Lỗi cập nhật hồ sơ Lab: ' + err.message, 'danger');
    }
  }
};

window.ProfileModule = ProfileModule;
