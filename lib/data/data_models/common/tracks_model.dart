import 'package:ampify/data/repositories/music_repo.dart';
import 'package:ampify/data/utils/exports.dart';

class Track extends Equatable {
  final Album? album;
  final SongYtDetails? ytDetails;
  final List<Artist>? artists;
  final Duration? duration;
  final bool? explicit;
  final String? href;
  final String? id;
  final String? name;
  final int? popularity;
  final String? irsc;
  final int? trackNumber;
  final String? snapId;
  final String? type;
  final String? uri;

  const Track({
    this.album,
    this.artists,
    this.duration,
    this.explicit,
    this.href,
    this.id,
    this.name,
    this.ytDetails,
    this.popularity,
    this.trackNumber,
    this.irsc,
    this.snapId,
    this.type,
    this.uri,
  });

  factory Track.fromJson(Map<String, dynamic> json,
      {String? image, Album? album}) {
    return Track(
      album: json['album'] != null ? Album.fromJson(json['album']) : album,
      artists: List<Artist>.from(
          json['artists']?.map((e) => Artist.fromJson(e)) ?? []),
      duration: Duration(milliseconds: json['duration_ms']),
      ytDetails: json['ytDetails'] != null
          ? SongYtDetails.fromJson(json['ytDetails'])
          : null,
      explicit: json['explicit'],
      href: json['href'],
      id: json['id'],
      name: json['name'],
      irsc: json['external_ids']?['isrc'],
      popularity: json['popularity'],
      trackNumber: json['track_number'],
      snapId: json['snapshot_id'],
      type: json['type'],
      uri: json['uri'],
    );
  }

  Map<String, dynamic> toJson() => {
        'album': album?.toJson(),
        'artists': artists?.map((v) => v.toJson()).toList(),
        'duration_ms': duration?.inMilliseconds,
        'explicit': explicit,
        'href': href,
        'id': id,
        'name': name,
        'ytDetails': ytDetails?.toJson(),
        'external_ids': {'isrc': irsc},
        'popularity': popularity,
        'track_number': trackNumber,
        'snapshot_id': snapId,
        'type': type,
        'uri': uri,
      };

  Track copyWith(SongYtDetails ytDetails) {
    return Track(
      album: album,
      artists: artists,
      duration: duration,
      explicit: explicit,
      href: href,
      id: id,
      name: name,
      ytDetails: ytDetails,
      popularity: popularity,
      trackNumber: trackNumber,
      irsc: irsc,
      snapId: snapId,
      type: type,
      uri: uri,
    );
  }

  TrackDetails get asTrackDetails {
    return TrackDetails.track(
      id: id,
      title: name,
      albumId: album?.id,
      image: album?.image,
      subtitle: artists?.asString,
      duration: ytDetails?.duration,
      videoId: ytDetails?.videoId,
    );
  }

  @override
  List<Object?> get props => [
        album,
        artists,
        duration,
        explicit,
        href,
        id,
        name,
        popularity,
        trackNumber,
        type,
        uri,
        irsc,
        snapId,
      ];
}

class TrackDetails extends Equatable {
  final String? id;
  final String? videoId;
  final String? albumId;
  final Duration? duration;
  final String? image;
  final String? title;
  final String? subtitle;
  final Color? bgColor;
  final Color? darkBgColor;

  const TrackDetails({
    required this.id,
    required this.videoId,
    required this.albumId,
    required this.duration,
    required this.image,
    required this.title,
    required this.subtitle,
    required this.bgColor,
    required this.darkBgColor,
  });

  const TrackDetails.init()
      : id = null,
        videoId = null,
        duration = null,
        albumId = null,
        image = null,
        title = null,
        subtitle = null,
        darkBgColor = null,
        bgColor = null;
  const TrackDetails.track({
    required this.id,
    required this.albumId,
    required this.image,
    required this.title,
    required this.subtitle,
    this.duration,
    this.videoId,
  })  : darkBgColor = null,
        bgColor = null;

  TrackDetails copyWith({
    String? id,
    String? videoId,
    String? uri,
    String? albumId,
    String? image,
    String? title,
    Duration? duration,
    String? subtitle,
    Color? bgColor,
    Color? darkBgColor,
  }) {
    return TrackDetails(
      id: id ?? this.id,
      videoId: videoId ?? this.videoId,
      albumId: albumId ?? this.albumId,
      duration: duration ?? this.duration,
      image: image ?? this.image,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      bgColor: bgColor ?? this.bgColor,
      darkBgColor: darkBgColor ?? this.darkBgColor,
    );
  }

  Track get asTrack {
    return Track(
        id: id,
        name: title,
        duration: duration,
        album: Album(id: albumId, image: image),
        artists: subtitle?.split(',').map((e) {
          return Artist(name: e);
        }).toList());
  }

  factory TrackDetails.fromJson(Map<String, dynamic> json) {
    final duration = Duration(seconds: json['duration'] ?? 0);
    return TrackDetails(
      id: json['id'],
      videoId: json['videoId'],
      albumId: json['albumId'],
      image: json['image'],
      title: json['title'],
      subtitle: json['subtitle'],
      duration: duration.inSeconds > 0 ? duration : null,
      bgColor: json['bgColor'] != null ? Color(json['bgColor']) : null,
      darkBgColor:
          json['darkBgColor'] != null ? Color(json['darkBgColor']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        if (videoId != null) 'videoId': videoId,
        if (albumId != null) 'albumId': albumId,
        if (image != null) 'image': image,
        if (title != null) 'title': title,
        if (subtitle != null) 'subtitle': subtitle,
        if (duration != null) 'duration': duration?.inSeconds,
        if (bgColor != null) 'bgColor': bgColor?.toARGB32(),
        if (darkBgColor != null) 'darkBgColor': darkBgColor?.toARGB32(),
      };

  @override
  List<Object?> get props => [
        id,
        videoId,
        albumId,
        duration,
        image,
        title,
        subtitle,
        bgColor,
        darkBgColor
      ];
}
