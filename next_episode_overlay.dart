import 'package:flutter/material.dart';

class NextEpisodeOverlay extends StatefulWidget {
  final VoidCallback onNext;
  final VoidCallback onCancel;

  const NextEpisodeOverlay({
    Key? key,
    required this.onNext,
    required this.onCancel,
  }) : super(key: key);

  @override
  State<NextEpisodeOverlay> createState() => _NextEpisodeOverlayState();
}

class _NextEpisodeOverlayState extends State<NextEpisodeOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  int _countdown = 10;

  @override
  void initState() {
    super.initState();
    
    // Initialize animation controller
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    );
    
    // Create animation
    _animation = Tween<double>(begin: 1.0, end: 0.0).animate(_controller)
      ..addListener(() {
        setState(() {
          _countdown = (_animation.value * 10).ceil();
        });
      })
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          widget.onNext();
        }
      });
    
    // Start animation
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: 16,
      bottom: 80,
      child: Container(
        width: 220,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.8),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            const Text(
              'Next Episode',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            
            // Progress indicator
            LinearProgressIndicator(
              value: _animation.value,
              backgroundColor: Colors.grey.withOpacity(0.3),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.red),
            ),
            const SizedBox(height: 16),
            
            // Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Cancel button
                OutlinedButton(
                  onPressed: () {
                    _controller.stop();
                    widget.onCancel();
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                  ),
                  child: const Text('Cancel'),
                ),
                
                // Play next button
                ElevatedButton.icon(
                  onPressed: () {
                    _controller.stop();
                    widget.onNext();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                  ),
                  icon: const Icon(Icons.play_arrow, size: 16),
                  label: Text('Play ($_countdown)'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

