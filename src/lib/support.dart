// *******************************************************************************************
//  File:  support.dart
//
//  Created: 01-03-2023
//
//  History:
//  01-03-2023: Initial version
//
// *******************************************************************************************
import 'dart:io';
import 'package:path/path.dart';

/// This function returns the path to the user's home folder
String getHomeFolder() {
  final envVariables = Platform.environment;

  String home = '';
  if ((Platform.isMacOS) || (Platform.isLinux)) {
    home = envVariables['HOME'] ?? '';
  }
  if (Platform.isWindows) {
    home = envVariables['UserProfile'] ?? '';
  }

  return home;
}

/// This function returns an instance of the File class pointing to the
/// configuration file
File getConfigFile({required String appName}) {
  Context ctx = Context(style: Style.posix);
  if (Platform.isWindows) {
    ctx = Context(style: Style.windows);
  }

  final folder = ctx.join(getHomeFolder(), 'support_libs', appName);

  final directory = Directory(folder);
  directory.createSync(recursive: true);

  final file = File(ctx.join(directory.path, 'config.toml'));

  return file;
}

/// This function returns an instance of the File class pointing to the
/// log file
File getLogFile({required String appName}) {
  Context ctx = Context(style: Style.posix);
  if (Platform.isWindows) {
    ctx = Context(style: Style.windows);
  }

  final folder = ctx.join(getHomeFolder(), 'support_libs', appName);

  final directory = Directory(folder);
  directory.createSync(recursive: true);

  final file = File(ctx.join(directory.path, '$appName.log'));

  return file;
}