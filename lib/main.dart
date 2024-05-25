import 'package:flutter/material.dart';
import 'package:proysqlite01/databasehelper.dart';
import 'package:logger/logger.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Perritos Demo',
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final dbHelper = DatabaseHelper();
  final _formKey = GlobalKey<FormState>();
  final Logger logger = Logger();
  String? name;
  int? age;
  int? id;
  List<Dog> dogsList = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Perritos Demo'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              TextFormField(
                decoration: const InputDecoration(labelText: 'Nombre'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa un nombre';
                  }
                  return null;
                },
                onSaved: (value) => name = value,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Edad'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa una edad';
                  }
                  return null;
                },
                onSaved: (value) => age = int.tryParse(value!),
              ),
              TextFormField(
                decoration: const InputDecoration(
                    labelText: 'ID (para actualizar/eliminar)'),
                keyboardType: TextInputType.number,
                onSaved: (value) => id =
                    value == null || value.isEmpty ? null : int.parse(value),
              ),
              const SizedBox(height: 20),
              Column(
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      ElevatedButton(
                        onPressed: _insertDog,
                        child: const Text('Insertar'),
                      ),
                      ElevatedButton(
                        onPressed: _updateDog,
                        child: const Text('Actualizar'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10), // Añadir espacio entre filas
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      ElevatedButton(
                        onPressed: _deleteDog,
                        child: const Text('Eliminar'),
                      ),
                      ElevatedButton(
                        onPressed: _listDogs,
                        child: const Text('Listar'),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Expanded(
                child: _buildDogList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _insertDog() async {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();
      if (name != null && age != null) {
        await dbHelper.insertDog(Dog(name: name!, age: age!));
        logger.i('Insertar perrito: Nombre: $name, Edad: $age');
      }
    }
  }

  void _updateDog() async {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();
      if (id != null && name != null && age != null) {
        await dbHelper.updateDog(Dog(id: id!, name: name!, age: age!));
        logger.i('Actualizar perrito: ID: $id, Nombre: $name, Edad: $age');
      }
    }
  }

  void _deleteDog() async {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();
      if (id != null) {
        await dbHelper.deleteDog(id!);
        logger.i('Eliminar perrito por ID: $id');
      }
    }
  }

  void _listDogs() async {
    List<Dog> dogs = await dbHelper.dogs();
    setState(() {
      dogsList = dogs;
    });
  }

  Widget _buildDogList() {
    return ListView.builder(
      itemCount: dogsList.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text('Name: ${dogsList[index].name}'),
          subtitle: Text('Age: ${dogsList[index].age}'),
          trailing: Text('ID: ${dogsList[index].id}'),
        );
      },
    );
  }
}
