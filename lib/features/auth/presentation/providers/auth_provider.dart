import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/user_entity.dart';
import '../../../../core/constants/app_constants.dart';

enum AuthState { initial, loading, authenticated, unauthenticated, error }

enum AuthProviderType { google, apple, email, linkedin }

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  AuthState _state = AuthState.initial;
  UserEntity? _currentUser;
  String? _errorMessage;
  bool _isOnboarded = false;

  AuthState get state => _state;
  UserEntity? get currentUser => _currentUser;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _state == AuthState.authenticated;
  bool get isLoading => _state == AuthState.loading;
  bool get isOnboarded => _isOnboarded;

  AuthProvider() {
    _init();
  }

  Future<void> _init() async {
    _auth.authStateChanges().listen((User? firebaseUser) async {
      if (firebaseUser != null) {
        await _loadUserData(firebaseUser.uid);
      } else {
        _state = AuthState.unauthenticated;
        _currentUser = null;
        notifyListeners();
      }
    });
  }

  Future<void> _loadUserData(String uid) async {
    try {
      final doc = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(uid)
          .get();

      if (doc.exists) {
        _currentUser = _userFromFirestore(doc);
        _isOnboarded = _currentUser!.isOnboardingComplete;
        _state = AuthState.authenticated;
      } else {
        _state = AuthState.unauthenticated;
      }
    } catch (e) {
      _errorMessage = e.toString();
      _state = AuthState.error;
    }
    notifyListeners();
  }

  UserEntity _userFromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserEntity(
      id: doc.id,
      email: data['email'] ?? '',
      firstName: data['firstName'] ?? '',
      lastName: data['lastName'] ?? '',
      photoUrl: data['photoUrl'],
      phoneNumber: data['phoneNumber'],
      profession: data['profession'] ?? '',
      industry: data['industry'] ?? '',
      careerGoal: data['careerGoal'] ?? '',
      isEmailVerified: data['isEmailVerified'] ?? false,
      isOnboardingComplete: data['isOnboardingComplete'] ?? false,
      subscriptionTier: data['subscriptionTier'] == 'pro'
          ? SubscriptionTier.pro
          : SubscriptionTier.free,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastActive: (data['lastActive'] as Timestamp?)?.toDate() ?? DateTime.now(),
      resumesCreated: data['resumesCreated'] ?? 0,
      atsScansCount: data['atsScansCount'] ?? 0,
    );
  }

  Future<void> signInWithGoogle() async {
    try {
      _setLoading();
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        _state = AuthState.unauthenticated;
        notifyListeners();
        return;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      await _createOrUpdateUser(userCredential.user!, AuthProviderType.google);
    } catch (e) {
      _setError(e.toString());
    }
  }

  Future<void> signInWithApple() async {
    try {
      _setLoading();
      final appleProvider = AppleAuthProvider()
        ..addScope('email')
        ..addScope('name');

      final userCredential = await _auth.signInWithProvider(appleProvider);
      await _createOrUpdateUser(userCredential.user!, AuthProviderType.apple);
    } catch (e) {
      _setError(e.toString());
    }
  }

  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      _setLoading();
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      await _loadUserData(userCredential.user!.uid);
    } on FirebaseAuthException catch (e) {
      _setError(_getAuthErrorMessage(e.code));
    } catch (e) {
      _setError(e.toString());
    }
  }

  Future<void> registerWithEmail({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) async {
    try {
      _setLoading();
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await userCredential.user?.updateDisplayName('$firstName $lastName');
      await userCredential.user?.sendEmailVerification();
      await _createUserDocument(
        uid: userCredential.user!.uid,
        email: email,
        firstName: firstName,
        lastName: lastName,
        provider: AuthProviderType.email,
      );
      await _loadUserData(userCredential.user!.uid);
    } on FirebaseAuthException catch (e) {
      _setError(_getAuthErrorMessage(e.code));
    } catch (e) {
      _setError(e.toString());
    }
  }

  Future<void> sendPasswordReset(String email) async {
    try {
      _setLoading();
      await _auth.sendPasswordResetEmail(email: email);
      _state = AuthState.unauthenticated;
      notifyListeners();
    } on FirebaseAuthException catch (e) {
      _setError(_getAuthErrorMessage(e.code));
    }
  }

  Future<void> _createOrUpdateUser(
    User firebaseUser,
    AuthProviderType provider,
  ) async {
    final docRef = _firestore
        .collection(AppConstants.usersCollection)
        .doc(firebaseUser.uid);

    final doc = await docRef.get();
    if (!doc.exists) {
      final nameParts = (firebaseUser.displayName ?? '').split(' ');
      await _createUserDocument(
        uid: firebaseUser.uid,
        email: firebaseUser.email ?? '',
        firstName: nameParts.isNotEmpty ? nameParts.first : '',
        lastName: nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '',
        photoUrl: firebaseUser.photoURL,
        provider: provider,
      );
    } else {
      await docRef.update({'lastActive': FieldValue.serverTimestamp()});
    }
    await _loadUserData(firebaseUser.uid);
  }

  Future<void> _createUserDocument({
    required String uid,
    required String email,
    required String firstName,
    required String lastName,
    String? photoUrl,
    required AuthProviderType provider,
  }) async {
    await _firestore.collection(AppConstants.usersCollection).doc(uid).set({
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'photoUrl': photoUrl,
      'authProvider': provider.name,
      'isEmailVerified': _auth.currentUser?.emailVerified ?? false,
      'isOnboardingComplete': false,
      'subscriptionTier': 'free',
      'resumesCreated': 0,
      'atsScansCount': 0,
      'savedTemplates': [],
      'createdAt': FieldValue.serverTimestamp(),
      'lastActive': FieldValue.serverTimestamp(),
    });
  }

  Future<void> completeOnboarding({
    required String profession,
    required String industry,
    required String careerGoal,
    required String experienceLevel,
  }) async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) return;

      await _firestore.collection(AppConstants.usersCollection).doc(uid).update({
        'profession': profession,
        'industry': industry,
        'careerGoal': careerGoal,
        'experienceLevel': experienceLevel,
        'isOnboardingComplete': true,
      });

      _currentUser = _currentUser?.copyWith(
        profession: profession,
        industry: industry,
        careerGoal: careerGoal,
        isOnboardingComplete: true,
      );
      _isOnboarded = true;
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    }
  }

  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
      _currentUser = null;
      _isOnboarded = false;
      _state = AuthState.unauthenticated;
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    }
  }

  Future<void> updateProfile({
    String? firstName,
    String? lastName,
    String? profession,
    String? industry,
  }) async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) return;

      final updates = <String, dynamic>{};
      if (firstName != null) updates['firstName'] = firstName;
      if (lastName != null) updates['lastName'] = lastName;
      if (profession != null) updates['profession'] = profession;
      if (industry != null) updates['industry'] = industry;

      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(uid)
          .update(updates);

      _currentUser = _currentUser?.copyWith(
        firstName: firstName,
        lastName: lastName,
        profession: profession,
        industry: industry,
      );
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    }
  }

  void _setLoading() {
    _state = AuthState.loading;
    _errorMessage = null;
    notifyListeners();
  }

  void _setError(String message) {
    _state = AuthState.error;
    _errorMessage = message;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    if (_state == AuthState.error) {
      _state = _currentUser != null
          ? AuthState.authenticated
          : AuthState.unauthenticated;
    }
    notifyListeners();
  }

  String _getAuthErrorMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No account found with this email address.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'email-already-in-use':
        return 'An account with this email already exists.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'weak-password':
        return 'Password must be at least 8 characters.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many failed attempts. Please try again later.';
      case 'operation-not-allowed':
        return 'This sign-in method is not enabled.';
      case 'network-request-failed':
        return 'Network error. Please check your connection.';
      default:
        return 'An error occurred. Please try again.';
    }
  }
}
