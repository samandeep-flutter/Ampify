import 'package:ampify/data/data_models/common/tracks_model.dart';
import 'package:ampify/data/utils/exports.dart';
import 'package:equatable/equatable.dart';
import 'other_models.dart';

class Playlist extends Equatable {
  final bool? collaborative;
  final String? description;
  final String? href;
  final String? id;
  final String? image;
  final String? name;
  final OwnerModel? owner;
  final bool? public;
  final String? snapshotId;
  final List<PLitemDetails>? tracks;
  final String? type;
  final String? uri;

  const Playlist({
    this.collaborative,
    this.description,
    this.href,
    this.id,
    this.image,
    this.name,
    this.owner,
    this.public,
    this.snapshotId,
    this.tracks,
    this.type,
    this.uri,
  });

  factory Playlist.fromJson(Map<String, dynamic> json) {
    return Playlist(
      collaborative: json['collaborative'],
      description: json['description'],
      href: json['href'],
      id: json['id'],
      image: (json['images'] as List?)?.firstElement?['url'],
      name: json['name'],
      owner: json['owner'] != null ? OwnerModel.fromJson(json['owner']) : null,
      public: json['public'],
      snapshotId: json['snapshot_id'],
      tracks: List<PLitemDetails>.from(json['tracks']?['items']?.map((e) {
            return PLitemDetails.fromJson(e);
          }) ??
          []),
      type: json['type'],
      uri: json['uri'],
    );
  }

  Map<String, dynamic> toJson() => {
        'collaborative': collaborative,
        'description': description,
        'href': href,
        'id': id,
        'images': image,
        'name': name,
        'owner': owner?.toJson(),
        'public': public,
        'snapshot_id': snapshotId,
        'tracks': tracks?.map((e) => e.toJson()).toList(),
        'type': type,
        'uri': uri,
      };

  @override
  List<Object?> get props => [
        collaborative,
        description,
        href,
        id,
        image,
        name,
        owner,
        public,
        snapshotId,
        tracks,
        type,
        uri,
      ];
}

class PLtracksItems extends Equatable {
  final String? href;
  final List<PLitemDetails>? track;
  final int? limit;
  final int? offset;
  final int? total;

  const PLtracksItems(
      {this.href, this.track, this.limit, this.offset, this.total});

  factory PLtracksItems.fromJson(Map<String, dynamic> json) {
    return PLtracksItems(
        href: json['href'],
        track: List<PLitemDetails>.from(
            json['items']?.map((e) => PLitemDetails.fromJson(e)) ?? []),
        limit: json['limit'],
        offset: json['offset'],
        total: json['total']);
  }

  Map<String, dynamic> toJson() => {
        'href': href,
        'items': track?.map((e) => e.toJson()).toList(),
        'limit': limit,
        'offset': offset,
        'total': total,
      };

  @override
  List<Object?> get props => [href, track, limit, offset, total];
}

class PLitemDetails extends Equatable {
  final String? addedAt;
  final String? addedBy;
  final bool? isLocal;
  final Track? track;

  const PLitemDetails({this.addedAt, this.addedBy, this.isLocal, this.track});

  factory PLitemDetails.fromJson(Map<String, dynamic> json) {
    return PLitemDetails(
      addedAt: json['added_at'],
      addedBy: json['added_by']?['id'],
      isLocal: json['is_local'],
      track: json['track'] != null ? Track.fromJson(json['track']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'added_at': addedAt,
        'added_by': addedBy,
        'is_local': isLocal,
        'track': track?.toJson(),
      };

  @override
  List<Object?> get props => [addedAt, addedBy, isLocal, track];
}
