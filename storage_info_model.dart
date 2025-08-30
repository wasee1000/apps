class StorageInfoModel {
  final int totalSpace;
  final int usedSpace;
  final int downloadedVideosSpace;
  final int availableSpace;
  final int downloadCount;

  StorageInfoModel({
    required this.totalSpace,
    required this.usedSpace,
    required this.downloadedVideosSpace,
    required this.availableSpace,
    required this.downloadCount,
  });

  factory StorageInfoModel.fromJson(Map<String, dynamic> json) {
    return StorageInfoModel(
      totalSpace: json['total_space'],
      usedSpace: json['used_space'],
      downloadedVideosSpace: json['downloaded_videos_space'],
      availableSpace: json['available_space'],
      downloadCount: json['download_count'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_space': totalSpace,
      'used_space': usedSpace,
      'downloaded_videos_space': downloadedVideosSpace,
      'available_space': availableSpace,
      'download_count': downloadCount,
    };
  }

  // Get formatted total space
  String get totalSpaceFormatted {
    return _formatBytes(totalSpace);
  }

  // Get formatted used space
  String get usedSpaceFormatted {
    return _formatBytes(usedSpace);
  }

  // Get formatted downloaded videos space
  String get downloadedVideosSpaceFormatted {
    return _formatBytes(downloadedVideosSpace);
  }

  // Get formatted available space
  String get availableSpaceFormatted {
    return _formatBytes(availableSpace);
  }

  // Get used space percentage
  double get usedSpacePercentage {
    return totalSpace > 0 ? usedSpace / totalSpace : 0;
  }

  // Get downloaded videos space percentage
  double get downloadedVideosSpacePercentage {
    return totalSpace > 0 ? downloadedVideosSpace / totalSpace : 0;
  }

  // Get available space percentage
  double get availableSpacePercentage {
    return totalSpace > 0 ? availableSpace / totalSpace : 0;
  }

  // Format bytes to human-readable string
  String _formatBytes(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    } else {
      return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
    }
  }
}

