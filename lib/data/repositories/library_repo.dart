import 'package:ampify/buisness_logic/library_bloc/library_bloc.dart';
import 'package:ampify/data/utils/exports.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LibraryRepo {
  final _firestore = FirebaseFirestore.instance;

  Future<LibResponseModel?> libDetails(String uid) async {
    try {
      final repo = _firestore.collection(FBKeys.library);
      final json = await repo.doc(uid).get();
      return LibResponseModel.fromJson(json.data()!);
    } catch (e) {
      logPrint(e, 'lib-details');
      return null;
    }
  }

  Future<void> updateOrder(String uid, SortOrder order) async {
    try {
      final repo = _firestore.collection(FBKeys.library);
      await repo.doc(uid).update({'sort_order': order.name});
    } catch (e) {
      logPrint(e, 'lib-order');
    }
  }

  Future<void> updateFilter(String uid, LibItemType filter) async {
    try {
      final repo = _firestore.collection(FBKeys.library);
      await repo.doc(uid).update({'filter_order': filter.id});
    } catch (e) {
      logPrint(e, 'lib-filter');
    }
  }

  Future<AggregateQuerySnapshot?> likedSnapshot(String uid) async {
    try {
      final _lib = _firestore.collection(FBKeys.library);
      final repo = _lib.doc(uid).collection(FBKeys.likedTracks);
      return await repo.count().get();
    } catch (e) {
      logPrint(e, 'liked-count');
      return null;
    }
  }

  Future<List<FirestoreSnapshot>> likedTracks(String uid,
      {required int limit, DocumentSnapshot? snapshot}) async {
    try {
      final _lib = _firestore.collection(FBKeys.library);
      final repo = _lib.doc(uid).collection(FBKeys.likedTracks);
      final query = repo.limit(limit).afterDoc(snapshot);
      final ref = await query.orderBy('added_at', descending: true).get();
      return ref.docs;
    } catch (e) {
      logPrint(e, 'liked-count');
      return [];
    }
  }

  Future<List<LibDbModel>> libraryItems(String uid) async {
    try {
      final repo = _firestore.collection(FBKeys.library).doc(uid);
      final query = await repo.collection(FBKeys.musicGroup).get();
      return query.docs.map((e) => LibDbModel.fromJson(e.data())).toList();
    } catch (e) {
      logPrint(e, 'lib-items');
      return [];
    }
  }
}
