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
  GoogleMapController? googleMapController;

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
}
