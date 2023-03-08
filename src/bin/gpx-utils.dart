// *******************************************************************************************
//  File:  gpx-utils.dart
//
//  Created: 28-02-2023
//
//  History:
//  28-02-2023: Initial version
//
// *******************************************************************************************
import 'dart:io' as io;
import 'package:args/args.dart' as args;
import 'package:version/version.dart' as ver;
import "package:console/console.dart";
import 'package:src/support.dart' as support;
import 'package:src/configfile.dart' as cfg;
import 'package:src/gpxfile.dart' as gpx;

final _appVersion = ver.Version(1, 0, 1, preRelease: ["alpha"]);
final _config = cfg.ConfigFile(support.getConfigFile(appName: 'gpx_utils'));

void mergeRoutes({required io.File sourceFile, required String outputFolder, required bool overwriteOutputFiles}) {
  final file = gpx.GPXMergeFileCommand(sourceFile);

  file.execute(outputFolder, deleteExiting: overwriteOutputFiles);
  print(
      "GPX file details - version: ${file.version}, creator: ${file.creator}");
}

void splitFile({required io.File sourceFile, required String outputFolder, required bool overwriteOutputFiles}) {
  final file = gpx.GPXSplitFileCommand(sourceFile);
  file.execute(outputFolder, deleteExiting: overwriteOutputFiles);
}

void browseFile({required io.File sourceFile}) {
  final file = gpx.GPXSplitFileCommand(sourceFile);
  final tree = file.toDisplayTree();
  print(tree);
}

/// Displays the application help
void displayHelp() {
  Console.setTextColor(_config.theme.helpTextColor);
  print("\nGpx-Utils Version: ${_appVersion.toString()}");
  print("-v or --version                Displays the application version");
  print("-h or --help                   Displays this text");
  print(
      "merge --file[f] <file name>    Merges route or tracking points into a single route or track");
  print(
      "split --file[f] <file name>    Splits routes or tracks into separate files");
  print("browse --file[f] <file name>   Displays the file contents");
  Console.setTextColor(_config.theme.textColor);
}

/// Displays the application version
void displayVersion() {
  Console.write("GPX-Utils Version: ${_appVersion.toString()}");
}

/// Application entry point
void main(List<String> options) {
  Console.init();
  Console.setTextColor(_config.theme.textColor);

  // Get the options selected by the user
  args.ArgResults results;

  try {
    results = support.getOptions(options);
  } on FormatException catch (e) {
    Console.setTextColor(_config.theme.errorTextColor);
    print("\nGPX-Utils: Unable to process command line arguments - $e");
    Console.setTextColor(_config.theme.textColor);
    displayHelp();
    io.exit(255);
  }

  // Respond to a request to display the version number
  final version = results['version'] ?? false;
  if (version) {
    displayVersion();
    io.exit(0);
  }

  // Respond to a request to display the help text
  final help = results['help'] ?? false;
  if (help) {
    displayHelp();
    io.exit(0);
  }

  // We have a command other than a request for the version number or to
  // display the help text
  final cmd = results.command;
  if (cmd != null) {
    final fileName = cmd["file"];
    final overwrite = cmd['overwrite'];

    switch (cmd.name) {
      case 'merge':
        mergeRoutes(sourceFile: io.File(fileName), outputFolder: _config.runtime.outputFolder, overwriteOutputFiles: overwrite);
        break;
      case 'split':
        splitFile(sourceFile: io.File(fileName), outputFolder: _config.runtime.outputFolder, overwriteOutputFiles: overwrite);
        break;
      case 'browse':
        browseFile(sourceFile: io.File(fileName));
        break;
    }
  }

  io.exit(0);
}
