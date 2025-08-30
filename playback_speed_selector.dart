import 'package:flutter/material.dart';

class PlaybackSpeedSelector extends StatelessWidget {
  final double currentSpeed;
  final Function(double) onSpeedSelected;
  final VoidCallback onClose;

  const PlaybackSpeedSelector({
    Key? key,
    required this.currentSpeed,
    required this.onSpeedSelected,
    required this.onClose,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // List of available speeds
    final speeds = [
      0.25,
      0.5,
      0.75,
      1.0,
      1.25,
      1.5,
      1.75,
      2.0,
    ];

    return Positioned(
      right: 16,
      top: 70,
      child: Container(
        width: 150,
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.8),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  const Text(
                    'Playback Speed',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: onClose,
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ],
              ),
            ),
            
            const Divider(
              color: Colors.grey,
              height: 1,
            ),
            
            // Speed options
            for (final speed in speeds)
              _buildSpeedOption(speed),
          ],
        ),
      ),
    );
  }

  Widget _buildSpeedOption(double speed) {
    final isSelected = speed == currentSpeed;
    final speedText = speed == 1.0 ? 'Normal' : '${speed}x';
    
    return InkWell(
      onTap: () => onSpeedSelected(speed),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        color: isSelected ? Colors.grey.withOpacity(0.3) : Colors.transparent,
        child: Row(
          children: [
            Text(
              speedText,
              style: TextStyle(
                color: Colors.white,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            const Spacer(),
            if (isSelected)
              const Icon(
                Icons.check,
                color: Colors.white,
                size: 16,
              ),
          ],
        ),
      ),
    );
  }
}

