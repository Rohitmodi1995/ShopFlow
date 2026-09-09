import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import '../../address/viewmodel/address_viewmodel.dart';
import '../../auth/emailverification/viewmodel/email_verification_viewmodel.dart';
import '../../auth/forgotpassword/viewmodel/forgot_password_viewmodel.dart';
import '../../auth/google/viewmodel/google_auth_viewmodel.dart';
import '../../auth/login/viewmodel/login_viewmodel.dart';
import '../../auth/signup/viewmodel/signup_viewmodel.dart';
import '../../cart/viewmodel/cart_viewmodel.dart';
import '../../categories/viewmodel/categories_viewmodel.dart';
import '../../home/viewmodel/home_viewmodel.dart';
import '../../notifications/viewmodel/notification_viewmodel.dart';
import '../../orders/viewmodel/order_viewmodel.dart';
import '../../payment/viewmodel/payment_viewmodel.dart';
import '../../productdetails/viewmodel/product_details_viewmodel.dart';
import '../../profile/viewmodel/profile_viewmodel.dart';
import '../../settings/help_support/viewmodel/help_support_viewmodel.dart';
import '../../settings/viewmodel/delete_account_viewmodel.dart';
import '../../settings/viewmodel/settings_viewmodel.dart';
import '../../splash/viewmodel/splash_viewmodel.dart';
import '../../wishlist/viewmodel/wishlist_viewmodel.dart';
import '../navigation/viewmodel/navigation_viewmodel.dart';
import '../network/viewmodel/network_viewmodel.dart';

class AppProviders {
  AppProviders._();

  static List<SingleChildWidget> get providers => [
    Provider<SplashViewModel>(create: (_) => SplashViewModel()),

    ChangeNotifierProvider<LoginViewModel>(create: (_) => LoginViewModel()),

    ChangeNotifierProvider<SignupViewModel>(create: (_) => SignupViewModel()),

    ChangeNotifierProvider<GoogleAuthViewModel>(
      create: (_) => GoogleAuthViewModel(),
    ),

    ChangeNotifierProvider<EmailVerificationViewModel>(
      create: (_) => EmailVerificationViewModel(),
    ),

    ChangeNotifierProvider<ForgotPasswordViewModel>(
      create: (_) => ForgotPasswordViewModel(),
    ),

    ChangeNotifierProvider<NetworkViewModel>(
      create: (_) => NetworkViewModel()..initialize(),
    ),

    ChangeNotifierProvider<HomeViewModel>(create: (_) => HomeViewModel()),

    ChangeNotifierProvider<NavigationViewModel>(
      create: (_) => NavigationViewModel(),
    ),

    ChangeNotifierProvider<ProductDetailsViewModel>(
      create: (_) => ProductDetailsViewModel(),
    ),

    ChangeNotifierProvider<WishlistViewModel>(
      create: (_) => WishlistViewModel(),
    ),

    ChangeNotifierProvider<CartViewModel>(create: (_) => CartViewModel()),

    ChangeNotifierProvider<CategoriesViewModel>(
      create: (_) => CategoriesViewModel(),
    ),

    ChangeNotifierProvider<AddressViewModel>(create: (_) => AddressViewModel()),

    ChangeNotifierProvider<OrderViewModel>(create: (_) => OrderViewModel()),

    ChangeNotifierProvider<PaymentViewModel>(create: (_) => PaymentViewModel()),

    ChangeNotifierProvider<ProfileViewModel>(create: (_) => ProfileViewModel()),

    ChangeNotifierProvider<SettingsViewModel>(
      create: (_) => SettingsViewModel()..initialize(),
    ),

    ChangeNotifierProvider<DeleteAccountViewModel>(
      create: (_) => DeleteAccountViewModel(),
    ),

    ChangeNotifierProvider<NotificationViewModel>(
      create: (_) => NotificationViewModel(),
    ),

    ChangeNotifierProvider<HelpSupportViewModel>(
      create: (_) => HelpSupportViewModel(),
    ),
  ];
}
