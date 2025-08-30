import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:video_player/video_player.dart';
import 'package:wakelock/wakelock.dart';

import '../../../core/models/episode_model.dart';
import '../../../core/utils/exceptions.dart';
import '../../../shared/widgets/loading_indicator.dart';
import '../../../shared/widgets/error_dialog.dart';
import '../providers/player_provider.dart';
import '../widgets/video_controls.dart';
import '../widgets/quality_selector.dart';
import '../widgets/playback_speed_selector.dart';
import '../widgets/episode_info_overlay.dart';
import '../widgets/next_episode_overlay.dart';

class VideoPlayerScreen extends ConsumerStatefulWidget {
  final String episodeId;
  final int startPosition;

  const VideoPlayerScreen({
    Key? key,
    required this.episodeId,
    this.startPosition = 0,
  }) : super(key: key);

  @override
  ConsumerState<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends ConsumerState<VideoPlayerScreen> {
  VideoPlayerController? _controller;
  bool _isControlsVisible = true;
  bool _isLocked = false;
  bool _isFullScreen = false;
  Timer? _controlsTimer;
  Timer? _progressTimer;
  bool _isDragging = false;
  bool _isBuffering = false;
  bool _showQualitySelector = false;
  bool _showSpeedSelector = false;
  bool _showNextEpisodeOverlay = false;
  double _playbackSpeed = 1.0;
  String _currentQuality = 'Auto';
  
  // For double tap to seek
  int _seekAmount = 10; // seconds
  bool _showForwardIndicator = false;
  bool _showBackwardIndicator = false;
  Timer? _forwardIndicatorTimer;
  Timer? _backwardIndicatorTimer;
  int _forwardTapCount = 0;
  int _backwardTapCount = 0;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
    
    // Enter landscape mode
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    
    // Enable wakelock to prevent screen from turning off
    Wakelock.enable();
    
    // Start progress tracking timer
    _startProgressTimer();
  }

  @override
  void dispose() {
    // Restore portrait mode
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    
    // Disable wakelock
    Wakelock.disable();
    
    // Dispose controllers and timers
    _controller?.dispose();
    _controlsTimer?.cancel();
    _progressTimer?.cancel();
    _forwardIndicatorTimer?.cancel();
    _backwardIndicatorTimer?.cancel();
    
    // Show system UI
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    
    super.dispose();
  }

