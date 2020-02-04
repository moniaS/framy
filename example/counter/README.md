# counter

Counter is used as example app for the framy package.

## Getting Started

In the directory counter/test_driver.dart there is implemented an automated test.
This test uses two main methods from *framy* package: 
- ```Future<void> takeScreenshot(String screenshotName)``` - which takes a screenshot of current state of the app.
- ```void generateWireFrames(String directoryPath, String initialFileName)``` - which generates wireframes tree based on the files names at the given directory path starting from initialFileName.


Every file name must contain two parts separated by a dash ('-') e.g. *1.1-home_page.png*.
First part indicates nesting hierarchy of the wireframe. Every dot means deeper node.
Second part means the name of the wireframe (with no spaces).

The following files *1-initial_page.png*, *1.1-first_child.png*, *1.2-second_child.png*, *1.1.1-first_child_first_child.png*, *1.1.2-first_child_second_child.png* will produce following structure:
- initial_page:
    -  first_child:
        - first_child_first_child
        - first_child_second_child
    - second_child
    
This hierarchy is shown in generated file framy.svg. 

![nesting hierarchy of the app views](https://i.ibb.co/sJTd2Qs/Screenshot-2020-02-04-at-09-58-01.png)


To run this test and produce *framy.svg* output you need to run the following command in the counter directory:
```
flutter drive --target=test_driver/app.dart 
```