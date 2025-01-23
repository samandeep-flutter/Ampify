import 'package:equatable/equatable.dart';

class ImagesModel extends Equatable {
  final int? height;
  final String? url;
  final int? width;

  const ImagesModel({this.height, this.url, this.width});

  factory ImagesModel.fromJson(Map<String, dynamic> json) {
    return ImagesModel(
      height: json['height'],
      url: json['url'],
      width: json['width'],
    );
  }

  Map<String, dynamic> toJson() =>
      {'height': height, 'url': url, 'width': width};

  @override
  List<Object?> get props => [height, width, url];
}

class OwnerModel extends Equatable {
  final String? displayName;
  final String? href;
  final String? id;
  final String? type;
  final String? uri;

  const OwnerModel({this.displayName, this.href, this.id, this.type, this.uri});

  factory OwnerModel.fromJson(Map<String, dynamic> json) {
    return OwnerModel(
      displayName: json['display_name'],
      href: json['href'],
      id: json['id'],
      type: json['type'],
      uri: json['uri'],
    );
  }

  Map<String, dynamic> toJson() => {
        'display_name': displayName,
        'href': href,
        'id': id,
        'type': type,
        'uri': uri,
      };

  @override
  List<Object?> get props => [displayName, href, id, type, uri];
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
