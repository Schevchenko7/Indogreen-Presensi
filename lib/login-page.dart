import 'package:flutter/material.dart';
import 'package:presensi_flutter_new/home-page.dart';
import 'package:presensi_flutter_new/registration-page.dart'; // Impor halaman registrasi
import 'package:http/http.dart' as myHttp;
import 'package:presensi_flutter_new/models/login-response.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Tidak memanggil checkToken di sini, tetapi hanya saat login
  }

  Future<void> checkToken() async {
    final SharedPreferences prefs = await _prefs;
    String token = prefs.getString("token") ?? "";
    String name = prefs.getString("name") ?? "";

    if (token.isNotEmpty && name.isNotEmpty) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    }
  }

  Future login(String email, String password) async {
    LoginResponse? loginResponse;
    Map<String, String> body = {"email": email, "password": password};
    var response = await myHttp.post(
      Uri.parse('http://192.168.1.88:8001/api/login'),
      body: body,
    );

    if (response.statusCode == 401) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Email Atau Password Salah!")));
    } else {
      loginResponse = LoginResponse.fromJson(json.decode(response.body));
      saveUser(loginResponse.data.token, loginResponse.data.name);
    }
    print(response.body);
  }

  Future<void> saveUser(String token, String name) async {
    try {
      final SharedPreferences pref = await _prefs;

      // Simpan token dan nama pengguna ke SharedPreferences
      bool isTokenSaved = await pref.setString("token", token);
      bool isNameSaved = await pref.setString("name", name);

      // Cek apakah penyimpanan berhasil
      if (isTokenSaved && isNameSaved) {
        print("Token dan nama berhasil disimpan: $token | $name");

        // Navigasi ke halaman HomePage jika penyimpanan berhasil
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => HomePage()),
        );
      } else {
        // Tampilkan pesan kesalahan jika penyimpanan gagal
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal menyimpan data pengguna.")),
        );
      }
    } catch (err) {
      // Tampilkan pesan kesalahan jika terjadi exception
      print('ERROR: $err');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Terjadi kesalahan: $err")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get screen size for responsive design
    var screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.green[400]!, Colors.green[800]!],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Center(
                      child: Column(
                        children: [
                          Image.asset(
                            'assets/lambang_indo_green-removebg-preview.png',
                            height: screenHeight * 0.15,
                          ),
                          SizedBox(height: screenHeight * 0.02),
                          Text(
                            "LOGIN",
                            style: TextStyle(
                              fontSize: screenHeight * 0.035,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.05),
                    Text(
                      "Email",
                      style: TextStyle(
                        fontSize: screenHeight * 0.022,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.01),
                    TextField(
                      controller: emailController,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.8),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.green),
                        ),
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.03),
                    Text(
                      "Password",
                      style: TextStyle(
                        fontSize: screenHeight * 0.022,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.01),
                    TextField(
                      controller: passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.8),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.green),
                        ),
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.04),
                    Center(
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            login(
                              emailController.text,
                              passwordController.text,
                            ).then((_) {
                              checkToken(); // Periksa token setelah login
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green[700],
                            padding: EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            "Masuk",
                            style: TextStyle(
                              fontSize: screenHeight * 0.025,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.04),
                    Center(
                      child: TextButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (context) => RegistrationPage()),
                          );
                        },
                        child: Text(
                          "Belum punya akun? Daftar",
                          style: TextStyle(
                            fontSize: screenHeight * 0.02,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
