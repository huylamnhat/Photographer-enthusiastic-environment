/**
 * In-Memory Data Store quản lý toàn bộ thực thể của Web Lab
 * Hỗ trợ các nghiệp vụ:
 * 1. CRUD gói dịch vụ + PAUSED + Ghi log đổi giá (Audit Trail)
 * 2. Đơn hàng + Price Snapshotting
 * 3. Tiến độ cuộn film (RECEIVED -> DEVELOPING -> SCANNING -> SCANS_UPLOADED), Bin code, Blank Film
 * 4. Scan metadata, Revoke & Replace trong 24h
 */

const {
  ROLES,
  ORDER_STATUS,
  ROLL_PROCESS_STAGES,
  SERVICE_STATUS,
  PROCESS_TYPES,
  FILM_FORMATS
} = require('../config/constants');

class LabDataStore {
  constructor() {
    this.initProfile();
    this.initServices();
    this.initPriceAuditLogs();
    this.initOrders();
  }

  initProfile() {
    this.profile = {
      id: 'LAB-01',
      name: 'LLab - Analog Film & Craft Lab',
      tagline: 'Chuyên tráng scan phim màu, đen trắng, điện ảnh ECN-2 và slide E-6',
      hotline: '0909 123 456',
      email: 'support@llab.vn',
      workingHours: '08:00 - 21:00 hàng ngày',
      addresses: [
        'Cơ sở 1: 385/2a Phan Xích Long, P.2, Q.Phú Nhuận, TP.HCM',
        'Cơ sở 2: 12B Ngõ 91 Nguyễn Chí Thanh, Q.Đống Đa, Hà Nội'
      ],
      slaPolicies: {
        c41StandardHours: 48,
        bwStandardHours: 72,
        ecn2StandardHours: 72,
        slideE6Days: 15
      },
      retentionPolicies: {
        scanFileRetentionDays: 60,   // File scan lưu trên Cloud 60 ngày
        negativeRetentionDays: 15     // Âm bản giữ tại tiệm 15 ngày
      },
      updatedAt: new Date().toISOString()
    };
  }

