import 'package:equatable/equatable.dart';

class MeshNetwork extends Equatable {
  final int? id;
  final String macRoot;
  final String name;

  const MeshNetwork({
    this.id,
    required this.macRoot,
    required this.name,
  });

  @override
  List<Object?> get props => [
        id,
        macRoot,
        name,
      ];

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'macRoot': macRoot,
      'name': name,
    };
  }

  factory MeshNetwork.fromMap(Map<String, dynamic> map) {
    return MeshNetwork(
      id: map['id'],
      macRoot: map['macRoot'],
      name: map['name'],
    );
  }
}
