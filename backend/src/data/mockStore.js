/**
 * MiniLab Platform - In-Memory Datastore & Initial Seed
 * Based on 44-Table Schema (doc/week 2/So do thiet ke Co so du lieu.md)
 * Shared backend for Mobile App, Web Lab Portal, and Web Admin Console.
 */

const mockUsers = [
  {
    user_id: 'usr-000',
    email: 'admin@minilab.vn',
    phone: '0900000000',
    password: 'password123',
    full_name: 'Quản trị viên Hệ thống (System Admin)',
    avatar_url: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150',
    role: 'Admin',
    created_at: '2026-01-01T00:00:00Z',
    address: 'Văn phòng MiniLab HQ, Hoàn Kiếm, Hà Nội',
    status: 'ACTIVE',
  },
  {
    user_id: 'usr-000b',
    email: 'admin.tuan@minilab.vn',
    phone: '0900000001',
    password: 'password123',
    full_name: 'Lê Tuấn (Tổng Quản Trị MiniLab)',
    avatar_url: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150',
    role: 'Admin',
    created_at: '2026-01-01T00:00:00Z',
    address: 'Văn phòng MiniLab HQ, Hoàn Kiếm, Hà Nội',
    status: 'ACTIVE',
  },
  {
    user_id: 'usr-002',
    email: 'croplab@minilab.vn',
    phone: '0987654321',
    password: 'password123',
    full_name: 'CropLab Hà Nội (Lab Quản Trị)',
    avatar_url: 'https://images.unsplash.com/photo-1570295999919-56ceb5ecca61?w=150',
    role: 'LabOwner',
    lab_id: 'lab-001',
    created_at: '2026-01-05T08:00:00Z',
    status: 'ACTIVE',
  },
  {
    user_id: 'usr-002b',
    email: 'saigon.lab@minilab.vn',
    phone: '0987654322',
    password: 'password123',
    full_name: 'LLab Film Sài Gòn (Lab Manager)',
    avatar_url: 'https://images.unsplash.com/photo-1570295999919-56ceb5ecca61?w=150',
    role: 'LabOwner',
    lab_id: 'lab-001',
    created_at: '2026-01-05T08:00:00Z',
    status: 'ACTIVE',
  },
  {
    user_id: 'usr-001',
    email: 'khachhang@minilab.vn',
    phone: '0912345678',
    password: 'password123',
    full_name: 'Nguyễn Hoàng Anh',
    avatar_url: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=150',
    role: 'Customer',
    created_at: '2026-01-10T08:00:00Z',
    address: '123 Phố Huế, Hai Bà Trưng, Hà Nội',
    status: 'ACTIVE',
  },
  {
    user_id: 'usr-003',
    email: 'chuyengia@film.vn',
    phone: '0909123456',
    password: 'password123',
    full_name: 'Lê Quang Huy',
    avatar_url: 'https://images.unsplash.com/photo-1522075469751-3a6694fb2f61?w=150',
    role: 'Expert',
    bio: 'Nhiếp ảnh gia phim tài liệu với 12 năm kinh nghiệm chụp medium format và tráng film thủ công.',
    created_at: '2026-01-02T08:00:00Z',
    status: 'ACTIVE',
  }
];