  initServices() {
    this.services = [
      {
        id: 'SRV-01',
        name: 'Tráng + Scan Standard - Film màu 135 (C-41)',
        format: FILM_FORMATS.F135,
        process: PROCESS_TYPES.C41,
        basePrice: 80000,
        surcharges: {
          pushPullPerStop: 25000,
          hiResScan: 25000,
          tiffFormat: 25000,
          rushExpress: 20000
        },
        outputFormats: ['JPG Standard', 'JPG Hi-Res', 'TIFF 16-bit'],
        sla: 'Tối đa 48 - 72 giờ',
        status: SERVICE_STATUS.ACTIVE,
        description: 'Tráng máy C-41 tiêu chuẩn Fuji/Noritsu, scan Standard JPG sắc nét.',
        createdAt: '2026-10-01T08:00:00Z',
        updatedAt: '2026-10-01T08:00:00Z'
      },
      {
        id: 'SRV-02',
        name: 'Tráng + Scan Standard - Film màu 120 (C-41)',
        format: FILM_FORMATS.F120,
        process: PROCESS_TYPES.C41,
        basePrice: 85000,
        surcharges: {
          pushPullPerStop: 25000,
          hiResScan: 30000,
          tiffFormat: 30000,
          rushExpress: 25000
        },
        outputFormats: ['JPG Standard', 'JPG Hi-Res', 'TIFF 16-bit'],
        sla: 'Tối đa 48 - 72 giờ',
        status: SERVICE_STATUS.ACTIVE,
        description: 'Dành cho Medium Format 6x4.5, 6x6, 6x7, 6x9.',
        createdAt: '2026-10-01T08:00:00Z',
        updatedAt: '2026-10-01T08:00:00Z'
      },
      {
        id: 'SRV-03',
        name: 'Tráng + Scan Film Đen Trắng (B&W Craft)',
        format: FILM_FORMATS.F135,
        process: PROCESS_TYPES.BW,
        basePrice: 90000,
        surcharges: {
          pushPullPerStop: 30000,
          hiResScan: 25000,
          tiffFormat: 30000,
          rushExpress: 30000
        },
        outputFormats: ['JPG Standard', 'JPG Hi-Res', 'TIFF 16-bit'],
        sla: 'Tối đa 72 giờ',
        status: SERVICE_STATUS.ACTIVE,
        description: 'Tráng tay thủ công bằng hóa chất Kodak D-76 / Ilford ID-11 chuẩn tương phản.',
        createdAt: '2026-10-01T08:00:00Z',
        updatedAt: '2026-10-01T08:00:00Z'
      },
      {
        id: 'SRV-04',
        name: 'Tráng + Scan Film Điện Ảnh Cine (ECN-2)',
        format: FILM_FORMATS.F135,
        process: PROCESS_TYPES.ECN2,
        basePrice: 110000,
        surcharges: {
          pushPullPerStop: 35000,
          hiResScan: 30000,
          tiffFormat: 35000,
          rushExpress: 40000
        },
        outputFormats: ['JPG Standard', 'JPG Hi-Res', 'TIFF 16-bit'],
        sla: 'Tối đa 72 giờ',
        status: SERVICE_STATUS.ACTIVE,
        description: 'Tẩy lớp muội than Carbon chuyên dụng cho dòng Kodak Vision3 50D, 250D, 500T.',
        createdAt: '2026-10-01T08:00:00Z',
        updatedAt: '2026-10-01T08:00:00Z'
      },
      {
        id: 'SRV-05',
        name: 'Tráng + Scan Film Slide Đảo Dương Bản (E-6)',
        format: FILM_FORMATS.F135,
        process: PROCESS_TYPES.E6,
        basePrice: 260000,
        surcharges: {
          pushPullPerStop: 40000,
          hiResScan: 35000,
          tiffFormat: 40000,
          rushExpress: 0
        },
        outputFormats: ['JPG High-Res', 'TIFF 16-bit'],
        sla: 'Tối đa 15 ngày (gom mẻ tráng)',
        status: SERVICE_STATUS.PAUSED, // Ví dụ tạm dừng vì cần gom đủ số cuộn mẻ tráng E-6
        description: 'Tráng hóa chất chuẩn E-6 cho phim dương bản Provia 100F, Velvia 50.',
        createdAt: '2026-10-01T08:00:00Z',
        updatedAt: '2026-10-25T14:30:00Z'
      }
    ];
  }

  initPriceAuditLogs() {
    this.priceAuditLogs = [
      {
        id: 'LOG-001',
        serviceId: 'SRV-04',
        serviceName: 'Tráng + Scan Film Điện Ảnh Cine (ECN-2)',
        oldPrice: 100000,
        newPrice: 110000,
        updatedBy: 'Nguyễn Văn Chủ (Lab Owner)',
        role: ROLES.OWNER,
        reason: 'Giá hóa chất tẩy muội than Remjet nhập khẩu tăng 10%',
        updatedAt: '2026-10-20T10:15:00Z'
      },
      {
        id: 'LOG-002',
        serviceId: 'SRV-05',
        serviceName: 'Tráng + Scan Film Slide Đảo Dương Bản (E-6)',
        oldPrice: 240000,
        newPrice: 260000,
        updatedBy: 'Nguyễn Văn Chủ (Lab Owner)',
        role: ROLES.OWNER,
        reason: 'Điều chỉnh chi phí vận hành gom mẻ tráng hóa chất 6 bước E-6',
        updatedAt: '2026-10-22T09:00:00Z'
      }
    ];
  }

