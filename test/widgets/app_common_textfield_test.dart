import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shopflow/core/components/app_common_textfield.dart';

void main() {
  Widget createWidget({
    required TextEditingController controller,
    String hintText = 'Enter Email',
    bool readOnly = false,
    bool obscureText = false,
    String? Function(String?)? validator,
    Widget? prefixIcon,
    Widget? suffixIcon,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: Form(
          child: CustomTextField(
            controller: controller,
            hintText: hintText,
            readOnly: readOnly,
            obscureText: obscureText,
            validator: validator,
            prefixIcon: prefixIcon,
            suffixIcon: suffixIcon,
          ),
        ),
      ),
    );
  }

  group('CustomTextField Widget Tests', () {
    testWidgets(
      'should display hint text',
      (tester) async {
        final controller = TextEditingController();

        await tester.pumpWidget(
          createWidget(
            controller: controller,
          ),
        );

        expect(
          find.text('Enter Email'),
          findsOneWidget,
        );

        controller.dispose();
      },
    );

    testWidgets(
      'should accept entered text',
      (tester) async {
        final controller = TextEditingController();

        await tester.pumpWidget(
          createWidget(
            controller: controller,
          ),
        );

        await tester.enterText(
          find.byType(TextFormField),
          'test@example.com',
        );

        await tester.pump();

        expect(
          controller.text,
          'test@example.com',
        );

        expect(
          find.text('test@example.com'),
          findsOneWidget,
        );

        controller.dispose();
      },
    );

    testWidgets(
      'should be read only when readOnly is true',
      (tester) async {
        final controller = TextEditingController(
          text: 'Existing Text',
        );

        await tester.pumpWidget(
          createWidget(
            controller: controller,
            readOnly: true,
          ),
        );

        final editableText = tester.widget<EditableText>(
          find.byType(EditableText),
        );

        expect(
          editableText.readOnly,
          true,
        );

        expect(
          controller.text,
          'Existing Text',
        );

        controller.dispose();
      },
    );

    testWidgets(
      'should obscure text when obscureText is true',
      (tester) async {
        final controller = TextEditingController();

        await tester.pumpWidget(
          createWidget(
            controller: controller,
            obscureText: true,
          ),
        );

        final editableText = tester.widget<EditableText>(
          find.byType(EditableText),
        );

        expect(
          editableText.obscureText,
          true,
        );

        controller.dispose();
      },
    );

    testWidgets(
      'should show validation error',
      (tester) async {
        final controller = TextEditingController();
        final formKey = GlobalKey<FormState>();

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Form(
                key: formKey,
                child: CustomTextField(
                  controller: controller,
                  hintText: 'Enter Email',
                  validator: (value) {
                    if (value == null ||
                        value.trim().isEmpty) {
                      return 'Email is required';
                    }

                    return null;
                  },
                ),
              ),
            ),
          ),
        );

        formKey.currentState?.validate();

        await tester.pump();

        expect(
          find.text('Email is required'),
          findsOneWidget,
        );

        controller.dispose();
      },
    );
  });
}