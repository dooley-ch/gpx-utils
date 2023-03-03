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
import 'package:xml/xml.dart';
import 'package:src/exceptions.dart';

/// The base class for all data points in a GPX file
abstract class PointBase {
  late String latitude;         // Geographical coordinate
  late String longitude;         // Geographical coordinate
  late String elevation;         // Altitude in meters
  late String dateTime;          // Date and time (UTC/Zulu) in ISO 8601 format: yyyy-mm -ddThh:mm:ssZ
  late String magneticVariation; // Declination / magnetic variation on site in degrees
  late String geoIdHeight;       // Height related to geoid
  late String name;              // Proper name of the element
  late String comment;           // Comment
  late String description;       // element description
  late String source;            // Data source/origin
  late String link;              // Link to further information
  late String displaySymbol;     // Display symbol
  late String type;              //  Classification
  late String fix;               // Type of position fix: none, 2d, 3d, dgps, pps
  late String sat;               // Number of satellites used for position calculation
  late String hdop;              // HDOP:Horizontal spread of the position specification
  late String vdop;              // VDOP: Vertical spread of the position information
  late String pdo;               // PDOP: Spread of the position information
  late String ageOfDgpsData;     // Seconds between last DGPS reception and position calculation
  late String dgpsId;            // ID of the DGPS station used
  late String extensions;        // GPX extension

  PointBase(XmlElement element) {
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
    this.name = name?.text ?? '';
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

/// Represents a way point defined in the GPX file using the tag: wpt
class WayPoint extends PointBase {
  WayPoint(super.element);
}

/// Represents a route point defined within a route using the tag: rtept
class RoutePoint extends PointBase {
  RoutePoint(super.element);
}

/// Represents a tracking point defined within a tracking data entry using the
/// tag: trkpt
class TrackPoint extends PointBase {
  TrackPoint(super.element);
}

/// Represents a route defined in a GPX file.  It is denoted by the tag: rte
class Route {
  late String name;
  late String desc;
  final List<RoutePoint> points = <RoutePoint>[];

  Route(XmlElement element) {
    final name = element.getElement("name");
    final desc = element.getElement("desc");
    final points = element.findElements("rte");

    this.name = name?.text ?? '';
    this.desc = desc?.text ?? '';

    if (points.isNotEmpty) {
      for (var point in points) {
        final wp = RoutePoint(point);
        this.points.add(wp);
      }
    }
  }
}

/// Represents information from tracking a route
class Track {
  late String name;
  late String desc;
  final List<TrackPoint> points = <TrackPoint>[];

  Track(XmlElement element) {
    final name = element.getElement("name");
    final desc = element.getElement("desc");
    final points = element.getElement("trkseg");

    this.name = name?.text ?? '';
    this.desc = desc?.text ?? '';

    if (points != null) {
      for (var point in points.childElements) {
        final wp = TrackPoint(point);
        this.points.add(wp);
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
  final List<Route> _routes = <Route>[];
  final List<Track> _tracks = <Track>[];

  String get version => _version;
  String get creator => _creator;
  Metadata get metadata => _metadata;
  List<Route> get routes => _routes;
  List<Track> get tracks => _tracks;

  GPXFile(this._file) {
    if (!_file.existsSync()) {
      throw FileNotFoundException("Unable to locate GPX file", _file.path);
    }

    final gpx = _getFileRoot(_file);

    _version = gpx.getAttribute('version') ?? 'Unknown';
    _creator = gpx.getAttribute("creator") ?? 'N/A';
    _metadata = _getMetadata(gpx);

    // Process the tracks
    final tracks = gpx.findAllElements("trk");
    if (tracks.isNotEmpty) {
      for (var element in tracks) {
        final node = Track(element);
        _tracks.add(node);
      }
    }

    // Process the routes
    final routes = gpx.findAllElements("rte");
    if (routes.isNotEmpty) {
      for (var element in routes) {
        final node = Route(element);
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
}

/// GPX file command to split a given file into a set of files one for each
/// track or route defined in the file
class GPXSplitFileCommand extends GPXFile {
  GPXSplitFileCommand(super._file);
}

/// GPX file command to merge all track or route definitions in the file into
/// single route or track
class GPXMergeFileCommand extends GPXFile {
  GPXMergeFileCommand(super._file);
}
