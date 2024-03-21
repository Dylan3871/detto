// ignore_for_file: file_names, use_key_in_widget_constructors, prefer_const_constructors_in_immutables, prefer_const_constructors, library_private_types_in_public_api

import 'package:flutter/material.dart';

class PantallaQR extends StatelessWidget {
  final String imagePath;

  PantallaQR({required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('QR para mas información'),
      ),
      body: Center(
        child: Hero(
          tag: 'qr',
          child: Image.asset(
            imagePath,
            height: 300.0,
          ),
        ),
      ),
    );
  }
}

class Paginatarjeta extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tarjeta de Contacto'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: TarjetaContacto(),
        ),
      ),
    );
  }
}

class TarjetaContacto extends StatefulWidget {
  @override
  _TarjetaContactoState createState() => _TarjetaContactoState();
}

class _TarjetaContactoState extends State<TarjetaContacto> {
  bool qrSelected = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 8.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(45.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(40.0),
        child: Column(
          children: [
            SizedBox(
              height: 90.0,
            ),
            CircleAvatar(
              radius: 120.0,
              backgroundImage: AssetImage('assets/images/fotografia.png'),
            ),
            Positioned(
              right: 0,
              bottom: 0,
              child: Image.asset(
                'assets/images/detto.png',
                width: 80.0,
                height: 80.0,
              ),
            ),
            SizedBox(height: 2.0),
            Text(
              'Ing. Victor V. Álvarez',
              style: TextStyle(
                fontSize: 30.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16.0),
            Text(
              'Gerente Comercial at Detto',
              style: TextStyle(
                fontSize: 30.0,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 16.0),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PantallaQR(imagePath: 'assets/images/codigoqr.png'),
                  ),
                );
              },
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Hero(
                    tag: 'qr',
                    child: Image.asset(
                      'assets/images/codigoqr.png',
                      height: qrSelected ? 400.0 : 200.0,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 80.0),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: Paginatarjeta(),
  ));
}
