// *******************************************************************************************
//  File:  gpxutils.dart
//
//  Created: 28-02-2023
//
//  History:
//  28-02-2023: Initial version
//
// *******************************************************************************************
import 'dart:io';
import 'package:args/command_runner.dart';
import "package:console/console.dart";
import 'package:logging/logging.dart';
import 'package:src/configfile.dart';
import 'package:src/commands.dart';
import 'package:src/support.dart';

void main(List<String> params) async {
  Console.init();
  Console.setTextColor(config.theme.textColor);

  final logFile = getLogFile(appName: 'gpxutils');
  logFile.writeAsStringSync('========== *** Start *** ==========\n', mode: FileMode.append);

  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) {
    logFile.writeAsStringSync("${record.time.toIso8601String()}: ${record.level.name}: ${record.message}\n", mode: FileMode.append);
  });

  int exitCode = 0;

  try {
    final runner = CommandRunner("gpx-utils",
        "A utility to merge and split gpx files for use with Komoot")
      ..addCommand(MergeTracksCommand())..addCommand(
          SplitTracksCommand())..addCommand(BrowseCommand())..addCommand(
          VersionCommand());

    await runner.run(params);
  } catch (e) {
    Console.setTextColor(config.theme.errorTextColor);
    Console.write("Operation failed: $e.\nSee log for details.");
    Console.setTextColor(config.theme.textColor);
    exitCode = 255;
  }

  logFile.writeAsStringSync('========== ***  End  *** ==========\n', mode: FileMode.append);
  exit(exitCode);
}
