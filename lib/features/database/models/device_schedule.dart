class DeviceSchedule {
  final int? id;
  final int deviceId;
  final String time;
  final String state;
  final bool enabled;

  DeviceSchedule({
    this.id,
    required this.deviceId,
    required this.time,
    required this.state,
    required this.enabled,
  });

  factory DeviceSchedule.fromMap(Map<String, dynamic> map) {
    return DeviceSchedule(
      id: map['id'],
      deviceId: map['deviceId'],
      time: map['time'],
      state: map['state'],
      enabled: map['enabled'] == 1, // SQLite stores booleans as 0/1
    );
  }

  Map<String, dynamic> toDisplayMap() {
    return {
      'scheduleId': id,
      'time': time,
      'state': state,
      'enabled': enabled,
    };
  }
}
