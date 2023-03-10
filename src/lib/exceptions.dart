// *******************************************************************************************
//  File:  exceptions.dart
//
//  Created: 02-03-2023
//
//  History:
//  02-03-2023: Initial version
//
// *******************************************************************************************
import 'dart:io' as io;

class FileNotFoundException extends io.FileSystemException {
  FileNotFoundException(super.message, super.path);

  @override
  String toString() => '$message: $path';
}

class SourceFileNotFoundException extends FileNotFoundException {
  SourceFileNotFoundException(super.message, super.path);
}

class InvalidGpxFileException implements Exception {
  final String message;

  const InvalidGpxFileException([this.message = ""]);

  @override
  String toString() => message;
}

class OutputFileExistsException implements Exception {
  late String message;

  OutputFileExistsException(String fileName) {
    message = "An output file with the name: $fileName, already exists";
  }

  @override
  String toString() => message;
}