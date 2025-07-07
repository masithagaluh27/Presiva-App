// lib/models/app_models.dart

class User {
  final int id;
  final String name;
  final String email;
  final int? batchId;
  final int? trainingId;
  final String? createdAt;
  final String? updatedAt;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.batchId,
    this.trainingId,
    this.createdAt,
    this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      batchId: json['batch_id'],
      trainingId: json['training_id'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'batch_id': batchId,
      'training_id': trainingId,
      'created_at': createdAt,
      'updated_at': updatedAt,
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
  final String? alasanIzin; // Field untuk alasan izin/sakit
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
      id: json['id'],
      userId: json['user_id'],
      date: json['date'],
      checkInTime: json['check_in_time'],
      checkInLat: json['check_in_lat'],
      checkInLng: json['check_in_lng'],
      checkInAddress: json['check_in_address'],
      status: json['status'],
      checkOutTime: json['check_out_time'],
      checkOutLat: json['check_out_lat'],
      checkOutLng: json['check_out_lng'],
      checkOutAddress: json['check_out_address'],
      alasanIzin: json['alasan_izin'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
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
  final String name;
  final String description;

  Batch({required this.id, required this.name, required this.description});

  factory Batch.fromJson(Map<String, dynamic> json) {
    return Batch(
      id: json['id'],
      name: json['name'],
      description: json['description'] ?? '', // Handle null description
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'description': description};
  }
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

  Training({
    required this.id,
    required this.title,
    this.description,
    this.participantCount,
    this.standard,
    this.duration,
    this.createdAt,
    this.updatedAt,
  });

  factory Training.fromJson(Map<String, dynamic> json) {
    return Training(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      participantCount: json['participant_count'],
      standard: json['standard'],
      duration: json['duration'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
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
    };
  }
}
