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

class ConfigFile {
  final io.File _file;

  ConfigFile(this._file);

  String get fileName => _file.toString();

  @override
  String toString() => fileName;
}