import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/crop_model.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('agriconnect.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE crops (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        quantity TEXT,
        imagePath TEXT
      )
    ''');
  }

  // :large_green_circle: INSERT
  Future<int> insertCrop(CropModel crop) async {
    final db = await instance.database;

    final result = await db.insert('crops', {
      'name': crop.name,
      'quantity': crop.quantity,
      'imagePath': crop.imagePath,
    });

    print("INSERT RESULT: $result"); // :point_left: ADD

    return result;
  }

  // :large_green_circle: GET ALL
  Future<List<CropModel>> getCrops() async {
    final db = await instance.database;

    final result = await db.query('crops');

    print("DB DATA: $result"); // :point_left: ADD

    return result.map((json) => CropModel(
      name: json['name'] as String,
      quantity: json['quantity'] as String,
      imagePath: json['imagePath'] as String?,
    )).toList();
  }
}