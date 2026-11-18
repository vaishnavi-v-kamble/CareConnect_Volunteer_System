import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:careconnect_volunteer_system/app.dart';

void main() {
  testWidgets('CareConnect welcome screen loads', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: CareConnectApp()));

    expect(find.text('CareConnect'), findsOneWidget);
    expect(find.text('Discover a\nNetwork of Hope'), findsOneWidget);
  });
}
