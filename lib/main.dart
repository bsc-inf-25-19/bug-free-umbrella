import 'package:flutter/material.dart';
import 'package:geocoding_assistant/controllers/map_controller.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

void main() {
  runApp(const MaterialApp(
    home: MyApp(),
  ));
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final MapController mapController = Get.put(MapController());
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initially fetch with empty query
    mapController.fetchLocations('');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: const InputDecoration(
                        labelText: 'Enter your search query',
                        border: OutlineInputBorder(),
                        isDense: true, // Reduce the height of the input field
                      ),
                    ),
                  ),
                  const SizedBox(width: 8.0), // Add some space between the text field and the button
                  ElevatedButton(
                    onPressed: () {
                      final searchText = _searchController.text;
                      mapController.fetchLocations(searchText);
                    },
                    child: const Text('Search'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Obx(
                    () => GoogleMap(
                  initialCameraPosition: const CameraPosition(
                    target: LatLng(-15.3875846, 35.3368270), // Initial location
                    zoom: 13,
                  ),
                  markers: Set<Marker>.from(mapController.markers),
                  onMapCreated: (GoogleMapController controller) {
                    mapController.googleMapController = controller;
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