  initOrders() {
    this.orders = [
      {
        id: 'ORD-20261031-01',
        orderCode: 'ORD24103101',
        customer: {
          name: 'Trần Minh Quân',
          phone: '0912345678',
          email: 'minhquan.analog@gmail.com',
          returnMethod: 'PICKUP_AT_LAB' // Nhận lại âm bản tại tiệm
        },
        status: ORDER_STATUS.PROCESSING,
        paymentStatus: 'PAID',
        createdAt: '2026-10-31T08:30:00Z',
        receivedAt: '2026-10-31T09:15:00Z',
        operatorConfirmedBy: 'Lê Hoàng (Operator)',
        subtotal: 185000,
        totalAmount: 185000,
        rolls: [
          {
            rollId: 'R01',
            filmName: 'Kodak Portra 400',
            filmFormat: FILM_FORMATS.F135,
            processType: PROCESS_TYPES.C41,
            stage: ROLL_PROCESS_STAGES.DEVELOPING, // Đang tráng
            // Price Snapshotting tại thời điểm đặt đơn
            priceSnapshot: {
              serviceId: 'SRV-01',
              serviceName: 'Tráng + Scan Standard - Film màu 135 (C-41)',
              unitPriceAtOrder: 80000,
              pushPullOption: '+1 Stop',
              pushPullSurcharge: 25000,
              scanOption: 'JPG Hi-Res',
              scanOptionSurcharge: 25000,
              itemTotal: 130000
            },
            notes: 'Khách yêu cầu push 1 stop vì chụp chiều tối',
            binCode: 'BIN-A01',
            binExpiryDate: '2026-11-15T18:00:00Z',
            isBlankFilm: false,
            blankFilmProofUrl: null,
            blankFilmReason: null,
            scanMetadata: null
          },
          {
            rollId: 'R02',
            filmName: 'Fujifilm C200',
            filmFormat: FILM_FORMATS.F135,
            processType: PROCESS_TYPES.C41,
            stage: ROLL_PROCESS_STAGES.RECEIVED, // Đã nhận tại tiệm
            priceSnapshot: {
              serviceId: 'SRV-01',
              serviceName: 'Tráng + Scan Standard - Film màu 135 (C-41)',
              unitPriceAtOrder: 80000,
              pushPullOption: 'Normal',
              pushPullSurcharge: 0,
              scanOption: 'JPG Standard',
              scanOptionSurcharge: 0,
              itemTotal: 80000
            },
            notes: 'Cuộn nguyên seal, chụp máy PnS',
            binCode: 'BIN-A02',
            binExpiryDate: '2026-11-15T18:00:00Z',
            isBlankFilm: false,
            blankFilmProofUrl: null,
            blankFilmReason: null,
            scanMetadata: null
          }
        ],
        timeline: [
          { time: '2026-10-31T08:30:00Z', event: 'Khách tạo đơn trực tuyến' },
          { time: '2026-10-31T09:00:00Z', event: 'Thanh toán thành công' },
          { time: '2026-10-31T09:15:00Z', event: 'Lab nhận phim thực tế, gán khay BIN-A01 & BIN-A02' },
          { time: '2026-10-31T10:00:00Z', event: 'Bắt đầu tráng cuộn R01 (C-41 Push +1)' }
        ]
      },
      {
        id: 'ORD-20261031-02',
        orderCode: 'ORD24103102',
        customer: {
          name: 'Nguyễn Thị Hương',
          phone: '0988776655',
          email: 'huong.photo@gmail.com',
          returnMethod: 'POSTAL_DELIVERY' // Giao âm bản qua bưu điện
        },
        status: ORDER_STATUS.PROCESSING,
        paymentStatus: 'PAID',
        createdAt: '2026-10-30T14:20:00Z',
        receivedAt: '2026-10-31T08:45:00Z',
        operatorConfirmedBy: 'Lê Hoàng (Operator)',
        subtotal: 110000,
        totalAmount: 110000,
        rolls: [
          {
            rollId: 'R01',
            filmName: 'Kodak Vision3 500T',
            filmFormat: FILM_FORMATS.F135,
            processType: PROCESS_TYPES.ECN2,
            stage: ROLL_PROCESS_STAGES.SCANNING, // Đang scan sau khi tráng & tẩy muội than
            priceSnapshot: {
              serviceId: 'SRV-04',
              serviceName: 'Tráng + Scan Film Điện Ảnh Cine (ECN-2)',
              unitPriceAtOrder: 110000,
              pushPullOption: 'Normal',
              pushPullSurcharge: 0,
              scanOption: 'JPG Standard',
              scanOptionSurcharge: 0,
              itemTotal: 110000
            },
            notes: 'Film cine chiết bánh lớn, dặn kỹ tẩy sạch muội than',
            binCode: 'BIN-C05',
            binExpiryDate: '2026-11-15T18:00:00Z',
            isBlankFilm: false,
            blankFilmProofUrl: null,
            blankFilmReason: null,
            scanMetadata: null
          }
        ],
        timeline: [
          { time: '2026-10-30T14:20:00Z', event: 'Khách tạo đơn gửi bưu điện' },
          { time: '2026-10-31T08:45:00Z', event: 'Bưu tá giao film đến Lab, quét mã tiếp nhận' },
          { time: '2026-10-31T09:30:00Z', event: 'Hoàn tất tráng ECN-2 tẩy muội than & sấy khô' },
          { time: '2026-10-31T10:45:00Z', event: 'Đang tiến hành scan máy Noritsu HS-1800' }
        ]
      },
      {
        id: 'ORD-20261030-03',
        orderCode: 'ORD24103003',
        customer: {
          name: 'Phạm Đăng Khoa',
          phone: '0903112233',
          email: 'dangkhoa.film@yahoo.com',
          returnMethod: 'PICKUP_AT_LAB'
        },
        status: ORDER_STATUS.SCANS_UPLOADED,
        paymentStatus: 'PAID',
        createdAt: '2026-10-30T10:00:00Z',
        receivedAt: '2026-10-30T11:00:00Z',
        operatorConfirmedBy: 'Nguyễn Văn Chủ (Owner)',
        subtotal: 90000,
        totalAmount: 90000,
        rolls: [
          {
            rollId: 'R01',
            filmName: 'Ilford HP5 Plus 400',
            filmFormat: FILM_FORMATS.F135,
            processType: PROCESS_TYPES.BW,
            stage: ROLL_PROCESS_STAGES.SCANS_UPLOADED,
            priceSnapshot: {
              serviceId: 'SRV-03',
              serviceName: 'Tráng + Scan Film Đen Trắng (B&W Craft)',
              unitPriceAtOrder: 90000,
              pushPullOption: 'Normal',
              pushPullSurcharge: 0,
              scanOption: 'JPG Standard',
              scanOptionSurcharge: 0,
              itemTotal: 90000
            },
            notes: 'Tráng D-76 1:1',
            binCode: 'BIN-B03',
            binExpiryDate: '2026-11-14T18:00:00Z',
            isBlankFilm: false,
            blankFilmProofUrl: null,
            blankFilmReason: null,
            scanMetadata: {
              fileName: 'ORD24103003_R01_0903112233_IlfordHP5Plus400.zip',
              fileSizeMb: 142.5,
              totalFrames: 36,
              format: 'JPG Standard',
              scannerModel: 'Noritsu HS-1800',
              resolution: '3000x2000 (Standard)',
              cloudPath: 's3://llab-scans/2026/10/ORD24103003_R01.zip',
              uploadedAt: '2026-10-30T17:30:00Z',
              uploadedBy: 'Lê Hoàng (Operator)',
              isRevoked: false,
              revokedAt: null,
              revokeReason: null
            }
          }
        ],
        timeline: [
          { time: '2026-10-30T10:00:00Z', event: 'Khách mang film đến gửi tại quầy' },
          { time: '2026-10-30T11:00:00Z', event: 'Nhận film và thanh toán tiền mặt' },
          { time: '2026-10-30T14:30:00Z', event: 'Tráng thủ công B&W D-76 hoàn tất' },
          { time: '2026-10-30T16:45:00Z', event: 'Scan và QC đạt chuẩn' },
          { time: '2026-10-30T17:30:00Z', event: 'Upload file scan thành công, gửi thông báo cho khách' }
        ]
      },
      {
        id: 'ORD-20261029-04',
        orderCode: 'ORD24102904',
        customer: {
          name: 'Vũ Quốc Bảo',
          phone: '0977223344',
          email: 'quocbao@outlook.com',
          returnMethod: 'NO_RETURN' // Khách không nhận lại âm bản
        },
        status: ORDER_STATUS.PROCESSING,
        paymentStatus: 'PAID',
        createdAt: '2026-10-29T16:00:00Z',
        receivedAt: '2026-10-30T09:00:00Z',
        operatorConfirmedBy: 'Lê Hoàng (Operator)',
        subtotal: 80000,
        totalAmount: 80000,
        rolls: [
          {
            rollId: 'R01',
            filmName: 'Kodak ColorPlus 200',
            filmFormat: FILM_FORMATS.F135,
            processType: PROCESS_TYPES.C41,
            stage: ROLL_PROCESS_STAGES.BLANK_FILM, // Phim trắng
            priceSnapshot: {
              serviceId: 'SRV-01',
              serviceName: 'Tráng + Scan Standard - Film màu 135 (C-41)',
              unitPriceAtOrder: 80000,
              pushPullOption: 'Normal',
              pushPullSurcharge: 0,
              scanOption: 'JPG Standard',
              scanOptionSurcharge: 0,
              itemTotal: 80000
            },
            notes: 'Máy mượn người quen chụp thử lần đầu',
            binCode: 'BIN-BLANK-01',
            binExpiryDate: '2026-11-14T18:00:00Z',
            isBlankFilm: true,
            blankFilmProofUrl: 'assets/proofs/blank_film_ORD24102904.jpg',
            blankFilmReason: 'Lắp phim không cuốn hoặc màn trập kẹt không mở sáng, mép phim vẫn hiện số frame chuẩn.',
            refundRecommendation: 'Hoàn 45.000đ (phần phí scan), giữ 35.000đ (phí tráng hóa chất)',
            scanMetadata: null
          }
        ],
        timeline: [
          { time: '2026-10-29T16:00:00Z', event: 'Khách tạo đơn trực tuyến' },
          { time: '2026-10-30T09:00:00Z', event: 'Lab nhận film thực tế' },
          { time: '2026-10-30T11:20:00Z', event: 'Tráng xong phát hiện phim trong suốt (Blank Film)' },
          { time: '2026-10-30T11:30:00Z', event: 'Đã chụp ảnh bằng chứng và gửi thông báo hoàn phí scan cho khách' }
        ]
      }
    ];
  }

