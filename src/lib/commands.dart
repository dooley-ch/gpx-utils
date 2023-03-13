// *******************************************************************************************
//  File:  commands.dart
//
//  Created: 10-03-2023
//
//  History:
//  10-03-2023: Initial version
//
// *******************************************************************************************
import 'dart:io';
import 'package:args/command_runner.dart';
import 'package:console/console.dart';
import 'package:logging/logging.dart';
import 'configfile.dart';
import 'exceptions.dart';
import 'gpxfile.dart';
import 'version.dart';


/// This class defines the commands supported by the application
class CommandArguments {
  static const String mergeCommand = 'merge';
  static const String splitCommand = 'split';
  static const String browseCommand = 'browse';
  static const String versionCommand = 'version';

  static const String fileOption = 'file';
  static const String deleteExistingFilesOption = 'delete';
  static const String outputFolderOption = 'output';
}

/// This class provides code that is common to all three of the commands
mixin CommandSupport {
  /// This is the logger for all the commands
  final Logger log = Logger('command-runner');

  /// This method converts the [filePath] for the source file to a File object and checks that it exists
  File getSourceFile(String filePath) {
    final File file = File(filePath);

    if (!file.existsSync()) {
      throw SourceFileNotFoundException('Source file not found', filePath);
    }

    return file;
  }
}

/// This class implements the merge tracks command
class MergeTracksCommand extends Command with CommandSupport {
  @override
  String get description => 'Merges all tracking sections into a single one in a new file';

  @override
  String get name => CommandArguments.mergeCommand;

  MergeTracksCommand() {
    argParser.addOption(CommandArguments.fileOption, abbr: "f", help: 'The source file to use in the merger operation');
    argParser.addOption(CommandArguments.outputFolderOption, abbr: "o", defaultsTo: null, help: 'The output folder to store the file in');
    argParser.addFlag(CommandArguments.deleteExistingFilesOption, abbr: "d", defaultsTo: false, negatable: false);
  }

  @override
  void run() {
    final sourceFileName = argResults![CommandArguments.fileOption];
    final deleteExisting = argResults![CommandArguments.deleteExistingFilesOption];
    final outputFolder = argResults![CommandArguments.outputFolderOption] ?? config.runtime.outputFolder;

    log.info("Merge Command - f: $sourceFileName, output: $outputFolder, delete: $deleteExisting");

    try {
      final sourceFile = getSourceFile(sourceFileName);

      final file = GPXMergeFileCommand(sourceFile);
      file.execute(outputFolder, deleteExiting: deleteExisting);

      Console.setTextColor(config.theme.successTextColor);
      print('File merged successfully');
      Console.setTextColor(config.theme.textColor);
    } catch (e) {
      log.severe("Failed to merge file: $e");
      rethrow;
    }
  }
}

/// This class implements the split tracks command
class SplitTracksCommand extends Command with CommandSupport  {
  @override
  String get description => 'Splits all tracking sections into separate files';

  @override
  String get name => CommandArguments.splitCommand;

  SplitTracksCommand() {
    argParser.addOption(CommandArguments.fileOption, abbr: "f", help: 'The source file to use in the split operation');
    argParser.addOption(CommandArguments.outputFolderOption, abbr: "o", defaultsTo: null, help: 'The output folder to store the file in');
    argParser.addFlag(CommandArguments.deleteExistingFilesOption, abbr: "d", defaultsTo: false, negatable: false);
  }

  @override
  void run() {
    final sourceFileName = argResults![CommandArguments.fileOption];
    final deleteExisting =  argResults![CommandArguments.deleteExistingFilesOption];
    final outputFolder = argResults![CommandArguments.outputFolderOption] ?? config.runtime.outputFolder;

    log.info("Split Command - f: $sourceFileName, output: $outputFolder, delete: $deleteExisting");

    try {
      final sourceFile = getSourceFile(sourceFileName);

      final file = GPXSplitFileCommand(sourceFile);
      file.execute(outputFolder, deleteExiting: deleteExisting);

      Console.setTextColor(config.theme.successTextColor);
      print('File split successfully');
      Console.setTextColor(config.theme.textColor);
    } catch (e) {
      log.severe("Failed to merge file: $e");
      rethrow;
    }
  }
}

// This class implements the browse command
class BrowseCommand extends Command with CommandSupport  {
  @override
  String get description => 'Prints the file structure';

  @override
  String get name => CommandArguments.browseCommand;

  BrowseCommand() {
    argParser.addOption(CommandArguments.fileOption, abbr: "f", help: 'The file to browse');
  }

  @override
  void run() {
    final sourceFileName = argResults![CommandArguments.fileOption];

    log.info("Browse Command - f: $sourceFileName");

    try {
      final sourceFile = getSourceFile(sourceFileName);

      final file = GPXSplitFileCommand(sourceFile);
      final tree = file.toDisplayTree();
      print(tree);
    } catch (e) {
      log.severe("Failed to browse file: $e");
      rethrow;
    }
  }
}

// This class implements the version command
class VersionCommand extends Command with CommandSupport {
  @override
  String get description => 'Prints the application version number';

  @override
  String get name => CommandArguments.versionCommand;

  @override
  void run() {
    log.info("Version Command");

    print(appVersion.toString());
  }
}
