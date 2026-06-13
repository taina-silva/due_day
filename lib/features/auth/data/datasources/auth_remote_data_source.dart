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
          'Usuário não encontrado no banco de dados.',
        );
      }

      final user = userCredential.user!;
      return _getUserFromFirestore(user.uid, authUser: user);
    } on FirebaseAuthException catch (e) {
      throw ServerException(e.message ?? 'Erro na autenticação.');
    } catch (e) {
      throw const ServerException('Erro inesperado ao fazer login.');
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
      throw ServerException(e.message ?? 'Erro ao criar conta.');
    } catch (e) {
      throw const ServerException('Erro inesperado ao criar conta.');
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

      // Verifica se o usúário já existe
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
      throw ServerException(e.message ?? 'Erro no login com Google.');
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) {
        throw const ServerException('Login pelo Google cancelado.');
      }
      throw ServerException(e.description ?? 'Erro na autenticação com Google.');
    } catch (e) {
      throw const ServerException('Erro inesperado no login com Google.');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await Future.wait([firebaseAuth.signOut(), googleSignIn.signOut()]);
    } catch (e) {
      throw const ServerException('Erro ao sair da conta.');
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
      await firestore
          .collection('users')
          .doc(user.uid)
          .update(user.toJson());
    } catch (e) {
      throw const ServerException('Erro ao atualizar perfil do usuário.');
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
      throw const ServerException('Usuário não encontrado no banco de dados.');
    }
  }
}
