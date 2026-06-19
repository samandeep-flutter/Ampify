import 'package:ampify/data/utils/exports.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthRepo {
  // Future<bool> exists(String uid) async {
  //   try {
  //     final doc = await firestore.doc(uid).get();
  //     return doc.exists;
  //   } catch (_) {
  //     return false;
  //   }
  // }

  final _firestore = FirebaseFirestore.instance;

  Future<UserModel?> getUser(String uid) async {
    try {
      final repo = _firestore.collection(FBKeys.users);
      final doc = await repo.doc(uid).get();
      return UserModel.fromJson(doc.data()!);
    } catch (e) {
      logPrint(e, 'get-user');
      return null;
    }
  }

  Future<void> addUser(UserModel user) async {
    try {
      final repo = _firestore.collection(FBKeys.users);
      await repo.doc(user.id).set(user.toJson());
    } catch (e) {
      logPrint(e, 'update-user');
    }
  }

  Future<bool> updateLogin(String uid, bool login) async {
    try {
      final repo = _firestore.collection(FBKeys.users);
      await repo.doc(uid).update({'login': login});
      return true;
    } catch (e) {
      logPrint(e, 'update-login');
      return false;
    }
  }

  Future<void> updateToken(String uid, String? token) async {
    try {
      final repo = _firestore.collection(FBKeys.users);
      await repo.doc(uid).update({'device_token': token});
    } catch (e) {
      logPrint(e, 'update-login');
    }
  }
}
