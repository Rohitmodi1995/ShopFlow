import 'package:flutter/material.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_languages.dart';
import '../repository/support_repository.dart';

class HelpSupportViewModel extends ChangeNotifier {
  final SupportRepository _supportRepository;

  HelpSupportViewModel({SupportRepository? supportRepository})
    : _supportRepository = supportRepository ?? SupportRepository();

  static const String _orderIssue = 'order';
  static const String _paymentIssue = 'payment';
  static const String _accountIssue = 'account';
  static const String _deliveryIssue = 'delivery';
  static const String _otherIssue = 'other';

  final List<String> issueTypes = const [
    _orderIssue,
    _paymentIssue,
    _accountIssue,
    _deliveryIssue,
    _otherIssue,
  ];

  String _selectedIssueType = _orderIssue;
  bool _isLoading = false;
  String? _errorMessage;
  String? _ticketId;

  String get selectedIssueType => _selectedIssueType;

  bool get isLoading => _isLoading;

  String? get errorMessage => _errorMessage;

  String? get ticketId => _ticketId;

  String getIssueTypeLabel(String issueType) {
    switch (issueType) {
      case _orderIssue:
        return AppLanguage.orderIssue[AppConstant.language];

      case _paymentIssue:
        return AppLanguage.paymentIssue[AppConstant.language];

      case _accountIssue:
        return AppLanguage.accountIssue[AppConstant.language];

      case _deliveryIssue:
        return AppLanguage.deliveryIssue[AppConstant.language];

      case _otherIssue:
        return AppLanguage.otherIssue[AppConstant.language];

      default:
        return issueType;
    }
  }

  void changeIssueType(String? value) {
    if (value == null ||
        value == _selectedIssueType ||
        !issueTypes.contains(value)) {
      return;
    }

    _selectedIssueType = value;
    _errorMessage = null;

    notifyListeners();
  }

  Future<bool> submitSupportRequest({
    required String name,
    required String email,
    required String message,
  }) async {
    if (_isLoading) {
      return false;
    }

    _setLoading(true);

    _errorMessage = null;
    _ticketId = null;

    try {
      _ticketId = await _supportRepository.submitSupportRequest(
        name: name.trim(),
        email: email.trim(),
        issueType: _selectedIssueType,
        message: message.trim(),
      );

      return true;
    } catch (_) {
      _errorMessage =
          AppLanguage.unableToSubmitSupportRequestError[AppConstant.language];

      return false;
    } finally {
      _setLoading(false);
    }
  }

  void resetForm() {
    _selectedIssueType = _orderIssue;
    _errorMessage = null;
    _ticketId = null;

    notifyListeners();
  }

  void clearError() {
    if (_errorMessage == null) {
      return;
    }

    _errorMessage = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    if (_isLoading == value) {
      return;
    }

    _isLoading = value;
    notifyListeners();
  }
}
