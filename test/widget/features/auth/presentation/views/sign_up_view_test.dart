import 'package:zedu/core/core.dart';
import 'package:zedu/features/features.dart';
import '../../../../../helpers/helpers.dart';

Widget buildSignUpViewUnderTest() {
  return const ProviderScope(
    child: MaterialApp(home: SignUpView()),
  );
}

void main() {
  group('SignUpView', () {
    testWidgets('renders correct legal consent text without capitalized "Signing"', (
      tester,
    ) async {
      await tester.pumpWidget(buildSignUpViewUnderTest());
      await tester.pump();

      expect(
        find.textContaining('By signing up, you agree to our '),
        findsOneWidget,
      );
      expect(
        find.textContaining('By Signing up'),
        findsNothing,
      );
      expect(
        find.text('Terms of Service'),
        findsOneWidget,
      );
      expect(
        find.text('Privacy Policy'),
        findsOneWidget,
      );
    });
  });
}
