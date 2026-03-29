import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dg_app_partner/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    // We wrap it in ProviderScope because DgPartnerApp is a ConsumerWidget.
    await tester.pumpWidget(
      const ProviderScope(
        child: DgPartnerApp(),
      ),
    );

    // Since the app starts with a Splash screen or Login screen (via GoRouter),
    // and might involve Supabase initialization which isn't mocked here,
    // we just check that the widget tree can be built without crashing immediately.
    expect(find.byType(DgPartnerApp), findsOneWidget);
  });
}
