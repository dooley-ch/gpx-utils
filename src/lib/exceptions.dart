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
}

/// Exception thrown when a file GPX file cannot be processed.
class InvalidGpxFileException implements Exception {
  /// Message describing the error.
  final String message;

  /// Creates a new GPX file exception with an optional part.
  const InvalidGpxFileException([this.message = ""]);
}