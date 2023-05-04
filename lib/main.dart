// ignore_for_file: use_build_context_synchronously, library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:device_info/device_info.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Detector de GPS Falso')),
        body: const FakeGPSChecker(),
      ),
    );
  }
}

class FakeGPSChecker extends StatefulWidget {
  const FakeGPSChecker({Key? key}) : super(key: key);

  @override
  _FakeGPSCheckerState createState() => _FakeGPSCheckerState();
}

class _FakeGPSCheckerState extends State<FakeGPSChecker> {
  String _message = 'Verificando GPS...';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkFakeGPS();
    });
  }

  Future<void> _checkFakeGPS() async {
    Location location = Location();
    try {
      // Comprobar si los servicios de ubicación están habilitados
      bool serviceEnabled = await location.serviceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _message = 'Por favor, habilita los servicios de ubicación.';
        });
        return;
      }

      // Comprobar si se ha concedido el permiso de ubicación
      PermissionStatus permissionGranted = await location.hasPermission();
      if (permissionGranted == PermissionStatus.denied) {
        permissionGranted = await location.requestPermission();
        if (permissionGranted != PermissionStatus.granted) {
          setState(() {
            _message = 'Se requiere el permiso de ubicación.';
          });
          return;
        }
      }

      // Obtener la configuración de localización actual
      LocationData locationData = await location.getLocation();

      // Comprobar si la ubicación es falsa
      // Comprobar si la ubicación es falsa
      Locale deviceLocale = Localizations.localeOf(context);
      if (locationData.isMock == true && deviceLocale.languageCode != 'en') {
        setState(() {
          _message = 'Se detectó un GPS falso.';
        });
      } else {
        setState(() {
          _message = 'GPS real en uso.';
        });
      }
    } catch (e) {
      setState(() {
        _message = 'Error al verificar el GPS: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(_message),
    );
  }
}
