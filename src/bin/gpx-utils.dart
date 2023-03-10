// *******************************************************************************************
//  File:  gpx-utils.dart
//
//  Created: 28-02-2023
//
//  History:
//  28-02-2023: Initial version
//
// *******************************************************************************************
import 'package:args/command_runner.dart';
import 'package:version/version.dart' as ver;
import "package:console/console.dart";
import 'package:src/configfile.dart';
import 'package:src/commands.dart';

final _appVersion = ver.Version(1, 0, 1, preRelease: ["alpha"]);

void main(List<String> params) {
  Console.init();
  Console.setTextColor(config.theme.textColor);

  CommandRunner("gpx-utils", "A utility to merge and split gpx files for use with Komoot")
    ..addCommand(MergeTracksCommand())
    ..addCommand(SplitTracksCommand())
    ..addCommand(BrowseCommand())
    ..run(params);
}