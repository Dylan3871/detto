// ignore_for_file: file_names, use_key_in_widget_constructors, prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';

class Paginadetto extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        alignment: Ali gnment.centerLeft,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Detto",
              style: TextStyle(fontSize: 30),
            ),
            SizedBox(height: 20),
            _buildTextContainer(
              "Bienvenido a Detto, donde conocerás más acerca de nosotros. Esta es nuestra información relevante acerca de nosotros.",
            ),
            SizedBox(height: 20),
            _buildTextContainer(
              "Misión: Ser la empresa elegida por el cliente por el uso de modas y tendencias en uniformes empresariales y escolares para contribuir a sus necesidades.",
            ),
            SizedBox(height: 20),
            _buildTextContainer(
              "Visión: Ser la empresa elegida por el cliente por el uso de modas y tendencias en uniformes empresariales y escolares para contribuir a sus necesidades.",
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextContainer(String text) {
    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(color: const Color.fromARGB(255, 188, 75, 75)), // Puedes personalizar el borde
        borderRadius: BorderRadius.circular(30), // Puedes personalizar la esquina
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 18),
      ),
    );
  }
}
