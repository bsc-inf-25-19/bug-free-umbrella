import 'package:flutter/material.dart';
import 'package:geocoding_assistant/controllers/map_controller.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

main() {
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
  MapController mapController = Get.put(MapController());
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initially fetch with empty query
    mapController.fetchLocations(""); 
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
                      decoration: InputDecoration(
                        labelText: 'Enter your search query',
                        border: OutlineInputBorder(),
                        isDense: true, // Reduce the height of the input field
                      ),
                    ),
                  ),
                  SizedBox(width: 8.0), // Add some space between the text field and the button
                  ElevatedButton(
                    onPressed: () {
                      String searchText = _searchController.text;
                      mapController.fetchLocations(searchText);
                    },
                    child: Text('Search'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Obx(
                () => GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: LatLng(-15.3875846, 35.3368270), // Initial location
                    zoom: 13,
                  ),
                  markers: Set<Marker>.from(mapController.markers),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

