// *******************************************************************************************
//  File:  configfile.dart
//
//  Created: 01-03-2023
//
//  History:
//  01-03-2023: Initial version
//
// *******************************************************************************************
import 'dart:io';
import 'package:console/console.dart';
import 'package:toml/toml.dart';
import 'support.dart';

/// This variable holds a reverence to an instance of the [ConfigFile] class.
final config = ConfigFile(getConfigFile(appName: 'gpxutils'));

/// This class holds the theme colors used by the application
class Theme {
  final int textColor;
  final int successTextColor;
  final int errorTextColor;
  final int helpTextColor;

  Theme(this.textColor, this.errorTextColor, this.helpTextColor, this.successTextColor);

  @override
  String toString() => "Theme - textColor: $textColor, errorTextColor: $errorTextColor, helpTextColor: $helpTextColor, successTextColor: $successTextColor";
}

/// This class holds the runtime parameters used by the application
class Runtime {
  final String outputFolder;

  Runtime(this.outputFolder);

  @override
  String toString() => "Runtime - outputFolder: $outputFolder";
}

/// This class holds the logging parameters used by the application
class Logging {
  final int level;

  Logging(this.level);

  @override
  String toString() => "Logging - level: $level";
}

/// This class loads and publishes the configuration parameters used by the application
///
/// **Note:** The parameters are stored in the following location - /Users/[[user account]]/support_libs/config.toml
class ConfigFile {
  final File _file;
  late Theme theme;
  late Runtime runtime;
  late Logging logging;

  ConfigFile(this._file) {
    if (_file.existsSync()) {
      final document = TomlDocument.loadSync(_file.path).toMap();

      final textColor = document['theme']['textColor'];
      final errorTextColor = document['theme']['errorTextColor'];
      final helpTextColor = document['theme']['helpTextColor'];
      final successTextColor = document['theme']['successTextColor'];
      theme = Theme(textColor, errorTextColor, helpTextColor, successTextColor);

      final outputFolder = document['runtime']['outputFolder'];
      runtime = Runtime(outputFolder);

      final loggingLevel = document['logging']['level'] as int;
      logging = Logging(loggingLevel);
    } else {
      theme = Theme(Color.DARK_BLUE.id, Color.DARK_RED.id, Color.LIGHT_GRAY.id, Color.GREEN.id);
      runtime = Runtime(Directory.current.path);
    }
  }

  bool save() {
    return false;
  }

  String get fileName => _file.path;

  @override
  String toString() => fileName;
}