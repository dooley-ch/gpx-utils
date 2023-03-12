// *******************************************************************************************
//  File:  gpxfile.dart
//
//  Created: 02-03-2023
//
//  History:
//  02-03-2023: Initial version
//
// *******************************************************************************************
import 'dart:io' as io;
import 'package:console/console.dart';
import 'package:xml/xml.dart';
import 'package:path/path.dart' as path;
import 'exceptions.dart';

/// This class represents a point of a route or track map
class Point {
  late String latitude; // Geographical coordinate
  late String longitude; // Geographical coordinate
  late String elevation; // Altitude in meters
  late String
      dateTime; // Date and time (UTC/Zulu) in ISO 8601 format: yyyy-mm -ddThh:mm:ssZ
  late String
      magneticVariation; // Declination / magnetic variation on site in degrees
  late String geoIdHeight; // Height related to geoid
  late String name; // Proper name of the element
  late String comment; // Comment
  late String description; // element description
  late String source; // Data source/origin
  late String link; // Link to further information
  late String displaySymbol; // Display symbol
  late String type; //  Classification
  late String fix; // Type of position fix: none, 2d, 3d, dgps, pps
  late String sat; // Number of satellites used for position calculation
  late String hdop; // HDOP:Horizontal spread of the position specification
  late String vdop; // VDOP: Vertical spread of the position information
  late String pdo; // PDOP: Spread of the position information
  late String
      ageOfDgpsData; // Seconds between last DGPS reception and position calculation
  late String dgpsId; // ID of the DGPS station used
  late String extensions; // GPX extension

  Point(XmlElement element) {
    final latitude = element.getAttribute("lat") ?? '';
    final longitude = element.getAttribute("lon") ?? '';

    final elevation = element.getElement("ele");
    final dateTime = element.getElement("time");
    final magneticVariation = element.getElement("magvar");
    final geoIdHeight = element.getElement("geoidheight");
    final name = element.getElement("name");
    final comment = element.getElement("cmt");
    final description = element.getElement("desc");
    final source = element.getElement("src");
    final link = element.getElement("link");
    final displaySymbol = element.getElement("sym");
    final type = element.getElement("type");
    final fix = element.getElement("fix");
    final sat = element.getElement("sat");
    final hdop = element.getElement("hdop");
    final vdop = element.getElement("vdop");
    final pdo = element.getElement("pdop");
    final ageOfDgpsData = element.getElement("ageofdgpsdata");
    final dgpsId = element.getElement("dgpsid");
    final extensions = element.getElement("extensions");

    this.latitude = latitude;
    this.longitude = longitude;

    this.elevation = elevation?.text ?? '';
    this.dateTime = dateTime?.text ?? '';
    this.magneticVariation = magneticVariation?.text ?? '';
    this.geoIdHeight = geoIdHeight?.text ?? '';
    this.name = name?.text ?? '<Unlabeled>';
    this.comment = comment?.text ?? '';
    this.description = description?.text ?? '';
    this.source = source?.text ?? '';
    this.link = link?.text ?? '';
    this.displaySymbol = displaySymbol?.text ?? '';
    this.type = type?.text ?? '';
    this.fix = fix?.text ?? '';
    this.sat = sat?.text ?? '';
    this.hdop = hdop?.text ?? '';
    this.vdop = vdop?.text ?? '';
    this.pdo = pdo?.text ?? '';
    this.ageOfDgpsData = ageOfDgpsData?.text ?? '';
    this.dgpsId = dgpsId?.text ?? '';
    this.extensions = extensions?.text ?? '';
  }
}

/// This class represents a route or a track in a GPX file
class PointsCollection {
  late String name;
  late String desc;
  final List<Point> points = <Point>[];

  PointsCollection(this.name, this.desc);