const mockLabs = [
  {
    lab_id: 'lab-001',
    owner_id: 'usr-002',
    name: 'CropLab Hà Nội',
    tagline: 'Chuyên gia tráng & scan chất lượng cao từ năm 2014',
    address: 'Số 10 ngõ 12 Đặng Thai Mai, Tây Hồ, Hà Nội',
    city: 'Hà Nội',
    phone: '0904567890',
    email: 'hanoi@croplab.vn',
    rating: 4.9,
    review_count: 328,
    turnaround_hours: 12,
    scanner_models: ['Noritsu HS-1800', 'Fuji Frontier SP-3000'],
    supported_formats: ['135', '120', '220', '4x5'],
    supported_processes: ['C-41', 'B&W', 'ECN-2', 'E-6 Slide'],
    cover_image: 'https://images.unsplash.com/photo-1516035069371-29a1b244cc32?w=800',
    logo_url: 'https://images.unsplash.com/photo-1495745966610-2a67f2297e5e?w=200',
    is_verified: true,
    status: 'APPROVED',
    price_range: '45.000đ - 120.000đ',
    description: 'CropLab cung cấp dịch vụ tráng và scan phim màu C-41, đen trắng B&W thủ công với hóa chất chuẩn Kodak & Ilford. Scan máy Noritsu HS-1800 cho độ phân giải sắc nét và dải màu trung thực.',
    created_at: '2026-01-05T08:00:00Z'
  },
  {
    lab_id: 'lab-002',
    owner_id: 'usr-004',
    name: 'LLab Film Sài Gòn',
    tagline: 'Màu sắc ấm áp, tốc độ siêu nhanh trong ngày',
    address: '40/2 Phan Văn Trị, Phường 12, Bình Thạnh, TP.HCM',
    city: 'TP.HCM',
    phone: '0938112233',
    email: 'saigon@llab.vn',
    rating: 4.8,
    review_count: 512,
    turnaround_hours: 8,
    scanner_models: ['Fuji Frontier SP-3000'],
    supported_formats: ['135', '120'],
    supported_processes: ['C-41', 'B&W', 'ECN-2'],
    cover_image: 'https://images.unsplash.com/photo-1452784444945-3f422708fe5e?w=800',
    logo_url: 'https://images.unsplash.com/photo-1488646953014-85cb44e25828?w=200',
    is_verified: true,
    status: 'APPROVED',
    price_range: '50.000đ - 110.000đ',
    description: 'LLab là điểm đến quen thuộc của cộng đồng film Sài Gòn với phong cách chỉnh màu Frontier tươi tắn đặc trưng và dịch vụ nhận trả film tận nơi.',
    created_at: '2026-01-08T08:00:00Z'
  },
  {
    lab_id: 'lab-003',
    owner_id: 'usr-005',
    name: 'Nadar Darkroom & Lab',
    tagline: 'Phòng tối tráng phim Fine-Art & In ấn thủ công',
    address: '15 Tràng Tiền, Hoàn Kiếm, Hà Nội',
    city: 'Hà Nội',
    phone: '0918776655',
    email: 'contact@nadarlab.com',
    rating: 5.0,
    review_count: 145,
    turnaround_hours: 24,
    scanner_models: ['Hasselblad Flextight X5', 'Noritsu HS-1800'],
    supported_formats: ['135', '120', '4x5', '8x10'],
    supported_processes: ['B&W Thủ công', 'C-41 Pro', 'E-6'],
    cover_image: 'https://images.unsplash.com/photo-1471341971476-ae15ff5dd4ea?w=800',
    logo_url: 'https://images.unsplash.com/photo-1542038784456-1ea8e935640e?w=200',
    is_verified: true,
    status: 'APPROVED',
    price_range: '70.000đ - 250.000đ',
    description: 'Chuyên dòng phim đen trắng nghệ thuật, tráng tay kiểm soát từng vùng sáng tối và scan độ phân giải cực đại TIFF 16-bit.',
    created_at: '2026-01-12T08:00:00Z'
  }
];

const mockPendingLabs = [
  {
    application_id: 'app-lab-901',
    name: 'Retro Hanoi Darkroom',
    owner_name: 'Phạm Gia Huy',
    email: 'retro.hanoi@gmail.com',
    phone: '0945667788',
    city: 'Hà Nội',
    address: 'Số 22 ngõ Huyện, Hàng Trống, Hoàn Kiếm, Hà Nội',
    business_license: 'DKKD-0109923481',
    scanner_models: ['Noritsu LS-600', 'Epson V850 Pro'],
    supported_processes: ['C-41', 'B&W'],
    applied_date: '2026-03-02T10:30:00Z',
    status: 'PENDING',
    inspection_note: 'Đã nộp đầy đủ giấy phép kinh doanh hóa chất tráng ảnh và hợp đồng xử lý chất thải môi trường.',
  },
  {
    application_id: 'app-lab-902',
    name: 'Analog Saigon Space',
    owner_name: 'Võ Thành Nam',
    email: 'analog.saigon@gmail.com',
    phone: '0919334455',
    city: 'TP.HCM',
    address: '88 Nguyễn Đình Chiểu, Phường Đa Kao, Quận 1, TP.HCM',
    business_license: 'DKKD-0318829102',
    scanner_models: ['Fuji Frontier SP-3000'],
    supported_processes: ['C-41', 'ECN-2 Cine'],
    applied_date: '2026-03-03T14:15:00Z',
    status: 'PENDING',
    inspection_note: 'Hồ sơ chờ xác minh máy scan thực tế và phòng tối sấy buồng kín.',
  }
];

