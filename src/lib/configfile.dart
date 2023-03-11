// *******************************************************************************************
//  File:  configfile.dart
//
//  Created: 01-03-2023
//
//  History:
//  01-03-2023: Initial version
//
// *******************************************************************************************
import 'dart:io' as io;
import 'package:console/console.dart';
import 'package:toml/toml.dart' as toml;
import 'package:src/support.dart' as support;

final config = ConfigFile(support.getConfigFile(appName: 'gpxutils'));

class Theme {
  final int textColor;
  final int errorTextColor;
  final int helpTextColor;

  Theme(this.textColor, this.errorTextColor, this.helpTextColor);

  @override
  String toString() => "Theme - textColor: $textColor, errorTextColor: $errorTextColor";
}

class Runtime {
  final String outputFolder;

  Runtime(this.outputFolder);

  @override
  String toString() => "Runtime - outputFolder: $outputFolder";
}

class Logging {
  final int level;

  Logging(this.level);

  @override
  String toString() => "Logging - level: $level";
}

class ConfigFile {
  final io.File _file;
  late Theme theme;
  late Runtime runtime;
  late Logging logging;

  ConfigFile(this._file) {
    if (_file.existsSync()) {
      final document = toml.TomlDocument.loadSync(_file.path).toMap();

      final textColor = document['theme']['textColor'];
      final errorTextColor = document['theme']['errorTextColor'];
      final helpTextColor = document['theme']['helpTextColor'];
      theme = Theme(textColor, errorTextColor, helpTextColor);

      final outputFolder = document['runtime']['outputFolder'];
      runtime = Runtime(outputFolder);

      final loggingLevel = document['logging']['level'] as int;
      logging = Logging(loggingLevel);
    } else {
      theme = Theme(Color.DARK_BLUE.id, Color.DARK_RED.id, Color.LIGHT_GRAY.id);
      runtime = Runtime(io.Directory.current.path);
    }
  }

  bool save() {
    return false;
  }

  String get fileName => _file.path;

  @override
  String toString() => fileName;
}