import 'package:ampify/data/utils/exports.dart';
import 'package:equatable/equatable.dart';

class ProfileModel extends Equatable {
  final String? id;
  final String? displayName;
  final String? email;
  final String? href;
  final int? followers;
  final String? image;
  final String? product;
  final String? type;

  const ProfileModel({
    this.id,
    this.displayName,
    this.email,
    this.followers,
    this.href,
    this.image,
    this.product,
    this.type,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      displayName: json['display_name'],
      email: json['email'],
      followers: json['followers']?['total'],
      href: json['href'],
      id: json['id'],
      image: (json['images'] as List?)?.firstElement?['url'],
      product: json['product'],
      type: json['type'],
    );
  }

  Map<String, dynamic> toJson() => {
        'display_name': displayName,
        'email': email,
        'followers': followers,
        'href': href,
        'id': id,
        'images': image,
        'product': product,
        'type': type,
      };

  @override
  List<Object?> get props =>
      [id, email, displayName, followers, href, image, product, type];
}
