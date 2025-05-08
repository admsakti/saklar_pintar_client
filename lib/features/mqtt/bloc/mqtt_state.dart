part of 'mqtt_bloc.dart';

abstract class MQTTState extends Equatable {
  @override
  List<Object?> get props => [];
}

class MQTTInitial extends MQTTState {}

class MQTTConnecting extends MQTTState {}

class MQTTError extends MQTTState {
  final String message;

  MQTTError(this.message);

  @override
  List<Object?> get props => [message];
}

class MQTTConnected extends MQTTState {
  final List<NodeMessage> messages;

  MQTTConnected({this.messages = const []});

  MQTTConnected copyWith({List<NodeMessage>? messages}) {
    return MQTTConnected(
      messages: messages ?? this.messages,
    );
  }

  @override
  List<Object?> get props => [messages];
}
