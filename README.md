Framy generates svg file that shows nesting hierarchy of the views in the app.

Framy provides two main methods:
- ```Future takeScreenshot(String screenshotName) ``` - which takes screenshot of the current view of the app. To take screenshot FlutterDriver object is required.
- ```void generateWireFrames(String directoryPath, String initialFileName) ``` - which generates svg file that shows the nesting hierarchy of the views in the app. Every node is represented by image and name. 

## Usage

A simple usage example in tests:

```dart
import 'package:framy/framy.dart';
import 'package:test/test.dart';
import 'package:flutter_driver/flutter_driver.dart';

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
```
Above code will produce svg file output. This file will contain the screenshots that were taken during the test.
The nesting hierarchy will look like this:

![nesting hierarchy of the app views](https://i.ibb.co/sJTd2Qs/Screenshot-2020-02-04-at-09-58-01.png)

Every file that will be considered has to be built from two main parts separated by '-'.
First part shows the nesting hierarchy of the views in the app. Every dot means deeper view of the app. Second part contains name of the screenshot that will be displayed in svg file - name cannot include spaces.
 
*1-initial_page.png*, *1.1-home_page.png*, *1.2.1-page_1.png* are valid file names.
*1.png*, *1-home page.png*, *1.-.png* are invalid file names.