  // --- Profile methods ---
  getProfile() {
    return this.profile;
  }

  updateProfile(data) {
    this.profile = {
      ...this.profile,
      ...data,
      updatedAt: new Date().toISOString()
    };
    return this.profile;
  }

  // --- Services methods ---
  getServices(filters = {}) {
    let result = [...this.services];
    if (filters.status) {
      result = result.filter(s => s.status === filters.status);
    }
    if (filters.process) {
      result = result.filter(s => s.process === filters.process);
    }
    return result;
  }

  getServiceById(id) {
    return this.services.find(s => s.id === id);
  }

  createService(serviceData) {
    const id = `SRV-0${this.services.length + 1}`;
    const now = new Date().toISOString();
    const newService = {
      id,
      name: serviceData.name,
      format: serviceData.format || FILM_FORMATS.F135,
      process: serviceData.process || PROCESS_TYPES.C41,
      basePrice: Number(serviceData.basePrice) || 80000,
      surcharges: {
        pushPullPerStop: Number(serviceData.surcharges?.pushPullPerStop) || 25000,
        hiResScan: Number(serviceData.surcharges?.hiResScan) || 25000,
        tiffFormat: Number(serviceData.surcharges?.tiffFormat) || 25000,
        rushExpress: Number(serviceData.surcharges?.rushExpress) || 20000
      },
      outputFormats: serviceData.outputFormats || ['JPG Standard', 'JPG Hi-Res'],
      sla: serviceData.sla || 'Tối đa 48 - 72 giờ',
      status: SERVICE_STATUS.ACTIVE,
      description: serviceData.description || '',
      createdAt: now,
      updatedAt: now
    };
    this.services.push(newService);
    return newService;
  }

