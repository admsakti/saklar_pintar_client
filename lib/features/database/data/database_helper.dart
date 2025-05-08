import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/device.dart';
import '../models/mesh_network.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'client.db');

    return await openDatabase(
      path,
      version: 1,
      onOpen: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: (db, version) async {
        await db.execute('''
        CREATE TABLE mesh_networks (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          macRoot TEXT NOT NULL,
          name TEXT NOT NULL
        )
      ''');

        await db.execute('''
        CREATE TABLE devices (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          deviceId TEXT NOT NULL,
          name TEXT NOT NULL,
          role TEXT NOT NULL,
          meshId INTEGER NOT NULL,
          FOREIGN KEY (meshId) REFERENCES mesh_networks(id) ON DELETE CASCADE
        )
      ''');
      },
      // onUpgrade: (db, oldVersion, newVersion) async {
      //   if (oldVersion < 2) {
      //     await db.execute('''
      //     CREATE TABLE mesh_networks (
      //       id INTEGER PRIMARY KEY AUTOINCREMENT,
      //       macRoot TEXT NOT NULL,
      //       name TEXT NOT NULL
      //     )
      //   ''');

      //     await db.execute('''
      //     ALTER TABLE devices ADD COLUMN meshId INTEGER REFERENCES mesh_networks(id)
      //   ''');
      //   }
      // },
    );
  }

  //// MESH
  Future<int> insertMeshNetwork({required MeshNetwork meshNetwork}) async {
    final db = await database;
    return await db.insert('mesh_networks', meshNetwork.toMap());
  }

  Future<List<MeshNetwork>> getMeshNetworks() async {
    final db = await database;
    final result = await db.query('mesh_networks');
    return result.map((e) => MeshNetwork.fromMap(e)).toList();
  }

  Future<MeshNetwork?> getMeshNetworkByMacRoot(
      {required String macRoot}) async {
    final db = await database;
    final result = await db.query(
      'mesh_networks',
      where: 'macRoot = ?',
      whereArgs: [macRoot],
      limit: 1,
    );

    if (result.isNotEmpty) {
      return MeshNetwork.fromMap(result.first);
    } else {
      return null;
    }
  }

  Future<int> updateMeshNetwork({
    required int id,
    String? macRoot,
    String? name,
  }) async {
    final db = await database;

    Map<String, dynamic> values = {};
    if (macRoot != null) values['macRoot'] = macRoot;
    if (name != null) values['name'] = name;

    return await db.update(
      'mesh_networks',
      values,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteMeshNetwork({required int id}) async {
    final db = await database;
    return await db.delete(
      'mesh_networks',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> resetMeshNetworkTable() async {
    final db = await database;
    return await db.delete('mesh_networks');
  }

  //// DEVICE
  Future<int> insertDevice({required Device device}) async {
    final db = await database;
    return await db.insert('devices', device.toMap());
  }

  Future<int?> insertDeviceWithMacRoot({
    required String macRoot,
    required String deviceId,
    required String name,
    required String role,
  }) async {
    final mesh = await getMeshNetworkByMacRoot(macRoot: macRoot);
    if (mesh == null) {
      print('Mesh with MAC $macRoot not found');
      return null;
    }

    final db = await database;
    return await db.insert('devices', {
      'deviceId': deviceId,
      'name': name,
      'role': role,
      'meshId': mesh.id,
    });
  }

  Future<List<Device>> getDevices() async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.query('devices');
    return result.map((e) => Device.fromMap(e)).toList();
  }

  Future<Device?> getDevice({required int id}) async {
    final db = await database;

    final result = await db.query(
      'device',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (result.isNotEmpty) {
      return Device.fromMap(result.first);
    } else {
      return null;
    }
  }

  Future<int> updateDevice({
    required int id,
    String? deviceId,
    String? name,
    String? role,
    int? meshId,
  }) async {
    final db = await database;

    Map<String, dynamic> values = {};
    if (deviceId != null) values['deviceId'] = deviceId;
    if (name != null) values['name'] = name;
    if (role != null) values['role'] = role;
    if (meshId != null) values['meshId'] = meshId;

    return await db.update(
      'devices',
      values,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteDevice({required int id}) async {
    final db = await database;
    return await db.delete(
      'devices',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> resetDeviceTable() async {
    final db = await database;
    return await db.delete('devices');
  }

  //// ALL
  Future<void> resetAllTables() async {
    final db = await database;
    await db.delete('devices');
    await db.delete('mesh_networks');
  }
}
