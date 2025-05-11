class MeshMessage {
  final String nodeId;
  final String value;

  MeshMessage({required this.nodeId, required this.value});

  factory MeshMessage.fromTopic(String topic, String payload) {
    final parts = topic.split('/');
    if (parts.length >= 4) {
      return MeshMessage(nodeId: parts[3], value: payload);
    }
    throw const FormatException('Invalid topic format');
  }

  @override
  String toString() => 'MeshMessage(nodeId: $nodeId, value: $value)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MeshMessage &&
          runtimeType == other.runtimeType &&
          nodeId == other.nodeId &&
          value == other.value;

  @override
  int get hashCode => nodeId.hashCode ^ value.hashCode;
}
