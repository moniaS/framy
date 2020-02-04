import 'package:flutter_driver/flutter_driver.dart';
import 'package:framy/framy.dart';
import 'package:test/test.dart';

void main() {
  FlutterDriver driver;
  Framy framy;

  setUpAll(() async {
    driver = await FlutterDriver.connect();
    framy = Framy(driver: driver, groupName: 'app');
  });

  test('application test', () async {
    await driver.waitFor(find.byType('Scaffold'));
    await framy.takeScreenshot('1-initial_page');
    await driver.tap(find.byType('FloatingActionButton'));
    await framy.takeScreenshot('1.1-first_child_page');
    await driver.tap(find.byType('FloatingActionButton'));
    await driver.tap(find.byType('FloatingActionButton'));
    await framy.takeScreenshot('1.2-second_child_page');
    await driver.tap(find.byType('FloatingActionButton'));
    await driver.tap(find.byType('FloatingActionButton'));
    await driver.tap(find.byType('FloatingActionButton'));
    await framy.takeScreenshot('1.1.1-first_child_first_child_page');
    await driver.tap(find.byType('FloatingActionButton'));
    await framy.takeScreenshot('1.1.2-first_child_second_child_page');
    framy.generateWireFrames('framy/app', '1-initial_page');
  });
}
