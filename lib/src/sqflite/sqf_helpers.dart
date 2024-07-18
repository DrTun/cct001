import 'dart:async';

import 'package:logger/logger.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'sqf_models.dart';

class DatabaseHelper{
  final Logger logger = Logger();
  
  static Database? _database;

  Future<Database> get database async{
    //if database exists, return database
    if(_database !=null) return _database!;

    //if database doesn't exist, create one
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async{

    //get device directory
    final documentDirectory = await getApplicationDocumentsDirectory();
    final String databasePath = path.join(documentDirectory.path , "sample_db.db");

    //open the database
    final database = await openDatabase(databasePath, version:1, onCreate: _createTable, onUpgrade: _updateTable);

    return database;
    
  }

  //_createTable is called if the database did not exist prior to calling
  FutureOr<void> _createTable(Database db, int version) async{
    try{
      logger.d("Createing Table....");
      await db.execute(
        'CREATE TABLE NOTE('
          'syskey TEXT PRIMARY KEY,'
          'title TEXT NOT NULL DEFAULT "",'
          'description TEXT NOT NULL DEFAULT "",'
          'priority INT NOT NULL DEFAULT 0'
        ')'
      );
    }catch(e){
      logger.e(e);
    }
    
  }

  //_updateTable is called if database already exists and [version] is higher than the last database version
  FutureOr<void> _updateTable(Database db, int oldVersion, int newVersion) async{
  }

  insertNote(NoteModel note)async{
    try{
      final Database db = await database;
      await db.insert('NOTE',note.toJson());
    }catch(e){
      logger.e(e);
    }
    
  }

  Future<List<NoteModel>> getAllNoteData()async{
    try{
      final Database db = await database;
      final List<Map<String,dynamic>> resultSet= await db.query(
        "NOTE",
        orderBy: "priority"
      );
      return List.generate(
        resultSet.length ,
        (index){
          return NoteModel.fromJson(resultSet[index]);
        }
      );
    }catch(e){
      logger.e(e);
      return [];
    }
    
  }

  Future<void> deleteNoteItem({required String? syskey})async{
    try{
      final Database db = await database;
      await db.delete("NOTE",where : "syskey = $syskey");
    }catch(e){
      logger.e(e);
    }
  }

  Future<void> updateNoteItem(NoteModel note)async{
    try{
      final Database db = await database;
      await db.update(
        "NOTE",
        note.toJson(),
        where: 'syskey = ${note.syskey}'
      );
    }catch(e){
      logger.e(e);
    }
    
  }

  Future<void> close() async{
    final Database db = await database;
    db.close();
  }

  
}