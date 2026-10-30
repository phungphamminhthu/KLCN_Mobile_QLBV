# MedCare Hospital Mobile – Flutter Starter

## Mục tiêu
Bộ khung khởi đầu cho ứng dụng mobile bệnh nhân. Web nhân viên/backend là project riêng.

## Chạy project
Từ thư mục gốc Flutter:
```bash
flutter pub get
flutter analyze
flutter devices
flutter run
```

## Quy ước
- `core/`: theme, router, network và widget nền tảng do trưởng nhóm quản lý.
- `shared/`: model/widget được nhiều tính năng sử dụng.
- `features/`: mỗi thành viên phát triển tính năng được giao.
- Màu sắc dùng `AppColors` trong `lib/core/theme/app_colors.dart`.
- Tên file `snake_case.dart`, tên class `PascalCase`, tên biến/hàm `camelCase`.
- Không commit API key, mật khẩu, thông tin bệnh nhân thật.
- Không sửa `main.dart`, `app.dart`, `app_router.dart`, `app_colors.dart` nếu chưa thống nhất với trưởng nhóm.

## Lưu ý
Đây là scaffold giao diện, dùng dữ liệu mẫu và placeholder; chưa tích hợp API/backend.
