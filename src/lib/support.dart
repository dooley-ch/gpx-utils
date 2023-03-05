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
import 'package:args/args.dart' as args;

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

/// This method parses the command line arguments
args.ArgResults getOptions(List<String> options) {
  final argParser = args.ArgParser();

  var cmd = argParser.addCommand("merge");
  cmd.addOption("file", abbr: "f");

  cmd = argParser.addCommand("split");
  cmd.addOption("file", abbr: "f");

  cmd = argParser.addCommand("browse");
  cmd.addOption("file", abbr: "f");

  argParser.addFlag("help", abbr: "h", negatable: false);
  argParser.addFlag("version", abbr: "v", negatable: false);

  return argParser.parse(options);
}