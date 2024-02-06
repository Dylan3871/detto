// ignore_for_file: prefer_const_constructors, use_key_in_widget_constructors, library_private_types_in_public_api

import 'package:flutter/material.dart';

class Paginatarjeta extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tarjeta de Contacto'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
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
      elevation: 8.0, // Agregamos un sombreado más pronunciado
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0), // Bordes redondeados
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            SizedBox(
              height: 60.0,
            ),
            CircleAvatar(
              radius: 80.0,
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
                fontSize: 20.0, // Fuente un poco más grande
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16.0),
            Text(
              'Gerente Comercial at Detto',
              style: TextStyle(
                fontSize: 20.0, // Fuente un poco más grande
                color: Colors.black, // Color de texto más oscuro
              ),
            ),
            SizedBox(height: 16.0),
            GestureDetector(
              onTap: () {
                setState(() {
                  qrSelected = !qrSelected;
                });
              },
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Hero(
                    tag: 'qr',
                    child: Image.asset(
                      'assets/images/codigoqr.png',
                      height: qrSelected ? 200.0 : 120.0, // Ajuste de tamaño
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20.0),
          ],
        ),
      ),
    );
  }
}

