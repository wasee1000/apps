import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as path;

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/loading_indicator.dart';
import '../../../shared/widgets/error_dialog.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../providers/admin_provider.dart';

class VideoUploadScreen extends ConsumerStatefulWidget {
  const VideoUploadScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<VideoUploadScreen> createState() => _VideoUploadScreenState();
}

class _VideoUploadScreenState extends ConsumerState<VideoUploadScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  File? _videoFile;
  File? _thumbnailFile;
  String? _selectedShowId;
  String? _selectedCategoryId;
  bool _isPremium = false;
  bool _isTrailer = false;
  bool _isProcessing = false;
  
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    // Load shows and categories
    ref.read(adminShowsProvider.notifier).loadShows();
    ref.read(adminCategoriesProvider.notifier).loadCategories();
  }

  Future<void> _pickVideo() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.video,
        allowMultiple: false,
      );
      
      if (result != null && result.files.isNotEmpty) {
        setState(() {
          _videoFile = File(result.files.first.path!);
        });
      }
    } catch (e) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => ErrorDialog(
            title: 'Error',
            message: 'Failed to pick video: ${e.toString()}',
          ),
        );
      }
    }
  }

  Future<void> _pickThumbnail() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );
      
      if (result != null && result.files.isNotEmpty) {
        setState(() {
          _thumbnailFile = File(result.files.first.path!);
        });
      }
    } catch (e) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => ErrorDialog(
            title: 'Error',
            message: 'Failed to pick thumbnail: ${e.toString()}',
          ),
        );
      }
    }
  }

  Future<void> _uploadVideo() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    if (_videoFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a video file'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    if (_thumbnailFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a thumbnail image'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    if (_selectedShowId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a show'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    setState(() {
      _isProcessing = true;
    });
    
    try {
      // Upload thumbnail
      final thumbnailFileName = 'thumbnail_${DateTime.now().millisecondsSinceEpoch}${path.extension(_thumbnailFile!.path)}';
      final thumbnailUrl = await ref.read(adminUploadProvider.notifier).uploadImage(
        _thumbnailFile!.path,
        thumbnailFileName,
      );
      
      // Upload video
      final videoFileName = 'video_${DateTime.now().millisecondsSinceEpoch}${path.extension(_videoFile!.path)}';
      final videoUrl = await ref.read(adminUploadProvider.notifier).uploadVideo(
        _videoFile!.path,
        videoFileName,
      );
      
      // Create episode
      final episodeData = {
        'show_id': _selectedShowId,
        'episode_title': _titleController.text,
        'description': _descriptionController.text,
        'video_url': videoUrl,
        'thumbnail_url': thumbnailUrl,
        'is_premium': _isPremium,
        'is_trailer': _isTrailer,
        'duration': 0, // Will be updated by backend
        'status': 'processing', // Will be updated by backend
      };
      
      await ref.read(adminEpisodesProvider.notifier).createEpisode(episodeData);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Video uploaded successfully'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Navigate back to episodes list
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => ErrorDialog(
            title: 'Upload Error',
            message: 'Failed to upload video: ${e.toString()}',
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final uploadProgress = ref.watch(adminUploadProvider);
    final shows = ref.watch(adminShowsProvider);
    final categories = ref.watch(adminCategoriesProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Video'),
        centerTitle: true,
      ),
      body: _isProcessing
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(
                    'Uploading Video...',
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  uploadProgress.when(
                    data: (progress) {
                      return Column(
                        children: [
                          SizedBox(
                            width: 200,
                            child: LinearProgressIndicator(
                              value: progress,
                              backgroundColor: Colors.grey.withOpacity(0.2),
                              valueColor: AlwaysStoppedAnimation<Color>(
                                theme.colorScheme.primary,
                              ),
                              minHeight: 8,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${(progress * 100).toStringAsFixed(0)}%',
                            style: theme.textTheme.bodyLarge,
                          ),
                        ],
                      );
                    },
                    loading: () => const CircularProgressIndicator(),
                    error: (error, stackTrace) => Text(
                      'Error: ${error.toString()}',
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Video selection
                    Text(
                      'Select Video',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Video picker
                    InkWell(
                      onTap: _pickVideo,
                      child: Container(
                        width: double.infinity,
                        height: 120,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: theme.dividerColor,
                          ),
                        ),
                        child: _videoFile != null
                            ? Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.video_file,
                                    size: 40,
                                    color: Colors.green,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    path.basename(_videoFile!.path),
                                    style: theme.textTheme.bodyMedium,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    'Tap to change',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.primary,
                                    ),
                                  ),
                                ],
                              )
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.upload_file,
                                    size: 40,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Tap to select video file',
                                    style: theme.textTheme.bodyMedium,
                                  ),
                                ],
                              ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Thumbnail selection
                    Text(
                      'Select Thumbnail',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Thumbnail picker
                    InkWell(
                      onTap: _pickThumbnail,
                      child: Container(
                        width: double.infinity,
                        height: 120,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: theme.dividerColor,
                          ),
                          image: _thumbnailFile != null
                              ? DecorationImage(
                                  image: FileImage(_thumbnailFile!),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: _thumbnailFile == null
                            ? Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.image,
                                    size: 40,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Tap to select thumbnail image',
                                    style: theme.textTheme.bodyMedium,
                                  ),
                                ],
                              )
                            : null,
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Video details
                    Text(
                      'Video Details',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Title
                    CustomTextField(
                      controller: _titleController,
                      label: 'Title',
                      hintText: 'Enter video title',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a title';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Description
                    CustomTextField(
                      controller: _descriptionController,
                      label: 'Description',
                      hintText: 'Enter video description',
                      maxLines: 3,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a description';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Show selection
                    Text(
                      'Select Show',
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    
                    shows.when(
                      data: (showsList) {
                        return DropdownButtonFormField<String>(
                          value: _selectedShowId,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                          hint: const Text('Select a show'),
                          items: showsList.map((show) {
                            return DropdownMenuItem<String>(
                              value: show.id,
                              child: Text(show.title),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedShowId = value;
                            });
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please select a show';
                            }
                            return null;
                          },
                        );
                      },
                      loading: () => const Center(
                        child: CircularProgressIndicator(),
                      ),
                      error: (error, stackTrace) => Center(
                        child: Text(
                          'Failed to load shows',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Premium and trailer toggles
                    Row(
                      children: [
                        // Premium toggle
                        Expanded(
                          child: CheckboxListTile(
                            title: const Text('Premium Content'),
                            value: _isPremium,
                            onChanged: (value) {
                              setState(() {
                                _isPremium = value ?? false;
                              });
                            },
                            controlAffinity: ListTileControlAffinity.leading,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                        
                        // Trailer toggle
                        Expanded(
                          child: CheckboxListTile(
                            title: const Text('Trailer'),
                            value: _isTrailer,
                            onChanged: (value) {
                              setState(() {
                                _isTrailer = value ?? false;
                              });
                            },
                            controlAffinity: ListTileControlAffinity.leading,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    
                    // Upload button
                    SizedBox(
                      width: double.infinity,
                      child: CustomButton(
                        onPressed: _uploadVideo,
                        text: 'Upload Video',
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

