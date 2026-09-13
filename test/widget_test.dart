import 'package:flutter_test/flutter_test.dart';
import 'package:anivortex_rebuild/main.dart';

void main() {
  testWidgets('AniVortex shell renders all primary destinations', (tester) async {
    await tester.pumpWidget(const AniVortexRebuildApp());
    await tester.pump();
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Search'), findsOneWidget);
    expect(find.text('Downloads'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);
  });
}
