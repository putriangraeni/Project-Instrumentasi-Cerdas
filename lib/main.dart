//import 'dart:developer';
//import 'dart:html';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/firebase_options.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  double dataUdara = 0;
  String statusUdara = '';

  bool status = false;

  double suhu = 0;
  double kelembapan = 0;
  int gas = 0;
  int debu = 0;

  String selectedImageUdara = '';
  String selectedImageSensor = '';

  // import data sensor
  final refSuhu = FirebaseDatabase.instance.ref('sensor/suhu');
  final refKelembapan = FirebaseDatabase.instance.ref('sensor/kelembapan');
  final refGas = FirebaseDatabase.instance.ref('sensor/gas');
  final refDebu = FirebaseDatabase.instance.ref('sensor/debu');

  // kontrol alat
  final kontrol = FirebaseDatabase.instance.ref('kontrol');

  // list gambar kualitas udara
  List gambarUdara = [
    'image/sehat.png',
    'image/Sedang.png',
    'image/Buruk.png',
  ];

  // list gambar sensor
  List gambarSensor = [
    'image/SH.png',
    'image/SDG.png',
    'image/B.png',
  ];

  @override
  void initState() {
    selectedImageUdara = gambarUdara[0];
    selectedImageSensor = gambarSensor[0];
    super.initState();
    // Menggabungkan pemanggilan onValue.listen untuk semua sensor
    refSuhu.onValue.listen((event) {
      setState(() {
        suhu = event.snapshot.value as double;
      });
    });

    refKelembapan.onValue.listen((event) {
      setState(() {
        kelembapan = event.snapshot.value as double;
      });
    });

    refGas.onValue.listen((event) {
      setState(() {
        gas = event.snapshot.value as int;
      });
    });

    refDebu.onValue.listen((event) {
      setState(() {
        debu = event.snapshot.value as int;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    // double persentaseSuhu = suhu > 100 ? 100 : suhu;
    // double persentaseKelembapan = kelembapan > 100 ? 100 : kelembapan;
    // int persentaseGas = gas > 100 ? 100 : gas;
    // int persentaseDebu = debu > 100 ? 100 : debu;

    double datagas = gas / 10;

    dataUdara = (suhu + kelembapan + datagas + debu) / 4;

    String nilaiDataudara = dataUdara.toStringAsFixed(2);

    if (dataUdara <= 50) {
      statusUdara = 'Udara Sehat';
      selectedImageUdara = gambarUdara[0];
      selectedImageSensor = gambarSensor[0];
    } else if (dataUdara > 50 && dataUdara <= 100) {
      statusUdara = 'Udara Sedang';
      selectedImageUdara = gambarUdara[1];
      selectedImageSensor = gambarSensor[1];
    } else if (dataUdara > 100) {
      statusUdara = 'Udara Buruk';
      selectedImageUdara = gambarUdara[2];
      selectedImageSensor = gambarSensor[2];
    }

    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(padding: EdgeInsets.only(top: 20)),
                  const Text(
                    'Welcome',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Padding(padding: EdgeInsets.only(top: 3)),
                  const Text(
                    'Smart Air Purifier',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 35,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Padding(padding: EdgeInsets.only(top: 3)),
                  const Text(
                    'Hidup sehat dengan udara bersih tanpa polutan',
                    style: TextStyle(color: Colors.white, fontSize: 15),
                  ),
                  const Padding(padding: EdgeInsets.only(top: 25)),
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Transform.scale(
                        scale: 1.2,
                        child: Image.asset(selectedImageUdara),
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            '$nilaiDataudara%',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            statusUdara,
                            style: const TextStyle(
                                color: Colors.white, fontSize: 16),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const Padding(padding: EdgeInsets.only(top: 35)),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FlutterSwitch(
                        width: 100.0,
                        height: 48.0,
                        valueFontSize: 20.0,
                        toggleSize: 40.0,
                        value: status,
                        borderRadius: 35.0,
                        padding: 5.0,
                        activeColor: const Color.fromARGB(255, 0, 219, 15),
                        showOnOff: true,
                        onToggle: (val) {
                          setState(() {
                            status = val;
                          });
                          kontrol.set(val);
                        },
                      )
                    ],
                  ),
                  const Padding(padding: EdgeInsets.only(top: 40)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Column(
                        children: [
                          const Text(
                            'Suhu',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Stack(
                            children: [
                              Image.asset(selectedImageSensor, scale: 0.9),
                              Positioned.fill(
                                child: Center(
                                  child: Text(
                                    '$suhu °C', // Ganti dengan data aktual suhu
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          const Text(
                            'Kelembapan',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Stack(
                            children: [
                              Image.asset(selectedImageSensor, scale: 0.9),
                              Positioned.fill(
                                child: Center(
                                  child: Text(
                                    '$kelembapan %', // Ganti dengan data aktual kelembapan
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          const Text(
                            'Gas',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Stack(
                            children: [
                              Image.asset(selectedImageSensor, scale: 0.9),
                              Positioned.fill(
                                child: Center(
                                  child: Text(
                                      '$datagas' +
                                          '\nppm', // Ganti dengan data aktual CO
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                      ),
                                      textAlign: TextAlign.center),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          const Text(
                            'Debu',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Stack(
                            children: [
                              Image.asset(selectedImageSensor, scale: 0.9),
                              Positioned.fill(
                                child: Center(
                                  child: Text(
                                    '$debu' +
                                        '\nµg/m³', // Ganti dengan data aktual PM2.5
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            ],
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
    );
  }
}
