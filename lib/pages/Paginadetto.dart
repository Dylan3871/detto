// ignore_for_file: file_names, use_key_in_widget_constructors, prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';

class Paginadetto extends StatelessWidget {
  final List<String> imagenes = [
    "assets/images/cli1.png",
    "assets/images/cli2.png",
    "assets/images/cli3.png",
    "assets/images/cli4.png",
    "assets/images/cli5.png",
    "assets/images/cli6.png",
    "assets/images/cli7.png",
    "assets/images/cli8.png",
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        alignment: Alignment.centerLeft,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Detto",
              style: TextStyle(fontSize: 30),
            ),
            SizedBox(height: 15),
            _buildTextContainer(
              "Bienvenido a Detto, donde conocerás más acerca de nosotros. Esta es nuestra información relevante acerca de nosotros.",
            ),
            SizedBox(height: 15),
            _buildTextContainer(
              "Misión: Ser la empresa elegida por el cliente por el uso de modas y tendencias en uniformes empresariales y escolares para contribuir a sus necesidades.",
            ),
            SizedBox(height: 15),
            _buildTextContainer(
              "Visión: Ser la empresa elegida por el cliente por el uso de modas y tendencias en uniformes empresariales y escolares para contribuir a sus necesidades.",
            ),
            SizedBox(height: 15),
            _buildTextContainer(
              "NUESTROS PRINCIPALES CLIENTES",
            ),
            SizedBox(height: 15),
            _buildImageCarousel(),
          ],
        ),
      ),
    );
  }

  Widget _buildTextContainer(String text) {
    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(color: const Color.fromARGB(255, 188, 75, 75)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 18),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildImageCarousel() {
    return Container(
      height: 200, // Ajusta la altura según tus necesidades
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: imagenes.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.all(20),
            child: Image.asset(
              imagenes[index],
              width: 130, // Ajusta el ancho según tus necesidades
              height: 200, // Ajusta la altura según tus necesidades
              fit: BoxFit.cover,
            ),
          );
        },
      ),
    );
  }
}