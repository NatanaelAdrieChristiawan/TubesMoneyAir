import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/transaction_model.dart' as t_model;

/// Service database menggunakan SQLite untuk penyimpanan transaksi jangka panjang.
///
/// Menggantikan SharedPreferences yang memiliki batas ukuran ~1MB,
/// sehingga data tidak akan hilang meskipun sudah ribuan transaksi.
class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  static Database? _database;

  DatabaseService._init();

  static const String _tableTransactions = 'transactions';
  static const int _dbVersion = 1;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('moneyair.db');
    return _database!;
  }

  Future<Database> _initDB(String fileName) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, fileName);

    return await openDatabase(
      path,
      version: _dbVersion,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $_tableTransactions (
        id TEXT PRIMARY KEY,
        amount REAL NOT NULL,
        type TEXT NOT NULL,
        category TEXT NOT NULL,
        date TEXT NOT NULL,
        notes TEXT NOT NULL DEFAULT '',
        wallet TEXT NOT NULL DEFAULT ''
      )
    ''');

    // Index untuk query cepat berdasarkan tanggal dan tipe
    await db.execute(
      'CREATE INDEX idx_transactions_date ON $_tableTransactions(date)',
    );
    await db.execute(
      'CREATE INDEX idx_transactions_type ON $_tableTransactions(type)',
    );
    await db.execute(
      'CREATE INDEX idx_transactions_date_type ON $_tableTransactions(date, type)',
    );
  }

  /// Inisialisasi database dan jalankan migrasi dari SharedPreferences jika ada.
  Future<void> initialize() async {
    final db = await database;
    await _migrateFromSharedPreferences(db);
  }

  /// Migrasi data transaksi lama dari SharedPreferences ke SQLite.
  /// Hanya berjalan sekali — setelah migrasi berhasil, key lama dihapus.
  Future<void> _migrateFromSharedPreferences(Database db) async {
    final prefs = await SharedPreferences.getInstance();
    final transactionsJson = prefs.getStringList('transactions');

    if (transactionsJson == null || transactionsJson.isEmpty) return;

    // Cek apakah sudah ada data di database (hindari duplikasi)
    final existingCount = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM $_tableTransactions'),
    );
    if (existingCount != null && existingCount > 0) {
      // Database sudah ada data, hapus key lama saja
      await prefs.remove('transactions');
      return;
    }

    // Migrasi: masukkan semua transaksi ke SQLite
    final batch = db.batch();
    for (final json in transactionsJson) {
      try {
        final transaction = t_model.Transaction.fromJson(json);
        batch.insert(
          _tableTransactions,
          transaction.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      } catch (e) {
        // Skip data yang rusak, lanjutkan yang lain
        continue;
      }
    }
    await batch.commit(noResult: true);

    // Hapus data lama dari SharedPreferences setelah migrasi berhasil
    await prefs.remove('transactions');
  }

  // ====== CRUD Operations ======

  Future<void> addTransaction(t_model.Transaction transaction) async {
    final db = await database;
    await db.insert(
      _tableTransactions,
      transaction.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateTransaction(t_model.Transaction transaction) async {
    final db = await database;
    await db.update(
      _tableTransactions,
      transaction.toMap(),
      where: 'id = ?',
      whereArgs: [transaction.id],
    );
  }

  Future<void> deleteTransaction(String id) async {
    final db = await database;
    await db.delete(
      _tableTransactions,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ====== Query Operations ======

  /// Ambil semua transaksi (untuk backward compatibility)
  Future<List<t_model.Transaction>> getAllTransactions() async {
    final db = await database;
    final maps = await db.query(
      _tableTransactions,
      orderBy: 'date DESC',
    );
    return maps.map((map) => t_model.Transaction.fromMap(map)).toList();
  }

  /// Ambil transaksi berdasarkan rentang tanggal — query utama untuk laporan
  Future<List<t_model.Transaction>> getTransactionsByDateRange(
    DateTime start,
    DateTime end,
  ) async {
    final db = await database;
    final maps = await db.query(
      _tableTransactions,
      where: 'date >= ? AND date <= ?',
      whereArgs: [start.toIso8601String(), end.toIso8601String()],
      orderBy: 'date DESC',
    );
    return maps.map((map) => t_model.Transaction.fromMap(map)).toList();
  }

  /// Ambil transaksi dengan pagination untuk lazy loading
  Future<List<t_model.Transaction>> getTransactionsPaginated({
    required DateTime start,
    required DateTime end,
    required int offset,
    required int limit,
    String? type,
  }) async {
    final db = await database;
    String where = 'date >= ? AND date <= ?';
    List<dynamic> whereArgs = [start.toIso8601String(), end.toIso8601String()];

    if (type != null) {
      where += ' AND type = ?';
      whereArgs.add(type);
    }

    final maps = await db.query(
      _tableTransactions,
      where: where,
      whereArgs: whereArgs,
      orderBy: 'date DESC',
      limit: limit,
      offset: offset,
    );
    return maps.map((map) => t_model.Transaction.fromMap(map)).toList();
  }

  /// Total pemasukan/pengeluaran untuk periode tertentu
  Future<double> getTotalByType(
    String type,
    DateTime start,
    DateTime end,
  ) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COALESCE(SUM(amount), 0) as total FROM $_tableTransactions '
      'WHERE type = ? AND date >= ? AND date <= ?',
      [type, start.toIso8601String(), end.toIso8601String()],
    );
    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }

  /// Ringkasan pengeluaran per kategori untuk pie chart
  Future<List<Map<String, dynamic>>> getExpenseSummaryByCategory(
    DateTime start,
    DateTime end,
  ) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT category, SUM(amount) as amount FROM $_tableTransactions '
      'WHERE type = ? AND date >= ? AND date <= ? '
      'GROUP BY category ORDER BY amount DESC',
      ['expense', start.toIso8601String(), end.toIso8601String()],
    );
    return result
        .map((r) => {
              'category': r['category'] as String,
              'amount': (r['amount'] as num).toDouble(),
            })
        .toList();
  }

  /// Data tren pengeluaran (grouped by day/week/month tergantung periode)
  Future<List<Map<String, dynamic>>> getExpenseTrendData(
    DateTime start,
    DateTime end,
    String period,
  ) async {
    final db = await database;

    // Ambil semua expense dalam range tersebut
    final expenses = await db.query(
      _tableTransactions,
      where: 'type = ? AND date >= ? AND date <= ?',
      whereArgs: ['expense', start.toIso8601String(), end.toIso8601String()],
      orderBy: 'date ASC',
    );

    // Group berdasarkan periode
    Map<String, double> trendMap = {};
    for (final row in expenses) {
      final date = DateTime.parse(row['date'] as String);
      final amount = (row['amount'] as num).toDouble();
      String key;

      switch (period) {
        case 'Harian':
          key = '${date.day}/${date.month}';
          break;
        case 'Mingguan':
          key = '${date.day}/${date.month}';
          break;
        case 'Bulanan':
          key = '${date.day}';
          break;
        case 'Tahunan':
          final months = [
            'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
            'Jul', 'Ags', 'Sep', 'Okt', 'Nov', 'Des'
          ];
          key = months[date.month - 1];
          break;
        default:
          key = '${date.day}/${date.month}';
      }

      trendMap.update(key, (value) => value + amount, ifAbsent: () => amount);
    }

    return trendMap.entries
        .map((e) => {'period': e.key, 'amount': e.value})
        .toList();
  }

  /// Jumlah total transaksi dalam date range (untuk pagination)
  Future<int> getTransactionCount(DateTime start, DateTime end,
      {String? type}) async {
    final db = await database;
    String query =
        'SELECT COUNT(*) FROM $_tableTransactions WHERE date >= ? AND date <= ?';
    List<dynamic> args = [start.toIso8601String(), end.toIso8601String()];

    if (type != null) {
      query += ' AND type = ?';
      args.add(type);
    }

    return Sqflite.firstIntValue(await db.rawQuery(query, args)) ?? 0;
  }
}