const mockServicePackages = [
  {
    package_id: 'pkg-001',
    lab_id: 'lab-001',
    name: 'Tráng & Scan 135 Color (C-41) - Chuẩn M',
    film_format: '135',
    process_type: 'C-41',
    scan_resolution: 'M (3000x2000px)',
    price: 50000,
    estimated_hours: 12,
    status: 'ACTIVE',
    description: 'Gói tráng và scan tiêu chuẩn cho cuộn film 35mm màu phổ thông (Kodak Gold, ColorPlus, Fuji C200, UltraMax).',
  },
  {
    package_id: 'pkg-002',
    lab_id: 'lab-001',
    name: 'Tráng & Scan 135 Color (C-41) - Scan Cao Cấp L (TIFF/JPG)',
    film_format: '135',
    process_type: 'C-41',
    scan_resolution: 'L (6000x4000px TIFF)',
    price: 85000,
    estimated_hours: 16,
    status: 'ACTIVE',
    description: 'Độ phân giải lớn nhất từ Noritsu HS-1800, lưu giữ toàn bộ chi tiết hạt grain và màu sắc chân thực.',
  },
  {
    package_id: 'pkg-003',
    lab_id: 'lab-001',
    name: 'Tráng & Scan 135 B&W (Đen Trắng Thủ Công)',
    film_format: '135',
    process_type: 'B&W',
    scan_resolution: 'M (3000x2000px)',
    price: 65000,
    estimated_hours: 24,
    status: 'ACTIVE',
    description: 'Tráng với thuốc Kodak D-76 hoặc Ilford ID-11, kiểm soát độ tương phản và chi tiết vùng tối.',
  },
  {
    package_id: 'pkg-004',
    lab_id: 'lab-001',
    name: 'Tráng & Scan Cine Film ECN-2 (Tẩy than)',
    film_format: '135',
    process_type: 'ECN-2',
    scan_resolution: 'M (3000x2000px)',
    price: 75000,
    estimated_hours: 24,
    status: 'ACTIVE',
    description: 'Xử lý cuộn film điện ảnh Kodak Vision3 (50D, 250D, 500T), tẩy than remjet sạch sẽ.',
  },
  {
    package_id: 'pkg-005',
    lab_id: 'lab-001',
    name: 'Tráng & Scan Medium Format 120 (C-41)',
    film_format: '120',
    process_type: 'C-41',
    scan_resolution: 'L (4800x4800px)',
    price: 80000,
    estimated_hours: 12,
    status: 'ACTIVE',
    description: 'Dành cho máy ảnh khổ vuông 6x6, 6x7, 6x4.5 (Hasselblad, Rolleiflex, Pentax 67).',
  }
];

