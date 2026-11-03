/**
 * MiniLab Platform - In-Memory Datastore & Initial Seed
 * Based on 44-Table Schema (doc/week 2/So do thiet ke Co so du lieu.md)
 * Self-contained without external API dependencies.
 */

const mockUsers = [
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
  },
  {
    user_id: 'usr-002',
    email: 'labowner@croplab.vn',
    phone: '0987654321',
    password: 'password123',
    full_name: 'Trần Văn Đức (CropLab)',
    avatar_url: 'https://images.unsplash.com/photo-1570295999919-56ceb5ecca61?w=150',
    role: 'LabOwner',
    created_at: '2026-01-05T08:00:00Z',
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
    price_range: '45.000đ - 120.000đ',
    description: 'CropLab cung cấp dịch vụ tráng và scan phim màu C-41, đen trắng B&W thủ công với hóa chất chuẩn Kodak & Ilford. Scan máy Noritsu HS-1800 cho độ phân giải sắc nét và dải màu trung thực.',
  },
  {
    lab_id: 'lab-002',
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
    price_range: '50.000đ - 110.000đ',
    description: 'LLab là điểm đến quen thuộc của cộng đồng film Sài Gòn với phong cách chỉnh màu Frontier tươi tắn đặc trưng và dịch vụ nhận trả film tận nơi.',
  },
  {
    lab_id: 'lab-003',
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
    price_range: '70.000đ - 250.000đ',
    description: 'Chuyên dòng phim đen trắng nghệ thuật, tráng tay kiểm soát từng vùng sáng tối và scan độ phân giải cực đại TIFF 16-bit.',
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
    description: 'Độ phân giải lớn nhất từ Noritsu HS-1800, lưu giữ toàn bộ chi tiết hạt grain và màu sắc chân thực.',
  },
  {
    package_id: 'pkg-003',
    lab_id: 'lab-001',
    name: 'Tráng & Scan 135 B&W (Đen Trắng)',
    film_format: '135',
    process_type: 'B&W',
    scan_resolution: 'M (3000x2000px)',
    price: 65000,
    estimated_hours: 24,
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
    description: 'Dành cho máy ảnh khổ vuông 6x6, 6x7, 6x4.5 (Hasselblad, Rolleiflex, Pentax 67).',
  }
];

