import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:presensi_flutter_new/models/save-presensi-response.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_maps/maps.dart';
import 'package:http/http.dart' as myHttp;

class SimpanPage extends StatefulWidget {
  const SimpanPage({Key? key}) : super(key: key);

  @override
  State<SimpanPage> createState() => _SimpanPageState();
}

class _SimpanPageState extends State<SimpanPage> {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  late Future<String> _token;

  @override
  void initState() {
    super.initState();
    _token = _prefs.then((SharedPreferences prefs) {
      return prefs.getString("token") ?? "";
    });
  }

  Future<LocationData?> _currenctLocation() async {
    bool serviceEnable;
    PermissionStatus permissionGranted;

    Location location = new Location();

    serviceEnable = await location.serviceEnabled();

    if (!serviceEnable) {
      serviceEnable = await location.requestService();
      if (!serviceEnable) {
        return null;
      }
    }

    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return null;
      }
    }

    return await location.getLocation();
  }

  Future savePresensi(latitude, longitude) async {
    SaveResponseModel savePresensiResponseModel;
    Map<String, String> body = {
      "latitude": latitude.toString(),
      "longitude": longitude.toString()
    };

    Map<String, String> headers = {'Authorization': 'Bearer ' + await _token};

    var response = await myHttp.post(
        Uri.parse("http://192.168.1.88:8001/api/save-presensi"),
        body: body,
        headers: headers);

    savePresensiResponseModel =
        SaveResponseModel.fromJson(json.decode(response.body));

    if (savePresensiResponseModel.success) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Sukses simpan Presensi')));
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Gagal simpan Presensi')));
    }
  }

  @override
  Widget build(BuildContext context) {
    var screenHeight = MediaQuery.of(context).size.height;
    var screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text("Presensi"),
        backgroundColor: Colors.green[700],
      ),
      body: FutureBuilder<LocationData?>(
        future: _currenctLocation(),
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasData) {
            final LocationData currentLocation = snapshot.data;
            return SafeArea(
              child: Padding(
                padding: EdgeInsets.all(screenWidth * 0.05),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: screenHeight * 0.4,
                      decoration: BoxDecoration(
                        color: Colors.green[100],
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            offset: Offset(0, 4),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: SfMaps(
                          layers: [
                            MapTileLayer(
                              initialFocalLatLng: MapLatLng(
                                  currentLocation.latitude!,
                                  currentLocation.longitude!),
                              initialZoomLevel: 15,
                              initialMarkersCount: 1,
                              urlTemplate:
                                  "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                              markerBuilder: (BuildContext context, int index) {
                                return MapMarker(
                                  latitude: currentLocation.latitude!,
                                  longitude: currentLocation.longitude!,
                                  child: Icon(
                                    Icons.location_on,
                                    color: Colors.red,
                                    size: screenHeight * 0.05,
                                  ),
                                );
                              },
                            )
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.05),
                    Center(
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            savePresensi(currentLocation.latitude,
                                currentLocation.longitude);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green[700],
                            padding: EdgeInsets.symmetric(
                                vertical: screenHeight * 0.02),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            "Simpan Presensi",
                            style: TextStyle(
                              fontSize: screenHeight * 0.025,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          } else {
            return Center(
              child: Text("Gagal mendapatkan lokasi"),
            );
          }
        },
      ),
    );
  }
}
