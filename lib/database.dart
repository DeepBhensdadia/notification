import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';



class DatabaseHelper {
  static final _databaseName = "cardb.db";
  static final _databaseVersion = 1;

  static final table = 'cars_table';

  static final columnId = 'id';
  static final columnName = 'name';
  static final columnImageData = 'image';
  static final columnEmail = 'email';

  // make this a singleton class
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  // only have a single app-wide reference to the database
  static Database? _database;
  Future<Database> get database async {
    if (_database != null) return _database!;
    // lazily instantiate the db the first time it is accessed
    _database = await _initDatabase();
    return _database!;
  }

  // this opens the database (and creates it if it doesn't exist)
  _initDatabase() async {
    String path = join(await getDatabasesPath(), _databaseName);
    return await openDatabase(path,
        version: _databaseVersion, onCreate: _onCreate);
  }

  // SQL code to create the database table
  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
    CREATE TABLE $table (
      $columnName TEXT NOT NULL,
      $columnEmail TEXT NOT NULL,
      $columnImageData TEXT NOT NULL
    )
    ''');
  }

  Future<dynamic> insert(String name,String email,var image) async {
    Database db = await instance.database;
    return await db.insert(table, {'name': name, 'email': email,"image" : image});
  }

  Future<List<Map<String, dynamic>>> queryAllRows() async {
    Database db = await instance.database;
    return await db.query(table);
  }

  Future<List<Map<String, dynamic>>> queryRows(name) async {
    Database db = await instance.database;
    return await db.query(table, where: "$columnName LIKE '%$name%'");
  }

  // Future<int> update(Car car) async {
  //   Database db = await instance.database;
  //   int id = car.toMap()['id'];
  //   return await db
  //       .update(table, car.toMap(), where: '$columnId = ?', whereArgs: [id]);
  // }

  Future<int> delete(String name) async {
    Database db = await instance.database;
    return await db.delete(table, where: '$columnName = ?', whereArgs: [name]);
  }
}
