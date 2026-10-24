import 'package:flutter_test/flutter_test.dart';
import 'package:oyaroo/main.dart';

void main() {
  test('Oyaroo root widget has the correct app class', () {
    const app = OyarooApp();

    expect(app, isA<OyarooApp>());
    expect(app.key, isNull);
  });
}
