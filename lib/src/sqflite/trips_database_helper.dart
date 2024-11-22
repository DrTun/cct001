// ignore_for_file: depend_on_referenced_packages

import 'dart:async';
import 'package:logger/logger.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../modules/flaxi/api_data_models/rateby_groups_models.dart';
import '../shared/global_data.dart';
import '../modules/flaxi/helpers/log_model.dart';
import '../modules/flaxi/helpers/log_service.dart';
import 'extras_model.dart';
import 'trip_model.dart';

class TripsDatabaseHelper {
  String timestamp = DateTime.now().toIso8601String();
  TripsDatabaseHelper._privateConstructor();
  // The single instance of DatabaseHelper
  static final TripsDatabaseHelper instance =
      TripsDatabaseHelper._privateConstructor();

  final Logger logger = Logger();

  static Database? _database;
  static int dbVersion = 5;

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
      version: dbVersion,
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
          'user_id TEXT NOT NULL,'
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
          'distance_amount TEXT NOT NULL,'
          'extras_total TEXT NOT NULL,'
          'total_amount TEXT NOT NULL,'
          'rate TEXT NOT NULL,'
          'initial TEXT NOT NULL,'
          'created_date TEXT NOT NULL,'
          'cloud_status TEXT NOT NULL,'
          'domain_id TEXT NOT NULL,' //group syskey
          'group_id TEXT NOT NULL,'
          'currency TEXT NOT NULL,'
          'wallet_initial TEXT NOT NULL DEFAULT "",'
          'wallet_amount TEXT NOT NULL DEFAULT "",'
          'wallet_total TEXT NOT NULL DEFAULT ""'
          ')');

      await db.execute('CREATE TABLE Extras('
          'id INTEGER PRIMARY KEY AUTOINCREMENT,'
          'trip_id TEXT NOT NULL,'
          'name TEXT NOT NULL DEFAULT "",'
          'sub_total TEXT NOT NULL DEFAULT "",'
          'amount TEXT NOT NULL DEFAULT "",'
          'qty TEXT NOT NULL DEFAULT "",'
          'type TEXT NOT NULL DEFAULT ""'
          ')');
    } catch (e) {
      LogService.writeLog(LogModel(
          errorMessage: e.toString(),
          stackTrace: ' Tripdatabase (trips_database_helper)',
          timestamp: timestamp));
      logger.e(e);
    }
  }

  //_updateTable is called if database already exists and [version] is higher than the last database version

  Future<void> _updateTable(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < newVersion) {
      if (oldVersion < 2) {
        await addColumnIfNotExists(db, 'TRIPS', 'domain_id', 'TEXT NOT NULL DEFAULT ""');
      }
      if (oldVersion < 3) {

        await addColumnIfNotExists(db, 'TRIPS', 'domain_id', 'TEXT NOT NULL DEFAULT ""');
        
        await addColumnIfNotExists(db, 'TRIPS', 'group_id', 'TEXT NOT NULL DEFAULT ""');
        await addColumnIfNotExists(db, 'TRIPS', 'distance_amount', 'TEXT NOT NULL DEFAULT ""');
        await addColumnIfNotExists(db, 'TRIPS', 'extras_total', 'TEXT NOT NULL DEFAULT ""');
        await db.execute('CREATE TABLE Extras('
            'id INTEGER PRIMARY KEY AUTOINCREMENT,'
            'trip_id TEXT NOT NULL,'
            'name TEXT NOT NULL DEFAULT "",'
            'amount TEXT NOT NULL DEFAULT "",'
            'type TEXT NOT NULL DEFAULT ""'
            ')');
      }
      if (oldVersion < 4) {
        await addColumnIfNotExists(db, 'TRIPS', 'currency', 'TEXT NOT NULL DEFAULT ""');
        await addColumnIfNotExists(db, 'Extras', 'sub_total', 'TEXT NOT NULL DEFAULT ""');
        await addColumnIfNotExists(db, 'Extras', 'qty', 'TEXT NOT NULL DEFAULT ""');
      }
      if (oldVersion < 5) { 
        await addColumnIfNotExists(db, 'TRIPS', 'wallet_initial', 'TEXT NOT NULL DEFAULT ""');
        await addColumnIfNotExists(db, 'TRIPS', 'wallet_amount', 'TEXT NOT NULL DEFAULT ""');
        await addColumnIfNotExists(db, 'TRIPS', 'wallet_total', 'TEXT NOT NULL DEFAULT ""');
      }

    }
  }

  Future<void> addColumnIfNotExists(Database db, String tableName, String columnName, String columnType) async {
  var result = await db.rawQuery(
    "PRAGMA table_info($tableName);"
  );
  bool columnExists = result.any((column) => column['name'] == columnName);
  if (!columnExists) {
    await db.execute("ALTER TABLE $tableName ADD COLUMN $columnName $columnType");
  }
}

  Future<void> insertTrip(TripModel trip) async {
    try {
      final Database db = await database;
      await db.insert('TRIPS', trip.toJson());
    } catch (e) {
      LogService.writeLog(LogModel(
          errorMessage: e.toString(),
          stackTrace: ' insertTripdatabase (trips_database_helper)',
          timestamp: timestamp));
      logger.e(e);
    }
  }

  Future<void> insertExtras(ExtrasModel extras) async {
    try {
      final Database db = await database;
      await db.insert('Extras', extras.toJson());
      logger.i(extras.toJson());
    } catch (e) {
      logger.e(e);
    }
  }

  Future<List<TripModel>> getTripsByDate(
      String startDate, String endDate) async {
    final Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'TRIPS',
      where: GlobalAccess.userID.isNotEmpty
          ? 'created_date BETWEEN ? AND ?'
          : 'created_date BETWEEN ? AND ? AND user_id = ?',
      whereArgs: GlobalAccess.userID.isNotEmpty
          ? [startDate, endDate]
          : [startDate, endDate, GlobalAccess.userID],
       orderBy: 'created_date id DESC',
    );
    logger.i(maps);
    final List<TripModel> trips = maps.map((map) => TripModel.fromMap(map)).toList();
    return (trips);
  }

  Future<List<TripModel>> getTripsByDatewithDriverGroup(
      String startDate, String endDate, String domainID) async {
    final Database db = await database;
    if (domainID.isEmpty) {
      throw ArgumentError('domainID must not be empty');
    }
    final List<Map<String, dynamic>> maps = await db.query(
      'TRIPS',
      where: 'created_date BETWEEN ? AND ? AND domain_id = ?',
      whereArgs: [startDate, endDate, domainID],
      orderBy: 'id DESC',
    );
    logger.i(maps);
    final List<TripModel> trips =
        maps.map((map) => TripModel.fromMap(map)).toList();
    return trips;
  }

  Future<List<ExtrasModel>> getExtrasByTripID(String tripID) async {
    final Database db = await database;
    List<ExtrasModel> extras = [];
    final List<Map<String, dynamic>> maps = await db.query(
      'Extras',
      where: 'trip_id = ?',
      whereArgs: [tripID],
    );
    logger.i(maps);
    if(maps.isNotEmpty){
      extras = maps.map((map) => ExtrasModel.fromMap(map)).toList();
    }
  return extras;
}

