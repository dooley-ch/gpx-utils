// *******************************************************************************************
//  File:  main.dart
//
//  Created: 28-02-2023
//
//  History:
//  28-02-2023: Initial version
//
// *******************************************************************************************
import 'dart:io' as io;
import 'package:args/args.dart' as args;
import 'package:src/support.dart' as support;
import 'package:src/configfile.dart' as cfg;

args.ArgParser getArgsParser() {
  final argParser = args.ArgParser();

  var cmd = argParser.addCommand("merge");
  cmd.addOption("file", abbr: "f");

  cmd = argParser.addCommand("split");
  cmd.addOption("file", abbr: "f");

  argParser.addFlag("help", abbr: "h", negatable: false);
  argParser.addFlag("version", abbr: "v", negatable: false);

  return argParser;
}

void mergeRoutes({required io.File sourceFile}) {
  print("Merge file: ${sourceFile.toString()}");
}

void splitFile({required io.File sourceFile}) {
  print("Split file: ${sourceFile.toString()}");
}

void displayHelp() {
  print("Display help");
}

void displayVersion() {
  print("Display version");
}

void main(List<String> options) {
  // Get the configuration parameters
  final cfg.ConfigFile config = cfg.ConfigFile(support.getConfigFile(appName: 'gpx_utils'));
  print(config.toString());

  // Get the options selected by the user
  final argsParser = getArgsParser();

  args.ArgResults results;

  try {
    results= argsParser.parse(options);
  } on FormatException {
    displayHelp();
    io.exit(255);
  }

  // Determine the command selected
  final version = results['version'] ?? false;
  if (version) {
    displayVersion();
    io.exit(0);
  }

  final help = results['help'] ?? false;
  if (help) {
    displayHelp();
    io.exit(0);
  }

  final cmd = results.command;
  if (cmd != null) {
    switch (cmd.name) {
      case 'merge':
        final fileName = cmd["file"];
        mergeRoutes(sourceFile: io.File(fileName));
        break;
      case 'split':
        final fileName = cmd["file"];
        splitFile(sourceFile: io.File(fileName));
        break;
    }
  }

  io.exit(0);
}
