import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Datos API - Grupo Whatsapp6a',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 4,
        ),
        cardTheme: const CardThemeData(
        elevation: 2,
        margin: EdgeInsets.all(8),
        shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
       ),
      ),
    ),
      home: const ApiDataViewer(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class ApiDataViewer extends StatefulWidget {
  const ApiDataViewer({super.key});

  @override
  State<ApiDataViewer> createState() => _ApiDataViewerState();
}

class _ApiDataViewerState extends State<ApiDataViewer> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<dynamic> sexos = [];
  List<dynamic> telefonos = [];
  List<dynamic> estadosCiviles = [];
  List<dynamic> direcciones = [];
  List<dynamic> personas = [];
  bool isLoading = true;
  DateTime? lastUpdateTime;

  final Map<String, String> apiEndpoints = {
    'Sexos': 'https://educaysoft.org/whatsapp6a/app/controllers/SexoController.php?action=api',
    'Teléfonos': 'https://educaysoft.org/whatsapp6a/app/controllers/TelefonoController.php?action=api',
    'Estados Civiles': 'https://educaysoft.org/whatsapp6a/app/controllers/EstadocivilController.php?action=api',
    'Direcciones': 'https://educaysoft.org/whatsapp6a/app/controllers/DireccionController.php?action=api',
    'Personas': 'https://educaysoft.org/whatsapp6a/app/controllers/PersonaController.php?action=api',
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
    fetchAllData();
  }

  Future<void> fetchAllData() async {
    setState(() {
      isLoading = true;
    });

    try {
      final responses = await Future.wait([
        fetchData(apiEndpoints['Sexos']!),
        fetchData(apiEndpoints['Teléfonos']!),
        fetchData(apiEndpoints['Estados Civiles']!),
        fetchData(apiEndpoints['Direcciones']!),
        fetchData(apiEndpoints['Personas']!),
      ]);

      setState(() {
        sexos = responses[0];
        telefonos = responses[1];
        estadosCiviles = responses[2];
        direcciones = responses[3];
        personas = responses[4];
        isLoading = false;
        lastUpdateTime = DateTime.now();
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al cargar datos: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<List<dynamic>> fetchData(String url) async {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      String fixedJson = '[${response.body.replaceAll('}{', '},{')}]';
      return json.decode(fixedJson);
    } else {
      throw Exception('Error ${response.statusCode}: ${response.reasonPhrase}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Datos API - Grupo Whatsapp6a'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: Colors.white,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold),
          tabs: const [
            Tab(icon: Icon(Icons.person), text: 'Sexos'),
            Tab(icon: Icon(Icons.phone), text: 'Teléfonos'),
            Tab(icon: Icon(Icons.family_restroom), text: 'Estados Civiles'),
            Tab(icon: Icon(Icons.location_on), text: 'Direcciones'),
            Tab(icon: Icon(Icons.people), text: 'Personas'),
            Tab(icon: Icon(Icons.info), text: 'Acerca de'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          DataListView(data: sexos, title: 'Sexos'),
          DataListView(data: telefonos, title: 'Teléfonos'),
          DataListView(data: estadosCiviles, title: 'Estados Civiles'),
          DataListView(data: direcciones, title: 'Direcciones'),
          PersonasListView(data: personas),
          const AboutTab(),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: fetchAllData,
            tooltip: 'Actualizar datos',
            child: const Icon(Icons.refresh),
          ),
          const SizedBox(height: 10),
          if (lastUpdateTime != null)
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Text(
                'Últ. actualización: ${DateFormat('HH:mm:ss').format(lastUpdateTime!)}',
                style: const TextStyle(color: Colors.grey),
              ),
            ),
        ],
      ),
    );
  }
}

class DataListView extends StatelessWidget {
  final List<dynamic> data;
  final String title;

  const DataListView({super.key, required this.data, required this.title});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Text(
            title,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: data.length,
            itemBuilder: (context, index) {
              final item = data[index];
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: item.entries.map<Widget>((entry) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: '${entry.key}: ',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              TextSpan(text: '${entry.value}'),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class PersonasListView extends StatelessWidget {
  final List<dynamic> data;

  const PersonasListView({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.all(12.0),
          child: Text(
            'Personas',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: data.length,
            itemBuilder: (context, index) {
              final persona = data[index];
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${persona['nombres']} ${persona['apellidos']}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildInfoRow('Fecha Nacimiento', persona['fechanacimiento']),
                      _buildInfoRow('Sexo', '${persona['sexo_nombre']} (ID: ${persona['idsexo']})'),
                      _buildInfoRow('Estado Civil', '${persona['estadocivil_nombre']} (ID: ${persona['idestadocivil']})'),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}

class AboutTab extends StatelessWidget {
  const AboutTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Center(
            child: CircleAvatar(
              radius: 50,
              backgroundColor: Colors.blue,
              child: Icon(
                Icons.group,
                size: 50,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Center(
            child: Text(
              'Grupo Whatsapp6a',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
          ),
          const SizedBox(height: 30),
          const Text(
            'Integrantes:',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 15),
          _buildMemberCard('STEVEN ENRIQUE BURBANO CHERE'),
          _buildMemberCard('HEIDY NAYELLI JORDAN CORTEZ'),
          _buildMemberCard('ROXANA YAMILETH MENDOZA GIRON'),
          _buildMemberCard('JEOHASSIN WILTON OREJUELA GARCIA'),
          _buildMemberCard('NINA MAURY TAPUYO AÑAPA'),
          const SizedBox(height: 30),
          const Center(
            child: Text(
              'Actividad A2.1',
              style: TextStyle(
                fontSize: 18,
                fontStyle: FontStyle.italic,
                color: Colors.grey,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMemberCard(String name) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        leading: const Icon(Icons.person, color: Colors.blue),
        title: Text(name),
      ),
    );
  }
}