const mockOrders = [
  {
    order_id: 'ORD-2026-8801',
    user_id: 'usr-001',
    lab_id: 'lab-001',
    lab_name: 'CropLab Hà Nội',
    order_date: '2026-03-01T09:30:00Z',
    status: 'READY_FOR_DOWNLOAD', // PENDING_FILM, RECEIVED, PROCESSING, QC_CHECK, READY_FOR_DOWNLOAD, COMPLETED
    total_amount: 135000,
    shipping_method: 'PICKUP', // PICKUP, DROP_AT_LAB
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
        quantity: 1,
        price: 50000,
        options: { push_pull: 'Normal (Box speed)', cut_negatives: 'Cắt 6 frames/dải' }
      },
      {
        item_id: 'item-102',
        package_id: 'pkg-002',
        name: 'Tráng & Scan 135 Color (C-41) - Scan Cao Cấp L (TIFF/JPG)',
        film_name: 'Fujifilm Pro 400H',
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
    lab_id: 'lab-001',
    lab_name: 'CropLab Hà Nội',
    order_date: '2026-03-02T14:10:00Z',
    status: 'PROCESSING',
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
  },
  {
    photo_id: 'pho-003',
    user_id: 'usr-001',
    order_id: 'ORD-2026-8801',
    roll_code: 'ROLL-FUJI400-02',
    title: 'Bến thuyền Tràng An chiều muộn',
    image_url: 'https://images.unsplash.com/photo-1506744038136-46273834b3fb?w=1200',
    thumbnail_url: 'https://images.unsplash.com/photo-1506744038136-46273834b3fb?w=400',
    album_name: 'Chuyến đi Ninh Bình',
    is_favorite: false,
    created_at: '2026-03-01T17:15:00Z',
    metadata: {
      camera: 'Canon AE-1 Program',
      lens: 'Canon FD 50mm f/1.4',
      film_stock: 'Fujifilm Pro 400H',
      iso: 400,
      aperture: 'f/2.0',
      shutter_speed: '1/125s',
      focal_length: '50mm',
      process: 'C-41 Noritsu HS-1800 (+1 Push)',
      lab: 'CropLab Hà Nội',
      dimensions: '6048 x 4032',
      file_size: '19.1 MB TIFF'
    }
  },
  {
    photo_id: 'pho-004',
    user_id: 'usr-001',
    order_id: 'ORD-2026-8801',
    roll_code: 'ROLL-FUJI400-02',
    title: 'Quán cafe đường tàu',
    image_url: 'https://images.unsplash.com/photo-1514432324607-a09d9b4aefdd?w=1200',
    thumbnail_url: 'https://images.unsplash.com/photo-1514432324607-a09d9b4aefdd?w=400',
    album_name: 'Mùa thu Hà Nội 2026',
    is_favorite: false,
    created_at: '2026-03-01T17:15:00Z',
    metadata: {
      camera: 'Canon AE-1 Program',
      lens: 'Canon FD 50mm f/1.4',
      film_stock: 'Fujifilm Pro 400H',
      iso: 400,
      aperture: 'f/1.4',
      shutter_speed: '1/60s',
      focal_length: '50mm',
      process: 'C-41 Noritsu HS-1800',
      lab: 'CropLab Hà Nội',
      dimensions: '6048 x 4032',
      file_size: '17.3 MB TIFF'
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
    status: 'ACTIVE',
    location: 'Hoàn Kiếm, Hà Nội',
    phone_contact: '0912345678',
    zalo_contact: '0912345678',
    image_urls: [
      'https://images.unsplash.com/photo-1526170375885-4d8ecf77b99f?w=800',
      'https://images.unsplash.com/photo-1495745966610-2a67f2297e5e?w=800'
    ],
    description: 'Cần nhượng lại Canon QL17 GIII bản đen hiếm. Kính trong vắt, không mốc xước, đo sáng nhạy chuẩn pin PX625 adapter. Cơ tốc nảy đanh, kèm filter UV zin và bao da.',
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
    status: 'ACTIVE',
    location: 'Bình Thạnh, TP.HCM',
    phone_contact: '0909123456',
    zalo_contact: '0909123456',
    image_urls: [
      'https://images.unsplash.com/photo-1502920917128-1aa500764cbd?w=800'
    ],
    description: 'Huyền thoại cơ khí OM-1 màn trập lụa êm ái. Đo sáng hoạt động tốt, view ngắm sạch không lăng kính thủy triều. Kèm ống kính tiêu cự vàng 50mm f/1.4 xóa phông mượt.',
    created_at: '2026-02-27T15:30:00Z'
  },
  {
    listing_id: 'mkt-003',
    seller_id: 'usr-002',
    seller_name: 'Trần Văn Đức (CropLab)',
    seller_avatar: 'https://images.unsplash.com/photo-1570295999919-56ceb5ecca61?w=150',
    title: 'Combo 5 Cuộn Film Kodak Ultramax 400 (Date 2027)',
    category: 'Cuộn Film 135',
    condition: '100% Mới nguyên seal bảo quản tủ mát 18°C',
    price: 1150000,
    status: 'ACTIVE',
    location: 'Tây Hồ, Hà Nội',
    phone_contact: '0904567890',
    zalo_contact: '0904567890',
    image_urls: [
      'https://images.unsplash.com/photo-1563245372-f21724e3856d?w=800'
    ],
    description: 'Kodak Ultramax 400 chính hãng date mới toanh 2027. Độ nhạy cao chụp được cả trong nhà và ngoài trời nắng, màu sắc rực rỡ.',
    created_at: '2026-03-01T08:00:00Z'
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
    content: 'Phim âm bản màu như Kodak Portra hay Fuji Superia có khả năng giữ chi tiết vùng sáng (highlight latitude) cực kỳ ấn tượng, lên đến +3 hoặc +4 stops mà không bị cháy bết. Tuy nhiên, vùng tối (shadow) nếu bị thiếu sáng sẽ sinh ra noise màu hạt thô và ngả xám đục. Lời khuyên vàng: Hãy luôn ưu tiên đo sáng vào vùng tối nhất bạn muốn giữ chi tiết, hoặc set ISO thấp hơn box speed 1/3 đến 1 stop để bức ảnh luôn trong trẻo!',
    image_url: 'https://images.unsplash.com/photo-1516035069371-29a1b244cc32?w=800',
    category: 'Kỹ thuật chụp',
    likes_count: 89,
    comments_count: 14,
    created_at: '2026-03-01T10:00:00Z',
    comments: [
      {
        comment_id: 'cmt-1',
        user_name: 'Nguyễn Hoàng Anh',
        avatar_url: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=150',
        content: 'Bài viết rất hữu ích anh ơi! Em chụp Portra 400 toàn set 200 trên máy, ảnh tráng ra màu da hồng hào cực thích.',
        created_at: '2026-03-01T11:20:00Z'
      },
      {
        comment_id: 'cmt-2',
        user_name: 'Trần Văn Đức (CropLab)',
        avatar_url: 'https://images.unsplash.com/photo-1570295999919-56ceb5ecca61?w=150',
        content: 'Hoàn toàn đồng ý với Huy! Phim âm bản thừa sáng một chút khi scan máy Noritsu chỉnh lại cực kỳ dễ và mượt mà.',
        created_at: '2026-03-01T12:05:00Z'
      }
    ]
  },
  {
    post_id: 'post-002',
    author_id: 'usr-001',
    author_name: 'Nguyễn Hoàng Anh',
    author_avatar: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=150',
    author_badge: 'Thành viên đam mê',
    title: 'Trải nghiệm cuộn Cine Film 500T đầu tiên tráng quy trình ECN-2',
    content: 'Trước giờ mình toàn chụp film C-41 thông thường, hôm nay nhận file scan cuộn Kodak Vision3 500T từ CropLab thực sự bất ngờ với hiệu ứng halo đỏ quanh nguồn sáng ban đêm và độ mịn của hạt cine. Anh em nào thích tông điện ảnh thì nhất định nên thử một lần!',
    image_url: 'https://images.unsplash.com/photo-1514432324607-a09d9b4aefdd?w=800',
    category: 'Review Film',
    likes_count: 64,
    comments_count: 8,
    created_at: '2026-02-28T20:30:00Z',
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
    fee: 'Miễn phí tham gia (Hỗ trợ 20% phí tráng scan tại CropLab)',
    cover_image: 'https://images.unsplash.com/photo-1528127269322-539801943592?w=800',
    description: 'Buổi giao lưu chụp ảnh đường phố đầu xuân dành cho tất cả mọi người yêu thích máy ảnh cơ. Chúng ta sẽ cùng nhau chia sẻ góc nhìn về bố cục, ánh sáng và trải nghiệm những cuộn film màu sắc phong phú.',
    is_registered: false
  },
  {
    event_id: 'evt-002',
    organizer_id: 'usr-002',
    organizer_name: 'CropLab Academy',
    title: 'Workshop Thực Hành: Tự Tráng Phim Đen Trắng Thủ Công Tại Nhà',
    date: 'Thứ Bảy, 21/03/2026 • 14:00 - 17:30',
    location: 'Phòng tối CropLab - Đặng Thai Mai, Tây Hồ',
    registered_count: 8,
    max_slots: 10,
    fee: '250.000đ (Bao gồm hóa chất, tank tráng và 1 cuộn Ilford HP5)',
    cover_image: 'https://images.unsplash.com/photo-1471341971476-ae15ff5dd4ea?w=800',
    description: 'Học cách lên cuộn trong túi tối (changing bag), pha chế dung dịch Kodak D-76, kiểm soát chu kỳ lắc agitation và tự tay mang về dải film âm bản sắc nét.',
    is_registered: true
  }
];

const mockReviews = [
  {
    review_id: 'rev-001',
    lab_id: 'lab-001',
    user_name: 'Hoàng Long',
    rating: 5,
    date: '28/02/2026',
    comment: 'CropLab làm cực nhanh! Mình gửi tráng sáng 10h thì chiều 4h đã có link tải file scan TIFF trên app. Màu Noritsu chuẩn không cần chỉnh.',
    service_name: 'Tráng & Scan 135 Color C-41'
  },
  {
    review_id: 'rev-002',
    lab_id: 'lab-001',
    user_name: 'Mai Phương',
    rating: 5,
    date: '25/02/2026',
    comment: 'Đóng gói film trả cẩn thận, cắt dải bọc bao bảo vệ chu đáo. Shipper pickup tận nơi rất tiện cho người bận rộn như mình.',
    service_name: 'Tráng & Scan Medium Format 120'
  }
];

module.exports = {
  mockUsers,
  mockLabs,
  mockServicePackages,
  mockOrders,
  mockArchivePhotos,
  mockListings,
  mockCommunityPosts,
  mockEvents,
  mockReviews
};

