// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, prefer_final_fields

import 'package:detto/database/database_helper.dart';
import 'package:detto/pages/Paginatarjeta.dart';
import 'package:detto/pages/Paginadetto.dart';
import 'package:detto/pages/Paginavideo.dart';
import 'package:detto/pages/Paginapreguntas.dart';
import 'package:detto/pages/Paginacatalogo.dart';
import 'package:detto/pages/Paginacotizador.dart';
import 'package:detto/pages/Paginaresultados.dart';
import 'package:detto/pages/Paginausuarios.dart';
import 'package:flutter/material.dart';
//import 'package:detto/database/database_helper.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
  await DatabaseHelper.instance.init();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int _paginaActual = 0;
  List<Widget> _paginas = [
    Paginatarjeta(),
    Paginadetto(),
    Paginavideo(),
    Paginapreguntas(),
    Paginacatalogo(),
    Paginacotizador(),
    Paginaresultados(),
    Paginausuarios(),
  ];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Detto',
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Detto'),
        ),
        body: _paginas[_paginaActual],
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: Colors.blue,
          selectedItemColor: const Color.fromARGB(255, 139, 10, 10),
          unselectedItemColor: const Color.fromARGB(255, 184, 142, 142),
          selectedLabelStyle: TextStyle(color: Color.fromARGB(255, 160, 234, 69)),
          onTap: (index) {
            setState(() {
              _paginaActual = index;
            });
          },
          currentIndex: _paginaActual,
          items: [
            BottomNavigationBarItem(icon: Icon(Icons.group), label: "Tarjeta"),
            BottomNavigationBarItem(icon: Icon(Icons.balcony), label: "Detto"),
            BottomNavigationBarItem(icon: Icon(Icons.video_call), label: "Video"),
            BottomNavigationBarItem(icon: Icon(Icons.create), label: "Preguntas"),
            BottomNavigationBarItem(icon: Icon(Icons.dry_cleaning), label: "Catálogo"),
            BottomNavigationBarItem(icon: Icon(Icons.find_in_page), label: "Cotizador"),
            BottomNavigationBarItem(icon: Icon(Icons.grading), label: "Resultados"),
            BottomNavigationBarItem(icon: Icon(Icons.supervised_user_circle), label: "Usuarios"),
          ],
        ),
      ),
    );
  }
}
