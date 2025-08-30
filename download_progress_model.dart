class DownloadProgressModel {
  final String episodeId;
  final String episodeTitle;
  final String? showTitle;
  final String? thumbnailUrl;
  final double progress;
  final int downloadedBytes;
  final int totalBytes;
  final String status; // 'downloading', 'paused', 'completed', 'failed'
  final DateTime startTime;
  final DateTime? endTime;
  final String? errorMessage;

  DownloadProgressModel({
    required this.episodeId,
    required this.episodeTitle,
    this.showTitle,
    this.thumbnailUrl,
    required this.progress,
    required this.downloadedBytes,
    required this.totalBytes,
    required this.status,
    required this.startTime,
    this.endTime,
    this.errorMessage,
  });

  factory DownloadProgressModel.fromJson(Map<String, dynamic> json) {
    return DownloadProgressModel(
      episodeId: json['episode_id'],
      episodeTitle: json['episode_title'],
      showTitle: json['show_title'],
      thumbnailUrl: json['thumbnail_url'],
      progress: json['progress'].toDouble(),
      downloadedBytes: json['downloaded_bytes'],
      totalBytes: json['total_bytes'],
      status: json['status'],
      startTime: DateTime.parse(json['start_time']),
      endTime: json['end_time'] != null ? DateTime.parse(json['end_time']) : null,
      errorMessage: json['error_message'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'episode_id': episodeId,
      'episode_title': episodeTitle,
      'show_title': showTitle,
      'thumbnail_url': thumbnailUrl,
      'progress': progress,
      'downloaded_bytes': downloadedBytes,
      'total_bytes': totalBytes,
      'status': status,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime?.toIso8601String(),
      'error_message': errorMessage,
    };
  }

  // Get formatted download speed
  String get downloadSpeed {
    if (status != 'downloading' || endTime == null) return '';
    
    final duration = endTime!.difference(startTime).inSeconds;
    if (duration <= 0) return '';
    
    final bytesPerSecond = downloadedBytes / duration;
    
    if (bytesPerSecond < 1024) {
      return '${bytesPerSecond.toStringAsFixed(1)} B/s';
    } else if (bytesPerSecond < 1024 * 1024) {
      return '${(bytesPerSecond / 1024).toStringAsFixed(1)} KB/s';
    } else {
      return '${(bytesPerSecond / (1024 * 1024)).toStringAsFixed(1)} MB/s';
    }
  }

  // Get formatted downloaded size
  String get downloadedSize {
    if (downloadedBytes < 1024) {
      return '$downloadedBytes B';
    } else if (downloadedBytes < 1024 * 1024) {
      return '${(downloadedBytes / 1024).toStringAsFixed(1)} KB';
    } else if (downloadedBytes < 1024 * 1024 * 1024) {
      return '${(downloadedBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    } else {
      return '${(downloadedBytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
    }
  }

  // Get formatted total size
  String get totalSize {
    if (totalBytes < 1024) {
      return '$totalBytes B';
    } else if (totalBytes < 1024 * 1024) {
      return '${(totalBytes / 1024).toStringAsFixed(1)} KB';
    } else if (totalBytes < 1024 * 1024 * 1024) {
      return '${(totalBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    } else {
      return '${(totalBytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
    }
  }

  // Get formatted progress percentage
  String get progressPercentage {
    return '${(progress * 100).toStringAsFixed(0)}%';
  }

  // Get estimated time remaining
  String get estimatedTimeRemaining {
    if (status != 'downloading' || progress <= 0) return '';
    
    final elapsedTime = DateTime.now().difference(startTime).inSeconds;
    if (elapsedTime <= 0) return '';
    
    final remainingTime = (elapsedTime / progress) * (1 - progress);
    
    if (remainingTime < 60) {
      return '${remainingTime.toStringAsFixed(0)} sec';
    } else if (remainingTime < 3600) {
      return '${(remainingTime / 60).toStringAsFixed(0)} min';
    } else {
      return '${(remainingTime / 3600).toStringAsFixed(1)} hr';
    }
  }
}

