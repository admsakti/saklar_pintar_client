import 'package:equatable/equatable.dart';

class Device extends Equatable {
  final int? id;
  final String deviceId;
  final String name;
  final String role; // root / node
  final int meshId; // Foreign key ke mesh

  const Device({
    this.id,
    required this.deviceId,
    required this.name,
    required this.role,
    required this.meshId,
  });

  @override
  List<Object?> get props => [
        id,
        deviceId,
        name,
        role,
        meshId,
      ];

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'deviceId': deviceId,
      'name': name,
      'role': role,
      'meshId': meshId,
    };
  }

  factory Device.fromMap(Map<String, dynamic> map) {
    return Device(
      id: map['id'],
      deviceId: map['deviceId'],
      name: map['name'],
      role: map['role'],
      meshId: map['meshId'],
    );
  }
}
