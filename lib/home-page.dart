import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:presensi_flutter_new/login-page.dart';
import 'package:presensi_flutter_new/models/home-response.dart';
import 'package:presensi_flutter_new/simpan-page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as myHttp;

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  late Future<String> _name, _token;
  HomeResponseModel? homeResponseModel;
  Datum? hariIni;
  List<Datum> riwayat = [];

  @override
  void initState() {
    super.initState();
    _token = _prefs.then((SharedPreferences prefs) {
      return prefs.getString("token") ?? "";
    });

    _name = _prefs.then((SharedPreferences prefs) {
      return prefs.getString("name") ?? "";
    });

    getData();
  }

  void logout(BuildContext context) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    await prefs.remove('token');
    await prefs.remove('name');

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }

  Future getData() async {
    final Map<String, String> headers = {
      'Authorization': 'Bearer ' + await _token
    };
    var response = await myHttp.get(
        Uri.parse('http://192.168.1.88:8001/api/get-presensi'),
        headers: headers);

    if (response.statusCode == 200) {
      homeResponseModel = HomeResponseModel.fromJson(json.decode(response.body));
      riwayat.clear();
      homeResponseModel!.data.forEach((element) {
        if (element.isHariIni) {
          hariIni = element;
        } else {
          riwayat.add(element);
        }
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal memuat data presensi.")));
    }
  }

  @override
  Widget build(BuildContext context) {
    var screenHeight = MediaQuery.of(context).size.height;
    var screenWidth = MediaQuery.of(context).size.width;
    var padding = MediaQuery.of(context).padding;
    var safeHeight = screenHeight - padding.top - padding.bottom;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            logout(context);
          },
          icon: Icon(Icons.logout),
        ),
        title: FutureBuilder(
          future: _name,
          builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Text("Memuat...");
            } else if (snapshot.hasData) {
              return Text("Halo, ${snapshot.data}",
                  style: TextStyle(fontSize: screenHeight * 0.03));
            } else {
              return Text("Pengguna", style: TextStyle(fontSize: screenHeight * 0.03));
            }
          },
        ),
        backgroundColor: Colors.green[700],
      ),
      body: FutureBuilder(
          future: getData(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else {
              return SafeArea(
                child: Padding(
                  padding: EdgeInsets.all(screenWidth * 0.05),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(screenHeight * 0.02),
                        decoration: BoxDecoration(
                          color: Colors.green[700],
                          borderRadius: BorderRadius.circular(12.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              offset: Offset(0, 4),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Text(
                              hariIni?.tanggal ?? '-',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: screenHeight * 0.025,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: screenHeight * 0.02),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Column(
                                  children: [
                                    Text(
                                      hariIni?.masuk ?? '-',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: screenHeight * 0.04,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      "Masuk",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: screenHeight * 0.02,
                                      ),
                                    ),
                                  ],
                                ),
                                Column(
                                  children: [
                                    Text(
                                      hariIni?.pulang ?? '-',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: screenHeight * 0.04,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      "Pulang",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: screenHeight * 0.02,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: safeHeight * 0.05),
                      Text(
                        "Riwayat Presensi",
                        style: TextStyle(
                          fontSize: screenHeight * 0.03,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.02),
                      Expanded(
                        child: ListView.builder(
                          itemCount: riwayat.length,
                          itemBuilder: (context, index) => Card(
                            margin: EdgeInsets.only(bottom: screenHeight * 0.02),
                            elevation: 3,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: screenWidth * 0.05,
                                vertical: screenHeight * 0.01,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    riwayat[index].tanggal,
                                    style: TextStyle(
                                      fontSize: screenHeight * 0.025,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: screenHeight * 0.01),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Masuk: ${riwayat[index].masuk}",
                                            style: TextStyle(
                                              fontSize: screenHeight * 0.02,
                                            ),
                                          ),
                                          Text(
                                            "Pulang: ${riwayat[index].pulang}",
                                            style: TextStyle(
                                              fontSize: screenHeight * 0.02,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }
          }),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context)
              .push(MaterialPageRoute(builder: (context) => SimpanPage()))
              .then((value) {
            setState(() {
              getData();
            });
          });
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.green[700],
      ),
    );
  }
}
