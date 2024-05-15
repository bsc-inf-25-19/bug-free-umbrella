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

  fetchLocations() async {
    try {
      isLoading(true);
      http.Response response = await http.get(Uri.tryParse('http://192.168.201.205:3000/search?text=matawale%2025%20Ngwalangwa')!);
      if (response.statusCode == 200) {
        ///data successfully
        var result = jsonDecode(response.body);
        log(result.toString());
        mapModel.addAll(RxList<Map<String, dynamic>>.from(result)
            .map((e) => MapModel.fromJson(e))
            .toList());
      } else {
        print('error fetching data');
      }
    } catch (e) {
      print('Error while getting data is $e');
    } finally {
      isLoading(false);
      print('finaly: $mapModel');
      createMarkers();
    }
  }

  createMarkers() {
    mapModel.forEach((element) {
      markers.add(Marker(
        markerId: MarkerId(element.id.toString()),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        position: LatLng(element.latitude, element.longitude),
        infoWindow: InfoWindow(title: element.house_no, snippet: element.area_name),
        onTap: () {
          print('market tapped');
        },
      ));
    });
  }
}