Future<List<Extra>> getExtraByTripID(String tripID) async {
    final Database db = await database;
    List<Extra> extras = [];

    // Query the database including the 'type' column
    final List<Map<String, dynamic>> maps = await db.query(
      'Extras',
      columns: ['name', 'amount', 'qty', 'sub_total', 'type'], 
      where: 'trip_id = ? AND sub_total > 0',
      whereArgs: [tripID],
    );

    logger.i(maps);

    if (maps.isNotEmpty) {
      extras = maps.map((map) {
        return Extra(
          name: map['name'],
          amount: map['amount'],
          qty: map['qty'] != "" && map['qty'] != null
              ? int.parse(map['qty'])
              : 0,
          subTotal: map['sub_total'] != "" ? int.parse(map['sub_total']) : 0,
          type: map['type']
        );
      }).toList();
    }

    return extras;
  }


  Future<void> updateCloudStatus(String tripID, String newStatus) async {
    final Database db = await database;
    try {
      await db.update(
        'TRIPS',
        {'cloud_status': newStatus},
        where: 'trip_id = ?',
        whereArgs: [tripID],
      );
    } catch (error) {
      LogService.writeLog(LogModel(
          errorMessage: error.toString(),
          stackTrace: ' updateCloudStatus (trips_database_helper)',
          timestamp: timestamp));
      logger.e(error);
    }
  }

  Future<List<TripModel>> getSavedTrip() async {
    final Database db = await database;
    try {
      final List<Map<String, dynamic>> maps = await db.query(
        'TRIPS',
        where: 'cloud_status = ? AND user_id = ?',
        whereArgs: ['saved', GlobalAccess.userID],
      );
      logger.i('$maps');
      final List<TripModel> trips =
          maps.map((map) => TripModel.fromMap(map)).toList();
      logger.i('$trips');
      return (trips);
    } catch (error) {
      LogService.writeLog(LogModel(
          errorMessage: error.toString(),
          stackTrace: ' getSavedTrip (trips_database_helper)',
          timestamp: timestamp));
      logger.e("Database error in getsavedtrip: $error");
      return [];
    }
  }
}
