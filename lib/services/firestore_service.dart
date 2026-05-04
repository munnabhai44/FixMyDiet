import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fix_my_diet/features/survey/models/survey_data.dart';
import 'package:fix_my_diet/features/plan_generation/models/diet_plan.dart';
import 'package:uuid/uuid.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Save or update user profile + survey data
  Future<void> saveUserProfile(String uid, String email, SurveyData survey) async {
    await _db.collection('users').doc(uid).set({
      'uid': uid,
      'email': email,
      'selectedLanguage': survey.selectedLanguage,
      ...survey.toMap(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  // Get user survey data
  Future<SurveyData?> getUserSurvey(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    if (!doc.exists || doc.data() == null) return null;
    final data = doc.data()!;
    if (data['age'] == null) return null; // No survey done yet
    return SurveyData.fromMap(data);
  }

  // Save generated plan
  Future<String> savePlan(String uid, DietPlan plan) async {
    final planId = const Uuid().v4();
    await _db.collection('users').doc(uid).collection('plans').doc(planId).set({
      'planId': planId,
      ...plan.toMap(),
    });
    return planId;
  }

  // Get latest plan
  Future<DietPlan?> getLatestPlan(String uid) async {
    final query = await _db
        .collection('users')
        .doc(uid)
        .collection('plans')
        .orderBy('generatedAt', descending: true)
        .limit(1)
        .get();
    if (query.docs.isEmpty) return null;
    return DietPlan.fromMap(query.docs.first.data());
  }

  // Get plan history (last 5)
  Future<List<Map<String, dynamic>>> getPlanHistory(String uid) async {
    final query = await _db
        .collection('users')
        .doc(uid)
        .collection('plans')
        .orderBy('generatedAt', descending: true)
        .limit(5)
        .get();
    return query.docs.map((d) => d.data()).toList();
  }

  // Update language preference
  Future<void> updateLanguage(String uid, String language) async {
    await _db.collection('users').doc(uid).update({
      'selectedLanguage': language,
    });
  }

  // Get user language
  Future<String> getUserLanguage(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    return doc.data()?['selectedLanguage'] ?? 'English';
  }
}
