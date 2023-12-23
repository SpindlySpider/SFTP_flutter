import 'package:sqflite/sqflite.dart';
import "sql_datamodels.dart";
Future<void> insertServer(Session sesh,Database db) async {
  // Get a reference to the database.

  // Insert the Dog into the correct table. You might also specify the
  // `conflictAlgorithm` to use in case the same dog is inserted twice.
  //
  // In this case, replace any previous data.
  await db.insert(
    'session',
    sesh.toMap(),
    conflictAlgorithm: ConflictAlgorithm.replace,
  );
}

Future<List<Session>> getSessions(Database db) async {
  // Get a reference to the database.

  // Query the table for all The Dogs.
  final List<Map<String, dynamic>> maps = await db.query('session');

  // Convert the List<Map<String, dynamic> into a List<Dog>.
  return List.generate(maps.length, (i) {
    return Session(
      session_id: maps[i]['session_id'] as int,
      hostname: maps[i]['hostname'] as String,
      port: maps[i]['port'] as int,
      username: maps[i]['username'] as String,
      password: maps[i]['password'] as String,
      user_salt: maps[i]['user_salt'] as String,
      cwd_server: maps[i]['cwd_server'] as String,
      cwd_client: maps[i]['cwd_client'] as String,
    );
  });
}