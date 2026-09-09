import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shopflow/core/components/app_common_button.dart';

void main() {
  Widget createWidget({
    required VoidCallback? onPressed,
    String title = 'Login',
    IconData? icon,
    bool isOutlined = false,
    bool isLoading = false,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: AppCommonButton(
          title: title,
          onPressed: onPressed,
          icon: icon,
          isOutlined: isOutlined,
          isLoading: isLoading,
        ),
      ),
    );
  }

  group('AppCommonButton Widget Tests', () {
    testWidgets(
      'should display button title',
      (tester) async {
        await tester.pumpWidget(
          createWidget(
            onPressed: () {},
          ),
        );

        expect(
          find.text('Login'),
          findsOneWidget,
        );

        expect(
          find.byType(ElevatedButton),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'should call onPressed when button is tapped',
      (tester) async {
        var wasPressed = false;

        await tester.pumpWidget(
          createWidget(
            onPressed: () {
              wasPressed = true;
            },
          ),
        );

        await tester.tap(
          find.byType(ElevatedButton),
        );

        await tester.pump();

        expect(
          wasPressed,
          true,
        );
      },
    );

    testWidgets(
      'should show loading indicator and disable button when loading',
      (tester) async {
        var pressCount = 0;

        await tester.pumpWidget(
          createWidget(
            isLoading: true,
            onPressed: () {
              pressCount++;
            },
          ),
        );

        expect(
          find.byType(
            CircularProgressIndicator,
          ),
          findsOneWidget,
        );

        expect(
          find.text('Login'),
          findsNothing,
        );

        final button = tester.widget<ElevatedButton>(
          find.byType(ElevatedButton),
        );

        expect(
          button.onPressed,
          isNull,
        );

        await tester.tap(
          find.byType(ElevatedButton),
        );

        await tester.pump();

        expect(
          pressCount,
          0,
        );
      },
    );

    testWidgets(
      'should display outlined button with icon',
      (tester) async {
        await tester.pumpWidget(
          createWidget(
            title: 'Edit Profile',
            icon: Icons.edit_outlined,
            isOutlined: true,
            onPressed: () {},
          ),
        );

        expect(
          find.byType(OutlinedButton),
          findsOneWidget,
        );

        expect(
          find.byType(ElevatedButton),
          findsNothing,
        );

        expect(
          find.text('Edit Profile'),
          findsOneWidget,
        );

        expect(
          find.byIcon(Icons.edit_outlined),
          findsOneWidget,
        );
      },
    );
  });
}