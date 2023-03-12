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

/// An instance of this class is thrown when a given file can't be found
class FileNotFoundException extends io.FileSystemException {
  FileNotFoundException(super.message, super.path);

  @override
  String toString() => '$message: $path';
}

/// An instance of this class is thrown when the source file can't be found
class SourceFileNotFoundException extends FileNotFoundException {
  SourceFileNotFoundException(super.message, super.path);
}

/// An instance of this class is thrown if the GPX file can't be parsed
class InvalidGpxFileException implements Exception {
  final String message;

  const InvalidGpxFileException([this.message = ""]);

  @override
  String toString() => message;
}

/// An instance of this class is thrown if a given output file exists and the
/// delete existing files flag is not set
class OutputFileExistsException implements Exception {
  late String message;

  OutputFileExistsException(String fileName) {
    message = "An output file with the name: $fileName, already exists";
  }

  @override
  String toString() => message;
}