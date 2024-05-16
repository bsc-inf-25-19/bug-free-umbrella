import 'dart:convert';
import 'dart:developer';

import 'package:geocoding_assistant/models/map_model.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

class MapController extends GetxController {
  List<MapModel> mapModel = <MapModel>[].obs;
  var markers = RxSet<Marker>();
  var isLoading = false.obs;

  fetchLocations(String searchText) async {
    try {
      isLoading(true);
      final Uri url = Uri.parse('http://localhost:3000/search?text=$searchText');
      log('Requesting URL: $url');
      http.Response response = await http.get(url);
      if (response.statusCode == 200) {
        // Data successfully fetched
        var result = jsonDecode(response.body);
        log(result.toString());
        mapModel.clear();
        mapModel.addAll(RxList<Map<String, dynamic>>.from(result)
            .map((e) => MapModel.fromJson(e))
            .toList());
      } else {
        print('Error fetching data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error while getting data: $e');
    } finally {
      isLoading(false);
      print('Finally: $mapModel');
      createMarkers();
    }
  }

  createMarkers() {
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
}
