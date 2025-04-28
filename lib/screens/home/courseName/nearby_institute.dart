import 'dart:convert';

import 'package:aieducator/components/modal/error_modal.dart';
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
  final LatLng _origin = LatLng(37.773972, -122.431297); // San Francisco
  final LatLng _destination = LatLng(34.052235, -118.243683); // Los Angeles

  final Set<Polyline> _polylines = {};
  final Set<Marker> _markers = {};
  @override
  void initState() {
    _markers.add(Marker(
      markerId: MarkerId('origin'),
      position: _origin,
      infoWindow: InfoWindow(title: 'Origin'),
    ));
    _markers.add(Marker(
      markerId: MarkerId('destination'),
      position: _destination,
      infoWindow: InfoWindow(title: 'Destination'),
    ));

    _getDirections();
    super.initState();
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  Future<void> _getDirections() async {
    const String apiKey = "AIzaSyCzZMy01KjsngSrrvOAcGi8HfElYxW-zT8"; 
    final String url =
        "https://maps.googleapis.com/maps/api/directions/json?origin=${_origin.latitude},${_origin.longitude}&destination=${_destination.latitude},${_destination.longitude}&key=$apiKey";

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final points = data['routes'][0]['overview_polyline']['points'];
      _addPolyline(points);
    } else {
      print('Failed to load directions');
    }
  }

  void _addPolyline(String encodedPolyline) {
    List<LatLng> polylineCoordinates = _decodePolyline(encodedPolyline);

    setState(() {
      _polylines.add(Polyline(
        polylineId: PolylineId('route'),
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

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          Container(
            height: 475,
            width: double.infinity,
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
          const SizedBox(
            height: 20,
          ),
          Container(
            height: 120,
            width: double.infinity,
            decoration: BoxDecoration(
                border: Border.all(width: 2, color: Colors.grey),
                borderRadius: BorderRadius.circular(25)),
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  widget.courseName,
                  style: AppTextStyles.textLabelStyle(),
                ),
                Text(
                  "Bahria University Islamabad",
                  style: AppTextStyles.textLabelStyle()
                      .copyWith(color: Colors.white70),
                ),
                Text(
                  "E-8, Islamabad",
                  style: AppTextStyles.textLabelSmallStyle(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
