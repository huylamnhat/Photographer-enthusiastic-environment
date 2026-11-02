/**
 * MiniLab In-Memory Database & Seed Data
 * Aligned with SQL Server Schema (Week 2) and Web Lab Functional Specs
 */

const mockDb = {
  // Current Lab Profile (Saigon Darkroom)
  labProfile: {
    lab_id: 'LAB-SGN-01',
    brand_name: 'Saigon Darkroom & Film Lab',
    license_no: '0319842109',
    region: 'HCM',
    address: '145/3 Bis Đường Nguyễn Đình Chiểu, Phường Võ Thị Sáu, Quận 3, TP.HCM',
    hotline: '0918 245 890',
    email: 'labmaster@saigondarkroom.vn',
    has_dropbox: true,
    representative_name: 'NGUYỄN VĂN AN KHANG',
    cccd_number: '079092004581',
    scanners: ['Noritsu HS-1800', 'Fuji Frontier SP-3000'],
    processor: 'Noritsu V30',
    chemistries: ['C-41', 'B&W', 'ECN-2'],
    bio: 'Phòng lab tráng & scan phim analog chuyên nghiệp tại trung tâm Sài Gòn. Máy scan Noritsu HS-1800 & Fuji Frontier SP-3000 chuẩn màu. Bể hóa chất C-41 điều nhiệt tự động 37.8°C.',
    operating_hours: 'Thứ 2 - Chủ Nhật: 08:30 - 20:30',
    turnaround_pledge: 'Cam kết trả file scan trong vòng 24h - 48h đối với C-41 & B&W.',
    logo_url: '/uploads/branding/logo.png',
    cover_url: '/uploads/branding/cover.jpg',
    dropbox_info: 'Thùng nhận phim dropbox thông minh trước cửa tiệm 24/7 có mã QR check-in.',
    branches: [
      { id: 'sgn-01', name: 'Chi nhánh 01 - Quận 3, TP.HCM (Lab Trung Tâm)', is_active: true },
      { id: 'sgn-02', name: 'Chi nhánh 02 - Thảo Điền, TP.Thủ Đức (Lab Scan Tốc Độ)', is_active: true },
      { id: 'han-01', name: 'Chi nhánh 03 - Hoàn Kiếm, Hà Nội (Trạm Nhận)', is_active: true }
    ]
  },

  // Lab Operators / Users
  users: [
    {
      user_id: 'USR-OP-01',
      email: 'lab@saigonfilm.vn',
      password: 'password123', // In demo accepted alongside any valid check
      full_name: 'Lê Hoài Nam',
      role: 'OPERATOR',
      title: 'KỸ THUẬT VIÊN TRƯỞNG',
      branch_id: 'sgn-01',
      shift: 'Ca sáng (08:00 - 16:00)'
    },
    {
      user_id: 'USR-OWNER-01',
      email: 'owner@saigonfilm.vn',
      password: 'password123',
      full_name: 'Nguyễn Văn An Khang',
      role: 'OWNER',
      title: 'CHỦ PHÒNG LAB',
      branch_id: 'sgn-01'
    }
  ],

  // Real-time Station Telemetry
  telemetry: {
    shift: 'CA TRỰC SÁNG: 28 ĐƠN ĐANG XỬ LÝ',
    c41_temp: '37.8°C',
    c41_status: 'CHUẨN ±0.1°',
    ecn2_rolls_run: 14,
    ecn2_capacity: 25,
    scanner_active: 'Noritsu HS-1800 & Fuji SP-3000 #1',
    sla_at_risk_count: 2,
    qc_pass_rate: 94.8,
    today_total_rolls: 54
  },

  // Orders on Kanban Board
  orders: [
    {
      order_id: 'ORD-2024-88412',
      customer_name: 'Lê Hoàng Nam',
      customer_phone: '0903 112 334',
      stage: 'READY_QC', // Column: QC & Sẵn sàng trả file
      roll_count: 2,
      film_type: 'Kodak Portra 400 (135/36)',
      process_type: 'C-41',
      scanner: 'Noritsu HS-1800',
      resolution: 'TIFF 16-bit',
      push_pull: 'Box Speed (Standard)',
      sla_deadline: '2026-11-02T16:00:00Z',
      sla_hours_left: 3.5,
      is_urgent: false,
      note: 'Ưu tiên tone ấm da tự nhiên',
      created_at: '2026-11-01T09:30:00Z'
    },
    {
      order_id: 'ORD-2024-88415',
      customer_name: 'Trần Minh Đức',
      customer_phone: '0912 889 001',
      stage: 'PROCESSING_DEV', // Column: Đang tráng
      roll_count: 3,
      film_type: 'Fujicolor C200 & Ilford HP5',
      process_type: 'C-41 + B&W',
      scanner: 'Fuji Frontier SP-3000',
      resolution: 'JPEG Hi-Res',
      push_pull: '+1 Stop (HP5)',
      sla_deadline: '2026-11-02T18:00:00Z',
      sla_hours_left: 5.5,
      is_urgent: false,
      note: 'D-76 1:1 stock',
      created_at: '2026-11-01T11:00:00Z'
    },
    {
      order_id: 'ORD-2024-88419',
      customer_name: 'Phạm Quỳnh Anh',
      customer_phone: '0977 445 667',
      stage: 'PROCESSING_SCAN', // Column: Đang scan
      roll_count: 1,
      film_type: 'Kodak Vision3 250D',
      process_type: 'ECN-2',
      scanner: 'Noritsu HS-1800',
      resolution: 'TIFF Flat Profile',
      push_pull: 'Standard',
      sla_deadline: '2026-11-02T14:30:00Z',
      sla_hours_left: 2.0,
      is_urgent: true,
      note: 'Remjet sạch kỹ, scan flat màu để làm màu hậu kỳ',
      created_at: '2026-11-01T08:00:00Z'
    },
    {
      order_id: 'ORD-2024-88422',
      customer_name: 'Vũ Quốc Huy',
      customer_phone: '0988 234 567',
      stage: 'WAITING_DEV', // Column: Chờ tráng
      roll_count: 4,
      film_type: 'Kodak ColorPlus 200',
      process_type: 'C-41',
      scanner: 'Fuji Frontier SP-3000',
      resolution: 'JPEG Hi-Res',
      push_pull: 'Standard',
      sla_deadline: '2026-11-03T10:00:00Z',
      sla_hours_left: 21.0,
      is_urgent: false,
      note: 'Giao âm bản sau khi cắt sleeve 6 frame',
      created_at: '2026-11-01T15:20:00Z'
    },
    {
      order_id: 'ORD-2024-88426',
      customer_name: 'Ngô Thanh Thảo',
      customer_phone: '0934 998 776',
      stage: 'RECEIVED', // Column: Tiếp nhận & Phân loại
      roll_count: 1,
      film_type: 'Fujichrome Provia 100F (120)',
      process_type: 'E-6',
      scanner: 'Noritsu HS-1800',
      resolution: 'TIFF 16-bit Pro',
      push_pull: 'Standard',
      sla_deadline: '2026-11-05T12:00:00Z',
      sla_hours_left: 72.0,
      is_urgent: false,
      note: 'Film slide dương bản 120, khách yêu cầu giữ nguyên cuộn không cắt',
      created_at: '2026-11-02T06:30:00Z'
    }
  ],

  // QC & Scan Batch for Active Order (e.g., ORD-2024-88412)
  qcBatches: {
    'ORD-2024-88412': {
      order_id: 'ORD-2024-88412',
      total_files: 72,
      uploaded_files: 72,
      passed_frames: 69,
      flagged_frames: 3,
      upload_status: 'COMPLETED',
      speed: '48.2 MB/s',
      scanner: 'Noritsu HS-1800',
      format: 'TIFF 16-bit (3.4 GB)',
      md5_checksum: '0x9F4BD21A472A8812',
      frames: Array.from({ length: 72 }, (_, i) => {
        const frameNo = i + 1;
        const isFlagged = frameNo === 14 || frameNo === 38 || frameNo === 62;
        return {
          frame_id: `FRAME-${frameNo.toString().padStart(2, '0')}`,
          frame_number: frameNo,
          filename: `R1_${frameNo.toString().padStart(2, '0')}.tif`,
          thumb_url: `https://picsum.photos/seed/roll_${frameNo}/300/200`,
          qc_status: isFlagged ? 'FLAGGED' : 'PASSED',
          defect_type: isFlagged
            ? (frameNo === 14 ? 'Vết bụi quang học (Dust spot)' : frameNo === 38 ? 'Vết xước nhũ tương cơ học' : 'Lệch cân bằng trắng (Color shift)')
            : null,
          resolution: '4492 x 6774 px',
          color_space: 'sRGB / 16-bit ProPhoto',
          operator_note: isFlagged ? 'Cần rescan hoặc chấm bụi trước khi trả file' : 'Đạt chuẩn nét viền và độ hạt'
        };
      })
    }
  },

  // Service Catalog & Pricing Packages
  services: [
    {
      service_id: 'SVC-C41-135-STD',
      name: 'Tráng + Scan Standard - Film Màu 135',
      film_format: '135 (35mm)',
      process_type: 'C-41',
      scanner: 'Noritsu HS-1800 / Fuji SP-3000',
      base_price: 80000,
      push_pull_fee: 25000,
      high_res_fee: 25000,
      sla_hours: 48,
      status: 'ACTIVE',
      output_format: 'JPEG (2048x3072)',
      description: 'Quy trình tráng C-41 điều nhiệt tự động, scan màu tự nhiên chuẩn tone Noritsu hoặc Fuji Frontier.',
      created_at: '2025-01-10T00:00:00Z'
    },
    {
      service_id: 'SVC-C41-120-STD',
      name: 'Tráng + Scan Standard - Film Màu 120 (Trung khổ)',
      film_format: '120 (Medium Format)',
      process_type: 'C-41',
      scanner: 'Noritsu HS-1800',
      base_price: 90000,
      push_pull_fee: 30000,
      high_res_fee: 30000,
      sla_hours: 48,
      status: 'ACTIVE',
      output_format: 'JPEG / TIFF (3000x3000+)',
      description: 'Xử lý film khổ 6x4.5, 6x6, 6x7, 6x9 với holder phẳng chống cong vênh.',
      created_at: '2025-01-10T00:00:00Z'
    },
    {
      service_id: 'SVC-BW-135-ART',
      name: 'Tráng Thủ công + Scan Hi-Res - Film B&W 135',
      film_format: '135 (35mm)',
      process_type: 'B&W',
      scanner: 'Noritsu HS-1800',
      base_price: 100000,
      push_pull_fee: 30000,
      high_res_fee: 0,
      sla_hours: 72,
      status: 'ACTIVE',
      output_format: 'TIFF 16-bit Grayscale',
      description: 'Tráng thủ công từng cuộn bằng Kodak D-76 hoặc Rodinal tùy biến theo ISO nhũ tương.',
      created_at: '2025-01-12T00:00:00Z'
    },
    {
      service_id: 'SVC-ECN2-135-CINE',
      name: 'Tráng Điện ảnh Tẩy Remjet + Scan Flat - Film ECN-2',
      film_format: '135 (35mm)',
      process_type: 'ECN-2',
      scanner: 'Noritsu HS-1800 (Flat Profile)',
      base_price: 110000,
      push_pull_fee: 35000,
      high_res_fee: 30000,
      sla_hours: 72,
      status: 'ACTIVE',
      output_format: 'TIFF Flat Log-profile',
      description: 'Bồn tẩy than Remjet bằng kiềm PB-2 chuyên dụng, rửa sạch muội than không để lại hạt xước.',
      created_at: '2025-01-15T00:00:00Z'
    },
    {
      service_id: 'SVC-E6-135-SLIDE',
      name: 'Tráng Dương Bản 6-Bath - Film Slide E-6 135',
      film_format: '135 (35mm)',
      process_type: 'E-6',
      scanner: 'Noritsu HS-1800 Hi-Dmax',
      base_price: 260000,
      push_pull_fee: 50000,
      high_res_fee: 40000,
      sla_hours: 360, // 15 ngày gom cuộn
      status: 'PAUSED', // Tạm ẩn do gom mẻ
      output_format: 'TIFF 16-bit Full Dynamic Range',
      description: 'Quy trình 6 bể đảo màu hóa học nhiệt độ 38.0°C. Gom đủ 15 cuộn mở mẻ tráng một lần.',
      created_at: '2025-01-20T00:00:00Z'
    }
  ],

  // Price Change Audit History
  priceHistory: [
    {
      history_id: 'PRC-LOG-01',
      service_name: 'Tráng + Scan Standard - Film Màu 135',
      old_price: 75000,
      new_price: 80000,
      effective_date: '2025-10-01',
      changed_by: 'Nguyễn Văn An Khang (Chủ Lab)',
      reason: 'Biến động giá hóa chất C-41 nhập khẩu từ Nhật Bản (+8%)'
    },
    {
      history_id: 'PRC-LOG-02',
      service_name: 'Tráng Điện ảnh Tẩy Remjet - Film ECN-2',
      old_price: 100000,
      new_price: 110000,
      effective_date: '2025-09-15',
      changed_by: 'Nguyễn Văn An Khang (Chủ Lab)',
      reason: 'Nâng cấp bồn rửa cơ học sục khí rung siêu âm chống trầy muội than'
    },
    {
      history_id: 'PRC-LOG-03',
      service_name: 'Tráng Thủ công B&W - 135',
      old_price: 90000,
      new_price: 100000,
      effective_date: '2025-08-01',
      changed_by: 'Nguyễn Văn An Khang (Chủ Lab)',
      reason: 'Chuyển sang hóa chất cao cấp Kodak Xtol không chứa hydroquinone'
    }
  ],

  // Customer Disputes / Complaints
  disputes: [
    {
      dispute_id: 'DISP-2024-009',
      order_id: 'ORD-2024-87910',
      customer_name: 'Trương Mỹ Lan Anh',
      customer_avatar: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=100&h=100&fit=crop',
      status: 'NEGOTIATING', // 02 CA ĐANG THƯƠNG LƯỢNG
      category: 'Hư hỏng vật lý (Vết cào xước âm bản)',
      film_type: 'Kodak Tri-X 400 (135)',
      claim_amount: 320000,
      compensation_offered: 200000,
      created_at: '2026-11-01T14:15:00Z',
      messages: [
        {
          sender: 'CUSTOMER',
          name: 'Trương Mỹ Lan Anh',
          time: '14:15 Hôm qua',
          content: 'Chào Lab, cuộn Tri-X 400 của em nhận về có một vệt xước dài chạy ngang từ frame 12 đến frame 20. Đây là cuộn ảnh kỷ niệm chụp tốt nghiệp của em, nhờ lab giải quyết giúp ạ.'
        },
        {
          sender: 'LAB',
          name: 'Lê Hoài Nam (KTV Trưởng)',
          time: '14:40 Hôm qua',
          content: 'Dạ chào bạn Lan Anh, Lab đã kiểm tra lại cuộn âm bản và nhận thấy vệt xước do trục con lăn khay nạp của máy scan SP-3000 bị kẹt dị vật nhỏ. Lab thành thật xin lỗi bạn về sự cố ngoài ý muốn này!'
        },
        {
          sender: 'LAB',
          name: 'Lê Hoài Nam (KTV Trưởng)',
          time: '14:42 Hôm qua',
          content: 'Lab xin đề xuất giải pháp: (1) Lab sẽ cử chuyên viên phục chế số (Digital Retouching) xóa sạch vệt xước cho 9 frame ảnh trên bản scan; (2) Hoàn trả 100% tiền phí dịch vụ cuộn phim (100.000đ); (3) Tặng bạn 01 cuộn film Kodak Tri-X 400 mới đền bù.'
        }
      ]
    },
    {
      dispute_id: 'DISP-2024-010',
      order_id: 'ORD-2024-88005',
      customer_name: 'Hoàng Long',
      customer_avatar: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=100&h=100&fit=crop',
      status: 'NEGOTIATING',
      category: 'Trễ hạn cam kết SLA (>24 giờ)',
      film_type: 'Cinestill 800T (135)',
      claim_amount: 150000,
      compensation_offered: 150000,
      created_at: '2026-11-02T05:00:00Z',
      messages: [
        {
          sender: 'CUSTOMER',
          name: 'Hoàng Long',
          time: '05:00 Sáng nay',
          content: 'Đơn của mình hẹn 18h tối qua có file mà đến sáng nay vẫn chưa thấy link ảnh trong Archive. Mình cần ảnh gấp để nộp bài triển lãm sáng nay!'
        },
        {
          sender: 'LAB',
          name: 'Lê Hoài Nam (KTV Trưởng)',
          time: '07:30 Sáng nay',
          content: 'Chào anh Long, Lab rất xin lỗi anh vì tối qua hệ thống máy sấy gặp trục trặc làm chậm mẻ film. Hiện tại ảnh của anh đã scan xong 100% và đang kiểm định QC cuối, file sẽ nạp vào kho Archive trong 15 phút tới. Lab xin hoàn lại 50% phí đơn trễ hẹn cho anh theo chính sách SLA của tiệm ạ.'
        }
      ]
    }
  ],

  // Operational SLA and Performance History
  slaAnalytics: {
    period: 'Tháng 10/2024 (Hiện tại)',
    metrics: {
      total_orders: 1482,
      on_time_rate: 98.4,
      avg_turnaround_hours: 28.5,
      first_pass_qc: 94.8,
      total_disputes: 14,
      self_settled_rate: 92.0,
      compensation_fund_used: 4850000,
      compensation_fund_limit: 10000000
    },
    dailyStats: [
      { date: '25/10', orders: 48, on_time: 48, avg_time: 26.2 },
      { date: '26/10', orders: 55, on_time: 54, avg_time: 27.5 },
      { date: '27/10', orders: 62, on_time: 60, avg_time: 29.1 },
      { date: '28/10', orders: 58, on_time: 57, avg_time: 28.0 },
      { date: '29/10', orders: 52, on_time: 51, avg_time: 27.8 },
      { date: '30/10', orders: 60, on_time: 59, avg_time: 28.4 },
      { date: '31/10', orders: 54, on_time: 53, avg_time: 28.5 }
    ]
  }
};

module.exports = mockDb;

