import 'package:flutter/material.dart';

import '../../address/view/address_screen.dart';
import '../../auth/emailverification/view/email_verification_screen.dart';
import '../../auth/forgotpassword/view/forgot_password_screen.dart';
import '../../auth/login/view/login_screen.dart';
import '../../auth/signup/view/signup_screen.dart';
import '../../cart/view/cart_screen.dart';
import '../../checkout/model/order_summary_arguments.dart';
import '../../checkout/view/order_summary_screen.dart';
import '../../home/model/product_model.dart';
import '../../notifications/view/notifications_screen.dart';
import '../../orders/model/order_argument.dart';
import '../../orders/model/order_summary_argument.dart';
import '../../orders/view/my_orders_screen.dart';
import '../../orders/view/order_details_screen.dart';
import '../../orders/view/order_success_screen.dart';
import '../../productdetails/view/product_details_screen.dart';
import '../../profile/view/edit_profile_screen.dart';
import '../../profile/view/profile_screen.dart';
import '../../settings/help_support/view/help_support_screen.dart';
import '../../settings/view/about_us_screen.dart';
import '../../settings/view/change_password_screen.dart';
import '../../settings/view/delete_account_screen.dart';
import '../../settings/view/payment_methods_screen.dart';
import '../../settings/view/privacy_policy_screen.dart';
import '../../settings/view/settings_screen.dart';
import '../../settings/view/terms_conditions_screen.dart';
import '../../splash/splash_screen.dart';
import '../navigation/view/main_navigation_screen.dart';

class AppRoutes {
  AppRoutes._();

  static const String splash = '/';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String emailVerification = '/email-verification';
  static const String forgotPassword = '/forgot-password';
  static const String home = '/home';
  static const String productDetails = '/product-details';
  static const String cart = '/cart';
  static const String address = '/address';
  static const String orderSummary = '/order-summary';
  static const String payment = '/payment';
  static const String orderSuccess = '/order-success';
  static const String myOrders = '/my-orders';
  static const String orderDetails = '/order-details';
  static const String profile = '/profile';
  static const String editProfile = '/edit-profile';
  static const String setting = '/setting';
  static const String changePassword = '/change-password';
  static const String privacyPolicy = '/privacy-policy';
  static const String termsConditions = '/terms-conditions';
  static const String aboutUs = '/about-us';
  static const String paymentMethods = '/payment-methods';
  static const String helpSupport = '/help-support';
  static const String notifications = '/notifications';
  static const String deleteAccount = '/delete-account';

  static Route<dynamic> generateRoute(
    RouteSettings settings,
  ) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(
          builder: (_) => const SplashScreen(),
        );

      case login:
        return MaterialPageRoute(
          builder: (_) => const LoginScreen(),
        );

      case signup:
        return MaterialPageRoute(
          builder: (_) => const SignupScreen(),
        );

      case emailVerification:
        final email = settings.arguments as String?;

        if (email == null || email.isEmpty) {
          return _routeNotFound();
        }

        return MaterialPageRoute(
          builder: (_) => EmailVerificationScreen(
            email: email,
          ),
        );

      case forgotPassword:
        return MaterialPageRoute(
          builder: (_) => const ForgotPasswordScreen(),
        );

      case home:
        return MaterialPageRoute(
          builder: (_) => const MainNavigationScreen(),
        );

      case productDetails:
        final arguments = settings.arguments;

        if (arguments is! ProductModel) {
          return _routeNotFound();
        }

        return MaterialPageRoute(
          builder: (_) => ProductDetailsScreen(
            product: arguments,
          ),
        );

      case cart:
        return MaterialPageRoute(
          builder: (_) => const CartScreen(),
        );

      case address:
        return MaterialPageRoute(
          builder: (_) => const AddressScreen(
            isCheckout: true,
          ),
        );

      case orderSummary:
        final arguments = settings.arguments;

        if (arguments is! OrderSummaryArguments) {
          return _routeNotFound();
        }

        return MaterialPageRoute(
          builder: (_) => OrderSummaryScreen(
            address: arguments.address,
            checkoutData: arguments.checkoutData,
          ),
        );

      case orderSuccess:
        final arguments = settings.arguments;

        if (arguments is! OrderSuccessArguments) {
          return _routeNotFound();
        }

        return MaterialPageRoute(
          builder: (context) => OrderSuccessScreen(
            orderId: arguments.orderId,
            amount: arguments.amount,
            onContinue: () {
              Navigator.pushNamedAndRemoveUntil(
                context,
                AppRoutes.myOrders,
                (route) => route.isFirst,
              );
            },
          ),
        );

      case myOrders:
        return MaterialPageRoute(
          builder: (_) => const MyOrdersScreen(),
        );

      case orderDetails:
        final arguments = settings.arguments;

        if (arguments is! OrderDetailsArguments) {
          return _routeNotFound();
        }

        return MaterialPageRoute(
          builder: (_) => OrderDetailsScreen(
            order: arguments.order,
          ),
        );

      case profile:
        return MaterialPageRoute(
          builder: (_) => const ProfileScreen(),
        );

      case editProfile:
        return MaterialPageRoute(
          builder: (_) => const EditProfileScreen(),
        );

      case setting:
        return MaterialPageRoute(
          builder: (_) => const SettingsScreen(),
        );

      case changePassword:
        return MaterialPageRoute(
          builder: (_) => const ChangePasswordScreen(),
        );

      case deleteAccount:
        return MaterialPageRoute(
          builder: (_) => const DeleteAccountScreen(),
        );

      case privacyPolicy:
        return MaterialPageRoute(
          builder: (_) => const PrivacyPolicyScreen(),
        );

      case termsConditions:
        return MaterialPageRoute(
          builder: (_) => const TermsConditionsScreen(),
        );

      case aboutUs:
        return MaterialPageRoute(
          builder: (_) => AboutUsScreen(),
        );

      case paymentMethods:
        return MaterialPageRoute(
          builder: (_) => PaymentMethodsScreen(),
        );

      case helpSupport:
        return MaterialPageRoute(
          builder: (_) => HelpSupportScreen(),
        );

      case notifications:
        return MaterialPageRoute(
          builder: (_) => const NotificationsScreen(),
        );

      default:
        return _routeNotFound();
    }
  }

  static Route<dynamic> _routeNotFound() {
    return MaterialPageRoute(
      builder: (_) => const Scaffold(
        body: Center(
          child: Text('Route Not Found'),
        ),
      ),
    );
  }
}