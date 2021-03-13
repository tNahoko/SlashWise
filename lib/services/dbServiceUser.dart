import "package:cloud_firestore/cloud_firestore.dart";
import 'package:slash_wise/models/dbUser.dart';
import "package:slash_wise/models/user.dart";

class DatabaseServiceUser {
  final String uid;
  DatabaseServiceUser({this.uid});

  //collection reference
  final CollectionReference userCollection = FirebaseFirestore.instance
      .collection('users'); //Firestore => FirebaseFirestore

  // Stream<List<User>> users() {
  //   return groupCollection
  //       .snapshots()
  //       .map((QuerySnapshot querySnapshot) => querySnapshot.docs
  //           .map(
  //             (e) => User(e.id, e.data()['name'],
  //                 e.data()['users']?.cast<String>(), e.data()['date'].toDate()),
  //           )
  //           .toList());
  // }

  Future updateUserData(String email, String username) async {
    return await userCollection.doc(uid).set({
      //document => doc, setData => set
      'email': email,
      'username': username,
    });
  }

  // user list from snapshot
  List<DbUser> _userListFromSnapshot(QuerySnapshot snapshot) {
    return snapshot.docs.map((doc) {
      //documents => docs
      //print(doc.data()['email']);
      return DbUser(
        email: doc.data()['email'] ?? "",
        //age: doc.data['age'] ?? 0,
      );
    }).toList();
  }

  // get users stream
  Stream<List<User>> users() {
    return userCollection
        .snapshots()
        .map((QuerySnapshot querySnapshot) => querySnapshot.docs
            .map(
              (e) => User(e.id, e.data()['username'], e.data()['email']),
            )
            .toList());
  }

  Future<List<User>> getUsers(List<String> userIDs) async {
    final mappedUserIDs = userIDs.map((userID) async {
      return await getUser(userID);
    }).toList();

    final futureList = Future.wait(mappedUserIDs);
    List<User> result = await futureList;

    return result;
  }

  Future<User> getUser(String userID) async {
    final user =
        await userCollection.doc(userID).get().then((DocumentSnapshot doc) {
      final caughtUser = User(doc.id, doc["username"], doc["email"]);
      return caughtUser;
    });

    return user;
  }

  Future<User> getUserByEmail(String email) async {
    final User user = await userCollection
        .where("email", isEqualTo: email)
        .get()
        .then((QuerySnapshot doc) {
      if (doc.docs.isNotEmpty) {
        final caughtUser = User(doc.docs[0].id, doc.docs[0]["username"], email);
        return caughtUser;
      } else {
        return null;
      }
    });

    return user;
  }

  Future<void> deleteUser(String userID) async {
    await userCollection.doc(userID).delete();
  }

  Future<void> changeUserName(String userID, String newName) async {
    await userCollection.doc(userID).update({'username': newName});
  }
}
