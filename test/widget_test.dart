
import 'package:flutter_test/flutter_test.dart';
import 'package:quanly_benh_vien_mobile/app.dart';

void main() {
  testWidgets('MedCare app starts successfully', (WidgetTester tester) async {
    await tester.pumpWidget(const MedCareApp());

    expect(find.text('MedCare Hospital'), findsOneWidget);
  });
}
