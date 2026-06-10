import 'package:ampify/services/extension_services.dart';
import 'package:equatable/equatable.dart';

class OwnerModel extends Equatable {
  final String? name;
  final String? href;
  final String? id;
  final String? type;
  final String? uri;

  const OwnerModel({this.name, this.href, this.id, this.type, this.uri});

  factory OwnerModel.fromJson(Map<String, dynamic> json) {
    return OwnerModel(
      name: json['display_name'],
      href: json['href'],
      id: json['id'],
      type: json['type'],
      uri: json['uri'],
    );
  }

  Map<String, dynamic> toJson() => {
        'display_name': name,
        'href': href,
        'id': id,
        'type': type,
        'uri': uri,
      };

  @override
  List<Object?> get props => [name, href, id, type, uri];
}

class Copyrights extends Equatable {
  final String? text;
  final String? type;

  const Copyrights({this.text, this.type});

  factory Copyrights.fromJson(Map<String, dynamic> json) {
    return Copyrights(text: json['text'], type: json['type']);
  }

  Map<String, dynamic> toJson() => {'text': text, 'type': type};

  @override
  List<Object?> get props => [text, type];
}

// class Artist extends Equatable {
//   final String? id;
//   final String? image;
//   final String? name;

//   const Artist({this.id, this.image, this.name});

//   factory Artist.fromJson(Map<String, dynamic> json) {
//     return Artist(
//       id: json['id'],
//       image: (json['images'] as List?)?.firstOrNull?['url'],
//       name: json['name'],
//     );
//   }

//   Map<String, dynamic> toJson() => {
//         'id': id,
//         'images': image,
//         'name': name,
//       };

//   @override
//   List<Object?> get props => [id, image, name];
// }

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
