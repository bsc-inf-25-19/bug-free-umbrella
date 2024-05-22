import 'dart:convert';
import 'dart:developer';
import 'package:geocoding_assistant/models/map_model.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class MapController extends GetxController {
  List<MapModel> mapModel = <MapModel>[].obs;
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
          Uri.parse('http://localhost:3000/search?text=$searchText')
      );

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        log(result.toString());

        mapModel.clear();
        mapModel.addAll(result.map<MapModel>((e) => MapModel.fromJson(e)).toList());
        createMarkers();

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