  PointsCollection.fromXMLConstructor(XmlElement element,
      {required String pointTag, String? collectionTag}) {
    final name = element.getElement("name");
    final desc = element.getElement("desc");
    this.name = name?.text ?? '<Unlabeled>';
    this.desc = desc?.text ?? '';

    Iterable<XmlElement>? points;
    if (collectionTag != null) {
      final collection = element.getElement(collectionTag);
      points = collection?.childElements;
    } else {
      points = element.findElements(pointTag);
    }

    if (points != null) {
      if (points.isNotEmpty) {
        for (element in points) {
          final point = Point(element);
          this.points.add(point);
        }
      }
    }
  }
}

/// This class holds the metadata contained in a GPX file
class Metadata {
  late String name;
  late String desc;
  late String link;

  Metadata(this.name, this.desc, this.link);

  Metadata.emptyConstructor() {
    name = '';
    desc = '';
    link = '';
  }
}

/// This class holds the contents of a GPX source file
abstract class GPXFile {
  final io.File _file;
  late String _version;
  late String _creator;
  late Metadata _metadata;
  final List<PointsCollection> _tracks = <PointsCollection>[];

  String get version => _version;
  String get creator => _creator;
  Metadata get metadata => _metadata;
  List<PointsCollection> get tracks => _tracks;

  GPXFile(this._file) {
    if (!_file.existsSync()) {
      throw FileNotFoundException("Unable to locate GPX file", _file.path);
    }

    final gpx = _getFileRoot(_file);

    _version = gpx.getAttribute('version') ?? 'Unknown';
    _creator = gpx.getAttribute("creator") ?? 'N/A';
    _metadata = _getMetadata(gpx);

    final tracks = gpx.findAllElements("trk");
    if (tracks.isNotEmpty) {
      for (var element in tracks) {
        final node = PointsCollection.fromXMLConstructor(element,
            collectionTag: 'trkseg', pointTag: 'trkpt');
        _tracks.add(node);
      }
    }
  }

  XmlElement _getFileRoot(io.File file) {
    final content = _file.readAsStringSync();
    final document = XmlDocument.parse(content);
    final rootNode = document.getElement("gpx");

    if (rootNode == null) {
      throw InvalidGpxFileException("Root node gpx not found");
    }

    return rootNode;
  }

  Metadata _getMetadata(XmlNode root) {
    final searchResult = root.findAllElements("metadata");
    if (searchResult.isNotEmpty) {
      final metaData = searchResult.single;

      final metaDataName = metaData.getElement("name");
      final metaDataDesc = metaData.getElement("desc");
      final link = metaData.getAttribute("link") ?? '';

      return Metadata(metaDataName?.text ?? '', metaDataDesc?.text ?? '', link);
    }

    return Metadata.emptyConstructor();
  }

  String toDisplayTree() {
    // Root node
    final root = <String, dynamic>{};
    root['label'] =
        "GPX - Version $_version, Creator: $_creator (${_file.path})";
    root['nodes'] = [];

    if (_tracks.isNotEmpty) {
      final List<String> names = <String>[];
      for (var element in _tracks) {
        names.add(element.name);
      }

      final tracks = <String, dynamic>{};
      tracks['label'] = "Tracks (${_tracks.length})";
      tracks['nodes'] = names;

      final nodes = root['nodes'] as List<dynamic>;
      nodes.add(tracks);
    } else {
      final nodes = root['nodes'] as List<dynamic>;
      nodes.add("Routes (0)");
    }

    return createTree(root);
  }
}

/// This mixin holds code common to both splitting and merging a GPX file
mixin GPXFileCommandSupport {
  io.File getFileName (String name, io.File sourceFile, String outputFolder, {bool deleteExiting = false}){
    // Make sure the name can be used for a file name
    name = name.replaceAll(' ', '_').replaceAll('/', '_');

    final folder = io.Directory(outputFolder);
    folder.createSync(recursive: true);

    final originalFileName = path.basenameWithoutExtension(sourceFile.path);
    final newFileName = "${originalFileName}_$name.gpx";
    final newFileQualifiedName = path.join(outputFolder, newFileName);
    final newFile = io.File(newFileQualifiedName);

    if (newFile.existsSync()) {
      if (deleteExiting) {
        newFile.delete();
      } else {
        throw OutputFileExistsException(newFileQualifiedName);
      }
    }

    return newFile;
  }
}