  updateService(id, updateData, user = { name: 'Lab Owner', role: ROLES.OWNER }, reason = '') {
    const index = this.services.findIndex(s => s.id === id);
    if (index === -1) return null;

    const currentService = this.services[index];
    const oldPrice = currentService.basePrice;
    const newPrice = updateData.basePrice !== undefined ? Number(updateData.basePrice) : oldPrice;

    // Ghi audit log nếu có thay đổi giá
    if (oldPrice !== newPrice) {
      this.priceAuditLogs.unshift({
        id: `LOG-00${this.priceAuditLogs.length + 1}`,
        serviceId: id,
        serviceName: currentService.name,
        oldPrice,
        newPrice,
        updatedBy: user.name || 'Lab Owner',
        role: user.role || ROLES.OWNER,
        reason: reason || 'Cập nhật biểu phí dịch vụ',
        updatedAt: new Date().toISOString()
      });
    }

    const updated = {
      ...currentService,
      ...updateData,
      basePrice: newPrice,
      updatedAt: new Date().toISOString()
    };
    this.services[index] = updated;
    return updated;
  }

  togglePauseService(id) {
    const service = this.services.find(s => s.id === id);
    if (!service) return null;
    service.status = service.status === SERVICE_STATUS.ACTIVE ? SERVICE_STATUS.PAUSED : SERVICE_STATUS.ACTIVE;
    service.updatedAt = new Date().toISOString();
    return service;
  }

