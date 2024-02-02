// ignore_for_file: prefer_const_constructors, use_key_in_widget_constructors

import 'package:flutter/material.dart';

//pagina tarjeta
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

class TarjetaContacto extends StatelessWidget {
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
            CircleAvatar(
              radius: 60.0,
              backgroundImage: 
              AssetImage('assets/images/fotografia.png'),
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
            Image.asset(
                'assets/images/codigoqr.png', 
                height: 100.0,
            ),
            SizedBox(height: 16.0),
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
