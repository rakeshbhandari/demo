import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(TempleAdapter()); // Register the adapter
  await Hive.openBox<Item>('templeData');
  runApp(MyApp());
}

class Item {
  String id;
  String name;
  int stateId;
  int districtId;
  int municipalityId;
  String address;
  String shortDescription;
  String phone;
  String priest;

  Item({
    required this.id,
    required this.name,
    required this.stateId,
    required this.districtId,
    required this.municipalityId,
    required this.address,
    required this.shortDescription,
    required this.phone,
    required this.priest,
  });

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      id: json['id'],
      name: json['name'],
      stateId: json['stateId'],
      districtId: json['districtId'],
      municipalityId: json['municipalityId'],
      address: json['address'],
      shortDescription: json['shortDescription'],
      phone: json['phone'],
      priest: json['priest'],
    );
  }
}

class TempleAdapter extends TypeAdapter<Item> {
  @override
  final int typeId = 0;

  @override
  Item read(BinaryReader reader) {
    return Item(
      id: reader.readString(),
      name: reader.readString(),
      address: reader.readString(),
      shortDescription: reader.readString(),
      // description: reader.readString(),
      phone: reader.readString(),
      priest: reader.readString(),
      districtId: reader.readInt(),
      municipalityId: reader.readInt(),
      stateId: reader.readInt(),
    );
  }

  @override
  void write(BinaryWriter writer, Item obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.name);
    writer.writeString(obj.address);
    writer.writeString(obj.shortDescription);
    // writer.writeString(obj.description);
    writer.writeString(obj.phone);
    writer.writeString(obj.priest);
    writer.writeInt(obj.districtId);
    writer.writeInt(obj.municipalityId);
    writer.writeInt(obj.stateId);
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hive Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Box<Item>? _templeBox;

  @override
  void initState() {
    super.initState();
    _templeBox = Hive.box<Item>('templeData');
    // fetchDataFromApi();
  }

  Future<void> fetchDataFromApi() async {
    final response = await http.get(Uri.parse(
        'http://103.90.86.54:1010/api/services/app/Android/GetAllTemples'));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List<dynamic> items = data['result']['items'];

      //save instances to hive
      for (var item in items) {
        _templeBox?.add(Item.fromJson(item));
      }

      setState(() {});
    } else {
      print('Request failed with status: ${response.statusCode}.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final temples = _templeBox?.values.toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hive Flutter Demo'),
      ),
      body: Center(
        child: temples != null
            ? Column(
                children: [
                  ElevatedButton(
                    onPressed: () {
                      fetchDataFromApi();
                      // _templeBox?.clear();
                    },
                    child: Text('Test'),
                  ),
                  ListView.builder(
                    shrinkWrap: true,
                    itemCount: temples.length,
                    itemBuilder: (context, index) {
                      final temple = temples[index];
                      return ListTile(
                        title: Text(temple.name),
                        subtitle: Text(temple.address),
                        trailing: Icon(Icons.arrow_forward),
                        onTap: () {
                          // Handle onTap event
                        },
                      );
                    },
                  ),
                ],
              )
            : const CircularProgressIndicator(),
      ),
    );
  }
}
