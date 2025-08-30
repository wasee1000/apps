import 'package:flutter/material.dart';

class QualitySelector extends StatelessWidget {
  final String currentQuality;
  final Function(String) onQualitySelected;
  final VoidCallback onClose;

  const QualitySelector({
    Key? key,
    required this.currentQuality,
    required this.onQualitySelected,
    required this.onClose,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // List of available qualities
    final qualities = [
      'Auto',
      '1080p',
      '720p',
      '480p',
      '360p',
      '240p',
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
                    'Quality',
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
            
            // Quality options
            for (final quality in qualities)
              _buildQualityOption(quality),
          ],
        ),
      ),
    );
  }

  Widget _buildQualityOption(String quality) {
    final isSelected = quality == currentQuality;
    
    return InkWell(
      onTap: () => onQualitySelected(quality),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        color: isSelected ? Colors.grey.withOpacity(0.3) : Colors.transparent,
        child: Row(
          children: [
            Text(
              quality,
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

