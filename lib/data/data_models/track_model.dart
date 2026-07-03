import 'package:ampify/data/utils/exports.dart';

class Track extends Equatable {
  final String id;
  final String type;
  final String videoId;
  final String title;
  final MyArtistBasic artist;
  final Album? album;
  final Duration? duration;
  final Thumbnail? thumbnail;

  const Track({
    required this.id,
    required this.type,
    required this.videoId,
    required this.title,
    required this.artist,
    required this.album,
    required this.duration,
    required this.thumbnail,
  });

  factory Track.fromYT(SongDetailed track) {
    return Track(
      id: track.videoId,
      type: track.type,
      videoId: track.videoId,
      title: track.name,
      artist: MyArtistBasic.fromYT(track.artist),
      album: track.album != null ? Album.fromYtBasic(track.album!) : null,
      thumbnail: track.thumbnails.toThumbnail(),
      duration: track.duration?.toDuration(),
    );
  }
  factory Track.fromVid(VideoDetailed video) {
    return Track(
      id: video.videoId,
      type: video.type,
      videoId: video.videoId,
      title: video.name,
      album: null,
      artist: MyArtistBasic.fromYT(video.artist),
      thumbnail: video.thumbnails.toThumbnail(),
      duration: video.duration?.toDuration(),
    );
  }
  factory Track.fromUpNext(UpNextsDetails upnxt) {
    return Track(
      id: upnxt.videoId,
      type: upnxt.type,
      videoId: upnxt.videoId,
      title: upnxt.title,
      artist: MyArtistBasic.fromYT(upnxt.artists),
      album: upnxt.album != null ? Album.fromYtBasic(upnxt.album!) : null,
      thumbnail: upnxt.thumbnails.toThumbnail(),
      duration: Duration(seconds: upnxt.duration),
    );
  }

  Track copyWith({
    String? id,
    String? type,
    String? videoId,
    String? title,
    MyArtistBasic? artist,
    Album? album,
    Duration? duration,
    Thumbnail? thumbnail,
  }) {
    return Track(
      id: id ?? this.id,
      type: type ?? this.type,
      videoId: videoId ?? this.videoId,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      album: album ?? this.album,
      duration: duration ?? this.duration,
      thumbnail: thumbnail ?? this.thumbnail,
    );
  }

  factory Track.fromJson(Map<String, dynamic> json) {
    return Track(
      id: json['id'],
      type: json['type'],
      videoId: json['video_id'],
      title: json['title'],
      artist: MyArtistBasic.fromJson(json['artist']),
      album: json['album'] != null ? Album.fromJson(json['album']) : null,
      duration:
          json['duration'] != null ? Duration(seconds: json['duration']) : null,
      thumbnail: json['thumbnail'] != null
          ? Thumbnail.fromJson(json['thumbnail'])
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type,
        'video_id': videoId,
        'title': title,
        'artist': artist.toJson(),
        if (album != null) 'album': album?.toJson(),
        if (duration != null) 'duration': duration?.inSeconds,
        if (thumbnail != null) 'thumbnail': thumbnail?.toJson(),
      };

  @override
  List<Object?> get props =>
      [id, type, videoId, title, artist, album, duration, thumbnail];
}

class TrackDetails extends Equatable {
  final Track? track;
  final Color? bgColor;
  final Color? darkBgColor;

  const TrackDetails({
    required this.track,
    required this.bgColor,
    required this.darkBgColor,
  });

  const TrackDetails.init()
      : track = null,
        darkBgColor = null,
        bgColor = null;
  const TrackDetails.track(this.track)
      : darkBgColor = null,
        bgColor = null;

  TrackDetails copyWith({Track? track, Color? bgColor, Color? darkBgColor}) {
    return TrackDetails(
      track: track ?? this.track,
      bgColor: bgColor ?? this.bgColor,
      darkBgColor: darkBgColor ?? this.darkBgColor,
    );
  }

  factory TrackDetails.fromJson(Map<String, dynamic> json) {
    return TrackDetails(
      track: json['track'] != null ? Track.fromJson(json['track']) : null,
      bgColor: json['bg_color'] != null ? Color(json['bg_color']) : null,
      darkBgColor:
          json['dark_bg_color'] != null ? Color(json['dark_bg_color']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
        if (track != null) 'track': track?.toJson(),
        if (bgColor != null) 'bg_color': bgColor?.toARGB32(),
        if (darkBgColor != null) 'dark_bg_color': darkBgColor?.toARGB32(),
      };

  @override
  List<Object?> get props => [track, bgColor, darkBgColor];
}
