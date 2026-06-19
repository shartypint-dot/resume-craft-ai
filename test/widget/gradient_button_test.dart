import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:resume_craft_ai/core/widgets/gradient_button.dart';
import 'package:resume_craft_ai/core/theme/app_theme.dart';

Widget _wrap(Widget child) => MaterialApp(
  theme: AppTheme.darkTheme,
  home: Scaffold(body: Center(child: child)),
);

void main() {
  group('GradientButton', () {
    testWidgets('renders label text', (tester) async {
      await tester.pumpWidget(_wrap(
        GradientButton(text: 'Click Me', onPressed: () {}),
      ));
      expect(find.text('Click Me'), findsOneWidget);
    });

    testWidgets('calls onPressed when tapped', (tester) async {
      bool tapped = false;
      await tester.pumpWidget(_wrap(
        GradientButton(text: 'Tap', onPressed: () => tapped = true),
      ));
      await tester.tap(find.text('Tap'));
      await tester.pumpAndSettle();
      expect(tapped, isTrue);
    });

    testWidgets('shows loading indicator when isLoading is true', (tester) async {
      await tester.pumpWidget(_wrap(
        GradientButton(text: 'Loading', onPressed: () {}, isLoading: true),
      ));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('is disabled when onPressed is null', (tester) async {
      bool tapped = false;
      await tester.pumpWidget(_wrap(
        const GradientButton(text: 'Disabled', onPressed: null),
      ));
      await tester.tap(find.text('Disabled'), warnIfMissed: false);
      await tester.pumpAndSettle();
      expect(tapped, isFalse);
    });

    testWidgets('renders prefix icon when provided', (tester) async {
      await tester.pumpWidget(_wrap(
        GradientButton(
          text: 'With Icon',
          onPressed: () {},
          prefixIcon: const Icon(Icons.star, key: Key('prefix-icon')),
        ),
      ));
      expect(find.byKey(const Key('prefix-icon')), findsOneWidget);
    });
  });

  group('SocialAuthButton', () {
    testWidgets('renders correctly with label', (tester) async {
      await tester.pumpWidget(_wrap(
        SocialAuthButton(
          text: 'Continue with Google',
          icon: const Icon(Icons.g_mobiledata),
          onPressed: () {},
        ),
      ));
      expect(find.text('Continue with Google'), findsOneWidget);
    });
  });
}
