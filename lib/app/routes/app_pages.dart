import 'package:get/get.dart';
import 'app_routes.dart';
import '../views/auth/login_view.dart';
import '../views/dashboard/dashboard_view.dart';
import '../views/restaurants/restaurant_list_view.dart';
import '../views/restaurants/restaurant_form_view.dart';
import '../views/orders/order_list_view.dart';
import '../views/users/user_list_view.dart';
import '../views/content/banner_list_view.dart';
import '../views/content/cuisine_list_view.dart';
import '../views/content/facility_list_view.dart';
import '../views/menus/menu_list_view.dart';
import '../views/surprise_bags/surprise_bag_list_view.dart';
import '../views/surprise_bags/surprise_bag_form_view.dart';
import '../views/faqs/faq_list_view.dart';
import '../views/payouts/payout_list_view.dart';
import '../views/payment_gateways/payment_gateway_list_view.dart';
import '../views/bookings/booking_list_view.dart';
import '../views/gallery/gallery_list_view.dart';
import '../views/settings/settings_view.dart';
import '../bindings/initial_binding.dart';

class AppPages {
  static const initial = AppRoutes.login;

  static final routes = [
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginView(),
      binding: InitialBinding(),
    ),
    GetPage(
      name: AppRoutes.dashboard,
      page: () => const DashboardView(),
      binding: InitialBinding(),
    ),
    GetPage(
      name: AppRoutes.restaurants,
      page: () => const RestaurantListView(),
      binding: InitialBinding(),
    ),
    GetPage(
      name: AppRoutes.addRestaurant,
      page: () => const RestaurantFormView(),
      binding: InitialBinding(),
    ),
    GetPage(
      name: AppRoutes.editRestaurant,
      page: () => const RestaurantFormView(isEdit: true),
      binding: InitialBinding(),
    ),
    GetPage(
      name: AppRoutes.orders,
      page: () => const OrderListView(),
      binding: InitialBinding(),
    ),
    GetPage(
      name: AppRoutes.users,
      page: () => const UserListView(),
      binding: InitialBinding(),
    ),
    GetPage(
      name: AppRoutes.banners,
      page: () => const BannerListView(),
      binding: InitialBinding(),
    ),
    GetPage(
      name: AppRoutes.cuisines,
      page: () => const CuisineListView(),
      binding: InitialBinding(),
    ),
    GetPage(
      name: AppRoutes.facilities,
      page: () => const FacilityListView(),
      binding: InitialBinding(),
    ),
    GetPage(
      name: AppRoutes.menus,
      page: () => const MenuListView(),
      binding: InitialBinding(),
    ),
    GetPage(
      name: AppRoutes.surpriseBags,
      page: () => const SurpriseBagListView(),
      binding: InitialBinding(),
    ),
    GetPage(
      name: AppRoutes.addSurpriseBag,
      page: () => const SurpriseBagFormView(),
      binding: InitialBinding(),
    ),
    GetPage(
      name: AppRoutes.editSurpriseBag,
      page: () => const SurpriseBagFormView(),
      binding: InitialBinding(),
    ),
    GetPage(
      name: AppRoutes.faqs,
      page: () => const FaqListView(),
      binding: InitialBinding(),
    ),
    GetPage(
      name: AppRoutes.payouts,
      page: () => const PayoutListView(),
      binding: InitialBinding(),
    ),
    GetPage(
      name: AppRoutes.paymentGateways,
      page: () => const PaymentGatewayListView(),
      binding: InitialBinding(),
    ),
    GetPage(
      name: AppRoutes.bookings,
      page: () => const BookingListView(),
      binding: InitialBinding(),
    ),
    GetPage(
      name: AppRoutes.galleries,
      page: () => const GalleryListView(),
      binding: InitialBinding(),
    ),
    GetPage(
      name: AppRoutes.settings,
      page: () => const SettingsView(),
      binding: InitialBinding(),
    ),
  ];
}
