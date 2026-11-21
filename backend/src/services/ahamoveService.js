const config = require('../config');

let cachedToken = '';
let cachedTokenKey = '';

const LAB_DEFAULT_COORDS = {
  'lab-001': { lat: 21.0646, lng: 105.8226 }, // CropLab Tay Ho, Ha Noi
  'lab-002': { lat: 10.8135, lng: 106.7014 }, // LLab Binh Thanh, TP.HCM
  'lab-003': { lat: 21.0245, lng: 105.8548 }, // Nadar Hoan Kiem, Ha Noi
  'lab-004': { lat: 16.0680, lng: 108.2240 }, // Song Han Hai Chau, Da Nang
  'lab-005': { lat: 21.0695, lng: 105.8240 }, // Tay Ho Analog Master
};

function assertSandboxSafety() {
  const base = String(config.AHAMOVE?.baseUrl || '').trim().toLowerCase();
  if (!base.includes('apistg.ahamove.com') && !config.AHAMOVE?.allowProduction) {
    throw new Error(
      'CHẶN AN TOÀN: Hiện chỉ cho phép môi trường AhaMove Sandbox (partner-apistg.ahamove.com) để không đặt nhầm shipper thật!'
    );
  }
}

function isAhamoveConfigured() {
  const cfg = config.AHAMOVE || {};
  return Boolean(cfg.token || (cfg.apiKey && cfg.mobile));
}

function normalizeVnPhone(rawPhone, fallback = '0904567890') {
  const digits = String(rawPhone || '').replace(/[^0-9+]/g, '');
  if (!digits) return fallback;
  if (digits.startsWith('+84')) return `0${digits.slice(3)}`;
  return digits;
}

function resolveServiceId(cityOrAddress = '') {
  const norm = String(cityOrAddress || '').toLowerCase();
  if (norm.includes('hà nội') || norm.includes('ha noi') || norm.includes('tây hồ') || norm.includes('hoàn kiếm') || norm.includes('cầu giấy') || norm.includes('hai bà trưng')) {
    return 'HAN-BIKE';
  }
  if (norm.includes('đà nẵng') || norm.includes('da nang') || norm.includes('hải châu')) {
    return 'DAD-BIKE';
  }
  return 'SGN-BIKE';
}

function cityFallbackCoords(cityOrAddress = '', offsetLat = 0, offsetLng = 0) {
  const norm = String(cityOrAddress || '').toLowerCase();
  if (norm.includes('hà nội') || norm.includes('ha noi')) {
    return { lat: 21.0285 + offsetLat, lng: 105.8542 + offsetLng };
  }
  if (norm.includes('đà nẵng') || norm.includes('da nang')) {
    return { lat: 16.0544 + offsetLat, lng: 108.2022 + offsetLng };
  }
  return { lat: 10.7769 + offsetLat, lng: 106.7009 + offsetLng };
}

async function geocodeAddress(address, fallback) {
  const q = String(address || '').trim();
  if (!q) return fallback;
  try {
    const url = `https://nominatim.openstreetmap.org/search?format=json&limit=1&countrycodes=vn&q=${encodeURIComponent(q)}`;
    const res = await fetch(url, {
      headers: { 'User-Agent': 'MiniLabFilmPlatform/1.0' },
      signal: AbortSignal.timeout(4000),
    });
    if (res.ok) {
      const list = await res.json();
      if (Array.isArray(list) && list.length > 0) {
        const lat = Number(list[0].lat);
        const lng = Number(list[0].lon);
        if (Number.isFinite(lat) && Number.isFinite(lng)) {
          return { lat, lng };
        }
      }
    }
  } catch (_) {}
  return fallback;
}

async function resolvePickupAndLabCoords({ pickupAddress, lab }) {
  const labCity = lab?.city || lab?.address || '';
  const labCoords =
    (lab?.latitude && lab?.longitude
      ? { lat: Number(lab.latitude), lng: Number(lab.longitude) }
      : LAB_DEFAULT_COORDS[lab?.lab_id]) ||
    (await geocodeAddress(lab?.address || labCity, cityFallbackCoords(labCity)));

  const pickupFallback = cityFallbackCoords(pickupAddress || labCity, -0.018, -0.012);
  let pickupCoords = await geocodeAddress(pickupAddress, pickupFallback);

  // Ensure pickup and dropoff are never identical coordinates (AhaMove requires non-zero distance)
  if (
    Math.abs(pickupCoords.lat - labCoords.lat) < 0.0005 &&
    Math.abs(pickupCoords.lng - labCoords.lng) < 0.0005
  ) {
    pickupCoords = { lat: labCoords.lat - 0.015, lng: labCoords.lng - 0.01 };
  }

  return { pickupCoords, labCoords };
}

