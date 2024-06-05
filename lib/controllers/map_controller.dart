import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/map_model.dart';

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

  Future<void> fetchLocations(String searchText, BuildContext context) async {
    try {
      isLoading(true);
      final response = await http.get(
          Uri.parse('http://146.190.224.204:3000/search?text=$searchText')
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
          createMarkers(context);
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

  void createMarkers(BuildContext context) {
    markers.clear();
    for (var element in mapModel) {
      markers.add(Marker(
        markerId: MarkerId(element.id.toString()),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        position: LatLng(element.latitude, element.longitude),
        infoWindow: InfoWindow(
          title: element.house_no,
          snippet: element.area_name,
          onTap: () => _showAddressModal(context, element),
        ),
      ));
    }
  }

  void _showAddressModal(BuildContext context, MapModel address) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('House Number: ${address.house_no}', style: TextStyle(fontWeight: FontWeight.bold)),
              Text('Road Name: ${address.road_name}'),
              Text('Area Name: ${address.area_name}'),
              Text('Region: ${address.region}'),
              Text('Latitude: ${address.latitude}'),
              Text('Longitude: ${address.longitude}'),
              const SizedBox(height: 10),
              Row(
                children: [
                  IconButton(
                    onPressed: () {
                      final url = 'https://www.google.com/maps/dir/?api=1&destination=${address.latitude},${address.longitude}&destination_place_id=${address.id}';
                      _launchURL(url);
                    },
                    icon: Icon(Icons.navigation),
                  ),
                  IconButton(
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: address.toFullAddress()));
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Address copied to clipboard')));
                    },
                    icon: Icon(Icons.copy),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
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
