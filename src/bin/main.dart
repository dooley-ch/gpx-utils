// *******************************************************************************************
//  File:  main.dart
//
//  Created: 28-02-2023
//
//  History:
//  28-02-2023: Initial version
//
// *******************************************************************************************
import 'dart:io';
import 'package:src/support.dart' as support;

void main(List<String> args) {
  print(support.getConfigFile(appName: 'gpx_utils'));
  exit(0);
}
