/**
 * API Service Client giao tiếp nội bộ với Backend Express
 */

const API_BASE = '/api/lab';

class LabApiClient {
  constructor() {
    this.currentRole = localStorage.getItem('weblab_role') || 'LAB_OWNER';
    this.currentUserName = this.currentRole === 'LAB_OWNER' ? 'Nguyen Van Chu (Lab Owner)' : 'Le Hoang (Lab Operator)';
  }

  setRole(role) {
    this.currentRole = role;
    this.currentUserName = role === 'LAB_OWNER' ? 'Nguyen Van Chu (Lab Owner)' : 'Le Hoang (Lab Operator)';
    localStorage.setItem('weblab_role', role);
  }

  getHeaders() {
    return {
      'Content-Type': 'application/json',
      'x-user-role': this.currentRole,
      'x-user-name': this.currentUserName
    };
  }

  async request(endpoint, options = {}) {
    const url = `${API_BASE}${endpoint}`;
    const config = {
      ...options,
      headers: {
        ...this.getHeaders(),
        ...(options.headers || {})
      }
    };

    try {
      const response = await fetch(url, config);
      const data = await response.json();
      if (!response.ok) {
        throw new Error(data.message || `Lỗi HTTP: ${response.status}`);
      }
      return data;
    } catch (err) {
      console.error(`[API Error] ${endpoint}:`, err);
      throw err;
    }
  }

  // Profile API
  async getProfile() {
    return this.request('/profile');
  }

  async updateProfile(profileData) {
    return this.request('/profile', {
      method: 'PUT',
      body: JSON.stringify(profileData)
    });
  }

  // Services API
  async getServices(params = {}) {
    const query = new URLSearchParams(params).toString();
    return this.request(`/services${query ? '?' + query : ''}`);
  }

  async getService(id) {
    return this.request(`/services/${id}`);
  }

  async createService(serviceData) {
    return this.request('/services', {
      method: 'POST',
      body: JSON.stringify(serviceData)
    });
  }

  async updateService(id, serviceData) {
    return this.request(`/services/${id}`, {
      method: 'PUT',
      body: JSON.stringify(serviceData)
    });
  }

  async togglePauseService(id) {
    return this.request(`/services/${id}/toggle-pause`, {
      method: 'PATCH'
    });
  }

  async getPriceAuditLogs(serviceId = null) {
    const endpoint = serviceId ? `/services/${serviceId}/price-logs` : '/services/price-logs';
    return this.request(endpoint);
  }

  // Orders API
  async getOrders(params = {}) {
    const query = new URLSearchParams(params).toString();
    return this.request(`/orders${query ? '?' + query : ''}`);
  }

  async getOrder(id) {
    return this.request(`/orders/${id}`);
  }

  async updateOrderStatus(id, status) {
    return this.request(`/orders/${id}/status`, {
      method: 'PATCH',
      body: JSON.stringify({ status })
    });
  }

  // Roll lifecycle API
  async updateRollStage(orderId, rollId, stage) {
    return this.request(`/orders/${orderId}/rolls/${rollId}/process`, {
      method: 'PATCH',
      body: JSON.stringify({ stage })
    });
  }

  async assignRollBinCode(orderId, rollId, binCode, expiryDays = 15) {
    return this.request(`/orders/${orderId}/rolls/${rollId}/bin-code`, {
      method: 'PATCH',
      body: JSON.stringify({ binCode, expiryDays })
    });
  }

  async markBlankFilm(orderId, rollId, proofUrl, reason) {
    return this.request(`/orders/${orderId}/rolls/${rollId}/blank-film`, {
      method: 'PATCH',
      body: JSON.stringify({ proofUrl, reason })
    });
  }

  // Scan metadata API
  async saveScanMetadata(orderId, rollId, metadata) {
    return this.request(`/orders/${orderId}/rolls/${rollId}/scan-metadata`, {
      method: 'POST',
      body: JSON.stringify(metadata)
    });
  }

  async revokeAndReplaceScan(orderId, rollId, reason) {
    return this.request(`/orders/${orderId}/rolls/${rollId}/revoke-scan`, {
      method: 'POST',
      body: JSON.stringify({ reason })
    });
  }
}

window.apiClient = new LabApiClient();