async function getAhamoveToken(forceRefresh = false) {
  assertSandboxSafety();
  const cfg = config.AHAMOVE || {};
  if (cfg.token) return cfg.token;

  const keySig = `${cfg.mobile}:${cfg.apiKey}`;
  if (!forceRefresh && cachedToken && cachedTokenKey === keySig) {
    return cachedToken;
  }

  if (!cfg.apiKey || !cfg.mobile) {
    throw new Error('Chưa cấu hình AHAMOVE_TOKEN hoặc AHAMOVE_API_KEY + AHAMOVE_MOBILE trong backend/.env');
  }

  const baseUrl = cfg.baseUrl.replace(/\/+$/, '');
  const res = await fetch(`${baseUrl}/accounts/token`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      mobile: cfg.mobile,
      api_key: cfg.apiKey,
    }),
    signal: AbortSignal.timeout(12000),
  });

  const data = await res.json();
  if (!res.ok || !data?.token) {
    throw new Error(data?.description || data?.message || `Không lấy được token AhaMove Staging (${res.status})`);
  }

  cachedToken = data.token;
  cachedTokenKey = keySig;
  return cachedToken;
}

async function callAhamoveApi(pathSuffix, method = 'GET', body = null) {
  assertSandboxSafety();
  const baseUrl = (config.AHAMOVE?.baseUrl || 'https://partner-apistg.ahamove.com/v3').replace(/\/+$/, '');

  let token = await getAhamoveToken(false);
  const doFetch = async (authToken) => {
    const res = await fetch(`${baseUrl}${pathSuffix}`, {
      method,
      headers: {
        'Content-Type': 'application/json',
        Authorization: `Bearer ${authToken}`,
      },
      ...(body !== null ? { body: JSON.stringify(body) } : {}),
      signal: AbortSignal.timeout(15000),
    });
    const text = await res.text();
    let json = {};
    try {
      json = text ? JSON.parse(text) : {};
    } catch (_) {
      json = { raw: text };
    }
    return { status: res.status, ok: res.ok, data: json };
  };

  let resp = await doFetch(token);
  if (resp.status === 401 && !config.AHAMOVE?.token && config.AHAMOVE?.apiKey) {
    token = await getAhamoveToken(true);
    resp = await doFetch(token);
  }
  return resp;
}

function mapAhamoveStatusToDbStatus(ahaStatus = '') {
  const s = String(ahaStatus || '').toUpperCase();
  if (s === 'COMPLETED') return 'DELIVERED';
  if (s === 'IN PROCESS') return 'IN_TRANSIT';
  if (s === 'ACCEPTED') return 'ASSIGNED';
  if (s === 'CANCELLED') return 'CANCELLED';
  if (s === 'FAILED') return 'FAILED';
  return 'PENDING';
}

async function buildOrderPath({ pickupAddress, pickupName, pickupPhone, lab, orderId, itemValue }) {
  const { pickupCoords, labCoords } = await resolvePickupAndLabCoords({ pickupAddress, lab });
  return [
    {
      lat: pickupCoords.lat,
      lng: pickupCoords.lng,
      address: pickupAddress || 'Số 1 Đại Cồ Việt, Hai Bà Trưng, Hà Nội',
      short_address: String(pickupAddress || 'Điểm lấy film').slice(0, 60),
      name: pickupName || 'Khách hàng MiniLab',
      mobile: normalizeVnPhone(pickupPhone, '0901234567'),
      remarks: orderId ? `Lấy cuộn film đơn #${orderId}` : 'Lấy cuộn film gửi Lab tráng scan',
    },
    {
      lat: labCoords.lat,
      lng: labCoords.lng,
      address: `${lab?.address || 'Số 10 ngõ 12 Đặng Thai Mai, Tây Hồ'}, ${lab?.city || 'Hà Nội'}`,
      short_address: lab?.name || 'Film Lab',
      name: lab?.name || 'Film Lab MiniLab',
      mobile: normalizeVnPhone(lab?.phone, '0904567890'),
      cod: 0,
      item_value: Math.round(Number(itemValue) || 100000),
      tracking_number: orderId || '',
      remarks: `Giao cuộn film tới quầy tiếp nhận ${lab?.name || 'Film Lab'}`,
    },
  ];
}

