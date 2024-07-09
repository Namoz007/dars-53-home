import 'dart:convert';
import 'dart:math';

import 'package:dars_52/services/location_services.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_places_autocomplete_text_field/google_places_autocomplete_text_field.dart';
import 'package:google_places_autocomplete_text_field/model/prediction.dart';
import 'package:http/http.dart' as http;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isLoading = false;
  LatLng myLocation = LatLng(0, 0);
  final _formKey = GlobalKey<FormState>();
  final _yourProxyURL = 'https://your-proxy.com/';
  final _textController = TextEditingController();
  AutovalidateMode _autovalidateMode = AutovalidateMode.disabled;
  late GoogleMapController mapController;
  final LatLng _center = const LatLng(45.521563, -122.677433);
  LatLng najotTalim = const LatLng(41.2856806, 69.2034646);
  LatLng myCurrentPosition = LatLng(41.2856806, 69.2034646);
  Set<Marker> myMarkers = {};
  Set<Polyline> polylines = {};
  List<LatLng> myPositions = [];

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  void initState() {
    super.initState();

    Future.delayed(Duration.zero, () async {
      setState(() {
        isLoading = true;
      });
      await LocationService.getCurrentLocation();
        najotTalim = LatLng(LocationService.currentLocation!.latitude ?? 41.2904009, LocationService.currentLocation!.longitude ?? 69.1684991);
        myLocation = LatLng(LocationService.currentLocation!.latitude ?? 41.2904009, LocationService.currentLocation!.longitude ?? 69.1684991);
      setState(() {
        isLoading = false;
      });
    });

  }

  void onCameraMove(CameraPosition position) {
    setState(() {
      myCurrentPosition = position.target;
    });
  }

  void watchMyLocation() {
    LocationService.getLiveLocation().listen((location) {
      setState(() {
        myLocation = LatLng(location.latitude!, location.longitude!);
      });
    });
  }

  void addLocationMarker() {
    myMarkers.add(
      Marker(
        markerId: MarkerId(myMarkers.length.toString()),
        position: myCurrentPosition,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
      ),
    );

    myPositions.add(myCurrentPosition);

    if (myPositions.length == 2) {
      LocationService.fetchPolylinePoints(
        myPositions[0],
        myPositions[1],
      ).then((List<LatLng> positions) {
        polylines.add(
          Polyline(
            polylineId: PolylineId(UniqueKey().toString()),
            color: Colors.blue,
            width: 5,
            points: positions,
          ),
        );

        setState(() {});
      });
    }
  }

  Future<void> _onSubmit() async {
    if (_formKey.currentState!.validate()) {
      final url =
          'https://maps.googleapis.com/maps/api/geocode/json?address=${_textController.text}&key=AIzaSyBEjfX9jrWudgRcWl2scld4R7s0LtlaQmQ';
      final response = await http.get(Uri.parse(url));
      if(response != null){
        final location = jsonDecode(response.body)['results'][0]['geometry']['location'];
        final lat = location['lat'];
        final lng = location['lng'];
        najotTalim = LatLng(lat, lng);
        myCurrentPosition = LatLng(lat, lng);
      }
      setState(() => _autovalidateMode = AutovalidateMode.always);
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    watchMyLocation();
    return Scaffold(
      appBar: AppBar(
        title: Form(
          key: _formKey,
          autovalidateMode: _autovalidateMode,
          child: GooglePlacesAutoCompleteTextFormField(
            textEditingController: _textController,
            googleAPIKey: "AIzaSyBEjfX9jrWudgRcWl2scld4R7s0LtlaQmQ",
            decoration: const InputDecoration(
              hintText: 'Enter your address',
              labelText: 'Address',
              labelStyle: TextStyle(color: Colors.purple),
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value!.isEmpty) {
                return 'Please enter some text';
              }
              return null;
            },
            // proxyURL: _yourProxyURL,
            maxLines: 1,
            overlayContainer: (child) => Material(
              elevation: 1.0,
              color: Colors.green,
              borderRadius: BorderRadius.circular(12),
              child: child,
            ),
            getPlaceDetailWithLatLng: (prediction) {
              print('placeDetails${prediction.lng}');
            },
            itmClick: (Prediction prediction) =>
            _textController.text = prediction.description!,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _onSubmit,
            child: const Text('Submit'),
          ),
          // IconButton(
          //   onPressed: () {
          //     mapController.animateCamera(
          //       CameraUpdate.zoomOut(),
          //     );
          //   },
          //   icon: Icon(Icons.remove_circle),
          // ),
          // IconButton(
          //   onPressed: () {
          //     mapController.animateCamera(
          //       CameraUpdate.zoomIn(),
          //     );
          //   },
          //   icon: Icon(Icons.add_circle),
          // ),
        ],
      ),
      body: isLoading ? Center(child: CircularProgressIndicator(color: Colors.red,),) :  Stack(
        children: [
          GoogleMap(
            buildingsEnabled: true,
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(
              target: najotTalim,
              zoom: 16.0,
            ),
            trafficEnabled: true,
            onCameraMove: onCameraMove,
            mapType: MapType.hybrid,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            markers: {
              Marker(
                markerId: const MarkerId("najotTalim"),
                icon: BitmapDescriptor.defaultMarker,
                position: najotTalim,
                infoWindow: const InfoWindow(
                  title: "Najot Ta'lim",
                  snippet: "Xush kelibsiz",
                ),
              ),
              Marker(
                markerId: const MarkerId("myCurrentPosition"),
                icon: BitmapDescriptor.defaultMarkerWithHue(
                  BitmapDescriptor.hueBlue,
                ),
                position: myCurrentPosition,
                infoWindow: const InfoWindow(
                  title: "Najot Ta'lim",
                  snippet: "Xush kelibsiz",
                ),
              ),
              Marker(markerId: MarkerId("My Location"),icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),position: myLocation,infoWindow: InfoWindow(
                title: "My Location"
              )),
              ...myMarkers,
            },
            polylines: polylines,
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      floatingActionButton: myMarkers.length < 2 ? FloatingActionButton(
        onPressed: addLocationMarker,
        child: const Icon(Icons.add),
      ) : FloatingActionButton(onPressed: (){
        setState(() {
          myMarkers = {};
          polylines = {};
        });
      },child: Icon(Icons.cancel,color: Colors.red,),)
    );
  }
}