import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:web_gestor_site_covertix/app_config/app_widget.dart';
import 'package:web_gestor_site_covertix/widgets/app_logo.dart';

void main() {
  testWidgets('Login page is shown on startup', (WidgetTester tester) async {
    await tester.pumpWidget(const AppWidget());

    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is Image &&
            widget.image is AssetImage &&
            (widget.image as AssetImage).assetName == logoAsset,
      ),
      findsOneWidget,
    );
  });
}
