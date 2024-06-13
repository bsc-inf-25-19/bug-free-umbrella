import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import '../controllers/map_controller.dart';

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showWelcomeDialog(context);
    });
    mapController.fetchLocations('', context);
  }

  void _showWelcomeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('MALAWI GEOCODING ASSISTANT'),
          content: const Text('Welcome! Start by searching for an address.'),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
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
              child: Card(
                elevation: 10,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TypeAheadField<String>(
                          textFieldConfiguration: TextFieldConfiguration(
                            controller: _searchController,
                            decoration: InputDecoration(
                              hintText: 'Enter address(e.g 25, masawu court, matawale, zomba, eastern region)',
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(vertical: 8.0),
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
                          noItemsFoundBuilder: (context) => const SizedBox.shrink(),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.search),
                        onPressed: () {
                          final searchText = _searchController.text.trim();  // Trim whitespace

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
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
