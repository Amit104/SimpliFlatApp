
import 'package:cloud_firestore/cloud_firestore.dart';

//// Profile Page Models

class FlatAddUsersResponse {
  String name;
  String phone;
  String userId;
  DateTime createdAt;
  DateTime updatedAt;

  get getUpdatedAt => updatedAt;

  FlatAddUsersResponse(
      {this.userId, this.name, this.phone, this.createdAt, this.updatedAt});

  factory FlatAddUsersResponse.fromJson(Map<String, dynamic> json) {
    return FlatAddUsersResponse(
        userId: json['user_id'] as String,
        phone: json['phone'] as String,
        name: json['name'] as String,
        createdAt: (json['created_at'] as Timestamp).toDate(),
        updatedAt: (json['updated_at'] as Timestamp).toDate());
  }
}

class FlatIncomingResponse {
  String name;
  String phone;
  String userId;
  DateTime createdAt;
  DateTime updatedAt;

  get getUpdatedAt => updatedAt;

  FlatIncomingResponse(
      {this.name, this.phone, this.userId, this.createdAt, this.updatedAt});

  factory FlatIncomingResponse.fromJson(Map<String, dynamic> json) {
    return FlatIncomingResponse(
        name: json['name'],
        phone: json['phone'],
        userId: json['user_id'],
        createdAt: (json['created_at'] as Timestamp).toDate(),
        updatedAt: (json['updated_at'] as Timestamp).toDate());
  }
}

class FlatUsersResponse {
  final String name;
  final String userId;
  final DateTime createdAt;
  final DateTime updatedAt;

  get getUpdatedAt => updatedAt;

  FlatUsersResponse({this.name, this.userId, this.createdAt, this.updatedAt});

  factory FlatUsersResponse.fromJson(Map<String, dynamic> json, userId) {
    return FlatUsersResponse(
        name: json['name'],
        userId: userId,
        createdAt: (json['created_at'] as Timestamp).toDate(),
        updatedAt: (json['updated_at'] as Timestamp).toDate());
  }
}

class FlatContactsResponse {
  final String name;
  final String phone;
  final DateTime createdAt;
  final DateTime updatedAt;

  get getUpdatedAt => updatedAt;

  get getCreatedAt => createdAt;

  get getPhone => phone;

  FlatContactsResponse({this.name, this.phone, this.createdAt, this.updatedAt});

  factory FlatContactsResponse.fromJson(Map<String, dynamic> json) {
    return FlatContactsResponse(
        name: json['name'],
        phone: json['phone'],
        createdAt: (json['created_at'] as Timestamp).toDate(),
        updatedAt: (json['updated_at'] as Timestamp).toDate());
  }
}

class NotesResponse {
  final String noteId;
  final String note;
  final String flatId;
  final DateTime createdAt;
  final DateTime updatedAt;

  get getUpdatedAt => updatedAt;

  get getNoteId => noteId;

  get getCreatedAt => createdAt;

  NotesResponse({this.noteId, this.note, this.flatId, this.createdAt, this.updatedAt});

  factory NotesResponse.fromJson(Map<String, dynamic> json, String noteId) {
    return NotesResponse(
        noteId: noteId,
        note: json['note'],
        flatId: json['flat_id'],
        createdAt: (json['created_at'] as Timestamp).toDate(),
        updatedAt: (json['updated_at'] as Timestamp).toDate());
  }
}
