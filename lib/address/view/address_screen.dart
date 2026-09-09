import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../checkout/model/checkout_data.dart';
import '../../checkout/model/order_summary_arguments.dart';
import '../../core/components/app_common_button.dart';
import '../../core/components/app_common_header.dart';
import '../../core/components/shimmer/address_shimmer.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/app_languages.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/routes/app_routes.dart';
import '../model/address_model.dart';
import '../viewmodel/address_viewmodel.dart';
import 'add_edit_address_screen.dart';

class AddressScreen extends StatefulWidget {
  final bool isCheckout;
  final CheckoutData? checkoutData;

  const AddressScreen({
    super.key,
    this.isCheckout = false,
    this.checkoutData,
  });

  @override
  State<AddressScreen> createState() =>
      _AddressScreenState();
}

class _AddressScreenState
    extends State<AddressScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        if (!mounted) {
          return;
        }

        context
            .read<AddressViewModel>()
            .loadAddresses();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark =
        theme.brightness == Brightness.dark;

    final backgroundColor = isDark
        ? colorScheme.surface
        : AppColors.whiteColor;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppCommonHeader(
        title: widget.isCheckout
            ? AppLanguage
                    .selectDeliveryAddress[
                AppConstant.language]
            : AppLanguage.myAddresses[
                AppConstant.language],
      ),
      body: SafeArea(
        child: Consumer<AddressViewModel>(
          builder: (
            context,
            viewModel,
            child,
          ) {
            if (viewModel.isLoading) {
              return const AddressShimmer();
            }

            if (viewModel.errorMessage != null &&
                viewModel.addresses.isEmpty) {
              return _buildErrorView(
                context,
                viewModel,
              );
            }

            if (viewModel.addresses.isEmpty) {
              return _buildEmptyView(
                context,
              );
            }

            return RadioGroup<String>(
              groupValue:
                  viewModel.selectedAddressId,
              onChanged: (value) {
                if (value == null) {
                  return;
                }

                viewModel.selectAddress(value);
              },
              child: Center(
                child: ConstrainedBox(
                  constraints:
                      const BoxConstraints(
                    maxWidth: 800,
                  ),
                  child: RefreshIndicator(
                    onRefresh:
                        viewModel.loadAddresses,
                    child: ListView.separated(
                      physics:
                          const AlwaysScrollableScrollPhysics(),
                      padding:
                          const EdgeInsets.all(
                        AppSpacing.md,
                      ),
                      itemCount:
                          viewModel.addresses
                                  .length +
                              1,
                      separatorBuilder: (
                        context,
                        index,
                      ) {
                        return const SizedBox(
                          height:
                              AppSpacing.sm,
                        );
                      },
                      itemBuilder: (
                        context,
                        index,
                      ) {
                        if (index ==
                            viewModel
                                .addresses.length) {
                          return _buildAddButton(
                            context,
                          );
                        }

                        final address =
                            viewModel
                                .addresses[index];

                        return _buildAddressCard(
                          context,
                          viewModel,
                          address,
                        );
                      },
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
      bottomNavigationBar:
          widget.isCheckout
              ? _buildCheckoutButton()
              : null,
    );
  }

  Widget _buildCheckoutButton() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark =
        theme.brightness == Brightness.dark;

    return Consumer<AddressViewModel>(
      builder: (
        context,
        viewModel,
        child,
      ) {
        final selectedAddress =
            viewModel.selectedAddress;

        return Material(
          color: isDark
              ? colorScheme.surface
              : AppColors.whiteColor,
          child: SafeArea(
            top: false,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: isDark
                        ? colorScheme.onSurface
                            .withValues(
                              alpha: 0.12,
                            )
                        : AppColors.inputBorder,
                  ),
                ),
              ),
              padding: const EdgeInsets.all(
                AppSpacing.md,
              ),
              child: Align(
                alignment: Alignment.center,
                heightFactor: 1,
                child: ConstrainedBox(
                  constraints:
                      const BoxConstraints(
                    maxWidth: 800,
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    child: AppCommonButton(
                      title: AppLanguage
                              .deliverToThisAddress[
                          AppConstant.language],
                      onPressed:
                          selectedAddress ==
                                      null ||
                                  viewModel
                                      .isLoading
                              ? null
                              : () {
                                  _continueCheckout(
                                    selectedAddress,
                                  );
                                },
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAddressCard(
    BuildContext context,
    AddressViewModel viewModel,
    AddressModel address,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark =
        theme.brightness == Brightness.dark;

    final isSelected =
        viewModel.selectedAddressId ==
            address.id;

    final cardColor = isDark
        ? colorScheme.surfaceContainer
        : AppColors.whiteColor;

    final borderColor = isSelected
        ? colorScheme.primary
        : isDark
            ? colorScheme.onSurface
                .withValues(
                  alpha: 0.16,
                )
            : AppColors.inputBorder;

    return Card(
      margin: EdgeInsets.zero,
      elevation: isSelected ? 3 : 1,
      color: cardColor,
      surfaceTintColor:
          Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(12),
        side: BorderSide(
          color: borderColor,
          width: isSelected ? 1.3 : 1,
        ),
      ),
      child: InkWell(
        borderRadius:
            BorderRadius.circular(12),
        onTap: () {
          viewModel.selectAddress(
            address.id,
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(
            AppSpacing.md,
          ),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Radio<String>(
                    value: address.id,
                  ),
                  Expanded(
                    child: Text(
                      address.name,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight:
                            FontWeight.w600,
                        color: colorScheme
                            .onSurface,
                      ),
                    ),
                  ),
                  if (address.isDefault)
                    Container(
                      padding:
                          const EdgeInsets
                              .symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration:
                          BoxDecoration(
                        color: colorScheme
                            .primary
                            .withValues(
                              alpha: 0.10,
                            ),
                        borderRadius:
                            BorderRadius
                                .circular(
                          20,
                        ),
                      ),
                      child: Text(
                        AppLanguage
                                .defaultText[
                            AppConstant
                                .language],
                        style: TextStyle(
                          fontSize: 12,
                          color: colorScheme
                              .primary,
                          fontWeight:
                              FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(
                height: AppSpacing.sm,
              ),
              Text(
                address.phone,
                style: TextStyle(
                  fontSize: 14,
                  color:
                      colorScheme.onSurface,
                ),
              ),
              const SizedBox(
                height: AppSpacing.xs,
              ),
              Text(
                _getFullAddress(address),
                style: TextStyle(
                  fontSize: 14,
                  height: 1.4,
                  color: colorScheme
                      .onSurface
                      .withValues(
                        alpha: 0.70,
                      ),
                ),
              ),
              const SizedBox(
                height: AppSpacing.md,
              ),
              Row(
                children: [
                  TextButton.icon(
                    onPressed: () {
                      _openEditAddress(
                        context,
                        address,
                      );
                    },
                    icon: const Icon(
                      Icons.edit_outlined,
                      size: 18,
                    ),
                    label: Text(
                      AppLanguage.edit[
                          AppConstant
                              .language],
                    ),
                  ),
                  const SizedBox(
                    width: AppSpacing.xs,
                  ),
                  TextButton.icon(
                    onPressed: () {
                      _showDeleteDialog(
                        context,
                        address,
                      );
                    },
                    icon: const Icon(
                      Icons.delete_outline,
                      size: 18,
                    ),
                    label: Text(
                      AppLanguage.delete[
                          AppConstant
                              .language],
                    ),
                  ),
                  const Spacer(),
                  if (!address.isDefault)
                    TextButton(
                      onPressed:
                          viewModel.isSaving
                              ? null
                              : () async {
                                  await viewModel
                                      .setDefaultAddress(
                                    address.id,
                                  );
                                },
                      child: Text(
                        AppLanguage
                                .setDefault[
                            AppConstant
                                .language],
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyView(
    BuildContext context,
  ) {
    final colorScheme =
        Theme.of(context).colorScheme;

    return Center(
      child: ConstrainedBox(
        constraints:
            const BoxConstraints(
          maxWidth: 500,
        ),
        child: Padding(
          padding: const EdgeInsets.all(
            AppSpacing.lg,
          ),
          child: Column(
            mainAxisAlignment:
                MainAxisAlignment.center,
            children: [
              Icon(
                Icons.location_on_outlined,
                size: 70,
                color: colorScheme.primary,
              ),
              const SizedBox(
                height: AppSpacing.md,
              ),
              Text(
                AppLanguage.noAddressesAdded[
                    AppConstant.language],
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight:
                      FontWeight.w600,
                  color:
                      colorScheme.onSurface,
                ),
              ),
              const SizedBox(
                height: AppSpacing.sm,
              ),
              Text(
                AppLanguage
                        .addDeliveryAddressDescription[
                    AppConstant.language],
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: colorScheme
                      .onSurface
                      .withValues(
                        alpha: 0.65,
                      ),
                ),
              ),
              const SizedBox(
                height: AppSpacing.lg,
              ),
              AppCommonButton(
                title: AppLanguage
                        .addAddress[
                    AppConstant.language],
                onPressed: () {
                  _openAddAddress(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorView(
    BuildContext context,
    AddressViewModel viewModel,
  ) {
    final colorScheme =
        Theme.of(context).colorScheme;

    return Center(
      child: ConstrainedBox(
        constraints:
            const BoxConstraints(
          maxWidth: 500,
        ),
        child: Padding(
          padding: const EdgeInsets.all(
            AppSpacing.lg,
          ),
          child: Column(
            mainAxisAlignment:
                MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 60,
                color: colorScheme.error,
              ),
              const SizedBox(
                height: AppSpacing.md,
              ),
              Text(
                viewModel.errorMessage ??
                    AppLanguage
                            .somethingWentWrong[
                        AppConstant.language],
                textAlign: TextAlign.center,
                style: TextStyle(
                  color:
                      colorScheme.onSurface,
                ),
              ),
              const SizedBox(
                height: AppSpacing.lg,
              ),
              AppCommonButton(
                title: AppLanguage.retry[
                    AppConstant.language],
                icon: Icons.refresh,
                onPressed: () {
                  viewModel.loadAddresses();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAddButton(
    BuildContext context,
  ) {
    return AppCommonButton(
      title: AppLanguage.addNewAddress[
          AppConstant.language],
      isOutlined: true,
      onPressed: () {
        _openAddAddress(context);
      },
    );
  }

  String _getFullAddress(
    AddressModel address,
  ) {
    return '${address.house}, '
        '${address.street}, '
        '${address.city}, '
        '${address.state} - '
        '${address.pincode}';
  }

  Future<void> _openAddAddress(
    BuildContext context,
  ) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            const AddEditAddressScreen(),
      ),
    );
  }

  Future<void> _openEditAddress(
    BuildContext context,
    AddressModel address,
  ) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            AddEditAddressScreen(
          address: address,
        ),
      ),
    );
  }

  Future<void> _showDeleteDialog(
    BuildContext context,
    AddressModel address,
  ) async {
    final shouldDelete =
        await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        final colorScheme =
            Theme.of(dialogContext)
                .colorScheme;

        return AlertDialog(
          backgroundColor:
              colorScheme.surface,
          surfaceTintColor:
              Colors.transparent,
          title: Text(
            AppLanguage.deleteAddress[
                AppConstant.language],
            style: TextStyle(
              color:
                  colorScheme.onSurface,
            ),
          ),
          content: Text(
            AppLanguage
                    .deleteAddressConfirmation[
                AppConstant.language],
            style: TextStyle(
              color: colorScheme.onSurface
                  .withValues(
                    alpha: 0.75,
                  ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  false,
                );
              },
              child: Text(
                AppLanguage.cancel[
                    AppConstant.language],
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  true,
                );
              },
              child: Text(
                AppLanguage.delete[
                    AppConstant.language],
                style: TextStyle(
                  color:
                      colorScheme.error,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true ||
        !context.mounted) {
      return;
    }

    final success = await context
        .read<AddressViewModel>()
        .deleteAddress(address);

    if (!context.mounted) {
      return;
    }

    if (!success) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              AppLanguage
                      .unableToDeleteAddress[
                  AppConstant.language],
            ),
          ),
        );
    }
  }

  void _continueCheckout(
    AddressModel address,
  ) {
    final checkoutData =
        widget.checkoutData;

    if (checkoutData == null) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              AppLanguage
                      .checkoutDataNotAvailable[
                  AppConstant.language],
            ),
          ),
        );

      return;
    }

    Navigator.pushNamed(
      context,
      AppRoutes.orderSummary,
      arguments:
          OrderSummaryArguments(
        address: address,
        checkoutData: checkoutData,
      ),
    );
  }
}