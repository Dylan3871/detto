// ignore_for_file: file_names, use_key_in_widget_constructors, prefer_const_constructors, prefer_const_literals_to_create_immutables, sized_box_for_whitespace

import 'package:flutter/material.dart';

class Paginadetto extends StatelessWidget {
  final List<String> imagenes = [
    "assets/images/cli1.png",
    "assets/images/cli2.png",
    "assets/images/cli3.png",
    "assets/images/cli4.png",
    "assets/images/cli5.png",
    "assets/images/cli6.png",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Acerca de nosotros'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "",
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 40),
            _buildInfoCard(
              context,
              "Bienvenido a Detto, donde conocerás más acerca de nosotros. Esta es nuestra información relevante acerca de nosotros.",
            ),
            SizedBox(height: 40),
            _buildInfoCard(
              context,
              "Misión: Ser la empresa elegida por el cliente por el uso de modas y tendencias en uniformes empresariales y escolares para contribuir a sus necesidades.",
            ),
            SizedBox(height: 40),
            _buildInfoCard(
              context,
              "Visión: Ser la empresa elegida por el cliente por el uso de modas y tendencias en uniformes empresariales y escolares para contribuir a sus necesidades.",
            ),
            SizedBox(height: 40),
            _buildInfoCard(
              context,
              "NUESTROS PRINCIPALES CLIENTES",
            ),
            SizedBox(height: 80),
            _buildCarouselCard(context),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, String text) {
  return Card(
    elevation: 4,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
    ),
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        alignment: Alignment.center, // Centra el contenido
        child: Text(
          text,
          style: TextStyle(
            fontSize: 18,
            color: Colors.black),
          textAlign: TextAlign.center,
        ),
      ),
    ),
  );
}


  Widget _buildCarouselCard(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(40.0),
        child: Container(
          height: 250,
          width: double.infinity,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: imagenes.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.all(20.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.asset(
                    imagenes[index],
                    width: 260,
                    height: 100,
                    fit: BoxFit.cover,
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: Paginadetto(),
  ));
}

