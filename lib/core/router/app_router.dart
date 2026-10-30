  import 'package:flutter/material.dart';

  // Các màn hình của ứng dụng.
  import '../../features/home/screens/features_screen.dart';
  import '../../features/news/screens/news_screen.dart';
  import '../../features/appointments/screens/appointments_screen.dart';
  import '../../features/notifications/screens/notifications_screen.dart';
  import '../../features/profile/screens/profile_screen.dart';
  import '../../features/auth/screens/login_screen.dart';
  import '../../features/home/screens/home_screen.dart';
  import '../../features/auth/screens/register_screen.dart';
  import '../../features/booking/screens/booking_screen.dart';
  import '../../features/booking/screens/doctor_list_screen.dart';
  import '../../features/home/screens/services_screen.dart';
  import '../../features/services/screens/service_price_screen.dart';

  import '../../features/home/screens/main_navigation_screen.dart';
  import '../../features/home/screens/about_tab.dart';
  import '../../features/news/screens/home_screen.dart' as news_page;
  import '../../features/medical_records/screens/medical_records_screen.dart';
  import '../../features/invoices/screens/invoices_screen.dart';
  import '../../features/follow_ups/screens/follow_ups_screen.dart';

  /// ============================================================
  /// APP ROUTER - QUẢN LÝ ĐIỀU HƯỚNG TOÀN BỘ ỨNG DỤNG
  /// ============================================================
  /// Quy ước route:
  /// '/'               : Trang chủ
  /// '/news'           : Tin tức
  /// '/appointments'   : Lịch sử đặt khám
  /// '/notifications'  : Thông báo
  /// '/features'       : Chức năng
  /// '/profile'        : Cá nhân
  ///
  /// Khi tạo màn hình mới:
  /// 1. Import màn hình.
  /// 2. Khai báo route.
  /// 3. Thêm case trong onGenerateRoute.
  /// ============================================================

  class AppRouter {
    AppRouter._();

    // Tên route của từng màn hình.
    static const home = '/';
    static const login = '/login';
    static const register = '/register';
    static const news = '/news';
    static const appointments = '/appointments';
    static const notifications = '/notifications';
    static const features = '/features';
    static const profile = '/profile';
    static const patientHome = '/patient-home';
    static const booking = '/booking';
    static const doctors = '/doctors';
    static const services = '/services';
    static const about = '/about'; // trang giới thiệu
    static const String medicalRecords = '/medical-records'; // trang hosobenhan
    static const String invoices = '/invoices'; // trang thanhtoan
    static const String followUps = '/follow-ups';

    /// Xác định màn hình cần mở dựa trên tên route.
    static Route<dynamic> onGenerateRoute(RouteSettings settings) {
      switch (settings.name) {
        case AppRouter.home:
          // return MaterialPageRoute(
          //   settings: settings,
          //   builder: (_) => const NewsScreen(),
          // );
          return MaterialPageRoute(
            settings: settings,
            builder: (_) => const MainNavigationScreen(),
          );

        case login:
          return MaterialPageRoute(
            settings: settings,
            builder: (_) => const LoginScreen(),
          );

        case register:
          return MaterialPageRoute(
            settings: settings,
            builder: (_) => const RegisterScreen(),
          );

        case AppRouter.patientHome:
          return MaterialPageRoute(
            settings: settings,
            builder: (_) => const HomeScreen(),
          );

        case booking:
          return MaterialPageRoute(
            settings: settings,
            builder: (_) => const BookingScreen(),
          );

        case doctors:
          return MaterialPageRoute(
            settings: settings,
            builder: (_) => const DoctorListScreen(),
          );
        case news:
          return MaterialPageRoute(
            settings: settings,
            builder: (_) => const news_page.HomeScreen(),
          );
        case about:
          return MaterialPageRoute(
            settings: settings,
            builder: (_) => const AboutTab(),
          );

        case appointments:
          return MaterialPageRoute(
            settings: settings,
            builder: (_) => const AppointmentsScreen(),
          );

        case invoices:
          return MaterialPageRoute(
            settings: settings,
            builder: (_) => const InvoicesScreen(),
          );

        case followUps:
          return MaterialPageRoute(
            settings: settings,
            builder: (_) => const FollowUpsScreen(),
          ); 

        case notifications:
          return MaterialPageRoute(
            settings: settings,
            builder: (_) => const NotificationsScreen(),
          );

        case features:
          return MaterialPageRoute(
            settings: settings,
            builder: (_) => const FeaturesScreen(),
          );

        case services:
          return MaterialPageRoute(
            settings: settings,
            builder: (_) => const ServicePriceScreen(),
          );
        
        case medicalRecords:
          return MaterialPageRoute(
            settings: settings,
            builder: (_) => const MedicalRecordsScreen(),
          );
        case profile:
          return MaterialPageRoute(
            settings: settings,
            builder: (_) => const ProfileScreen(),
          );

        // Nếu route chưa được đăng ký, hiển thị trang báo lỗi
        // thay vì âm thầm chuyển người dùng về Trang chủ.
        default:
          return MaterialPageRoute(
            settings: settings,
            builder: (_) => Scaffold(
              appBar: AppBar(title: const Text('Không tìm thấy trang')),
              body: Center(
                child: Text(
                  'Route không tồn tại: ${settings.name ?? "không xác định"}',
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          );
      }
    }
  }

  // Màn hình tạm login
  class AuthPlaceholderScreen extends StatelessWidget {
    const AuthPlaceholderScreen({super.key, required this.title});

    final String title;

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(title: Text(title)),
        body: Center(
          child: Text(
            '$title\nMàn hình đang được phát triển.',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
  }
