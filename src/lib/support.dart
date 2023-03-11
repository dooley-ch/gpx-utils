// *******************************************************************************************
//  File:  support.dart
//
//  Created: 01-03-2023
//
//  History:
//  01-03-2023: Initial version
//
// *******************************************************************************************
import 'dart:io' as io;
import 'package:path/path.dart' as path;

String getHomeFolder() {
  final envVariables = io.Platform.environment;

  String home = '';
  if ((io.Platform.isMacOS) || (io.Platform.isLinux)) {
    home = envVariables['HOME'] ?? '';
  }
  if (io.Platform.isWindows) {
    home = envVariables['UserProfile'] ?? '';
  }

  return home;
}

io.File getConfigFile({required String appName}) {
  path.Context ctx = path.Context(style: path.Style.posix);
  if (io.Platform.isWindows) {
    ctx = path.Context(style: path.Style.windows);
  }

  final folder = ctx.join(getHomeFolder(), 'support_libs', appName);

  final directory = io.Directory(folder);
  directory.createSync(recursive: true);

  final file = io.File(ctx.join(directory.path, 'config.toml'));

  return file;
}

io.File getLogFile({required String appName}) {
  path.Context ctx = path.Context(style: path.Style.posix);
  if (io.Platform.isWindows) {
    ctx = path.Context(style: path.Style.windows);
  }

  final folder = ctx.join(getHomeFolder(), 'support_libs', appName);

  final directory = io.Directory(folder);
  directory.createSync(recursive: true);

  final file = io.File(ctx.join(directory.path, '$appName.log'));

  return file;
}