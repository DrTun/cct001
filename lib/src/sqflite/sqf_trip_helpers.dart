import 'dart:async';
import '/src/sqflite/sqf_trip_model.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class TripsDatabaseHelper {
  TripsDatabaseHelper._privateConstructor();
  // The single instance of DatabaseHelper
  static final TripsDatabaseHelper instance =
      TripsDatabaseHelper._privateConstructor();

  final Logger logger = Logger();

  static Database? _database;
  static int dbVersion = 1;

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    // Get the path to the database
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, 'trip_database.db');

    // Open the database, creating it if it doesn't exist
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createTable,
      onUpgrade: _updateTable,
    );
  }

  //_createTable is called if the database did not exist prior to calling
  FutureOr<void> _createTable(Database db, int version) async {
    try {
      logger.d("Creating Table....");
      await db.execute('CREATE TABLE TRIPS('
          'id INTEGER PRIMARY KEY AUTOINCREMENT,'
          'trip_id TEXT NOT NULL,'
          'start_time TEXT NOT NULL,'
          'end_time TEXT NOT NULL,'
          'route TEXT NOT NULL,'
          'original_route TEXT NOT NULL,'
          'date_time_list TEXT NOT NULL,'
          'org_date_time_list TEXT NOT NULL,'
          'trip_status TEXT NOT NULL,'
          'trip_duration TEXT NOT NULL,'
          'distance TEXT NOT NULL,'
          'org_distance TEXT NOT NULL,'
          'start_loc_name TEXT NOT NULL,'
          'end_loc_name TEXT NOT NULL,'
          'total_amount TEXT NOT NULL,'
          'rate TEXT NOT NULL,'
          'initial TEXT NOT NULL,'
          'created_date TEXT NOT NULL'
          ')');
    } catch (e) {
      logger.e(e);
    }
  }

  //_updateTable is called if database already exists and [version] is higher than the last database version
  FutureOr<void> _updateTable(
      Database db, int oldVersion, int newVersion) async {}

  Future<void> insertTrip(TripModel trip) async {
    try {
      final Database db = await database;
      await db.insert('TRIPS', trip.toJson());
    } catch (e) {
      logger.e(e);
    }
  }

  Future<List<TripModel>> getTodayTrips() async {
    final Database db = await database;
    String todayDate = DateFormat('yyyyMMdd').format(DateTime.now());
    logger.i(todayDate);
    // Adjust the SQL query based on your date format
    final List<Map<String, dynamic>> maps = await db.query(
      'TRIPS',
      where: 'starttime LIKE ?',
      whereArgs: ['%$todayDate%'],
    );
    logger.i(maps);
    final List<TripModel> trips =
        maps.map((map) => TripModel.fromMap(map)).toList();

    return (trips);
  }

  Future<List<TripModel>> getTripsByDate(
      String startDate, String endDate) async {
    final Database db = await database;
    //String todayDate = DateFormat('yyyyMMdd').format(DateTime.now());

    // Adjust the SQL query based on your date format
    final List<Map<String, dynamic>> maps = await db.query(
      'TRIPS',
      where: 'created_date BETWEEN ? AND ?',
      whereArgs: [startDate, endDate],
    );
    logger.i(maps);
    final List<TripModel> trips =
        maps.map((map) => TripModel.fromMap(map)).toList();

    return (trips);
  }
}
