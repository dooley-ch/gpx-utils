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
import 'package:src/exceptions.dart';

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

/// Represents metadata from the file
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

/// The base class for all forms of GPX file command
abstract class GPXFile {
  final io.File _file;
  late String _version;
  late String _creator;
  late Metadata _metadata;
  final List<PointsCollection> _routes = <PointsCollection>[];
  final List<PointsCollection> _tracks = <PointsCollection>[];
  final List<Point> _wayPoints = <Point>[];

  String get version => _version;
  String get creator => _creator;
  Metadata get metadata => _metadata;
  List<PointsCollection> get routes => _routes;
  List<PointsCollection> get tracks => _tracks;
  List<Point> get wayPoints => _wayPoints;

  GPXFile(this._file) {
    if (!_file.existsSync()) {
      throw FileNotFoundException("Unable to locate GPX file", _file.path);
    }

    final gpx = _getFileRoot(_file);

    _version = gpx.getAttribute('version') ?? 'Unknown';
    _creator = gpx.getAttribute("creator") ?? 'N/A';
    _metadata = _getMetadata(gpx);

    // Process the way points, if any
    final wayPoints = gpx.findAllElements("wpt");
    if (wayPoints.isNotEmpty) {
      for (var element in wayPoints) {
        final point = Point(element);
        this.wayPoints.add(point);
      }
    }

    // Process the tracks
    final tracks = gpx.findAllElements("trk");
    if (tracks.isNotEmpty) {
      for (var element in tracks) {
        final node = PointsCollection.fromXMLConstructor(element,
            collectionTag: 'trkseg', pointTag: 'trkpt');
        _tracks.add(node);
      }
    }

    // Process the routes
    final routes = gpx.findAllElements("rte");
    if (routes.isNotEmpty) {
      for (var element in routes) {
        final node =
            PointsCollection.fromXMLConstructor(element, pointTag: 'rtept');
        _routes.add(node);
      }
    }
  }

  // This method parses the GPX file and returns the file's root node
  XmlElement _getFileRoot(io.File file) {
    final content = _file.readAsStringSync();
    final document = XmlDocument.parse(content);
    final rootNode = document.getElement("gpx");

    if (rootNode == null) {
      throw InvalidGpxFileException("Root node gpx not found");
    }

    return rootNode;
  }

  // This method extracts the meta data from the GPX file
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

  /// Returns tree representation of the file contents
  ///
  /// The return value is usually displayed in the console
  String toDisplayTree() {
    // Root node
    final root = <String, dynamic>{};
    root['label'] =
        "GPX - Version $_version, Creator: $_creator (${_file.path})";
    root['nodes'] = [];

    if (_wayPoints.isNotEmpty) {
      final wayPoints = <String, dynamic>{};
      wayPoints['label'] = "WayPoints (${_wayPoints.length})";
      wayPoints['nodes'] = [];
      final nodes = root['nodes'] as List<dynamic>;
      nodes.add(wayPoints);
    } else {
      final nodes = root['nodes'] as List<dynamic>;
      nodes.add("WayPoints (0)");
    }

    if (_routes.isNotEmpty) {
      final routes = <String, dynamic>{};
      routes['label'] = "Routes (${_routes.length})";
      routes['nodes'] = [];
      final nodes = root['nodes'] as List<dynamic>;
      nodes.add(routes);
    } else {
      final nodes = root['nodes'] as List<dynamic>;
      nodes.add("Routes (0)");
    }

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

/// Holds common routines used in executing the commands
mixin GPXFileCommandSupport {
  io.File getFileName(String name, io.File sourceFile, {bool deleteExiting = false}) {
    // Make sure the name can be used for a file name
    name = name.replaceAll(' ', '_').replaceAll('/', '_');

    // Construct the new file name
    final originalFileName = path.basenameWithoutExtension(sourceFile.path);
    final newFileName = "${originalFileName}_$name.gpx";
    final folder = sourceFile.parent;
    final newFileQualifiedName = path.join(folder.path, newFileName);
    final newFile = io.File(newFileQualifiedName);

    // Delete if it already exits
    if (newFile.existsSync() && deleteExiting) {
      newFile.delete();
    }

    return newFile;
  }
}


/// GPX file command to split a given file into a set of files one for each
/// track or route defined in the file
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

  /// This method executes the split command
  bool execute() {
    if (_tracks.isNotEmpty) {
      var fileCount = 0;

      for (var track in tracks) {
        // Create the file name
        String fileName = track.name;
        if (fileName == '<Unlabeled>') {
          fileName = (fileCount++).toString();
        }
        final file = getFileName(fileName, _file);

        _exportFile(track, file);
      }
    } else {
      return false;
    }

    return true;
  }
}

/// GPX file command to merge all track or route definitions in the file into
/// single route or track
class GPXMergeFileCommand extends GPXFile with GPXFileCommandSupport {
  GPXMergeFileCommand(super._file);

  /// This method executes the merge command
  bool execute() {
    // Build the file name
    // TODO - had support for path dividers
    final outputFile = getFileName('merged', _file);

    // Construct the xml content
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

      // Write the file
      final doc = builder.buildDocument();
      final content = doc.toXmlString(pretty: true);
      outputFile.writeAsStringSync(content);
    }

    return true;
  }
}
