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
import 'package:src/configfile.dart' as cfg;

void main(List<String> args) {
  final cfg.ConfigFile config = cfg.ConfigFile(support.getConfigFile(appName: 'gpx_utils'));
  print(config.toString());
  exit(0);
}
