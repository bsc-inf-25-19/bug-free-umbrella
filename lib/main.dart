import 'package:flutter/material.dart';
import 'package:geocoding_assistant/controllers/map_controller.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final MapController mapController = Get.put(MapController());
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initially fetch with empty query
    mapController.fetchLocations('', context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TypeAheadField<String>(
                          textFieldConfiguration: TextFieldConfiguration(
                            controller: _searchController,
                            decoration: const InputDecoration(
                              labelText: 'Enter your search query',
                              border: OutlineInputBorder(),
                              isDense: true, // Reduce the height of the input field
                            ),
                          ),
                          suggestionsCallback: (pattern) {
                            return mapController.searchHistory.where((historyItem) =>
                                historyItem.toLowerCase().contains(pattern.toLowerCase()));
                          },
                          itemBuilder: (context, suggestion) {
                            return ListTile(
                              title: Text(suggestion),
                            );
                          },
                          onSuggestionSelected: (suggestion) {
                            _searchController.text = suggestion;
                            mapController.fetchLocations(suggestion, context);
                          },
                        ),
                      ),
                      const SizedBox(width: 8.0), // Add some space between the text field and the button
                      ElevatedButton(
                        onPressed: () {
                          final searchText = _searchController.text;
                          mapController.fetchLocations(searchText, context);
                        },
                        child: const Text('Search'),
                      ),
                    ],
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
                  polygons: Set<Polygon>.from(mapController.polygons),
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
