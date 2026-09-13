import 'package:flutter_test/flutter_test.dart';

import 'package:anivortex_rebuild/core/app.dart';

void main() {
  testWidgets('AniVortex app starts', (tester) async {
    await tester.pumpWidget(const AniVortexRebuildApp());
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Search'), findsOneWidget);
    expect(find.text('Downloads'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);
  });
}
