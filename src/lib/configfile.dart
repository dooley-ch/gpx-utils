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
import 'package:toml/toml.dart' as toml;

class ConfigFile {
  final io.File _file;

  ConfigFile(this._file) {
    if (_file.existsSync()) {
      // If the file exists we load the contents and use to config the application
      final document = toml.TomlDocument.load(_file.toString());
    } else {
      // If no config file is found we fall back on the default values
    }
  }

  bool save() {
    return false;
  }

  String get fileName => _file.toString();

  @override
  String toString() => fileName;
}