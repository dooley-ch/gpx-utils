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

class CommandArguments {
  static const String mergeCommand = 'merge';
  static const String splitCommand = 'split';
  static const String browseCommand = 'browse';

  static const String fileOption = 'file';
  static const String deleteExistingFilesOption = 'delete';
  static const String outputFolderOption = 'output';
}


/// This method parses the command line arguments
args.ArgResults getOptions(List<String> options) {
  final argParser = args.ArgParser();

  var cmd = argParser.addCommand(CommandArguments.mergeCommand);
  cmd.addOption(CommandArguments.fileOption, abbr: "f");
  cmd.addFlag(CommandArguments.deleteExistingFilesOption, abbr: "d", defaultsTo: false, negatable: false);
  cmd.addOption(CommandArguments.outputFolderOption, abbr: "o", defaultsTo: null);

  cmd = argParser.addCommand(CommandArguments.splitCommand);
  cmd.addOption(CommandArguments.fileOption, abbr: "f");
  cmd.addFlag(CommandArguments.deleteExistingFilesOption, abbr: "d", defaultsTo: false, negatable: false);
  cmd.addOption(CommandArguments.outputFolderOption, abbr: "o", defaultsTo: null);

  cmd = argParser.addCommand(CommandArguments.browseCommand);
  cmd.addOption(CommandArguments.fileOption, abbr: "f");

  argParser.addFlag("help", abbr: "h", negatable: false);
  argParser.addFlag("version", abbr: "v", negatable: false);

  return argParser.parse(options);
}