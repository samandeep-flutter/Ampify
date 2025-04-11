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
