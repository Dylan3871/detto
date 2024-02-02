// ignore_for_file: prefer_const_constructors, use_key_in_widget_constructors

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
      elevation: 5.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            SizedBox(
              height: 80.0,
            ),
            Hero(
              tag: 'avatar',
              child: CircleAvatar(
                radius: 80.0,
                backgroundImage: AssetImage('assets/images/fotografia.png'),
              ),
            ),
            SizedBox(height: 16.0),
            Text(
              'Ing. Victor',
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Gerente de DETTO UNIFORMES',
              style: TextStyle(
                fontSize: 16.0,
                color: Colors.grey,
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
                      height: qrSelected ? 200.0 : 120.0,
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




class IconEnlace extends StatelessWidget {
  final IconData icono;
  final String enlace;

  IconEnlace({
    required this.icono,
    required this.enlace,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Puedes abrir el enlace en una aplicación externa o realizar otra acción según tus necesidades
      },
      child: CircleAvatar(
        radius: 20.0,
        backgroundColor: Color.fromARGB(255, 155, 29, 36),
        child: Icon(
          icono,
          color: Colors.white,
        ),
      ),
    );
  }
}
