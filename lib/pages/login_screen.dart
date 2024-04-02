import 'package:flutter/material.dart';
import 'package:detto/main.dart';
import 'package:detto/database/usuarios_dao.dart';
import 'package:detto/models/usuarios_model.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _correoController = TextEditingController();
  final TextEditingController _contrasenaController = TextEditingController();

  Future<void> _iniciarSesion() async {
    String correo = _correoController.text;
    String contrasena = _contrasenaController.text;

    // Verificar si las credenciales coinciden con las credenciales de administrador
    if (correo == 'admin' && contrasena == '12345678') {
      // Navegar a la pantalla principal de administrador
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MainScreen(isAdmin: true)),
      );
      return; // Salir de la función después de la navegación
    }

    // Verificar las credenciales en la base de datos
    UsuariosDao usuariosDao = UsuariosDao();
    UsuariosModel? usuario = await usuariosDao.authenticateUser(correo, contrasena);

    // Si el usuario es diferente de null, las credenciales son válidas
    if (usuario != null) {
      // Determinar el tipo de usuario según el campo "cargo"
      if (usuario.cargo == 'vendedor') {
        // Navegar a la pantalla principal de vendedor
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MainScreen(isAdmin: false)),
        );
      } else if (usuario.cargo == 'administrador') {
        // Navegar a la pantalla principal de administrador
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MainScreen(isAdmin: true)),
        );
      }
    } else {
      // Mostrar un mensaje de error
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error de inicio de sesión'),
            content: Text('Credenciales incorrectas. Por favor, inténtalo de nuevo.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Inicio de Sesión'),
      ),
      body: Container(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _correoController,
              decoration: InputDecoration(
                labelText: 'Correo',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16.0),
            TextFormField(
              controller: _contrasenaController,
              decoration: InputDecoration(
                labelText: 'Contraseña',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            SizedBox(height: 32.0),
            ElevatedButton(
              onPressed: _iniciarSesion,
              child: Text('Iniciar Sesión'),
            ),
          ],
        ),
      ),
    );
  }
}
