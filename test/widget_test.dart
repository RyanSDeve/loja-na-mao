import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:loja_na_mao/main.dart';

void main() {
  testWidgets('storefront demo renders main shopping flow', (tester) async {
    await tester.pumpWidget(const LojaNaMaoApp());
    await tester.pumpAndSettle();

    expect(find.text('Doce Encanto Demo'), findsWidgets);
    expect(find.text('Caixa Brigadeiros Gourmet'), findsOneWidget);
    expect(find.byIcon(Icons.shopping_bag_outlined), findsWidgets);

    await tester.tap(find.byIcon(Icons.add_shopping_cart).first);
    await tester.pump();

    expect(find.textContaining('1 item'), findsOneWidget);
  });
}