const mockOrders = [
  {
    order_id: 'ORD-2026-8801',
    user_id: 'usr-001',
    customer_name: 'Nguyễn Hoàng Anh',
    customer_phone: '0912345678',
    lab_id: 'lab-001',
    lab_name: 'CropLab Hà Nội',
    order_date: '2026-03-01T09:30:00Z',
    status: 'READY_FOR_DOWNLOAD', // PENDING_FILM, RECEIVED, PROCESSING, DRYING, SCANNING, QC_CHECK, READY_FOR_DOWNLOAD, COMPLETED
    kanban_column: 'READY', // QUEUE, DEVELOPING, SCANNING, QC, READY
    total_amount: 135000,
    shipping_method: 'PICKUP',
    pickup_address: '123 Phố Huế, Hai Bà Trưng, Hà Nội',
    payment_status: 'PAID',
    payment_method: 'MOMO',
    sla_deadline: '2026-03-02T12:00:00Z',
    items: [
      {
        item_id: 'item-101',
        package_id: 'pkg-001',
        name: 'Tráng & Scan 135 Color (C-41) - Chuẩn M',
        film_name: 'Kodak Portra 400',
        roll_code: 'ROLL-PORTRA400-01',
        quantity: 1,
        price: 50000,
        options: { push_pull: 'Normal (Box speed)', cut_negatives: 'Cắt 6 frames/dải' }
      },
      {
        item_id: 'item-102',
        package_id: 'pkg-002',
        name: 'Tráng & Scan 135 Color - Scan Cao Cấp L (TIFF)',
        film_name: 'Fujifilm Pro 400H',
        roll_code: 'ROLL-FUJI400-02',
        quantity: 1,
        price: 85000,
        options: { push_pull: '+1 Stop (Push)', cut_negatives: 'Để nguyên cuộn không cắt' }
      }
    ],
    timeline: [
      { step: 1, name: 'Tạo đơn & Đã thanh toán', status: 'COMPLETED', time: '09:30 01/03/2026', note: 'Thanh toán MoMo thành công' },
      { step: 2, name: 'Đã nhận cuộn film tại Lab', status: 'COMPLETED', time: '11:15 01/03/2026', note: 'Shipper giao film đến quầy tiếp nhận' },
      { step: 3, name: 'Tráng hóa chất C-41', status: 'COMPLETED', time: '14:20 01/03/2026', note: 'Nhiệt độ 38°C, máy tráng tự động' },
      { step: 4, name: 'Rửa sạch & Sấy buồng kín', status: 'COMPLETED', time: '15:10 01/03/2026', note: 'Sấy khô nhiệt độ phòng không bụi' },
      { step: 5, name: 'Scan máy Noritsu HS-1800', status: 'COMPLETED', time: '16:40 01/03/2026', note: 'Scan độ phân giải cao' },
      { step: 6, name: 'Kiểm định chất lượng QC', status: 'COMPLETED', time: '17:05 01/03/2026', note: 'Đạt chuẩn màu sắc & độ sạch' },
      { step: 7, name: 'File sẵn sàng trong Archive', status: 'COMPLETED', time: '17:15 01/03/2026', note: 'Đã đồng bộ vào kho ảnh số cá nhân' }
    ]
  },
  {
    order_id: 'ORD-2026-8802',
    user_id: 'usr-001',
    customer_name: 'Nguyễn Hoàng Anh',
    customer_phone: '0912345678',
    lab_id: 'lab-001',
    lab_name: 'CropLab Hà Nội',
    order_date: '2026-03-02T14:10:00Z',
    status: 'PROCESSING',
    kanban_column: 'DEVELOPING',
    total_amount: 65000,
    shipping_method: 'DROP_AT_LAB',
    payment_status: 'PAID',
    payment_method: 'BANK_TRANSFER',
    sla_deadline: '2026-03-03T18:00:00Z',
    items: [
      {
        item_id: 'item-103',
        package_id: 'pkg-003',
        name: 'Tráng & Scan 135 B&W (Đen Trắng)',
        film_name: 'Ilford HP5 Plus 400',
        roll_code: 'ROLL-ILFORD-03',
        quantity: 1,
        price: 65000,
        options: { push_pull: '+2 Stops (Push ISO 1600)', cut_negatives: 'Cắt 6 frames/dải' }
      }
    ],
    timeline: [
      { step: 1, name: 'Tạo đơn & Đã thanh toán', status: 'COMPLETED', time: '14:10 02/03/2026', note: 'Chuyển khoản QR Techcombank' },
      { step: 2, name: 'Đã nhận cuộn film tại Lab', status: 'COMPLETED', time: '15:30 02/03/2026', note: 'Khách gửi trực tiếp tại quầy' },
      { step: 3, name: 'Đang tráng hóa chất B&W', status: 'IN_PROGRESS', time: '16:00 02/03/2026', note: 'Tráng tay dung dịch Kodak D-76' },
      { step: 4, name: 'Rửa & Sấy buồng kín', status: 'PENDING', time: '', note: '' },
      { step: 5, name: 'Scan máy Noritsu HS-1800', status: 'PENDING', time: '', note: '' },
      { step: 6, name: 'Kiểm định chất lượng QC', status: 'PENDING', time: '', note: '' },
      { step: 7, name: 'File sẵn sàng trong Archive', status: 'PENDING', time: '', note: '' }
    ]
  },
  {
    order_id: 'ORD-2026-8803',
    user_id: 'usr-003',
    customer_name: 'Lê Quang Huy',
    customer_phone: '0909123456',
    lab_id: 'lab-001',
    lab_name: 'CropLab Hà Nội',
    order_date: '2026-03-03T08:00:00Z',
    status: 'RECEIVED',
    kanban_column: 'QUEUE',
    total_amount: 80000,
    shipping_method: 'PICKUP',
    pickup_address: 'Tây Hồ, Hà Nội',
    payment_status: 'PAID',
    payment_method: 'VNPAY',
    sla_deadline: '2026-03-03T20:00:00Z',
    items: [
      {
        item_id: 'item-104',
        package_id: 'pkg-005',
        name: 'Tráng & Scan Medium Format 120 (C-41)',
        film_name: 'Kodak Ektar 100',
        roll_code: 'ROLL-EKTAR-04',
        quantity: 1,
        price: 80000,
        options: { push_pull: 'Normal', cut_negatives: 'Cắt 4 frames/dải' }
      }
    ],
    timeline: [
      { step: 1, name: 'Tạo đơn & Đã thanh toán', status: 'COMPLETED', time: '08:00 03/03/2026', note: 'VNPAY QR thành công' },
      { step: 2, name: 'Đã nhận cuộn film tại Lab', status: 'COMPLETED', time: '09:15 03/03/2026', note: 'Chờ đưa vào tank tráng mẻ sáng' }
    ]
  }
];

