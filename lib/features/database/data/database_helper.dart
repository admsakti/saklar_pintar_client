import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/device.dart';
import '../models/device_schedule.dart';
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
          nodeId TEXT NOT NULL,
          name TEXT NOT NULL,
          role TEXT NOT NULL,
          meshId INTEGER NOT NULL,
          FOREIGN KEY (meshId) REFERENCES mesh_networks(id) ON DELETE CASCADE
        )
        ''');

        await db.execute('''
        CREATE TABLE device_schedules (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          deviceId INTEGER NOT NULL,
          time TEXT NOT NULL,
          state TEXT NOT NULL,
          enabled INTEGER NOT NULL DEFAULT 1,
          FOREIGN KEY (deviceId) REFERENCES devices(id) ON DELETE CASCADE
        )
        ''');
      },
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

  Future<MeshNetwork?> getMeshNetworkById({required int id}) async {
    final db = await database;
    final result = await db.query(
      'mesh_networks',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (result.isNotEmpty) {
      return MeshNetwork.fromMap(result.first);
    } else {
      return null;
    }
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

  Future<int> updateMeshNetworkName({
    required int id,
    String? name,
  }) async {
    final db = await database;

    Map<String, dynamic> values = {};
    if (name != null) values['name'] = name;

    return await db.update(
      'mesh_networks',
      values,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteMeshNetworkById({required int id}) async {
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
  Future<int?> insertDeviceWithMacRoot({
    required String macRoot,
    required String nodeId,
    required String name,
    required String role,
  }) async {
    final mesh = await getMeshNetworkByMacRoot(macRoot: macRoot);
    if (mesh == null) {
      // print('Mesh with MAC $macRoot not found');
      return null;
    }

    final db = await database;
    return await db.insert('devices', {
      'nodeId': nodeId,
      'name': name,
      'role': role,
      'meshId': mesh.id,
    });
  }

  Future<List<Device>> getDevices() async {
    final db = await database;
    // final List<Map<String, dynamic>> result = await db.query('devices');
    final List<Map<String, dynamic>> result = await db.rawQuery('''
      SELECT 
        d.id AS idDevice, d.nodeId AS deviceIdentifier, d.name, d.role,
        m.id AS idMesh, m.macRoot AS macIdentifier, m.name AS meshName
      FROM devices d
      INNER JOIN mesh_networks m ON d.meshId = m.id
    ''');

    return result.map((e) => Device.fromMapWithMeshNetwork(e)).toList();
  }

  Future<Device?> getDeviceById({required int id}) async {
    final db = await database;

    final result = await db.rawQuery('''
      SELECT 
        d.id AS idDevice, 
        d.nodeId AS deviceIdentifier, 
        d.name, 
        d.role,
        m.id AS idMesh, 
        m.macRoot AS macIdentifier, 
        m.name AS meshName
      FROM devices d
      INNER JOIN mesh_networks m ON d.meshId = m.id
      WHERE d.id = ?
      LIMIT 1
    ''', [id]);

    if (result.isNotEmpty) {
      return Device.fromMapWithMeshNetwork(result.first);
    } else {
      return null;
    }
  }

  Future<Device?> getDeviceByNodeId({required String nodeId}) async {
    final db = await database;

    final result = await db.rawQuery('''
      SELECT 
        d.id AS idDevice, 
        d.nodeId AS deviceIdentifier, 
        d.name, 
        d.role,
        m.id AS idMesh, 
        m.macRoot AS macIdentifier, 
        m.name AS meshName
      FROM devices d
      INNER JOIN mesh_networks m ON d.meshId = m.id
      WHERE d.nodeId = ?
      LIMIT 1
    ''', [nodeId]);

    if (result.isNotEmpty) {
      return Device.fromMapWithMeshNetwork(result.first);
    } else {
      return null;
    }
  }

  Future<int> updateDeviceName({
    required int id,
    String? name,
  }) async {
    final db = await database;

    Map<String, dynamic> values = {};
    if (name != null) values['name'] = name;

    return await db.update(
      'devices',
      values,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteDeviceById({required int id}) async {
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

  //// SCHEDULE
  Future<int> insertDeviceSchedulewithDeviceId({
    required int deviceId,
    required String time,
    required String state,
    required bool enabled,
  }) async {
    final db = await database;
    return await db.insert(
      'device_schedules',
      {
        'deviceId': deviceId,
        'time': time,
        'state': state,
        'enabled': enabled ? 1 : 0,
      },
    );
  }

  Future<List<DeviceSchedule>> getSchedulesByDeviceId({
    required int deviceId,
  }) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'device_schedules',
      where: 'deviceId = ?',
      whereArgs: [deviceId],
    );

    return List.generate(maps.length, (i) {
      return DeviceSchedule.fromMap(maps[i]);
    });
  }

  Future<int> updateDeviceScheduleEnabled({
    required int scheduleId,
    required bool enabled,
  }) async {
    final db = await database;
    return await db.update(
      'device_schedules',
      {'enabled': enabled ? 1 : 0},
      where: 'id = ?',
      whereArgs: [scheduleId],
    );
  }

  Future<int> deleteDeviceSchedule({
    required int scheduleId,
  }) async {
    final db = await database;
    return await db.delete(
      'device_schedules',
      where: 'id = ?',
      whereArgs: [scheduleId],
    );
  }

  Future<int> resetScheduleTable() async {
    final db = await database;
    return await db.delete('device_schedules');
  }

  //// ALL
  Future<void> resetAllTables() async {
    final db = await database;
    await db.delete('device_schedules');
    await db.delete('devices');
    await db.delete('mesh_networks');
  }
}