  Future<void> _initializePlayer() async {
    try {
      // Load episode details
      await ref.read(currentEpisodeProvider(widget.episodeId).notifier).loadEpisode();
      
      // Get episode from provider
      final episodeAsync = ref.read(currentEpisodeProvider(widget.episodeId));
      
      if (episodeAsync.hasValue && episodeAsync.value != null) {
        final episode = episodeAsync.value!;
        
        // Check if premium content is accessible
        final canAccessPremium = await ref.read(canAccessPremiumProvider.future);
        
        if (episode.isPremium && !canAccessPremium) {
          // Show premium content dialog
          if (mounted) {
            _showPremiumContentDialog();
            return;
          }
        }
        
        // Initialize video player
        if (episode.videoUrl != null) {
          _controller = VideoPlayerController.network(
            episode.videoUrl!,
            videoPlayerOptions: VideoPlayerOptions(mixWithOthers: false),
          );
          
          await _controller!.initialize();
          
          if (mounted) {
            // Set initial position if provided
            if (widget.startPosition > 0) {
              await _controller!.seekTo(Duration(seconds: widget.startPosition));
            }
            
            // Start playback
            await _controller!.play();
            
            // Update state
            setState(() {
              _isBuffering = false;
            });
            
            // Hide controls after a delay
            _resetControlsTimer();
            
            // Listen for player state changes
            _controller!.addListener(_onControllerUpdate);
          }
        } else {
          throw VideoException('Video URL is not available');
        }
      }
    } catch (e) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => ErrorDialog(
            title: 'Playback Error',
            message: 'Failed to load video: ${e.toString()}',
            onButtonPressed: () {
              context.pop();
            },
          ),
        );
      }
    }
  }

  void _onControllerUpdate() {
    if (_controller == null) return;
    
    // Check if video is buffering
    final isBuffering = _controller!.value.isBuffering;
    if (isBuffering != _isBuffering) {
      setState(() {
        _isBuffering = isBuffering;
      });
    }
    
    // Check if video has ended
    if (_controller!.value.position >= _controller!.value.duration) {
      _onVideoCompleted();
    }
    
    // Check if we're near the end to show next episode overlay
    final duration = _controller!.value.duration;
    final position = _controller!.value.position;
    final timeRemaining = duration - position;
    
    if (timeRemaining.inSeconds <= 10 && !_showNextEpisodeOverlay) {
      setState(() {
        _showNextEpisodeOverlay = true;
      });
    }
  }

  void _onVideoCompleted() {
    // Get next episode
    final nextEpisode = ref.read(nextEpisodeProvider);
    
    if (nextEpisode != null) {
      // Show next episode dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text('Episode Completed'),
          content: Text('Would you like to watch the next episode: ${nextEpisode.title}?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                context.pop();
              },
              child: const Text('Close'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                context.go('/player/${nextEpisode.id}');
              },
              child: const Text('Watch Next'),
            ),
          ],
        ),
      );
    } else {
      // No next episode, just show completion message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Episode completed'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _startProgressTimer() {
    _progressTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (_controller != null && 
          _controller!.value.isPlaying && 
          !_isDragging) {
        // Save watch progress
        final position = _controller!.value.position.inSeconds;
        ref.read(playerProvider.notifier).saveWatchProgress(
          widget.episodeId,
          position,
        );
      }
    });
  }

  void _toggleControls() {
    setState(() {
      _isControlsVisible = !_isControlsVisible;
    });
    
    if (_isControlsVisible) {
      _resetControlsTimer();
    }
  }

  void _resetControlsTimer() {
    _controlsTimer?.cancel();
    _controlsTimer = Timer(const Duration(seconds: 3), () {
      if (mounted && !_isDragging && !_showQualitySelector && !_showSpeedSelector) {
        setState(() {
          _isControlsVisible = false;
        });
      }
    });
  }

  void _togglePlayPause() {
    if (_controller == null) return;
    
    setState(() {
      if (_controller!.value.isPlaying) {
        _controller!.pause();
      } else {
        _controller!.play();
        _resetControlsTimer();
      }
    });
  }

  void _toggleLock() {
    setState(() {
      _isLocked = !_isLocked;
      if (_isLocked) {
        _isControlsVisible = false;
      } else {
        _isControlsVisible = true;
        _resetControlsTimer();
      }
    });
  }

  void _toggleFullScreen() {
    setState(() {
      _isFullScreen = !_isFullScreen;
      
      if (_isFullScreen) {
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
      } else {
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      }
      
      _resetControlsTimer();
    });
  }

  void _onSeekStart() {
    setState(() {
      _isDragging = true;
    });
    _controlsTimer?.cancel();
  }

  void _onSeekEnd() {
    setState(() {
      _isDragging = false;
    });
    _resetControlsTimer();
  }

  void _seek(double value) {
    if (_controller == null) return;
    
    final duration = _controller!.value.duration;
    final position = duration * value;
    _controller!.seekTo(position);
  }

  void _fastForward() {
    if (_controller == null) return;
    
    final currentPosition = _controller!.value.position;
    final newPosition = currentPosition + Duration(seconds: _seekAmount);
    _controller!.seekTo(newPosition);
    _resetControlsTimer();
    
    // Show forward indicator
    setState(() {
      _showForwardIndicator = true;
      _forwardTapCount++;
    });
    
    _forwardIndicatorTimer?.cancel();
    _forwardIndicatorTimer = Timer(const Duration(milliseconds: 800), () {
      if (mounted) {
        setState(() {
          _showForwardIndicator = false;
          _forwardTapCount = 0;
        });
      }
    });
  }

  void _rewind() {
    if (_controller == null) return;
    
    final currentPosition = _controller!.value.position;
    final newPosition = currentPosition - Duration(seconds: _seekAmount);
    _controller!.seekTo(newPosition.inSeconds > 0 
        ? newPosition 
        : Duration.zero);
    _resetControlsTimer();
    
    // Show backward indicator
    setState(() {
      _showBackwardIndicator = true;
      _backwardTapCount++;
    });
    
    _backwardIndicatorTimer?.cancel();
    _backwardIndicatorTimer = Timer(const Duration(milliseconds: 800), () {
      if (mounted) {
        setState(() {
          _showBackwardIndicator = false;
          _backwardTapCount = 0;
        });
      }
    });
  }

  void _toggleQualitySelector() {
    setState(() {
      _showQualitySelector = !_showQualitySelector;
      _showSpeedSelector = false;
    });
    _resetControlsTimer();
  }

  void _toggleSpeedSelector() {
    setState(() {
      _showSpeedSelector = !_showSpeedSelector;
      _showQualitySelector = false;
    });
    _resetControlsTimer();
  }

  void _setPlaybackSpeed(double speed) {
    if (_controller == null) return;
    
    setState(() {
      _playbackSpeed = speed;
      _showSpeedSelector = false;
    });
    
    _controller!.setPlaybackSpeed(speed);
    _resetControlsTimer();
  }

  void _setQuality(String quality) {
    // In a real app, this would switch between different quality streams
    setState(() {
      _currentQuality = quality;
      _showQualitySelector = false;
    });
    _resetControlsTimer();
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Switched to $quality quality'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showPremiumContentDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Premium Content'),
        content: const Text(
          'This is premium content. Please subscribe to watch this episode.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.pop();
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.push('/profile/subscription');
            },
            child: const Text('Subscribe Now'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final episodeAsync = ref.watch(currentEpisodeProvider(widget.episodeId));
    
    return Scaffold(
      backgroundColor: Colors.black,
      body: episodeAsync.when(
        data: (episode) => _buildPlayer(episode, size),
        loading: () => const LoadingIndicator(
          message: 'Loading video...',
          color: Colors.white,
        ),
        error: (error, stackTrace) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 48,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              Text(
                'Failed to load video',
                style: TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  context.pop();
                },
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlayer(EpisodeModel? episode, Size size) {
    if (episode == null || _controller == null) {
      return const Center(
        child: Text(
          'Video not available',
          style: TextStyle(color: Colors.white),
        ),
      );
    }
    
    return GestureDetector(
      onTap: _isLocked ? null : _toggleControls,
      onDoubleTapDown: (details) {
        final screenWidth = size.width;
        final tapPosition = details.globalPosition.dx;
        
        // Determine if tap is on left or right side of screen
        if (tapPosition < screenWidth / 2) {
          // Left side - rewind
          _rewind();
        } else {
          // Right side - fast forward
          _fastForward();
        }
      },
      child: Stack(
        children: [
          // Video Player
          Center(
            child: AspectRatio(
              aspectRatio: _controller!.value.aspectRatio,
              child: VideoPlayer(_controller!),
            ),
          ),
          
          // Buffering Indicator
          if (_isBuffering)
            const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
          
          // Double Tap Indicators
          if (_showForwardIndicator)
            Align(
              alignment: Alignment.centerRight,
              child: Container(
                margin: const EdgeInsets.only(right: 50),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.fast_forward,
                      color: Colors.white,
                      size: 32,
                    ),
                    Text(
                      '+${_seekAmount * _forwardTapCount}s',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          
          if (_showBackwardIndicator)
            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                margin: const EdgeInsets.only(left: 50),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.fast_rewind,
                      color: Colors.white,
                      size: 32,
                    ),
                    Text(
                      '-${_seekAmount * _backwardTapCount}s',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          
          // Lock Button (always visible)
          Positioned(
            top: 16,
            right: 16,
            child: IconButton(
              icon: Icon(
                _isLocked ? Icons.lock : Icons.lock_open,
                color: Colors.white,
              ),
              onPressed: _toggleLock,
            ),
          ),
          
          // Controls Overlay
          if (_isControlsVisible && !_isLocked)
            VideoControls(
              controller: _controller!,
              onPlayPause: _togglePlayPause,
              onSeekStart: _onSeekStart,
              onSeekEnd: _onSeekEnd,
              onSeek: _seek,
              onRewind: _rewind,
              onFastForward: _fastForward,
              onBack: () => context.pop(),
              onFullScreen: _toggleFullScreen,
              onQualityTap: _toggleQualitySelector,
              onSpeedTap: _toggleSpeedSelector,
              isFullScreen: _isFullScreen,
              currentQuality: _currentQuality,
              currentSpeed: _playbackSpeed,
            ),
          
          // Quality Selector
          if (_showQualitySelector && !_isLocked)
            QualitySelector(
              currentQuality: _currentQuality,
              onQualitySelected: _setQuality,
              onClose: _toggleQualitySelector,
            ),
          
          // Speed Selector
          if (_showSpeedSelector && !_isLocked)
            PlaybackSpeedSelector(
              currentSpeed: _playbackSpeed,
              onSpeedSelected: _setPlaybackSpeed,
              onClose: _toggleSpeedSelector,
            ),
          
          // Episode Info Overlay (shown briefly at start)
          if (episode.show != null && _controller != null && _controller!.value.position.inSeconds < 5)
            EpisodeInfoOverlay(
              episode: episode,
              show: episode.show!,
            ),
          
          // Next Episode Overlay
          if (_showNextEpisodeOverlay && !_isLocked)
            NextEpisodeOverlay(
              onNext: () {
                final nextEpisode = ref.read(nextEpisodeProvider);
                if (nextEpisode != null) {
                  context.go('/player/${nextEpisode.id}');
                }
              },
              onCancel: () {
                setState(() {
                  _showNextEpisodeOverlay = false;
                });
              },
            ),
        ],
      ),
    );
  }
}

