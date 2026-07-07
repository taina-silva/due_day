import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:due_day/core/errors/exceptions.dart';
import 'package:due_day/features/auth/data/models/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> signInWithEmail(String email, String password);
  Future<UserModel> signUpWithEmail(
    String email,
    String password,
    String? name,
  );
  Future<UserModel> signInWithGoogle();
  Future<void> signOut();
  Future<UserModel?> getCurrentUser();
  Future<void> updateUser(UserModel user);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final FirebaseAuth firebaseAuth;
  final FirebaseFirestore firestore;
  final GoogleSignIn googleSignIn;

  AuthRemoteDataSourceImpl({
    required this.firebaseAuth,
    required this.firestore,
    required this.googleSignIn,
  });

  @override
  Future<UserModel> signInWithEmail(String email, String password) async {
    try {
      final userCredential = await firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user == null) {
        throw const ServerException(
          'User not found in database.',
          'user-not-found-firestore',
        );
      }

      final user = userCredential.user!;
      return _getUserFromFirestore(user.uid, authUser: user);
    } on FirebaseAuthException catch (e) {
      throw ServerException(e.message ?? 'Authentication error.', e.code);
    } catch (e) {
      throw const ServerException('Unexpected login error.');
    }
  }

  @override
  Future<UserModel> signUpWithEmail(
    String email,
    String password,
    String? name,
  ) async {
    try {
      final userCredential = await firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final UserModel newUser = UserModel(
        uid: userCredential.user!.uid,
        email: email,
        name: name,
        createdAt: DateTime.now(),
      );

      await firestore
          .collection('users')
          .doc(newUser.uid)
          .set(newUser.toJson());

      return newUser;
    } on FirebaseAuthException catch (e) {
      throw ServerException(e.message ?? 'Error creating account.', e.code);
    } catch (e) {
      throw const ServerException('Unexpected error creating account.');
    }
  }

  @override
  Future<UserModel> signInWithGoogle() async {
    try {
      final GoogleSignInAccount googleUser = await googleSignIn.authenticate();

      final GoogleSignInAuthentication googleAuth = googleUser.authentication;
      final OAuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await firebaseAuth
          .signInWithCredential(credential);
      final User user = userCredential.user!;

      final doc = await firestore.collection('users').doc(user.uid).get();
      if (doc.exists && doc.data() != null) {
        final data = Map<String, dynamic>.from(doc.data()!);
        data['uid'] ??= user.uid;
        data['email'] ??= user.email ?? '';
        return UserModel.fromJson(data);
      } else {
        final UserModel newUser = UserModel(
          uid: user.uid,
          email: user.email ?? '',
          name: user.displayName,
          photoUrl: user.photoURL,
          createdAt: DateTime.now(),
        );
        await firestore
            .collection('users')
            .doc(newUser.uid)
            .set(newUser.toJson());
        return newUser;
      }
    } on FirebaseAuthException catch (e) {
      throw ServerException(e.message ?? 'Google sign-in error.', e.code);
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) {
        throw const ServerException(
          'Google sign-in cancelled.',
          'google-sign-in-canceled',
        );
      }
      throw ServerException(
        e.description ?? 'Google sign-in authentication error.',
        e.code.name,
      );
    } catch (e) {
      throw const ServerException('Unexpected Google sign-in error.');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await Future.wait([firebaseAuth.signOut(), googleSignIn.signOut()]);
    } catch (e) {
      throw const ServerException('Error signing out.');
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    final user = firebaseAuth.currentUser;
    if (user != null) {
      return _getUserFromFirestore(user.uid, authUser: user);
    }
    return null;
  }

  @override
  Future<void> updateUser(UserModel user) async {
    try {
      await firestore.collection('users').doc(user.uid).update(user.toJson());
    } catch (e) {
      throw const ServerException('Error updating user profile.');
    }
  }

  Future<UserModel> _getUserFromFirestore(String uid, {User? authUser}) async {
    final doc = await firestore.collection('users').doc(uid).get();
    if (doc.exists && doc.data() != null) {
      final data = Map<String, dynamic>.from(doc.data()!);
      data['uid'] ??= uid;
      data['email'] ??= authUser?.email ?? '';
      return UserModel.fromJson(data);
    } else {
      throw const ServerException(
        'User not found in database.',
        'user-not-found-firestore',
      );
    }
  }
}