  getPriceAuditLogs(serviceId = null) {
    if (serviceId) {
      return this.priceAuditLogs.filter(log => log.serviceId === serviceId);
    }
    return this.priceAuditLogs;
  }

  // --- Orders methods ---
  getOrders(filters = {}) {
    let result = [...this.orders];
    if (filters.status) {
      result = result.filter(o => o.status === filters.status);
    }
    if (filters.search) {
      const q = filters.search.toLowerCase();
      result = result.filter(o =>
        o.orderCode.toLowerCase().includes(q) ||
        o.customer.name.toLowerCase().includes(q) ||
        o.customer.phone.includes(q) ||
        o.rolls.some(r => r.filmName.toLowerCase().includes(q))
      );
    }
    return result;
  }

  getOrderById(id) {
    return this.orders.find(o => o.id === id || o.orderCode === id);
  }

  updateOrderStatus(orderId, newStatus, operatorName = 'Lab Operator') {
    const order = this.getOrderById(orderId);
    if (!order) return null;

    order.status = newStatus;
    order.timeline.push({
      time: new Date().toISOString(),
      event: `Chuyển trạng thái đơn sang ${newStatus} bởi ${operatorName}`
    });
    return order;
  }

  // --- Roll processing lifecycle methods ---
  updateRollStage(orderId, rollId, stage, operatorName = 'Lab Operator') {
    const order = this.getOrderById(orderId);
    if (!order) return null;

    const roll = order.rolls.find(r => r.rollId === rollId);
    if (!roll) return null;

    roll.stage = stage;
    order.timeline.push({
      time: new Date().toISOString(),
      event: `Cuộn [${roll.rollId} - ${roll.filmName}] chuyển sang công đoạn: ${stage} (bởi ${operatorName})`
    });

    // Tự động kiểm tra nếu tất cả cuộn trong đơn đã hoàn thành SCANS_UPLOADED
    const allScansUploaded = order.rolls.every(r =>
      r.stage === ROLL_PROCESS_STAGES.SCANS_UPLOADED || r.stage === ROLL_PROCESS_STAGES.BLANK_FILM
    );
    if (allScansUploaded && order.status === ORDER_STATUS.PROCESSING) {
      order.status = ORDER_STATUS.SCANS_UPLOADED;
      order.timeline.push({
        time: new Date().toISOString(),
        event: 'Toàn bộ cuộn phim trong đơn đã hoàn thành upload scan. Sẵn sàng trả file cho khách.'
      });
    }

    return { order, roll };
  }

  assignRollBinCode(orderId, rollId, binCode, expiryDays = 15) {
    const order = this.getOrderById(orderId);
    if (!order) return null;

    const roll = order.rolls.find(r => r.rollId === rollId);
    if (!roll) return null;

    const expiryDate = new Date();
    expiryDate.setDate(expiryDate.getDate() + Number(expiryDays));

    roll.binCode = binCode;
    roll.binExpiryDate = expiryDate.toISOString();

    order.timeline.push({
      time: new Date().toISOString(),
      event: `Gán cuộn [${roll.rollId}] vào khay âm bản vật lý [${binCode}], hạn giữ: ${expiryDays} ngày`
    });

    return { order, roll };
  }

