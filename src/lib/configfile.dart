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

final config = ConfigFile(support.getConfigFile(appName: 'gpx_utils'));

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

class ConfigFile {
  final io.File _file;
  late Theme theme;
  late Runtime runtime;

  ConfigFile(this._file) {
    if (_file.existsSync()) {
      // If the file exists we load the contents and use to config the application
      final document = toml.TomlDocument.loadSync(_file.path).toMap();

      final textColor = document['theme']['textColor'];
      final errorTextColor = document['theme']['errorTextColor'];
      final helpTextColor = document['theme']['helpTextColor'];

      theme = Theme(textColor, errorTextColor, helpTextColor);

      final outputFolder = document['runtime']['outputFolder'];

      runtime = Runtime(outputFolder);
    } else {
      // If no config file is found we fall back on the default values
      theme = Theme(Color.DARK_BLUE.id, Color.DARK_RED.id, Color.LIGHT_GRAY.id);
    }
  }

  bool save() {
    return false;
  }

  String get fileName => _file.path;

  @override
  String toString() => fileName;
}