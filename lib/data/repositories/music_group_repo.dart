import 'package:ampify/data/utils/app_constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MusicGroupRepo {
  final _firestore = FirebaseFirestore.instance;

  Future<void> addToLibrary(String uid) async {
    try {
      final _lib = _firestore.collection(FBKeys.library);
      final repo = _lib.doc(uid).collection(FBKeys.musicGroup);
    } catch (e) {
      logPrint(e, 'lib-add');
    }
  }

  Future<void> removeFromLibrary(String uid) async {}
}
