import 'package:ampify/data/data_models/common/album_model.dart';
import 'package:ampify/data/data_models/common/artist_model.dart';
import 'package:ampify/data/utils/exports.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class Track extends Equatable {
  final Album? album;
  final List<Artist>? artists;
  final int? discNumber;
  final int? durationMs;
  final bool? explicit;
  final String? href;
  final String? id;
  final String? name;
  final int? popularity;
  final int? trackNumber;
  final String? type;
  final String? uri;

  const Track({
    this.album,
    this.artists,
    this.discNumber,
    this.durationMs,
    this.explicit,
    this.href,
    this.id,
    this.name,
    this.popularity,
    this.trackNumber,
    this.type,
    this.uri,
  });

  factory Track.fromJson(Map<String, dynamic> json, {String? image}) {
    final defAlbum = Album(image: image, name: json['name'], id: json['id']);

    return Track(
      album: json['album'] != null ? Album.fromJson(json['album']) : defAlbum,
      artists: List<Artist>.from(
          json['artists']?.map((e) => Artist.fromJson(e)) ?? []),
      discNumber: json['disc_number'],
      durationMs: json['duration_ms'],
      explicit: json['explicit'],
      href: json['href'],
      id: json['id'],
      name: json['name'],
      popularity: json['popularity'],
      trackNumber: json['track_number'],
      type: json['type'],
      uri: json['uri'],
    );
  }

  Map<String, dynamic> toJson() => {
        'album': album?.toJson(),
        'artists': artists?.map((v) => v.toJson()).toList(),
        'disc_number': discNumber,
        'duration_ms': durationMs,
        'explicit': explicit,
        'href': href,
        'id': id,
        'name': name,
        'popularity': popularity,
        'track_number': trackNumber,
        'type': type,
        'uri': uri,
      };

  TrackDetails get asTrackDetails {
    return TrackDetails.track(
      id: id,
      title: name,
      albumId: album?.id,
      image: album?.image,
      subtitle: artists?.asString,
    );
  }

  @override
  List<Object?> get props => [
        album,
        artists,
        discNumber,
        durationMs,
        explicit,
        href,
        id,
        name,
        popularity,
        trackNumber,
        type,
        uri,
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
  })  : videoId = null,
        duration = null,
        darkBgColor = null,
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
        durationMs: duration?.inMilliseconds,
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
      duration: duration.inSeconds > 0 ? duration : null,
      image: json['image'],
      title: json['title'],
      subtitle: json['subtitle'],
      bgColor: json['bgColor'] != null ? Color(json['bgColor']) : null,
      darkBgColor:
          json['darkBgColor'] != null ? Color(json['darkBgColor']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'videoId': videoId,
        'albumId': albumId,
        'image': image,
        'title': title,
        'subtitle': subtitle,
        'duration': duration?.inSeconds,
        'bgColor': bgColor?.toARGB32(),
        'darkBgColor': darkBgColor?.toARGB32(),
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
