// lib/models/app_models.dart
import 'dart:convert'; // Hapus komentar jika jsonEncode/jsonDecode digunakan di luar ApiService

class User {
  final int id;
  final String name;
  final String email;
  final String? emailVerifiedAt;
  final int? currentTeamId;
  final String? profilePhotoPath;
  final String? jenisKelamin;
  final String? createdAt;
  final String? updatedAt;
  final String? profilePhotoUrl;
  final String? profilePhoto;
  final String? batchKe; // Untuk nilai 'batch_ke' langsung di objek user
  final String?
  trainingTitle; // Untuk nilai 'training_title' langsung di objek user

  // Properti baru untuk objek Batch dan Training bersarang
  final Batch? batch;
  final Training? training;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.emailVerifiedAt,
    this.currentTeamId,
    this.profilePhotoPath,
    this.jenisKelamin,
    this.createdAt,
    this.updatedAt,
    this.profilePhotoUrl,
    this.profilePhoto,
    this.batchKe,
    this.trainingTitle,
    this.batch,
    this.training,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      emailVerifiedAt: json['email_verified_at'] as String?,
      currentTeamId:
          json['current_team_id'] != null
              ? int.tryParse(json['current_team_id'].toString())
              : null,
      profilePhotoPath: json['profile_photo_path'] as String?,
      jenisKelamin: json['jenis_kelamin'] as String?,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
      profilePhotoUrl: json['profile_photo_url'] as String?,
      profilePhoto: json['profile_photo'] as String?,
      batchKe: json['batch_ke'] as String?,
      trainingTitle: json['training_title'] as String?,
      batch:
          json['batch'] != null
              ? Batch.fromJson(json['batch'] as Map<String, dynamic>)
              : null,
      training:
          json['training'] != null
              ? Training.fromJson(json['training'] as Map<String, dynamic>)
              : null,
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
      'created_at': createdAt,
      'updated_at': updatedAt,
      'profile_photo_url': profilePhotoUrl,
      'profile_photo': profilePhoto,
      'batch_ke': batchKe,
      'training_title': trainingTitle,
      'batch': batch?.toJson(),
      'training': training?.toJson(),
    };
  }
}

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
  final String
  checkIn; // Sesuai dengan field 'check_in' di JSON (full timestamp)
  final double checkInLat; // Menggunakan double sesuai JSON
  final double checkInLng; // Menggunakan double sesuai JSON
  final String checkInAddress;
  final String status;
  final String? checkOut; // Bisa null, sesuai field 'check_out' di JSON
  final double? checkOutLat; // Bisa null, menggunakan double?
  final double? checkOutLng; // Bisa null, menggunakan double?
  final String? checkOutAddress;
  final String? alasanIzin;
  final String? createdAt;
  final String? updatedAt;

  Attendance({
    required this.id,
    required this.userId,
    required this.checkIn,
    required this.checkInLat,
    required this.checkInLng,
    required this.checkInAddress,
    required this.status,
    this.checkOut,
    this.checkOutLat,
    this.checkOutLng,
    this.checkOutAddress,
    this.alasanIzin,
    this.createdAt,
    this.updatedAt,
  });

  factory Attendance.fromJson(Map<String, dynamic> json) {
    return Attendance(
      id: json['id'] as int? ?? 0,
      userId: json['user_id'] as int? ?? 0,
      checkIn: json['check_in'] as String? ?? '',
      checkInLat:
          (json['check_in_lat'] as num?)?.toDouble() ??
          0.0, // MODIFIKASI: Menambahkan ?? 0.0
      checkInLng:
          (json['check_in_lng'] as num?)?.toDouble() ??
          0.0, // MODIFIKASI: Menambahkan ?? 0.0
      checkInAddress: json['check_in_address'] as String? ?? '',
      status: json['status'] as String? ?? '',
      checkOut: json['check_out'] as String?,
      checkOutLat:
          (json['check_out_lat'] as num?)
              ?.toDouble(), // Null-aware operator (?)
      checkOutLng:
          (json['check_out_lng'] as num?)
              ?.toDouble(), // Null-aware operator (?)
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
      'check_in': checkIn,
      'check_in_lat': checkInLat,
      'check_in_lng': checkInLng,
      'check_in_address': checkInAddress,
      'status': status,
      'check_out': checkOut,
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
  final String batchKe;
  final String? description;
  final String? startDate;
  final String? endDate;
  final String? createdAt;
  final String? updatedAt;

  Batch({
    required this.id,
    required this.batchKe,
    this.description,
    this.startDate,
    this.endDate,
    this.createdAt,
    this.updatedAt,
  });

  factory Batch.fromJson(Map<String, dynamic> json) {
    return Batch(
      id: json['id'] as int,
      batchKe: json['batch_ke'].toString(),
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
      'batch_ke': batchKe,
      'description': description,
      'start_date': startDate,
      'end_date': endDate,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

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
  final List<dynamic>? units; // Jika isi list tidak ada model spesifik
  final List<dynamic>? activities; // Jika isi list tidak ada model spesifik

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
