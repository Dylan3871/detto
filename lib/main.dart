import 'package:detto/pages/Paginatarjeta.dart';
import 'package:detto/pages/Paginadetto.dart';
import 'package:detto/pages/Paginavideo.dart';
import 'package:detto/pages/Paginapreguntas.dart';
import 'package:detto/pages/Paginacatalogo.dart';
import 'package:detto/pages/Paginacotizador.dart';
import 'package:detto/pages/Paginaresultados.dart';

import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int _paginaActual = 0;
  List<Widget> _paginas = [//Hace la funcion de cambiar de pestañas
    Paginatarjeta(),
    Paginadetto(),
    Paginavideo(),
    Paginapreguntas(),
    Paginacatalogo(),
    Paginacotizador(),
    Paginaresultados(),
    
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
        //Menu Inferiror 
        bottomNavigationBar: BottomNavigationBar(
         backgroundColor: Colors.blue,
         selectedItemColor: const Color.fromARGB(255, 139, 10, 10), // Color del ícono seleccionado
          unselectedItemColor: const Color.fromARGB(255, 184, 142, 142), // Color del ícono no seleccionado
  selectedLabelStyle: TextStyle(color: Color.fromARGB(255, 160, 234, 69)), // Color del texto
          onTap: (index){
             setState(() {
               _paginaActual = index;
          });
          },
          currentIndex: _paginaActual,
          items: [//se definen botones 
            BottomNavigationBarItem(icon: Icon(Icons.group), label: "Tarjeta"),
            BottomNavigationBarItem(icon: Icon(Icons.balcony), label: "Detto"),
            BottomNavigationBarItem(icon: Icon(Icons.video_call), label: "video"),
            BottomNavigationBarItem(icon: Icon(Icons.create), label: "Peguntas"),
            BottomNavigationBarItem(icon: Icon(Icons.dry_cleaning),label: "Catalogo"),
            BottomNavigationBarItem(icon: Icon(Icons.find_in_page),label: "Cotizador"),
            BottomNavigationBarItem(icon: Icon(Icons.grading), label: "resultados"),

            
          ],
          ),
      ),
    );
  }
}






