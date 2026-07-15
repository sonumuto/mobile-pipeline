import 'package:flutter_test/flutter_test.dart';

import 'package:food_delivery_app/data/mock_data.dart';
import 'package:food_delivery_app/main.dart';

void main() {
  testWidgets('app boots to the home screen and lists restaurants',
      (WidgetTester tester) async {
    await tester.pumpWidget(const FoodDeliveryApp());

    expect(find.text('Deliver to'), findsOneWidget);
    expect(find.text('Search restaurants or cuisines'), findsOneWidget);
    expect(find.text(kRestaurants.first.name), findsOneWidget);
  });
}
