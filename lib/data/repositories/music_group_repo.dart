import 'package:ampify/data/utils/exports.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MusicGroupRepo {
  final _firestore = FirebaseFirestore.instance;

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
