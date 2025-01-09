import 'package:equatable/equatable.dart';
import 'common/playlist_model.dart';

class LibraryModel extends Equatable {
  final String? href;
  final int? limit;
  final dynamic next;
  final int? offset;
  final dynamic previous;
  final int? total;
  final List<Playlist>? items;

  const LibraryModel(
      {this.href,
      this.limit,
      this.next,
      this.offset,
      this.previous,
      this.total,
      this.items});

  factory LibraryModel.fromJson(Map<String, dynamic> json) {
    return LibraryModel(
      href: json['href'],
      limit: json['limit'],
      next: json['next'],
      offset: json['offset'],
      previous: json['previous'],
      total: json['total'],
      items: List<Playlist>.from(
          json['items']?.map((e) => Playlist.fromJson(e)) ?? []),
    );
  }

  Map<String, dynamic> toJson() => {
        'href': href,
        'limit': limit,
        'next': next,
        'offset': offset,
        'previous': previous,
        'total': total,
        'items': items?.map((v) => v.toJson()).toList(),
      };

  @override
  List<Object?> get props =>
      [href, limit, next, offset, previous, total, items];
}
