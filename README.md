
<p align="center">
  <img src="images/banner.svg" alt="Nền tảng kết nối cộng đồng nhiếp ảnh phim và Film Lab (MiniLab)" width="100%">
</p>

<h1 align="center">Platform Connecting Film Photography Enthusiasts with Film Labs</h1>

<p align="center">
  <b>Nền tảng kết nối cộng đồng nhiếp ảnh phim và các Film Lab (MiniLab)</b>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/App%20%26%20Web-Flutter-02569B?logo=flutter&logoColor=white" alt="Flutter">
  <img src="https://img.shields.io/badge/Backend-Node.js-339933?logo=nodedotjs&logoColor=white" alt="Node.js">
  <img src="https://img.shields.io/badge/Database-SQL%20Server-CC2927?logo=microsoftsqlserver&logoColor=white" alt="SQL Server">
  <img src="https://img.shields.io/badge/CI%2FCD-GitHub%20Actions-2088FF?logo=githubactions&logoColor=white" alt="GitHub Actions">
</p>

---

## Mục lục

1. [Giới thiệu](#giới-thiệu)
2. [Vấn đề cần giải quyết](#vấn-đề-cần-giải-quyết)
3. [Giải pháp đề xuất](#giải-pháp-đề-xuất)
4. [Vai trò trong hệ thống](#vai-trò-trong-hệ-thống)
5. [Luồng nghiệp vụ chính](#luồng-nghiệp-vụ-chính)
6. [Kiến trúc hệ thống](#kiến-trúc-hệ-thống)
7. [Công nghệ sử dụng](#công-nghệ-sử-dụng)
8. [Yêu cầu phi chức năng](#yêu-cầu-phi-chức-năng)
9. [Sản phẩm đầu ra](#sản-phẩm-đầu-ra)
10. [Kế hoạch thực hiện](#kế-hoạch-thực-hiện)
11. [Bắt đầu](#bắt-đầu)
12. [Thành viên nhóm](#thành-viên-nhóm)

---

## Giới thiệu

Nhiếp ảnh phim đang hồi sinh mạnh mẽ trên toàn thế giới, trong đó có Việt Nam. Ngày càng nhiều người yêu nhiếp ảnh, nghệ sĩ và nhà sưu tầm quay lại với phim nhờ vẻ đẹp đặc trưng và trải nghiệm sáng tạo riêng của nó. Nhu cầu về các dịch vụ **tráng phim, scan phim, in ảnh và lưu trữ số** vì vậy cũng tăng nhanh.

Dự án này xây dựng một **nền tảng số** kết nối **nhiếp ảnh gia, Film Lab, chuyên gia nhiếp ảnh và đối tác vận chuyển** trong cùng một hệ sinh thái: số hóa quy trình dịch vụ, quản lý đơn hàng minh bạch và thúc đẩy cộng đồng nhiếp ảnh phim.

## Vấn đề cần giải quyết

| Đối tượng | Hiện trạng |
|---|---|
| **Khách hàng** | Phải hỏi giá, thời gian xử lý, tình trạng đơn qua mạng xã hội, ứng dụng nhắn tin hoặc điện thoại. Chưa có nơi tập trung để tìm kiếm, so sánh, đặt lịch và theo dõi dịch vụ. |
| **Film Lab** | Nhiều lab vẫn làm thủ công: nhận film, theo dõi tiến độ, giao file scan, quản lý khách. Hiệu quả vận hành thấp, khó mở rộng. |
| **Cộng đồng** | Thiếu một hệ sinh thái số nơi mọi người tiếp cận kiến thức chuyên môn, tìm lab uy tín, trao đổi thiết bị, quản lý bộ sưu tập ảnh scan và tham gia hoạt động chung. |

## Giải pháp đề xuất

Nền tảng hoạt động như một hệ sinh thái cho nhiếp ảnh analog:

- **Tìm kiếm & so sánh Film Lab** theo chất lượng, giá, năng lực xử lý, thời gian hoàn thành, vị trí và đánh giá cộng đồng.
- **Đặt dịch vụ trực tuyến**: tráng, scan, in; yêu cầu pickup và giao nhận; thanh toán online.
- **Theo dõi tiến độ real-time** và nhận file scan số.
- **Digital Film Archive**: kho lưu trữ cá nhân cho ảnh scan, kèm metadata (loại film, máy ảnh, ống kính, ngày chụp, cách xử lý, thông số scan).
- **Cổng quản lý cho Film Lab**: gói dịch vụ, đơn hàng, lịch xử lý, giao file, doanh thu và báo cáo.
- **Marketplace**: mua, bán, trao đổi máy ảnh analog, ống kính, film và phụ kiện.
- **Kho kiến thức**: chuyên gia đăng hướng dẫn, review thiết bị, bài viết kỹ thuật; tổ chức workshop và photowalk.

## Vai trò trong hệ thống

<p align="center">
  <img src="images/roles.svg" alt="Các vai trò trong hệ thống" width="100%">
</p>

| Vai trò | Chức năng chính |
|---|---|
| **Photographer / Customer** | Đăng ký và quản lý tài khoản; tìm và so sánh Film Lab; đặt dịch vụ tráng, scan, in; yêu cầu pickup/giao nhận; theo dõi đơn; thanh toán online; tải và quản lý file scan; duy trì Digital Film Archive; đánh giá Film Lab; mua bán thiết bị trên Marketplace. |
| **Film Lab Owner** | Quản lý hồ sơ lab; cấu hình gói dịch vụ và giá; nhận đơn; cập nhật trạng thái xử lý; upload file scan; quản lý khách hàng; theo dõi doanh thu, hiệu quả kinh doanh và báo cáo vận hành. |
| **Photography Expert** | Đăng bài hướng dẫn; chia sẻ kỹ thuật; review film, máy ảnh, ống kính, Film Lab; tổ chức workshop và photowalk; trả lời câu hỏi cộng đồng. |
| **Delivery Partner** | Nhận yêu cầu pickup; lấy film từ khách; giao film đến lab; trả film đã xử lý cho khách; cập nhật trạng thái vận chuyển. Có thể tích hợp Ahamove, Lalamove. |
| **System Administrator** | Quản lý người dùng và phân quyền; duyệt Film Lab; quản lý Marketplace và danh mục dịch vụ; cấu hình phí giao dịch; giám sát thanh toán; kiểm duyệt đánh giá và nội dung; xử lý khiếu nại, tranh chấp; theo dõi hiệu năng nền tảng. |

## Luồng nghiệp vụ chính

<p align="center">
  <img src="images/flow.svg" alt="Vòng đời một đơn hàng film" width="100%">
</p>

**1. Tìm kiếm Film Lab.** Người dùng tìm lab theo vị trí, định dạng film hỗ trợ, dịch vụ, giá, thời gian xử lý, đánh giá hoặc kỹ thuật xử lý đặc biệt. Hệ thống tổng hợp thông tin từ nhiều lab để người dùng so sánh và chọn nhà cung cấp phù hợp.

**2. Đặt dịch vụ & thu nhận film.** Sau khi chọn lab, khách tạo đơn với loại film, tùy chọn xử lý, chất lượng scan, yêu cầu in và ghi chú thêm. Khách có thể tự mang film đến hoặc yêu cầu pickup qua đối tác vận chuyển. Lab xác nhận đơn và lên lịch xử lý.

**3. Quản lý vòng đời xử lý film.** Lab quản lý từng công đoạn: nhận film, tráng, rửa, sấy, scan, chuẩn bị ảnh và kiểm tra chất lượng cuối. Mỗi bước được ghi nhận và đồng bộ lên ứng dụng của khách để theo dõi real-time.

**4. Giao file số & quản lý Archive.** Khi hoàn tất, lab upload file scan lên cloud storage an toàn. Khách nhận thông báo, xem, tải về, sắp xếp và lưu trữ lâu dài trong Digital Film Archive cùng đầy đủ metadata.

**5. Marketplace & trao đổi thiết bị.** Thành viên đăng bài mua, bán, trao đổi máy ảnh analog, film, ống kính, phụ kiện. Có quản lý tin đăng, tìm kiếm nâng cao, đánh giá người bán, theo dõi giao dịch và liên hệ trực tiếp qua số điện thoại/Zalo giữa người mua và người bán.

**6. Chia sẻ kiến thức & cộng đồng.** Chuyên gia và thành viên giàu kinh nghiệm đăng hướng dẫn, bài kỹ thuật, review thiết bị, gợi ý lab. Người dùng thảo luận, đăng ký workshop, photowalk và cùng mở rộng kho kiến thức chung.

## Kiến trúc hệ thống

Hệ thống được tách module rõ ràng giữa App, Web, Backend và Storage để dễ bảo trì và mở rộng.

<p align="center">
  <img src="images/architecture.svg" alt="Kiến trúc hệ thống" width="100%">
</p>

## Công nghệ sử dụng

| Thành phần | Công nghệ |
|---|---|
| Mobile App | Flutter (Android & iOS) |
| Web Portal & Admin | Flutter Web |
| Backend | Node.js (Express) |
| Database | SQL Server |
| Authentication | JWT |
| Search Engine | Elasticsearch |
| Triển khai | Netlify and Render |
| CI/CD | GitHub Actions |
| Quản lý mã nguồn | GitHub |

## Yêu cầu phi chức năng

- Xác thực bằng **JWT** kết hợp **phân quyền theo vai trò (RBAC)**.
- **Cloud storage** cho file scan, có sao lưu tự động và cơ chế phục hồi.
- **Kiến trúc module** tách App, Web, Backend, Storage.
- **RESTful API** hỗ trợ tích hợp cổng thanh toán, đối tác logistics và các dịch vụ nhiếp ảnh trong tương lai.
- **Sẵn sàng cao, mở rộng tốt, nhất quán dữ liệu** cho nền tảng multi-tenant phục vụ nhiều Film Lab cùng lúc.

## Sản phẩm đầu ra

- [ ] Ứng dụng mobile (Flutter) cho nhiếp ảnh gia
- [ ] Web portal (Flutter Web) quản lý cho Film Lab
- [ ] Hệ thống web quản trị (Admin)
- [ ] Module Marketplace mua bán thiết bị
- [ ] Nền tảng cộng đồng & chia sẻ kiến thức
- [ ] Hệ thống quản lý Digital Film Archive
- [ ] Backend services (Node.js) & cơ sở dữ liệu SQL Server

## Kế hoạch thực hiện

| # | Công việc |
|---|---|
| 1 | Phân tích yêu cầu, thiết kế kiến trúc, mô hình hóa cơ sở dữ liệu SQL Server, phát triển Backend API (Node.js) |
| 2 | Phát triển ứng dụng Flutter cho nhiếp ảnh gia: đặt dịch vụ, theo dõi đơn, digital archive, marketplace, cộng đồng |
| 3 | Phát triển web portal (Flutter Web) cho chủ Film Lab và quản trị viên: quản lý dịch vụ, theo dõi quy trình, quản lý khách hàng, báo cáo, kiểm duyệt cộng đồng |
| 4 | Tích hợp hệ thống (thanh toán, logistics), kiểm thử, triển khai, tối ưu hiệu năng, hoàn thiện tài liệu kỹ thuật và báo cáo Capstone |

## Thành viên nhóm

| STT | Họ và tên | MSSV | Vai trò |
|---|---|---|---|
| 1 | _(điền tên)_ | _(điền MSSV)_ | _(vai trò)_ |
| 2 | _(điền tên)_ | _(điền MSSV)_ | _(vai trò)_ |
| 3 | _(điền tên)_ | _(điền MSSV)_ | _(vai trò)_ |
| 4 | _(điền tên)_ | _(điền MSSV)_ | _(vai trò)_ |

---

<p align="center"><i>Nhóm 8 · Term Project</i></p>
