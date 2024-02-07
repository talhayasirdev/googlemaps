import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: MapSample(),
    );
  }
}

//AIzaSyAwOWjAjFhrKZQ9fHnC595X73rDY_B3du8
class MapSample extends StatefulWidget {
  String api_key = 'AIzaSyAwOWjAjFhrKZQ9fHnC595X73rDY_B3du8';
  MapSample({super.key});

  @override
  State<MapSample> createState() => MapSampleState();
}

class MapSampleState extends State<MapSample> {
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(24.80812510442206, 67.03984548465584),
    zoom: 14.4746,
  );
  LatLng lastPoints = LatLng(24.80812510442206, 67.03984548465584);
  bool drawPoints = true;

//polylines
  PolylinePoints polylinePoints = PolylinePoints();

  Map<PolylineId, Polyline> polylines = {};

  List<LatLng> polylineCoordinates = [];
  Set<Marker> markers = {
    Marker(
        markerId: MarkerId('12'),
        position: LatLng(24.80812510442206, 67.03984548465584)),
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GoogleMap(
        mapType: MapType.normal,
        initialCameraPosition: _kGooglePlex,
        polylines: Set<Polyline>.of(polylines.values),
        onLongPress: (latlong) async {
          print('long press detected');
          if (drawPoints) {
            await getDirections(latlong);
          }
          lastPoints = latlong;
          drawPoints = !drawPoints;
          //adding marker
          Marker resultMarker = Marker(
            markerId: MarkerId(DateTime.now().toString()),
            infoWindow: InfoWindow(
              title: "${'new markers'}",
            ),
            position: LatLng(latlong.latitude, latlong.longitude),
          );
// Add it to Set
          markers.add(resultMarker);

          setState(() {});
        },
        markers: markers,
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
        },
      ),
    );
  }

  getDirections(LatLng pointLocation) async {
    LatLng startLocation = lastPoints;
    LatLng endLocation =
        LatLng(pointLocation.latitude, pointLocation.longitude);

    List<LatLng> polylineCoordinates = [];
    PolylinePoints polylinePoints = PolylinePoints();
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      widget.api_key,
      PointLatLng(startLocation.latitude, startLocation.longitude),
      PointLatLng(endLocation.latitude, endLocation.longitude),
      travelMode: TravelMode.driving,
    );

    if (result.points.isNotEmpty) {
      result.points.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });
    } else {
      print(result.errorMessage);
    }
    addPolyLine(polylineCoordinates);
  }

  addPolyLine(List<LatLng> polylineCoordinates) {
    PolylineId id = PolylineId(DateTime.now().toString());
    Polyline polyline = Polyline(
      polylineId: id,
      color: Colors.blue,
      points: polylineCoordinates,
      width: 8,
    );
    polylines[id] = polyline;
    setState(() {});
  }
}
