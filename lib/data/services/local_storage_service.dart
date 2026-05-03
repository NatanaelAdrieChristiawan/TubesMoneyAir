import 'package:shared_preferences/shared_preferences.dart';

import '../models/budget_model.dart';
import '../models/transaction_model.dart';
import '../models/user_model.dart';
import 'database_service.dart';

class LocalStorageService {
  static const String _userKey = 'user';
  static const String _budgetKey = 'budget';
  static const String _themeModeKey = 'theme_mode';

  final DatabaseService _db = DatabaseService.instance;

  Future<SharedPreferences> get _prefs async =>
      await SharedPreferences.getInstance();

  // ====== Transaction Methods (delegasi ke DatabaseService) ======

  Future<void> saveTransactions(List<Transaction> transactions) async {
    // Backward compat: simpan ulang semua transaksi
    for (final t in transactions) {
      await _db.addTransaction(t);
    }
  }

  Future<List<Transaction>> getTransactions() async {
    return await _db.getAllTransactions();
  }

  Future<void> addTransaction(Transaction transaction) async {
    await _db.addTransaction(transaction);
  }

  Future<void> updateTransaction(Transaction transaction) async {
    await _db.updateTransaction(transaction);
  }

  Future<void> deleteTransaction(String id) async {
    await _db.deleteTransaction(id);
  }

  // ====== User Methods (tetap SharedPreferences) ======

  Future<void> saveUser(User user) async {
    final prefs = await _prefs;
    await prefs.setString(_userKey, user.toJson());
  }

  Future<User?> getUser() async {
    final prefs = await _prefs;
    final userJson = prefs.getString(_userKey);
    if (userJson != null) {
      return User.fromJson(userJson);
    }
    return null;
  }

  // ====== Budget Methods (tetap SharedPreferences) ======

  Future<void> saveBudget(Budget budget) async {
    final prefs = await _prefs;
    await prefs.setString(_budgetKey, budget.toJson());
  }

  Future<Budget?> getBudget() async {
    final prefs = await _prefs;
    final budgetJson = prefs.getString(_budgetKey);
    if (budgetJson != null) {
      return Budget.fromJson(budgetJson);
    }
    return null;
  }

  // ====== Theme Mode Methods (tetap SharedPreferences) ======

  Future<void> setThemeModeRaw(String themeMode) async {
    final prefs = await _prefs;
    await prefs.setString(_themeModeKey, themeMode);
  }

  Future<String?> getThemeModeRaw() async {
    final prefs = await _prefs;
    return prefs.getString(_themeModeKey);
  }
}
