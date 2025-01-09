import 'package:ampify/data/data_models/common/tracks_model.dart';
import 'package:equatable/equatable.dart';
import 'images_models.dart';

class Playlist extends Equatable {
  final bool? collaborative;
  final String? description;
  final String? href;
  final String? id;
  final ImagesModel? image;
  final String? name;
  final OwnerModel? owner;
  final bool? public;
  final String? snapshotId;
  final List<TrackItems>? tracks;
  final String? type;
  final String? uri;

  const Playlist(
      {this.collaborative,
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
      this.uri});

  factory Playlist.fromJson(Map<String, dynamic> json) {
    return Playlist(
      collaborative: json['collaborative'],
      description: json['description'],
      href: json['href'],
      id: json['id'],
      image: (json['images'] as List?)?.isNotEmpty ?? false
          ? ImagesModel.fromJson((json['images'] as List).first)
          : null,
      name: json['name'],
      owner: json['owner'] != null ? OwnerModel.fromJson(json['owner']) : null,
      public: json['public'],
      snapshotId: json['snapshot_id'],
      tracks: (json['tracks']?['items'] as List?)
          ?.map((e) => TrackItems.fromJson(e))
          .toList(),
      type: json['type'],
      uri: json['uri'],
    );
  }

  Map<String, dynamic> toJson() => {
        'collaborative': collaborative,
        'description': description,
        'href': href,
        'id': id,
        'images': image?.toJson(),
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

// class TracksDetails {
//   String? href;
//   List<TrackItems>? items;
//   int? limit;
//   dynamic next;
//   int? offset;
//   dynamic previous;
//   int? total;

//   TracksDetails(
//       {this.href,
//       this.items,
//       this.limit,
//       this.next,
//       this.offset,
//       this.previous,
//       this.total});

//   TracksDetails.fromJson(Map<String, dynamic> json) {
//     href = json['href'];
//     if (json['items'] != null) {
//       items = <TrackItems>[];
//       json['items'].forEach((v) {
//         items!.add(TrackItems.fromJson(v));
//       });
//     }
//     limit = json['limit'];
//     next = json['next'];
//     offset = json['offset'];
//     previous = json['previous'];
//     total = json['total'];
//   }

//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = <String, dynamic>{};
//     data['href'] = href;
//     if (items != null) {
//       data['items'] = items!.map((v) => v.toJson()).toList();
//     }
//     data['limit'] = limit;
//     data['next'] = next;
//     data['offset'] = offset;
//     data['previous'] = previous;
//     data['total'] = total;
//     return data;
//   }
// }

class TrackItems {
  String? addedAt;
  String? addedBy;
  bool? isLocal;
  dynamic primaryColor;
  Track? track;

  TrackItems({
    this.addedAt,
    this.addedBy,
    this.isLocal,
    this.primaryColor,
    this.track,
  });

  TrackItems.fromJson(Map<String, dynamic> json) {
    addedAt = json['added_at'];
    addedBy = json['added_by']?['id'];
    isLocal = json['is_local'];
    primaryColor = json['primary_color'];
    track = json['track'] != null ? Track.fromJson(json['track']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['added_at'] = addedAt;
    data['added_by'] = addedBy;
    data['is_local'] = isLocal;
    data['primary_color'] = primaryColor;
    data['track'] = track?.toJson();
    return data;
  }
}