async function estimateAhamoveOrder({ pickupAddress, pickupName, pickupPhone, lab, itemValue, items }) {
  const serviceId = resolveServiceId(`${lab?.city || ''} ${pickupAddress || ''}`);
  const pathPoints = await buildOrderPath({ pickupAddress, pickupName, pickupPhone, lab, itemValue });
  const payload = {
    order_time: 0,
    path: pathPoints,
    services: [{ _id: serviceId, requests: [] }],
    payment_method: 'CASH',
    remarks: 'Ước tính phí lấy cuộn film MiniLab (Sandbox)',
    items: items || [{ _id: 'FILM-ROLL', num: 1, name: 'Cuộn phim chụp ảnh', price: Math.round(Number(itemValue) || 70000) }],
  };

  const resp = await callAhamoveApi('/orders/estimates', 'POST', payload);
  if (!resp.ok) {
    const errMsg = resp.data?.description || resp.data?.message || `AhaMove Staging trả lỗi ${resp.status}`;
    throw new Error(errMsg);
  }

  const list = Array.isArray(resp.data) ? resp.data : (Array.isArray(resp.data?.services) ? resp.data.services : [resp.data]);
  const first = list[0] || {};
  if (first.error) {
    const errMsg = first.error?.description || first.error?.message || JSON.stringify(first.error);
    throw new Error(errMsg);
  }
  const metrics = (first.data && typeof first.data === 'object') ? first.data : first;
  return {
    service_id: first.service_id || first._id || serviceId,
    total_fee: Number(metrics.total_pay ?? metrics.total_price ?? metrics.total_fee ?? metrics.fee ?? metrics.price ?? 0),
    distance: Number(metrics.distance ?? 0),
    duration: Number(metrics.duration ?? 0),
    sandbox: true,
    raw: resp.data,
  };
}

async function createAhamoveOrder({ pickupAddress, pickupName, pickupPhone, lab, orderId, itemValue, remarks, items }) {
  const serviceId = resolveServiceId(`${lab?.city || ''} ${pickupAddress || ''}`);
  const pathPoints = await buildOrderPath({ pickupAddress, pickupName, pickupPhone, lab, orderId, itemValue });
  const payload = {
    order_time: 0,
    path: pathPoints,
    service_id: serviceId,
    requests: [],
    payment_method: 'CASH',
    remarks: remarks || `MiniLab #${orderId}: Lấy film giao tới ${lab?.name || 'Film Lab'} (SANDBOX)`,
    items: items || [{ _id: orderId || 'FILM-ROLL', num: 1, name: `Cuộn film đơn #${orderId}`, price: Math.round(Number(itemValue) || 70000) }],
  };

  const resp = await callAhamoveApi('/orders', 'POST', payload);
  if (!resp.ok) {
    const errMsg = resp.data?.description || resp.data?.message || `AhaMove Staging trả lỗi ${resp.status}`;
    throw new Error(errMsg);
  }

  const orderObj = resp.data?.order || resp.data || {};
  const ahaOrderId = orderObj._id || resp.data?.order_id || '';
  if (!ahaOrderId) {
    throw new Error('AhaMove Staging không trả về mã đơn hàng (_id)');
  }

  return {
    ahamove_order_id: ahaOrderId,
    ahamove_status: orderObj.status || 'IDLE',
    status: mapAhamoveStatusToDbStatus(orderObj.status || 'IDLE'),
    service_id: orderObj.service_id || serviceId,
    total_fee: Number(orderObj.total_pay ?? orderObj.total_price ?? orderObj.total_fee ?? 0),
    distance: Number(orderObj.distance ?? 0),
    shared_link: orderObj.shared_link || resp.data?.shared_link || '',
    driver_name: orderObj.supplier_name || '',
    driver_phone: orderObj.supplier_id || '',
    sandbox: true,
    raw: resp.data,
  };
}

async function getAhamoveOrderDetail(ahamoveOrderId) {
  const resp = await callAhamoveApi(`/orders/${encodeURIComponent(ahamoveOrderId)}`, 'GET');
  if (!resp.ok) {
    const errMsg = resp.data?.description || resp.data?.message || `Không lấy được chi tiết đơn AhaMove (${resp.status})`;
    throw new Error(errMsg);
  }
  const orderObj = resp.data?.order || resp.data || {};
  return {
    ahamove_order_id: orderObj._id || ahamoveOrderId,
    ahamove_status: orderObj.status || 'IDLE',
    status: mapAhamoveStatusToDbStatus(orderObj.status || 'IDLE'),
    total_fee: Number(orderObj.total_pay ?? orderObj.total_price ?? orderObj.total_fee ?? 0),
    shared_link: orderObj.shared_link || '',
    driver_name: orderObj.supplier_name || '',
    driver_phone: orderObj.supplier_id || '',
    sandbox: true,
    raw: orderObj,
  };
}

async function cancelAhamoveOrder(ahamoveOrderId, comment = 'Khách hàng muốn hủy đơn') {
  const resp = await callAhamoveApi(`/orders/${encodeURIComponent(ahamoveOrderId)}`, 'DELETE', {
    comment: String(comment || 'Khách hàng muốn hủy đơn').slice(0, 200),
  });
  if (!resp.ok) {
    const errMsg = resp.data?.description || resp.data?.message || `Không hủy được đơn AhaMove (${resp.status})`;
    throw new Error(errMsg);
  }
  return { cancelled: true, sandbox: true, raw: resp.data };
}

module.exports = {
  assertSandboxSafety,
  isAhamoveConfigured,
  resolveServiceId,
  mapAhamoveStatusToDbStatus,
  estimateAhamoveOrder,
  createAhamoveOrder,
  getAhamoveOrderDetail,
  cancelAhamoveOrder,
};
