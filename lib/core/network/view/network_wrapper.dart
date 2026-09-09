import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../viewmodel/network_viewmodel.dart';

class NetworkWrapper extends StatelessWidget {
  final Widget child;

  const NetworkWrapper({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Selector<NetworkViewModel, bool>(
      selector: (_, viewModel) => viewModel.isConnected,
      builder: (context, isConnected, _) {
        return Stack(
          children: [
            child,

            if (!isConnected)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: SafeArea(
                  child: Material(
                    child: Container(
                      width: double.infinity,
                      color: Colors.red,
                      padding: const EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 16,
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.wifi_off_rounded,
                            size: 18,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'No internet connection',
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}