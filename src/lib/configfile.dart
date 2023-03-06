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

class Theme {
  final int textColor;
  final int errorTextColor;
  final int helpTextColor;

  Theme(this.textColor, this.errorTextColor, this.helpTextColor);

  @override
  String toString() => "Theme - textColor: $textColor, errorTextColor: $errorTextColor";
}

class ConfigFile {
  final io.File _file;
  late Theme theme;

  ConfigFile(this._file) {
    if (_file.existsSync()) {
      // If the file exists we load the contents and use to config the application
      final document = toml.TomlDocument.loadSync(_file.path).toMap();
      final textColor = document['theme']['textColor'];
      final errorTextColor = document['theme']['errorTextColor'];
      final helpTextColor = document['theme']['helpTextColor'];

      theme = Theme(textColor, errorTextColor, helpTextColor);
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