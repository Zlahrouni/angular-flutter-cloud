import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(); // Instance GoogleSignIn

  // Stream pour écouter les changements d'état de l'authentification
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Obtenir l'utilisateur actuel
  User? get currentUser => _auth.currentUser;

  // Inscription avec email/password
  Future<UserCredential?> register(String email, String password) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        throw 'Le mot de passe est trop faible';
      } else if (e.code == 'email-already-in-use') {
        throw 'Cet email est déjà utilisé';
      }
      throw e.message ?? 'Une erreur est survenue';
    }
  }

  // Connexion avec email/password
  Future<UserCredential?> login(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        throw 'Aucun utilisateur trouvé pour cet email';
      } else if (e.code == 'wrong-password') {
        throw 'Mot de passe incorrect';
      }
      throw e.message ?? 'Une erreur est survenue';
    }
  }

  // Connexion avec Google
  Future<UserCredential?> signInWithGoogle() async {
    try {
      // Déclencher le flux d'authentification Google
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      // Vérifier si l'utilisateur a annulé la connexion
      if (googleUser == null) {
        throw 'Connexion Google annulée';
      }

      // Obtenir les détails d'authentification
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Vérifier si nous avons bien reçu les tokens
      if (googleAuth.accessToken == null || googleAuth.idToken == null) {
        throw 'Impossible d\'obtenir les identifiants Google';
      }

      // Créer un nouvel identifiant
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Connexion à Firebase avec les identifiants Google
      return await _auth.signInWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      throw e.message ?? 'Erreur d\'authentification Firebase';
    } catch (e) {
      throw 'Erreur de connexion Google: ${e.toString()}';
    }
  }

  // Déconnexion
  Future<void> logout() async {
    try {
      await _googleSignIn.signOut(); // Déconnexion de Google
      await _auth.signOut(); // Déconnexion de Firebase
    } catch (e) {
      throw 'Erreur lors de la déconnexion';
    }
  }

  // Réinitialisation du mot de passe
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw e.message ?? 'Une erreur est survenue';
    }
  }

  // Mise à jour du profil
  Future<void> updateProfile({String? displayName, String? photoURL}) async {
    try {
      await currentUser?.updateDisplayName(displayName);
      await currentUser?.updatePhotoURL(photoURL);
    } catch (e) {
      throw 'Erreur lors de la mise à jour du profil';
    }
  }
}
