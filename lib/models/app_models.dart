// lib/models/app_models.dart
import 'dart:convert'; // Tambahkan ini jika jsonEncode/jsonDecode digunakan di luar ApiService

class User {
  final int id;
  final String name;
  final String email;
  final String? emailVerifiedAt;
  final int? currentTeamId;
  final String? profilePhotoPath;
  final String? jenisKelamin;
  final int? batchId;
  final int? trainingId;
  final String? createdAt;
  final String? updatedAt;
  final String? profilePhotoUrl;
  final String? profilePhoto;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.emailVerifiedAt,
    this.currentTeamId,
    this.profilePhotoPath,
    this.jenisKelamin,
    this.batchId,
    this.trainingId,
    this.createdAt,
    this.updatedAt,
    this.profilePhotoUrl,
    this.profilePhoto,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
      emailVerifiedAt: json['email_verified_at'] as String?,
      // Mengubah cara parsing untuk int? agar lebih kuat terhadap tipe data dari API
      currentTeamId:
          json['current_team_id'] != null
              ? int.tryParse(json['current_team_id'].toString())
              : null,
      profilePhotoPath: json['profile_photo_path'] as String?,
      jenisKelamin: json['jenis_kelamin'] as String?,
      batchId:
          json['batch_id'] != null
              ? int.tryParse(json['batch_id'].toString())
              : null,
      trainingId:
          json['training_id'] != null
              ? int.tryParse(json['training_id'].toString())
              : null,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
      profilePhotoUrl: json['profile_photo_url'] as String?,
      profilePhoto: json['profile_photo'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'email_verified_at': emailVerifiedAt,
      'current_team_id': currentTeamId,
      'profile_photo_path': profilePhotoPath,
      'jenis_kelamin': jenisKelamin,
      'batch_id': batchId,
      'training_id': trainingId,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'profile_photo_url': profilePhotoUrl,
      'profile_photo': profilePhoto,
    };
  }
}

// Model baru untuk respons autentikasi
class AuthResponse {
  final String accessToken;
  final String? tokenType;
  final int? expiresIn;
  final User user;

  AuthResponse({
    required this.accessToken,
    this.tokenType,
    this.expiresIn,
    required this.user,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      accessToken: json['token'] as String,
      tokenType: json['token_type'] as String?,
      // Mengubah cara parsing untuk int? agar lebih kuat terhadap tipe data dari API
      expiresIn:
          json['expires_in'] != null
              ? int.tryParse(json['expires_in'].toString())
              : null,
      user: User.fromJson(json['user'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'token': accessToken,
      'token_type': tokenType,
      'expires_in': expiresIn,
      'user': user.toJson(),
    };
  }
}

class Attendance {
  final int id;
  final int userId;
  final String date;
  final String checkInTime;
  final String checkInLat;
  final String checkInLng;
  final String checkInAddress;
  final String status;
  final String? checkOutTime;
  final String? checkOutLat;
  final String? checkOutLng;
  final String? checkOutAddress;
  final String? alasanIzin;
  final String? createdAt;
  final String? updatedAt;

  Attendance({
    required this.id,
    required this.userId,
    required this.date,
    required this.checkInTime,
    required this.checkInLat,
    required this.checkInLng,
    required this.checkInAddress,
    required this.status,
    this.checkOutTime,
    this.checkOutLat,
    this.checkOutLng,
    this.checkOutAddress,
    this.alasanIzin,
    this.createdAt,
    this.updatedAt,
  });

  factory Attendance.fromJson(Map<String, dynamic> json) {
    return Attendance(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      date: json['date'] as String,
      checkInTime: json['check_in_time'] as String,
      checkInLat: json['check_in_lat'] as String,
      checkInLng: json['check_in_lng'] as String,
      checkInAddress: json['check_in_address'] as String,
      status: json['status'] as String,
      checkOutTime: json['check_out_time'] as String?,
      checkOutLat: json['check_out_lat'] as String?,
      checkOutLng: json['check_out_lng'] as String?,
      checkOutAddress: json['check_out_address'] as String?,
      alasanIzin: json['alasan_izin'] as String?,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'date': date,
      'check_in_time': checkInTime,
      'check_in_lat': checkInLat,
      'check_in_lng': checkInLng,
      'check_in_address': checkInAddress,
      'status': status,
      'check_out_time': checkOutTime,
      'check_out_lat': checkOutLat,
      'check_out_lng': checkOutLng,
      'check_out_address': checkOutAddress,
      'alasan_izin': alasanIzin,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}

class Batch {
  final int id;
  final String title; // Ini akan memetakan ke 'name' dari response API
  final String? description;
  final String? startDate;
  final String? endDate;
  final String? createdAt;
  final String? updatedAt;

  Batch({
    required this.id,
    required this.title,
    this.description,
    this.startDate,
    this.endDate,
    this.createdAt,
    this.updatedAt,
  });

  factory Batch.fromJson(Map<String, dynamic> json) {
    return Batch(
      id: json['id'] as int,
      title:
          json['batch_ke']
              .toString(), // Tetap seperti ini, karena batch_ke adalah int yang diubah ke String untuk title
      description: json['description'] as String?,
      startDate: json['start_date'] as String?,
      endDate: json['end_date'] as String?,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': title,
      'description': description,
      'start_date': startDate,
      'end_date': endDate,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  // Tambahkan operator == dan hashCode untuk perbandingan objek
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Batch && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class Training {
  final int id;
  final String title;
  final String? description;
  final int? participantCount;
  final String? standard;
  final String? duration;
  final String? createdAt;
  final String? updatedAt;
  final List<dynamic>? units;
  final List<dynamic>? activities;

  Training({
    required this.id,
    required this.title,
    this.description,
    this.participantCount,
    this.standard,
    this.duration,
    this.createdAt,
    this.updatedAt,
    this.units,
    this.activities,
  });

  factory Training.fromJson(Map<String, dynamic> json) {
    return Training(
      id: json['id'] as int,
      title: json['title'] as String,
      description: json['description'] as String?,
      // Mengubah cara parsing untuk int? agar lebih kuat terhadap tipe data dari API
      participantCount:
          json['participant_count'] != null
              ? int.tryParse(json['participant_count'].toString())
              : null,
      standard: json['standard'] as String?,
      duration: json['duration'] as String?,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
      units: json['units'] as List?,
      activities: json['activities'] as List?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'participant_count': participantCount,
      'standard': standard,
      'duration': duration,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'units': units,
      'activities': activities,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Training && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
