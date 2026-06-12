import 'package:ampify/services/extension_services.dart';
import 'package:equatable/equatable.dart';

class UserModel extends Equatable {
  final String id;
  final String displayName;
  final String? image;
  final String email;
  final bool? login;
  final String? deviceToken;

  const UserModel({
    required this.id,
    required this.image,
    required this.displayName,
    required this.email,
    required this.login,
    required this.deviceToken,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      image: json['image'],
      displayName: json['display_name'],
      email: json['email'],
      deviceToken: json['device_token'],
      login: json['login'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'image': image,
        'display_name': displayName,
        'email': email,
        'login': login,
        if (deviceToken != null) 'device_token': deviceToken,
      };

  UserModel copyWith({
    String? id,
    String? displayName,
    String? image,
    String? email,
    bool? login,
    String? deviceToken,
  }) {
    return UserModel(
      id: id ?? this.id,
      image: image ?? this.image,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      login: login ?? this.login,
      deviceToken: deviceToken ?? this.deviceToken,
    );
  }

  UserModel copyFrom({required UserModel? details}) {
    return UserModel(
      id: details?.id ?? id,
      image: details?.image ?? image,
      displayName: details?.displayName ?? displayName,
      email: details?.email ?? email,
      login: details?.login ?? login,
      deviceToken: details?.deviceToken ?? deviceToken,
    );
  }

  @override
  List<Object?> get props =>
      [id, displayName, image, email, login, deviceToken];
}

enum LogType { error, info, network }

class LogModel extends Equatable {
  final String? title;
  final String? content;
  final String? extra;
  final String? time;
  final LogType? type;

  const LogModel({
    required this.title,
    required this.content,
    required this.extra,
    required this.time,
    required this.type,
  });

  factory LogModel.fromJson(Map<String, dynamic> json) {
    return LogModel(
      title: json['title'],
      content: json['content'],
      extra: json['extra'],
      time: json['time'],
      type: LogType.values.firstWhereOrNull((e) => e.name == json['type']),
    );
  }

  Map<String, dynamic> toJson() => {
        'title': title,
        'content': content,
        'extra': extra,
        'time': time,
        'type': type?.name
      };

  @override
  List<Object?> get props => [title, content, extra, time, type];
}