  markBlankFilm(orderId, rollId, proofUrl, reason) {
    const order = this.getOrderById(orderId);
    if (!order) return null;

    const roll = order.rolls.find(r => r.rollId === rollId);
    if (!roll) return null;

    roll.stage = ROLL_PROCESS_STAGES.BLANK_FILM;
    roll.isBlankFilm = true;
    roll.blankFilmProofUrl = proofUrl || 'assets/proofs/blank_film_default.jpg';
    roll.blankFilmReason = reason || 'Phim trắng toàn bộ (Blank Film). Không có khung hình nhận diện.';
    roll.refundRecommendation = 'Đề xuất hoàn lại 100% chi phí scan & in ảnh, Lab giữ lại phụ phí hóa chất tráng';

    order.timeline.push({
      time: new Date().toISOString(),
      event: `Đánh dấu cuộn [${roll.rollId}] là PHIM TRẮNG (Blank Film). Đã tải ảnh bằng chứng và chuyển tiếp đề xuất hoàn tiền.`
    });

    return { order, roll };
  }

  saveScanMetadata(orderId, rollId, metadata, operatorName = 'Lab Operator') {
    const order = this.getOrderById(orderId);
    if (!order) return null;

    const roll = order.rolls.find(r => r.rollId === rollId);
    if (!roll) return null;

    roll.scanMetadata = {
      fileName: metadata.fileName || `${order.orderCode}_${roll.rollId}_${order.customer.phone}_${roll.filmName.replace(/\s+/g, '')}.zip`,
      fileSizeMb: Number(metadata.fileSizeMb) || 120.5,
      totalFrames: Number(metadata.totalFrames) || 36,
      format: metadata.format || 'JPG Standard',
      scannerModel: metadata.scannerModel || 'Noritsu HS-1800',
      resolution: metadata.resolution || '3000x2000 (Standard)',
      cloudPath: metadata.cloudPath || `s3://llab-scans/${new Date().getFullYear()}/${order.orderCode}_${roll.rollId}.zip`,
      uploadedAt: new Date().toISOString(),
      uploadedBy: operatorName,
      isRevoked: false,
      revokedAt: null,
      revokeReason: null
    };

    // Tự động chuyển công đoạn cuộn sang SCANS_UPLOADED
    roll.stage = ROLL_PROCESS_STAGES.SCANS_UPLOADED;

    order.timeline.push({
      time: new Date().toISOString(),
      event: `Đã nạp file scan [${roll.scanMetadata.fileName}] (${roll.scanMetadata.totalFrames} frames) cho cuộn [${roll.rollId}]`
    });

    // Kiểm tra đơn
    const allDone = order.rolls.every(r =>
      r.stage === ROLL_PROCESS_STAGES.SCANS_UPLOADED || r.stage === ROLL_PROCESS_STAGES.BLANK_FILM
    );
    if (allDone) {
      order.status = ORDER_STATUS.SCANS_UPLOADED;
    }

    return { order, roll };
  }

  revokeAndReplaceScan(orderId, rollId, reason, operatorName = 'Lab Operator') {
    const order = this.getOrderById(orderId);
    if (!order) return null;

    const roll = order.rolls.find(r => r.rollId === rollId);
    if (!roll || !roll.scanMetadata) return null;

    roll.scanMetadata.isRevoked = true;
    roll.scanMetadata.revokedAt = new Date().toISOString();
    roll.scanMetadata.revokeReason = reason || 'Thu hồi do phát hiện nhầm lẫn/lệch frame cần scan lại';
    roll.stage = ROLL_PROCESS_STAGES.SCANNING; // Đưa về trạng thái đang scan lại

    if (order.status === ORDER_STATUS.SCANS_UPLOADED) {
      order.status = ORDER_STATUS.PROCESSING;
    }

    order.timeline.push({
      time: new Date().toISOString(),
      event: `THU HỒI file scan cũ của cuộn [${roll.rollId}] bởi ${operatorName}. Lý do: ${roll.scanMetadata.revokeReason}`
    });

    return { order, roll };
  }
}

// Khởi tạo Singleton store
const dbStore = new LabDataStore();

module.exports = dbStore;