const mockArchivePhotos = [
  {
    photo_id: 'pho-001',
    user_id: 'usr-001',
    order_id: 'ORD-2026-8801',
    roll_code: 'ROLL-PORTRA400-01',
    title: 'Nắng chiều Phố Cổ Hà Nội',
    image_url: 'https://images.unsplash.com/photo-1528127269322-539801943592?w=1200',
    thumbnail_url: 'https://images.unsplash.com/photo-1528127269322-539801943592?w=400',
    album_name: 'Mùa thu Hà Nội 2026',
    is_favorite: true,
    created_at: '2026-03-01T17:15:00Z',
    metadata: {
      camera: 'Leica M6 Classic',
      lens: 'Summicron 35mm f/2 ASPH',
      film_stock: 'Kodak Portra 400',
      iso: 400,
      aperture: 'f/2.8',
      shutter_speed: '1/250s',
      focal_length: '35mm',
      process: 'C-41 Noritsu HS-1800',
      lab: 'CropLab Hà Nội',
      dimensions: '6048 x 4032',
      file_size: '18.4 MB TIFF'
    }
  },
  {
    photo_id: 'pho-002',
    user_id: 'usr-001',
    order_id: 'ORD-2026-8801',
    roll_code: 'ROLL-PORTRA400-01',
    title: 'Gánh hoa bên góc đường Phan Đình Phùng',
    image_url: 'https://images.unsplash.com/photo-1509042239860-f550ce710b93?w=1200',
    thumbnail_url: 'https://images.unsplash.com/photo-1509042239860-f550ce710b93?w=400',
    album_name: 'Mùa thu Hà Nội 2026',
    is_favorite: true,
    created_at: '2026-03-01T17:15:00Z',
    metadata: {
      camera: 'Leica M6 Classic',
      lens: 'Summicron 35mm f/2 ASPH',
      film_stock: 'Kodak Portra 400',
      iso: 400,
      aperture: 'f/4.0',
      shutter_speed: '1/500s',
      focal_length: '35mm',
      process: 'C-41 Noritsu HS-1800',
      lab: 'CropLab Hà Nội',
      dimensions: '6048 x 4032',
      file_size: '16.8 MB TIFF'
    }
  }
];

const mockListings = [
  {
    listing_id: 'mkt-001',
    seller_id: 'usr-001',
    seller_name: 'Nguyễn Hoàng Anh',
    seller_avatar: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=150',
    title: 'Máy ảnh Film Canon QL17 GIII (Black Limited Edition)',
    category: 'Máy ảnh Rangefinder',
    condition: '98% Sưu tầm, cơ tốc đo sáng hoàn hảo',
    price: 4800000,
    status: 'ACTIVE', // PENDING_REVIEW, ACTIVE, REJECTED, SOLD
    moderation_status: 'APPROVED',
    location: 'Hoàn Kiếm, Hà Nội',
    phone_contact: '0912345678',
    zalo_contact: '0912345678',
    image_urls: ['https://images.unsplash.com/photo-1526170375885-4d8ecf77b99f?w=800'],
    description: 'Cần nhượng lại Canon QL17 GIII bản đen hiếm. Kính trong vắt, không mốc xước, đo sáng nhạy chuẩn pin PX625 adapter.',
    created_at: '2026-02-28T10:00:00Z'
  },
  {
    listing_id: 'mkt-002',
    seller_id: 'usr-003',
    seller_name: 'Lê Quang Huy',
    seller_avatar: 'https://images.unsplash.com/photo-1522075469751-3a6694fb2f61?w=150',
    title: 'Bộ máy ảnh Olympus OM-1 + Lens Zuiko 50mm f/1.4',
    category: 'Máy ảnh SLR cơ khí',
    condition: '95% Nguyên bản, view sáng rõ',
    price: 3600000,
    status: 'PENDING_REVIEW',
    moderation_status: 'PENDING',
    location: 'Bình Thạnh, TP.HCM',
    phone_contact: '0909123456',
    zalo_contact: '0909123456',
    image_urls: ['https://images.unsplash.com/photo-1502920917128-1aa500764cbd?w=800'],
    description: 'Huyền thoại cơ khí OM-1 màn trập lụa êm ái. Chờ Admin kiểm duyệt tiền kiểm 100%.',
    created_at: '2026-03-02T15:30:00Z'
  }
];

