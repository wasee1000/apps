import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoControls extends StatelessWidget {
  final VideoPlayerController controller;
  final VoidCallback onPlayPause;
  final VoidCallback onSeekStart;
  final VoidCallback onSeekEnd;
  final Function(double) onSeek;
  final VoidCallback onRewind;
  final VoidCallback onFastForward;
  final VoidCallback onBack;
  final VoidCallback onFullScreen;
  final VoidCallback onQualityTap;
  final VoidCallback onSpeedTap;
  final bool isFullScreen;
  final String currentQuality;
  final double currentSpeed;

  const VideoControls({
    Key? key,
    required this.controller,
    required this.onPlayPause,
    required this.onSeekStart,
    required this.onSeekEnd,
    required this.onSeek,
    required this.onRewind,
    required this.onFastForward,
    required this.onBack,
    required this.onFullScreen,
    required this.onQualityTap,
    required this.onSpeedTap,
    required this.isFullScreen,
    required this.currentQuality,
    required this.currentSpeed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Background gradient for better visibility
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withOpacity(0.7),
                Colors.transparent,
                Colors.transparent,
                Colors.black.withOpacity(0.7),
              ],
            ),
          ),
        ),
        
        // Top controls
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                // Back button
                IconButton(
                  icon: const Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                  ),
                  onPressed: onBack,
                ),
                
                const Spacer(),
                
                // Quality selector
                TextButton.icon(
                  onPressed: onQualityTap,
                  icon: const Icon(
                    Icons.high_quality,
                    color: Colors.white,
                    size: 20,
                  ),
                  label: Text(
                    currentQuality,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                ),
                
                const SizedBox(width: 16),
                
                // Speed selector
                TextButton.icon(
                  onPressed: onSpeedTap,
                  icon: const Icon(
                    Icons.speed,
                    color: Colors.white,
                    size: 20,
                  ),
                  label: Text(
                    '${currentSpeed}x',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        
        // Center controls
        Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Rewind button
              IconButton(
                iconSize: 40,
                icon: const Icon(
                  Icons.replay_10,
                  color: Colors.white,
                ),
                onPressed: onRewind,
              ),
              
              const SizedBox(width: 32),
              
              // Play/Pause button
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  iconSize: 40,
                  icon: Icon(
                    controller.value.isPlaying
                        ? Icons.pause
                        : Icons.play_arrow,
                    color: Colors.white,
                  ),
                  onPressed: onPlayPause,
                ),
              ),
              
              const SizedBox(width: 32),
              
              // Fast forward button
              IconButton(
                iconSize: 40,
                icon: const Icon(
                  Icons.forward_10,
                  color: Colors.white,
                ),
                onPressed: onFastForward,
              ),
            ],
          ),
        ),
        
        // Bottom controls
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Progress bar
                _buildProgressBar(),
                
                const SizedBox(height: 8),
                
                // Time and fullscreen
                Row(
                  children: [
                    // Current position
                    Text(
                      _formatDuration(controller.value.position),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                    
                    const Text(
                      ' / ',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                    
                    // Total duration
                    Text(
                      _formatDuration(controller.value.duration),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                    
                    const Spacer(),
                    
                    // Fullscreen button
                    IconButton(
                      icon: Icon(
                        isFullScreen
                            ? Icons.fullscreen_exit
                            : Icons.fullscreen,
                        color: Colors.white,
                      ),
                      onPressed: onFullScreen,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProgressBar() {
    return ValueListenableBuilder(
      valueListenable: controller,
      builder: (context, VideoPlayerValue value, child) {
        final duration = value.duration;
        final position = value.position;
        
        // Calculate progress
        double progress = 0.0;
        if (duration.inMilliseconds > 0) {
          progress = position.inMilliseconds / duration.inMilliseconds;
        }
        
        // Calculate buffered progress
        double bufferedProgress = 0.0;
        if (duration.inMilliseconds > 0 && value.buffered.isNotEmpty) {
          final bufferedEnd = value.buffered.last.end;
          bufferedProgress = bufferedEnd.inMilliseconds / duration.inMilliseconds;
        }
        
        return SliderTheme(
          data: SliderThemeData(
            trackHeight: 4,
            thumbShape: const RoundSliderThumbShape(
              enabledThumbRadius: 6,
            ),
            overlayShape: const RoundSliderOverlayShape(
              overlayRadius: 12,
            ),
            trackShape: _CustomTrackShape(bufferedProgress),
          ),
          child: Slider(
            value: progress,
            onChanged: onSeek,
            onChangeStart: (_) => onSeekStart(),
            onChangeEnd: (_) => onSeekEnd(),
            activeColor: Colors.red,
            inactiveColor: Colors.grey.withOpacity(0.5),
          ),
        );
      },
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    
    if (duration.inHours > 0) {
      final hours = duration.inHours.toString();
      return '$hours:$minutes:$seconds';
    } else {
      return '$minutes:$seconds';
    }
  }
}

// Custom track shape to show buffered progress
class _CustomTrackShape extends RoundedRectSliderTrackShape {
  final double bufferedProgress;
  
  _CustomTrackShape(this.bufferedProgress);
  
  @override
  void paint(
    PaintingContext context,
    Offset offset, {
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required Animation<double> enableAnimation,
    required TextDirection textDirection,
    required Offset thumbCenter,
    Offset? secondaryOffset,
    bool isDiscrete = false,
    bool isEnabled = false,
    double additionalActiveTrackHeight = 0,
  }) {
    // Paint the regular track
    super.paint(
      context,
      offset,
      parentBox: parentBox,
      sliderTheme: sliderTheme,
      enableAnimation: enableAnimation,
      textDirection: textDirection,
      thumbCenter: thumbCenter,
      isDiscrete: isDiscrete,
      isEnabled: isEnabled,
    );
    
    // Paint the buffered track
    final Canvas canvas = context.canvas;
    final Rect trackRect = getPreferredRect(
      parentBox: parentBox,
      offset: offset,
      sliderTheme: sliderTheme,
      isEnabled: isEnabled,
      isDiscrete: isDiscrete,
    );
    
    // Calculate buffered width
    final double bufferedWidth = trackRect.width * bufferedProgress;
    
    // Create buffered rect
    final Rect bufferedRect = Rect.fromLTWH(
      trackRect.left,
      trackRect.top,
      bufferedWidth,
      trackRect.height,
    );
    
    // Paint buffered progress
    final Paint bufferedPaint = Paint()
      ..color = Colors.white.withOpacity(0.5)
      ..style = PaintingStyle.fill;
    
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        bufferedRect,
        Radius.circular(trackRect.height / 2),
      ),
      bufferedPaint,
    );
  }
}

