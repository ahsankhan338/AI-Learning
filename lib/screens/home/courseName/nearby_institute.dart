import 'dart:convert';

import 'package:aieducator/api/institutes_api.dart';
import 'package:aieducator/components/spinner.dart';
import 'package:aieducator/components/toast.dart';
import 'package:aieducator/constants/constants.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

class NearbyInstituteScreen extends StatefulWidget {
  final String courseName;
  final String categoryId;

  const NearbyInstituteScreen({
    super.key,
    required this.courseName,
    required this.categoryId,
  });

  @override
  State<NearbyInstituteScreen> createState() => _NearbyInstituteScreenState();
}

class _NearbyInstituteScreenState extends State<NearbyInstituteScreen> {
  late GoogleMapController mapController;
  final String apiKey = "AIzaSyCzZMy01KjsngSrrvOAcGi8HfElYxW-zT8";

  static const LatLng _origin = LatLng(33.681560, 72.838093);

  final Set<Polyline> _polylines = {};
  final Set<Marker> _markers = {};
  List<dynamic> institutes = [];

  PageController _pageController = PageController();
  int _currentPage = 0;
  bool isLoading = true;

  final InstitutesApi _institutesApi = InstitutesApi();

  LatLng? _currentDestination;

  @override
  void initState() {
    _markers.add(const Marker(
      markerId: MarkerId('origin'),
      position: _origin,
      infoWindow: InfoWindow(title: 'Origin'),
    ));
    fetchInstitutes();

    super.initState();
  }

  Future<void> fetchInstitutes() async {
    try {
      setState(() => isLoading = true);

      final fetchedInstitutes = await _institutesApi.fetchInstitutes(
        courseName: widget.courseName,
      );

      institutes = fetchedInstitutes;

      _markers.clear(); // Clear old markers first
      for (var uni in institutes) {
        _markers.add(Marker(
          markerId: MarkerId(uni['name']),
          position: LatLng(uni['lat'], uni['lng']),
          infoWindow: InfoWindow(title: uni['name']),
        ));
      }

      if (institutes.isNotEmpty) {
        _currentDestination = LatLng(
          institutes[0]['lat'],
          institutes[0]['lng'],
        );
        await _updateRoute();
        
      }
    } catch (e) {
      showToast(message: "Error: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  void _addPolyline(String encodedPolyline) {
    List<LatLng> polylineCoordinates = _decodePolyline(encodedPolyline);

    setState(() {
      _polylines.add(Polyline(
        polylineId: const PolylineId('route'),
        color: Colors.blue,
        width: 5,
        points: polylineCoordinates,
      ));
    });
  }

  List<LatLng> _decodePolyline(String encoded) {
    List<LatLng> points = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;

      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);

      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);

      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      points.add(LatLng(lat / 1E5, lng / 1E5));
    }
    return points;
  }

  Future<void> _updateRoute() async {
    if (_currentDestination == null) return;
    final String url =
        "https://maps.googleapis.com/maps/api/directions/json?origin=${_origin.latitude},${_origin.longitude}&destination=${_currentDestination!.latitude},${_currentDestination!.longitude}&key=$apiKey";

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final points = data['routes'][0]['overview_polyline']['points'];

      setState(() {
        _polylines.clear(); // 🔥 Clear old polyline
        _addPolyline(points); // 🔥 Add new polyline
      });
    } else {
      print('Failed to load new directions');
    }
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const Center(
            child: SpinLoader()
          )
        : Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                Container(
                  height: 475,
                  decoration:
                      BoxDecoration(borderRadius: BorderRadius.circular(25)),
                  width: double.infinity,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(25),
                    child: GoogleMap(
                      onMapCreated: _onMapCreated,
                      initialCameraPosition: CameraPosition(
                        target: _origin,
                        zoom: 6.5,
                      ),
                      markers: _markers,
                      polylines: _polylines,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),

                SizedBox(
                  height: 170,
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: institutes.length,
                    onPageChanged: (index) {
                      setState(() {
                        _currentPage = index;
                        _currentDestination = LatLng(
                          institutes[index]['lat'],
                          institutes[index]['lng'],
                        );
                      });
                      _updateRoute();
                    },
                    itemBuilder: (context, index) {
                      final university = institutes[index];
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(25),
                          border: Border.all(width: 2, color: Colors.grey),
                          color: const Color(0xFF0E2C56),
                        ),
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              widget.courseName,
                              style: AppTextStyles.textLabelStyle(),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              university['name'],
                              style: AppTextStyles.textLabelStyle().copyWith(
                                  color: Colors.white70,
                                  fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              "Islamabad",
                              style: AppTextStyles.textLabelSmallStyle(),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(institutes.length, (index) {
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: _currentPage == index ? 10 : 8,
                      height: _currentPage == index ? 10 : 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color:
                            _currentPage == index ? Colors.white : Colors.grey,
                      ),
                    );
                  }),
                )
                // Container(
                //   height: 120,
                //   width: double.infinity,
                //   decoration: BoxDecoration(
                //       border: Border.all(width: 2, color: Colors.grey),
                //       borderRadius: BorderRadius.circular(25)),
                //   padding: const EdgeInsets.all(14),
                //   child: Column(
                //     crossAxisAlignment: CrossAxisAlignment.start,
                //     mainAxisAlignment: MainAxisAlignment.center,
                //     children: [
                //       Text(
                //         widget.courseName,
                //         style: AppTextStyles.textLabelStyle(),
                //       ),
                //       Text(
                //         "Bahria University Islamabad",
                //         style: AppTextStyles.textLabelStyle()
                //             .copyWith(color: Colors.white70),
                //       ),
                //       Text(
                //         "E-8, Islamabad",
                //         style: AppTextStyles.textLabelSmallStyle(),
                //       ),
                //     ],
                //   ),
                // ),
              ],
            ),
          );
  }
}