/// This class extends the GPXFile class by adding the ability to split track entries
/// into individual files
class GPXSplitFileCommand extends GPXFile with GPXFileCommandSupport {
  GPXSplitFileCommand(super._file);

  void _exportFile(PointsCollection track, io.File outputFile) {
    final builder = XmlBuilder();
    builder.processing('xml', 'version="1.0" encoding="UTF-8" standalone="yes"');

    builder.element("gpx",
        attributes: {'creator':"gpx-utils - https://github.com/dooley-ch/gpx-utils"},
        nest: () {
          builder.element("metadata", nest: () {
            builder.element("name", nest: () { builder.text(track.name);});
            builder.element("time", nest: () { builder.text(DateTime.now().toIso8601String());});
            builder.element("original-file", nest: () { builder.text(path.basename(_file.path));});
          });
          builder.element("trk", nest: () {
            for (Point point in track.points) {
              if (point.dateTime.isNotEmpty) {
                builder.element("trkpt", attributes: {
                  'lat': point.latitude,
                  'lon': point.longitude,
                  'time': point.dateTime
                });
              } else {
                builder.element("trkpt", attributes: {
                  'lat': point.latitude,
                  'lon': point.longitude
                });
              }
            }
          });
        });

    final doc = builder.buildDocument();
    final content = doc.toXmlString(pretty: true);

    outputFile.writeAsStringSync(content);
  }

  bool execute(String outputFolder, {bool deleteExiting = false}) {
    if (_tracks.isNotEmpty) {
      var fileCount = 0;

      for (var track in tracks) {
        String fileName = track.name;
        if (fileName == '<Unlabeled>') {
          fileName = (fileCount++).toString();
        }
        final file = getFileName(fileName, _file, outputFolder, deleteExiting: deleteExiting);

        _exportFile(track, file);
      }
    } else {
      return false;
    }

    return true;
  }
}

/// This class extends the GPXFile class by adding the ability to merge track entries
/// and store them in a new file
class GPXMergeFileCommand extends GPXFile with GPXFileCommandSupport {
  GPXMergeFileCommand(super._file);

  bool execute(String outputFolder, {bool deleteExiting = false}) {
    final outputFile = getFileName('merged', _file, outputFolder, deleteExiting: deleteExiting);

    if (_tracks.isNotEmpty) {
      final builder = XmlBuilder();
      builder.processing(
          'xml', 'version="1.0" encoding="UTF-8" standalone="yes"');

      builder.element("gpx",
          attributes: {
            'creator': "gpx-utils - https://github.com/dooley-ch/gpx-utils"
          },
          nest: () {
            builder.element("metadata", nest: () {
              builder.element("name", nest: () {
                builder.text("merged: ${path.basename(_file.path)}");
              });
              builder.element("time", nest: () {
                builder.text(DateTime.now().toIso8601String());
              });
              builder.element("original-file", nest: () {
                builder.text(path.basename(_file.path));
              });
            });
            builder.element("trk", nest: () {
              builder.element("name", nest: () {builder.text("merged: ${path.basename(_file.path)}");});
              builder.element("trkseg", nest: () {
                final firstPoint = _tracks[0].points[0];
                builder.element("trkpt", attributes: {
                  'lat': firstPoint.latitude,
                  'lon': firstPoint.longitude,
                  'time': firstPoint.dateTime
                });
                for (var element in _tracks) {
                  var isFirst = true;
                  for (var point in element.points) {
                    if (isFirst) {
                      isFirst = false;
                      continue;
                    }
                    builder.element("trkpt", attributes: {
                      'lat': point.latitude,
                      'lon': point.longitude,
                      'time': point.dateTime
                    });
                  }
                }
              });
            });
          });

      final doc = builder.buildDocument();
      final content = doc.toXmlString(pretty: true);
      outputFile.writeAsStringSync(content);
    }

    return true;
  }
}
