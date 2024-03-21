import 'package:flutter/material.dart';
import 'package:detto/database/database_helper.dart';
import 'package:detto/pages/Paginatarjeta.dart';
import 'package:detto/pages/Paginadetto.dart';
import 'package:detto/pages/Paginavideo.dart';
import 'package:detto/pages/Paginapreguntas.dart';
import 'package:detto/pages/Paginacatalogo.dart';
import 'package:detto/pages/Paginacotizador.dart';
import 'package:detto/pages/Paginaresultados.dart';
import 'package:detto/pages/Paginausuarios.dart';
import 'package:detto/pages/Paginaregistro.dart';
import 'package:detto/pages/Paginacotizaciones.dart';
import 'package:detto/pages/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseHelper.instance.init();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isLoggedIn = false; // Variable para controlar si el usuario ha iniciado sesión

  @override
  void initState() {
    super.initState();
    // Comprobar si el usuario ya está autenticado al inicio de la aplicación
    checkLoginStatus();
  }

  // Método para comprobar si el usuario ya ha iniciado sesión
  void checkLoginStatus() async {
    // Implementa lógica para comprobar si el usuario ya ha iniciado sesión (por ejemplo, consulta la base de datos)
    // Si el usuario ha iniciado sesión, actualiza _isLoggedIn a true
    // Si no, déjalo en false
    // Por ejemplo:
    // bool isLoggedIn = await DatabaseHelper.instance.isLoggedIn();
    setState(() {
      _isLoggedIn = false; // Actualiza el estado según la lógica de tu aplicación
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Detto',
      home: _isLoggedIn ? MainScreen(isAdmin: false) : LoginScreen(), // Aquí se muestra la pantalla de inicio de sesión si el usuario no ha iniciado sesión
    );
  }
}

class MainScreen extends StatefulWidget {
  final bool isAdmin;

  const MainScreen({Key? key, required this.isAdmin}) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _paginaActual = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detto'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              // Implementa la lógica para cerrar sesión aquí
              // Por ejemplo, navegar de vuelta a la pantalla de inicio de sesión
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()),
              );
            },
          ),
        ],
      ),
      body: _buildBody(),
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
        items: _buildBottomNavigationBarItems(),
      ),
    );
  }

  List<BottomNavigationBarItem> _buildBottomNavigationBarItems() {
    if (widget.isAdmin) {
      // Si el usuario es administrador, muestra todas las pestañas
      return [
        BottomNavigationBarItem(icon: Icon(Icons.group), label: "Tarjeta"),
        BottomNavigationBarItem(icon: Icon(Icons.balcony), label: "Detto"),
        BottomNavigationBarItem(icon: Icon(Icons.video_call), label: "Video"),
        BottomNavigationBarItem(icon: Icon(Icons.create), label: "Preguntas"),
        BottomNavigationBarItem(icon: Icon(Icons.dry_cleaning), label: "Catálogo"),
        BottomNavigationBarItem(icon: Icon(Icons.find_in_page), label: "Cotizador"),
        BottomNavigationBarItem(icon: Icon(Icons.grading), label: "Resultados"),
        BottomNavigationBarItem(icon: Icon(Icons.supervised_user_circle), label: "Usuarios"),
        BottomNavigationBarItem(icon: Icon(Icons.add), label: "Registro"),
        BottomNavigationBarItem(icon: Icon(Icons.access_alarm), label: "Cotizaciones"),
      ];
    } else {
      // Si el usuario es un vendedor, muestra solo las pestañas específicas para vendedores
      return [
        BottomNavigationBarItem(icon: Icon(Icons.group), label: "Tarjeta"),
        BottomNavigationBarItem(icon: Icon(Icons.balcony), label: "Detto"),
        BottomNavigationBarItem(icon: Icon(Icons.video_call), label: "Video"),
        BottomNavigationBarItem(icon: Icon(Icons.create), label: "Preguntas"),
        BottomNavigationBarItem(icon: Icon(Icons.dry_cleaning), label: "Catálogo"),
        BottomNavigationBarItem(icon: Icon(Icons.find_in_page), label: "Cotizador"),
      ];
    }
  }

  Widget _buildBody() {
    switch (_paginaActual) {
      case 0:
        return Paginatarjeta();
      case 1:
        return Paginadetto();
      case 2:
        return Paginavideo();
      case 3:
        return Paginapreguntas();
      case 4:
        return Paginacatalogo();
      case 5:
        return Paginacotizador();
      case 6:
        return Paginaresultados();
      case 7:
        return Paginausuarios();
      case 8:
        return Paginaregistro();
      case 9:
        return Paginacotizaciones();
      default:
        return SizedBox(); // Si el índice de página actual no coincide con ninguno de los casos anteriores, muestra un widget vacío
    }
  }
}
