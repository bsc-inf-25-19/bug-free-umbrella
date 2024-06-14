import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../controllers/map_controller.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final MapController mapController = Get.put(MapController());
  final TextEditingController _searchController = TextEditingController();
  List<String> searchHistory = []; // Track selected suggestions separately

  @override
  void initState() {
    super.initState();
    loadSearchHistory();
    mapController.fetchLocations('', context);
  }

  Future<void> loadSearchHistory() async {
    final prefs = await SharedPreferences.getInstance();
    searchHistory = prefs.getStringList('searchHistory') ?? [];
    setState(() {}); // Update the UI with loaded history
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Obx(
                  () => GoogleMap(
                initialCameraPosition: const CameraPosition(
                  target: LatLng(-15.3875846, 35.3368270),
                  zoom: 13,
                ),
                markers: Set<Marker>.from(mapController.markers),
                polygons: Set<Polygon>.from(mapController.polygons),
                onMapCreated: (GoogleMapController controller) {
                  mapController.googleMapController = controller;
                },
              ),
            ),
            Positioned(
              top: 10,
              left: 15,
              right: 15,
              child: Column(
                children: [
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TypeAheadField<String>(
                            textFieldConfiguration: TextFieldConfiguration(
                              controller: _searchController,
                              decoration: InputDecoration(
                                hintText: 'Search an address...',
                                hintStyle: TextStyle(color: Colors.black.withOpacity(0.3)), // Adjust opacity here
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30),
                                  borderSide: BorderSide.none,
                                ),
                                filled: true,
                                fillColor: Colors.white,
                                contentPadding: const EdgeInsets.symmetric(
                                    vertical: 0, horizontal: 20),
                                suffixIcon: IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    _searchController.clear();
                                    mapController.fetchLocations('', context);
                                  },
                                ),
                              ),
                            ),
                            suggestionsCallback: (pattern) async {
                              return searchHistory
                                  .where((item) => item
                                  .toLowerCase()
                                  .contains(pattern.toLowerCase()))
                                  .toList();
                            },
                            itemBuilder: (context, suggestion) {
                              return ListTile(
                                title: Text(suggestion),
                              );
                            },
                            onSuggestionSelected: (suggestion) {
                              _searchController.text = suggestion;
                              mapController.fetchLocations(suggestion, context);
                              updateSearchHistory(suggestion); // Update history on selection
                            },
                            noItemsFoundBuilder: (context) => const SizedBox.shrink(),

                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.search),
                          onPressed: () {
                            final searchText = _searchController.text
                                .trim(); // Trim whitespace

                            if (searchText.isEmpty) {
                              Fluttertoast.showToast(
                                msg: 'No address entered',
                                toastLength: Toast.LENGTH_SHORT,
                                gravity: ToastGravity.BOTTOM,
                                timeInSecForIosWeb: 1,
                                backgroundColor: Colors.grey[800],
                                textColor: Colors.white,
                                fontSize: 16.0,
                              );
                            } else {
                              log('Search button clicked with text: $searchText'); // Debug log
                              mapController.fetchLocations(searchText, context);
                              updateSearchHistory(searchText); // Update history on search button click
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
            Obx(
                  () => mapController.isLoading.value
                  ? Center(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const CircularProgressIndicator(),
                ),
              )
                  : Container(),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> updateSearchHistory(String searchText) async {
    final prefs = await SharedPreferences.getInstance();
    if (searchHistory.contains(searchText)) {
      searchHistory.remove(searchText);
    }
    searchHistory.insert(0, searchText); // Insert at the beginning for newest first order
    prefs.setStringList('searchHistory', searchHistory);
    setState(() {}); // Update UI with the new history
  }
}
