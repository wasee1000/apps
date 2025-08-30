class ShowModel {
  final String id;
  final String title;
  final String? description;
  final String? thumbnailUrl;
  final String? bannerUrl;
  final String? trailerUrl;
  final String? categoryId;
  final List<String> genre;
  final String language;
  final double rating;
  final int totalEpisodes;
  final String status;
  final bool isPremium;
  final List<String> tags;
  final int? releaseYear;
  final String? director;
  final List<String> cast;
  final DateTime createdAt;
  final DateTime updatedAt;

  ShowModel({
    required this.id,
    required this.title,
    this.description,
    this.thumbnailUrl,
    this.bannerUrl,
    this.trailerUrl,
    this.categoryId,
    this.genre = const [],
    this.language = 'hindi',
    this.rating = 0.0,
    this.totalEpisodes = 0,
    this.status = 'published',
    this.isPremium = false,
    this.tags = const [],
    this.releaseYear,
    this.director,
    this.cast = const [],
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  factory ShowModel.fromJson(Map<String, dynamic> json) {
    return ShowModel(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      thumbnailUrl: json['thumbnail_url'],
      bannerUrl: json['banner_url'],
      trailerUrl: json['trailer_url'],
      categoryId: json['category_id'],
      genre: json['genre'] != null
          ? List<String>.from(json['genre'])
          : [],
      language: json['language'] ?? 'hindi',
      rating: json['rating'] != null
          ? double.parse(json['rating'].toString())
          : 0.0,
      totalEpisodes: json['total_episodes'] ?? 0,
      status: json['status'] ?? 'published',
      isPremium: json['is_premium'] ?? false,
      tags: json['tags'] != null
          ? List<String>.from(json['tags'])
          : [],
      releaseYear: json['release_year'],
      director: json['director'],
      cast: json['cast'] != null
          ? List<String>.from(json['cast'])
          : [],
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
      'title': title,
      'description': description,
      'thumbnail_url': thumbnailUrl,
      'banner_url': bannerUrl,
      'trailer_url': trailerUrl,
      'category_id': categoryId,
      'genre': genre,
      'language': language,
      'rating': rating,
      'total_episodes': totalEpisodes,
      'status': status,
      'is_premium': isPremium,
      'tags': tags,
      'release_year': releaseYear,
      'director': director,
      'cast': cast,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  ShowModel copyWith({
    String? id,
    String? title,
    String? description,
    String? thumbnailUrl,
    String? bannerUrl,
    String? trailerUrl,
    String? categoryId,
    List<String>? genre,
    String? language,
    double? rating,
    int? totalEpisodes,
    String? status,
    bool? isPremium,
    List<String>? tags,
    int? releaseYear,
    String? director,
    List<String>? cast,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ShowModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      bannerUrl: bannerUrl ?? this.bannerUrl,
      trailerUrl: trailerUrl ?? this.trailerUrl,
      categoryId: categoryId ?? this.categoryId,
      genre: genre ?? this.genre,
      language: language ?? this.language,
      rating: rating ?? this.rating,
      totalEpisodes: totalEpisodes ?? this.totalEpisodes,
      status: status ?? this.status,
      isPremium: isPremium ?? this.isPremium,
      tags: tags ?? this.tags,
      releaseYear: releaseYear ?? this.releaseYear,
      director: director ?? this.director,
      cast: cast ?? this.cast,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  String get genreString => genre.join(', ');
  
  String get castString => cast.join(', ');
  
  String get yearString => releaseYear != null ? releaseYear.toString() : '';
  
  String get ratingString => rating.toStringAsFixed(1);
}

