class DeviceStatuses {
  final String nodeId;
  final String value;

  DeviceStatuses({required this.nodeId, required this.value});

  factory DeviceStatuses.fromTopic(String topic, String payload) {
    final parts = topic.split('/');
    if (parts.length >= 4) {
      return DeviceStatuses(nodeId: parts[3], value: payload);
    }
    throw const FormatException('Invalid topic format');
  }

  @override
  String toString() => 'DeviceStatuses(nodeId: $nodeId, value: $value)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DeviceStatuses &&
          runtimeType == other.runtimeType &&
          nodeId == other.nodeId &&
          value == other.value;

  @override
  int get hashCode => nodeId.hashCode ^ value.hashCode;
}
