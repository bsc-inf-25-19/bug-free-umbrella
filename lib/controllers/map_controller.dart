import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/map_model.dart';
import '../utils/convex_hull.dart';

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
    log('Search text: $searchText'); // Debug log
    try {
      isLoading(true);
      final response = await http.get(
          Uri.parse('http://146.190.224.204:3000/search?text=$searchText'));

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        log('API Response: $result'); // Debug log

        mapModel.clear();
        result.forEach((item) {
          try {
            mapModel.add(MapModel.fromJson(item));
          } catch (e) {
            log('Error parsing item: $item\nError: $e');
          }
        });

        if (searchText.contains(RegExp(r'\d'))) {
          // Contains a number, assume it's a house search
          createMarkers(context);
          polygons.clear(); // Clear polygons for house search
        } else {
          // No number, assume it's an area search
          createPolygons(context);
          markers.clear(); // Clear markers for area search
        }

        if (mapModel.isNotEmpty) {
          final firstResult = mapModel.first;
          final target =
          LatLng(firstResult.latitude, firstResult.longitude);
          googleMapController?.animateCamera(
            CameraUpdate.newLatLngZoom(target, 15),
          );
        }
        addSearchToHistory(searchText);
      } else {
        log('Error fetching data: ${response.statusCode}');
        handleNetworkError();
      }
    } catch (e) {
      log('Error while getting data: $e');
      handleNetworkError();
    } finally {
      isLoading(false);
    }
  }

  void createMarkers(BuildContext context) {
    markers.clear();
    for (var element in mapModel) {
      markers.add(Marker(
        markerId: MarkerId(element.id.toString()),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        position: LatLng(element.latitude, element.longitude),
        infoWindow: InfoWindow(
          title: '${element.house_no}, ${element.road_name}',
          snippet: '${element.area_name}......',
          onTap: () => _showAddressModal(context, element),
        ),
      ));
    }
  }

  void createPolygons(BuildContext context) {
    polygons.clear();
    List<LatLng> points =
    mapModel.map((e) => LatLng(e.latitude, e.longitude)).toList();
    List<MapLatLng> convexHullPoints =
    convexHull(points.map((e) => MapLatLng(e.latitude, e.longitude)).toList());
    List<LatLng> polygonPoints =
    convexHullPoints.map((e) => LatLng(e.latitude, e.longitude)).toList();

    log('Convex Hull Points: $polygonPoints'); // Debug log

    polygons.add(
      Polygon(
        polygonId: const PolygonId('areaPolygon'),
        points: polygonPoints,
        strokeColor: Colors.blue,
        strokeWidth: 2,
        fillColor: Colors.blue.withOpacity(0.15),
      ),
    );

    log('Polygons added: ${polygons.length}'); // Debug log
  }

  void _showAddressModal(BuildContext context, MapModel address) {
    showModalBottomSheet(
      context: context,
      elevation: 10,
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('House Number: ${address.house_no}', style: const TextStyle(fontWeight: FontWeight.bold)),
              Text('Road Name: ${address.road_name}'),
              Text('Area Name: ${address.area_name}'),
              Text('District: ${address.district}'),
              Text('Region: ${address.region}'),
              Text('Postcode: ${address.postcode}'),
              Text('Latitude: ${address.latitude}'),
              Text('Longitude: ${address.longitude}'),
              const SizedBox(height: 10),
              Text(address.toFullAddress()), // Display full address

              Row(
                children: [
                  IconButton(
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: address.toFullAddress()));
                      Fluttertoast.showToast(
                        msg: 'Address copied to clipboard',
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.BOTTOM,
                        timeInSecForIosWeb: 1,
                        backgroundColor: Colors.grey[800],
                        textColor: Colors.white,
                        fontSize: 16.0,
                      );
                    },
                    icon: const Icon(Icons.copy),
                  ),
                  IconButton(
                    onPressed: () {
                      _shareAddress(context, address.toFullAddress());
                    },
                    icon: const Icon(Icons.share),
                  ),
                  IconButton(
                    onPressed: () {
                      final destination = '${address.latitude},${address.longitude}';
                      final url = 'https://www.google.com/maps/dir/?api=1&destination=$destination';
                      _launchURL(url);
                    },
                    icon: const Icon(Icons.directions),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _shareAddress(BuildContext context, String address) {
    final RenderBox box = context.findRenderObject() as RenderBox;
    Share.share(
      address,
      sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size,
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
      searchHistory.insert(0, searchText);
      final prefs = await SharedPreferences.getInstance();
      prefs.setStringList('searchHistory', searchHistory);
    }
  }

  Future<void> loadSearchHistory() async {
    final prefs = await SharedPreferences.getInstance();
    searchHistory.value = prefs.getStringList('searchHistory') ?? [];
  }

  void handleNetworkError() {
    Fluttertoast.showToast(
      msg: 'Please check your internet connection.',
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.grey[800],
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }
}
