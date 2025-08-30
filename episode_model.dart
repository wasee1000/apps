import 'show_model.dart';

class EpisodeModel {
  final String id;
  final String showId;
  final int episodeNumber;
  final int seasonNumber;
  final String title;
  final String? description;
  final String? thumbnailUrl;
  final String? videoUrl;
  final int? videoDuration; // in seconds
  final int? fileSize; // in bytes
  final bool isPremium;
  final bool isTrailer;
  final String status;
  final DateTime? airDate;
  final int viewCount;
  final DateTime createdAt;
  final DateTime updatedAt;
  ShowModel? show; // Parent show reference

  EpisodeModel({
    required this.id,
    required this.showId,
    required this.episodeNumber,
    this.seasonNumber = 1,
    required this.title,
    this.description,
    this.thumbnailUrl,
    this.videoUrl,
    this.videoDuration,
    this.fileSize,
    this.isPremium = false,
    this.isTrailer = false,
    this.status = 'published',
    this.airDate,
    this.viewCount = 0,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.show,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  factory EpisodeModel.fromJson(Map<String, dynamic> json) {
    return EpisodeModel(
      id: json['id'],
      showId: json['show_id'],
      episodeNumber: json['episode_number'],
      seasonNumber: json['season_number'] ?? 1,
      title: json['title'],
      description: json['description'],
      thumbnailUrl: json['thumbnail_url'],
      videoUrl: json['video_url'],
      videoDuration: json['video_duration'],
      fileSize: json['file_size'],
      isPremium: json['is_premium'] ?? false,
      isTrailer: json['is_trailer'] ?? false,
      status: json['status'] ?? 'published',
      airDate: json['air_date'] != null
          ? DateTime.parse(json['air_date'])
          : null,
      viewCount: json['view_count'] ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'show_id': showId,
      'episode_number': episodeNumber,
      'season_number': seasonNumber,
      'title': title,
      'description': description,
      'thumbnail_url': thumbnailUrl,
      'video_url': videoUrl,
      'video_duration': videoDuration,
      'file_size': fileSize,
      'is_premium': isPremium,
      'is_trailer': isTrailer,
      'status': status,
      'air_date': airDate?.toIso8601String(),
      'view_count': viewCount,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  EpisodeModel copyWith({
    String? id,
    String? showId,
    int? episodeNumber,
    int? seasonNumber,
    String? title,
    String? description,
    String? thumbnailUrl,
    String? videoUrl,
    int? videoDuration,
    int? fileSize,
    bool? isPremium,
    bool? isTrailer,
    String? status,
    DateTime? airDate,
    int? viewCount,
    DateTime? createdAt,
    DateTime? updatedAt,
    ShowModel? show,
  }) {
    return EpisodeModel(
      id: id ?? this.id,
      showId: showId ?? this.showId,
      episodeNumber: episodeNumber ?? this.episodeNumber,
      seasonNumber: seasonNumber ?? this.seasonNumber,
      title: title ?? this.title,
      description: description ?? this.description,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      videoUrl: videoUrl ?? this.videoUrl,
      videoDuration: videoDuration ?? this.videoDuration,
      fileSize: fileSize ?? this.fileSize,
      isPremium: isPremium ?? this.isPremium,
      isTrailer: isTrailer ?? this.isTrailer,
      status: status ?? this.status,
      airDate: airDate ?? this.airDate,
      viewCount: viewCount ?? this.viewCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      show: show ?? this.show,
    );
  }

  String get episodeTitle => 'S${seasonNumber.toString().padLeft(2, '0')}E${episodeNumber.toString().padLeft(2, '0')}: $title';
  
  String get durationString {
    if (videoDuration == null) return '';
    
    final minutes = (videoDuration! / 60).floor();
    final seconds = videoDuration! % 60;
    
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
  
  String get fileSizeString {
    if (fileSize == null) return '';
    
    if (fileSize! < 1024 * 1024) {
      // KB
      return '${(fileSize! / 1024).toStringAsFixed(1)} KB';
    } else if (fileSize! < 1024 * 1024 * 1024) {
      // MB
      return '${(fileSize! / (1024 * 1024)).toStringAsFixed(1)} MB';
    } else {
      // GB
      return '${(fileSize! / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
    }
  }
  
  String get airDateString {
    if (airDate == null) return '';
    
    return '${airDate!.day}/${airDate!.month}/${airDate!.year}';
  }
}

