import 'package:ampify/data/utils/exports.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MusicGroupRepo {
  final YTMusic _ytMusic;
  MusicGroupRepo(this._ytMusic);
  final _firestore = FirebaseFirestore.instance;

  Future<Playlist> playlistDetails(String id) async {
    final playlist = await _ytMusic.getPlaylist(id);
    return Playlist.fromYT(playlist);
  }

  Future<Album> albumDetails(String id) async {
    final album = await _ytMusic.getAlbum(id);
    return Album.fromYtFull(album);
  }

  Future<List<Track>> playlistTracks(String id) async {
    try {
      final list = await _ytMusic.getPlaylistVideos(id);
      return List<Track>.from(list.map((e) => Track.fromVid(e)));
    } catch (e) {
      logPrint(e, 'playlist-tracks');
      return [];
    }
  }

  Future<bool> addToLibrary(String uid, LibraryModel model) async {
    try {
      final _lib = _firestore.collection(FBKeys.library);
      final repo = _lib.doc(uid).collection(FBKeys.musicGroup);
      final item = LibDbModel.fromLibrary(model, id: model.id);
      await repo.doc().set(item.toJson());
      return true;
    } catch (e) {
      logPrint(e, 'lib-add');
      return false;
    }
  }

  Future<bool> removeFromLibrary(String uid, String id) async {
    try {
      final _lib = _firestore.collection(FBKeys.library);
      final repo = _lib.doc(uid).collection(FBKeys.musicGroup);
      final query = await repo.where('id', isEqualTo: id).limit(1).get();
      await query.docs.firstOrNull?.reference.delete();
      return query.docs.firstOrNull != null;
    } catch (e) {
      logPrint(e, 'lib-remove');
      return false;
    }
  }

  Future<bool> isInLibrary(String uid, String id) async {
    final _lib = _firestore.collection(FBKeys.library);
    final repo = _lib.doc(uid).collection(FBKeys.musicGroup);
    final query = await repo.where('id', isEqualTo: id).limit(1).get();
    return query.docs.firstOrNull != null;
  }

  Future<void> createPlaylist(String uid, String title) async {
    final _lib = _firestore.collection(FBKeys.library);
    final repo = _lib.doc(uid).collection(FBKeys.musicGroup);
    final doc = repo.doc();
    final lib = LibraryModel.fb(id: doc.id, docId: doc.id, title: title);
    final item = LibDbModel.fromLibrary(lib, id: doc.id, owner: uid);
    await repo.doc(doc.id).set(item.toJson());
  }
}