const mockCommunityPosts = [
  {
    post_id: 'post-001',
    author_id: 'usr-003',
    author_name: 'Lê Quang Huy',
    author_avatar: 'https://images.unsplash.com/photo-1522075469751-3a6694fb2f61?w=150',
    author_badge: 'Chuyên gia nhiếp ảnh',
    title: 'Bí quyết chọn điểm đo sáng khi chụp phim âm bản màu (Color Negative)',
    content: 'Phim âm bản màu như Kodak Portra hay Fuji Superia có khả năng giữ chi tiết vùng sáng cực tốt...',
    category: 'Kỹ thuật chụp',
    likes_count: 89,
    comments_count: 14,
    status: 'ACTIVE',
    report_count: 0,
    created_at: '2026-03-01T10:00:00Z',
    comments: []
  },
  {
    post_id: 'post-002',
    author_id: 'usr-008',
    author_name: 'Người dùng vi phạm',
    author_avatar: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=150',
    author_badge: 'Thành viên mới',
    title: 'Rao bán hàng cấm và link spam tài chính cá độ',
    content: 'Click vào link nhận tiền thưởng ngay...',
    category: 'Spam',
    likes_count: 0,
    comments_count: 0,
    status: 'REPORTED',
    report_count: 5,
    report_reason: 'Spam quảng cáo sai quy định cộng đồng',
    created_at: '2026-03-02T11:00:00Z',
    comments: []
  }
];

const mockEvents = [
  {
    event_id: 'evt-001',
    organizer_id: 'usr-003',
    organizer_name: 'Lê Quang Huy & CropLab',
    title: 'Photowalk Mùa Hoa Sưa - Dạo Phố Cùng Máy Cơ',
    date: 'Chủ Nhật, 15/03/2026 • 07:30 - 11:30',
    location: 'Quanh Hồ Gươm & Phố Cổ Hà Nội',
    registered_count: 24,
    max_slots: 30,
    fee: 'Miễn phí tham gia',
    cover_image: 'https://images.unsplash.com/photo-1528127269322-539801943592?w=800',
    description: 'Buổi giao lưu chụp ảnh đường phố đầu xuân.',
    is_registered: false
  }
];

const mockDisputes = [
  {
    dispute_id: 'DSP-2026-001',
    order_id: 'ORD-2026-8801',
    customer_name: 'Nguyễn Hoàng Anh',
    lab_id: 'lab-001',
    lab_name: 'CropLab Hà Nội',
    issue_type: 'Trầy xước phim / Lỗi scan màu',
    description: 'Cuộn Portra 400 có 2 khung hình bị vệt xước dọc, muốn thương lượng scan lại độ phân giải TIFF hoặc hoàn phí tráng 50k.',
    amount_requested: 50000,
    status: 'NEGOTIATING', // OPEN, NEGOTIATING, RESOLVED, REFUNDED
    created_at: '2026-03-02T14:00:00Z',
    messages: [
      { sender: 'Khách hàng', text: 'Chào lab, khung hình số 12 và 13 bị vệt bụi dài ở góc phải.', time: '14:05 02/03' },
      { sender: 'CropLab', text: 'Dạ CropLab chào bạn! Bên mình sẽ đưa dải phim vào máy thổi khí ion và scan lại miễn phí ngay trong chiều nay nhé!', time: '14:30 02/03' }
    ]
  }
];

const mockReviews = [
  {
    review_id: 'rev-001',
    lab_id: 'lab-001',
    user_name: 'Hoàng Long',
    rating: 5,
    date: '28/02/2026',
    comment: 'CropLab làm cực nhanh! Màu Noritsu chuẩn không cần chỉnh.',
    service_name: 'Tráng & Scan 135 Color C-41'
  }
];

module.exports = {
  mockUsers,
  mockLabs,
  mockPendingLabs,
  mockServicePackages,
  mockOrders,
  mockArchivePhotos,
  mockListings,
  mockCommunityPosts,
  mockEvents,
  mockDisputes,
  mockReviews
};
