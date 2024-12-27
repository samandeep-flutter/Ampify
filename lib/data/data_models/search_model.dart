import 'package:ampify/data/data_models/album_model.dart';
import 'package:ampify/data/data_models/artist_model.dart';
import 'package:ampify/data/data_models/playlist_model.dart';

import 'tracks_model.dart';

class SearchModel {
  TrackModel? tracks;
  ArtistModel? artists;
  AlbumModel? albums;
  PlaylistModel? playlists;

  SearchModel({this.tracks, this.artists, this.albums, this.playlists});

  SearchModel.fromJson(Map<String, dynamic> json) {
    tracks =
        json['tracks'] != null ? TrackModel.fromJson(json['tracks']) : null;
    artists =
        json['artists'] != null ? ArtistModel.fromJson(json['artists']) : null;
    albums =
        json['albums'] != null ? AlbumModel.fromJson(json['albums']) : null;
    playlists = json['playlists'] != null
        ? PlaylistModel.fromJson(json['playlists'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['tracks'] = tracks?.toJson();
    data['artists'] = artists?.toJson();
    data['albums'] = albums?.toJson();
    data['playlists'] = playlists?.toJson();
    return data;
  }
}
