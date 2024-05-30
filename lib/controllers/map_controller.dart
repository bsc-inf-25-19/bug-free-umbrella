import 'dart:convert';
import 'dart:developer';
import 'package:geocoding_assistant/models/map_model.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

// LatLng class for convex hull algorithm
class MapLatLng {
  final double latitude;
  final double longitude;

  MapLatLng(this.latitude, this.longitude);

  double get x => longitude;
  double get y => latitude;
}

// Convex hull algorithm
List<MapLatLng> convexHull(List<MapLatLng> points) {
  if (points.length <= 3) {
    return points;
  }

  points.sort((a, b) => a.x.compareTo(b.x));

  List<MapLatLng> lower = [];
  for (MapLatLng point in points) {
    while (lower.length >= 2 &&
        cross(lower[lower.length - 2], lower[lower.length - 1], point) <= 0) {
      lower.removeLast();
    }
    lower.add(point);
  }

  List<MapLatLng> upper = [];
  for (MapLatLng point in points.reversed) {
    while (upper.length >= 2 &&
        cross(upper[upper.length - 2], upper[upper.length - 1], point) <= 0) {
      upper.removeLast();
    }
    upper.add(point);
  }

  lower.removeLast();
  upper.removeLast();
  lower.addAll(upper);

  return lower;
}

double cross(MapLatLng o, MapLatLng a, MapLatLng b) {
  return (a.x - o.x) * (b.y - o.y) - (a.y - o.y) * (b.x - o.x);
}

class MapController extends GetxController {
  List<MapModel> mapModel = <MapModel>[].obs;
  var polygons = RxSet<Polygon>();
  var markers = RxSet<Marker>();
  var isLoading = false.obs;
  GoogleMapController? googleMapController;
  var searchHistory = <String>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadSearchHistory();
  }

  Future<void> fetchLocations(String searchText) async {
    try {
      isLoading(true);
      final response = await http.get(
        Uri.parse('http://localhost:3000/search?text=$searchText'),
      );

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        log(result.toString());

        mapModel.clear();
        mapModel.addAll(result.map<MapModel>((e) => MapModel.fromJson(e)).toList());

        bool isPostcode = searchText.contains(RegExp(r'^\d+$')) && searchText.length >= 12;
        bool isAreaSearch = !searchText.contains(RegExp(r'\d'));

        if (isPostcode || isAreaSearch) {
          createPolygon();
        } else {
          createMarkers();
        }

        if (mapModel.isNotEmpty) {
          final firstResult = mapModel.first;
          final target = LatLng(firstResult.latitude, firstResult.longitude);
          googleMapController?.animateCamera(
            CameraUpdate.newLatLngZoom(target, 15),
          );
        }
        addSearchToHistory(searchText);  // Save search text to history
      } else {
        print('Error fetching data');
      }
    } catch (e) {
      print('Error while getting data: $e');
    } finally {
      isLoading(false);
    }
  }

  void createPolygon() {
    polygons.clear();
    List<MapLatLng> points = mapModel.map((element) => MapLatLng(element.latitude, element.longitude)).toList();
    List<MapLatLng> hullPoints = convexHull(points);

    polygons.add(Polygon(
      polygonId: PolygonId('polygon_1'),
      points: hullPoints.map((p) => LatLng(p.latitude, p.longitude)).toList(),
      strokeColor: Colors.blue,
      strokeWidth: 2,
      fillColor: Colors.blue.withOpacity(0.15),
    ));
  }

  void createMarkers() {
    markers.clear();
    for (var element in mapModel) {
      markers.add(Marker(
        markerId: MarkerId(element.id.toString()),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        position: LatLng(element.latitude, element.longitude),
        infoWindow: InfoWindow(
          title: element.house_no,
          snippet: element.area_name,
        ),
        onTap: () {
          print('Marker tapped');
        },
      ));
    }
  }

  Future<void> addSearchToHistory(String searchText) async {
    if (!searchHistory.contains(searchText)) {
      searchHistory.add(searchText);
      final prefs = await SharedPreferences.getInstance();
      prefs.setStringList('searchHistory', searchHistory);
    }
  }

  Future<void> loadSearchHistory() async {
    final prefs = await SharedPreferences.getInstance();
    searchHistory.value = prefs.getStringList('searchHistory') ?? [];
  }
}
