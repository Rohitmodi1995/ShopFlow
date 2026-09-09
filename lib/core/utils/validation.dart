import 'package:shopflow/core/constants/app_constants.dart';
import 'package:shopflow/core/constants/app_languages.dart';

mixin ValidationClass {
  String? validateName(String? value) {
    final fullName = value?.trim();

    if (fullName == null || fullName.isEmpty) {
      return AppLanguage.fullnameValidation[AppConstant.language];
    }

    return null;
  }

  String? validateEmail(String? value) {
    final email = value?.trim();

    if (email == null || email.isEmpty) {
      return AppLanguage.emailaddressValidation[AppConstant.language];
    }

    if (!AppConstant.emailRegex.hasMatch(email)) {
      return AppLanguage.validemailaddressValidation[AppConstant.language];
    }

    return null;
  }

  String? validatePassword(String? value) {
    final password = value?.trim();

    if (password == null || password.isEmpty) {
      return AppLanguage.passwordValidation[AppConstant.language];
    }

    if (password.length < 6) {
      return AppLanguage.passwordmustbeatleastValidation[AppConstant.language];
    }

    return null;
  }

  String? validateNewPassword(String? currentPassword, String? newPassword) {
    final passwordValidation = validatePassword(newPassword);

    if (passwordValidation != null) {
      return passwordValidation;
    }

    if (currentPassword?.trim() == newPassword?.trim()) {
      return AppLanguage.newPasswordMustBeDifferentValidation[AppConstant
          .language];
    }

    return null;
  }

  String? validateConfirmPassword(String? password, String? confirmPassword) {
    final confirm = confirmPassword?.trim();

    if (confirm == null || confirm.isEmpty) {
      return AppLanguage.confirmpasswordValidation[AppConstant.language];
    }

    if (password?.trim() != confirm) {
      return AppLanguage.passwordsdonotmatchValidation[AppConstant.language];
    }

    return null;
  }

  String? validateMessage(String? value) {
    final message = value?.trim();

    if (message == null || message.isEmpty) {
      return AppLanguage.describeyourproblemValidation[AppConstant.language];
    }

    if (message.length < 10) {
      return AppLanguage.atleastcharactersValidation[AppConstant.language];
    }

    return null;
  }

  String? validateDeleteAccountReason(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppLanguage.reasonfordeletingyourAccount[AppConstant.language];
    }

    return null;
  }
}
