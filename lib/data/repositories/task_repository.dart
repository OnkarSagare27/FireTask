import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/task_model.dart';

class TaskRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  TaskRepository({FirebaseFirestore? firestore, FirebaseAuth? auth})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _auth = auth ?? FirebaseAuth.instance;

  String get _userId => _auth.currentUser!.uid;

  CollectionReference get _taskCollection =>
      _firestore.collection('users').doc(_userId).collection('tasks');

  Future<Task> addTask(Task task) async {
    await _taskCollection.doc(task.id).set(task.toMap());
    return task;
  }

  Future<void> updateTask(Task task) async {
    await _taskCollection.doc(task.id).update(task.toMap());
  }

  Future<void> deleteTask(String taskId) async {
    await _taskCollection.doc(taskId).delete();
  }

  Future<List<Task>> getTasks() async {
    final snapshot = await _taskCollection.orderBy('dueDate').get();

    return snapshot.docs
        .map((doc) => Task.fromMap(doc.data() as Map<String, dynamic>, doc.id))
        .toList();
  }

  Future<Task?> getTaskById(String id) async {
    final doc = await _taskCollection.doc(id).get();
    if (doc.exists) {
      return Task.fromMap(doc.data() as Map<String, dynamic>, doc.id);
    }
    return null;
  }
}
