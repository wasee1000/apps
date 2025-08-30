import 'dart:async';
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// A utility class for optimizing app performance.
class PerformanceOptimizer {
  static final PerformanceOptimizer _instance = PerformanceOptimizer._internal();
  
  factory PerformanceOptimizer() => _instance;
  
  PerformanceOptimizer._internal();
  
  bool _isInitialized = false;
  bool _isMonitoringFrames = false;
  Timer? _memoryTimer;
  
  /// Initialize the performance optimizer.
  void initialize() {
    if (_isInitialized) return;
    
    // Enable debug flags in debug mode
    if (kDebugMode) {
      // Enable rendering debug flags
      debugPaintSizeEnabled = false;
      debugPaintBaselinesEnabled = false;
      debugPaintLayerBordersEnabled = false;
      debugPaintPointersEnabled = false;
      debugRepaintRainbowEnabled = false;
      
      // Enable widget debug flags
      debugPrintRebuildDirtyWidgets = false;
      debugPrintBuildScope = false;
      debugPrintScheduleBuildForStacks = false;
      
      // Start monitoring memory usage
      _startMemoryMonitoring();
    }
    
    _isInitialized = true;
  }
  
  /// Start monitoring frame build times.
  void startFrameMonitoring() {
    if (_isMonitoringFrames) return;
    
    // Start monitoring frame build times
    developer.Timeline.startSync('Frame Monitoring');
    _isMonitoringFrames = true;
  }
  
  /// Stop monitoring frame build times.
  void stopFrameMonitoring() {
    if (!_isMonitoringFrames) return;
    
    // Stop monitoring frame build times
    developer.Timeline.finishSync();
    _isMonitoringFrames = false;
  }
  
  /// Start monitoring memory usage.
  void _startMemoryMonitoring() {
    _memoryTimer?.cancel();
    _memoryTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      _logMemoryUsage();
    });
  }
  
  /// Log current memory usage.
  void _logMemoryUsage() {
    if (kDebugMode) {
      developer.log(
        'Memory Usage',
        name: 'PerformanceOptimizer',
        error: '${(WidgetsBinding.instance.runtimeType)}',
      );
    }
  }
  
  /// Dispose the performance optimizer.
  void dispose() {
    stopFrameMonitoring();
    _memoryTimer?.cancel();
    _memoryTimer = null;
  }
  
  /// Optimize image loading and caching.
  static Widget optimizedImage({
    required String imageUrl,
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
    Widget? placeholder,
    Widget? errorWidget,
  }) {
    return Image.network(
      imageUrl,
      width: width,
      height: height,
      fit: fit,
      cacheWidth: width != null ? (width * 2).toInt() : null,
      cacheHeight: height != null ? (height * 2).toInt() : null,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) {
          return child;
        }
        return placeholder ?? Center(
          child: CircularProgressIndicator(
            value: loadingProgress.expectedTotalBytes != null
                ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                : null,
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        return errorWidget ?? Container(
          width: width,
          height: height,
          color: Colors.grey.shade300,
          child: const Center(
            child: Icon(
              Icons.error_outline,
              color: Colors.red,
            ),
          ),
        );
      },
    );
  }
  
  /// Optimize list view by using lazy loading.
  static Widget optimizedListView<T>({
    required List<T> items,
    required Widget Function(BuildContext, int) itemBuilder,
    bool shrinkWrap = false,
    ScrollPhysics? physics,
    EdgeInsetsGeometry? padding,
    ScrollController? controller,
    Widget? separatorBuilder,
    Widget? emptyWidget,
    String? semanticLabel,
  }) {
    if (items.isEmpty) {
      return emptyWidget ?? const SizedBox.shrink();
    }
    
    return Semantics(
      label: semanticLabel,
      child: separatorBuilder != null
          ? ListView.separated(
              controller: controller,
              shrinkWrap: shrinkWrap,
              physics: physics,
              padding: padding,
              itemCount: items.length,
              itemBuilder: itemBuilder,
              separatorBuilder: (context, index) => separatorBuilder,
            )
          : ListView.builder(
              controller: controller,
              shrinkWrap: shrinkWrap,
              physics: physics,
              padding: padding,
              itemCount: items.length,
              itemBuilder: itemBuilder,
            ),
    );
  }
  
  /// Optimize grid view by using lazy loading.
  static Widget optimizedGridView<T>({
    required List<T> items,
    required Widget Function(BuildContext, int) itemBuilder,
    required SliverGridDelegate gridDelegate,
    bool shrinkWrap = false,
    ScrollPhysics? physics,
    EdgeInsetsGeometry? padding,
    ScrollController? controller,
    Widget? emptyWidget,
    String? semanticLabel,
  }) {
    if (items.isEmpty) {
      return emptyWidget ?? const SizedBox.shrink();
    }
    
    return Semantics(
      label: semanticLabel,
      child: GridView.builder(
        controller: controller,
        shrinkWrap: shrinkWrap,
        physics: physics,
        padding: padding,
        gridDelegate: gridDelegate,
        itemCount: items.length,
        itemBuilder: itemBuilder,
      ),
    );
  }
  
  /// Optimize page view by using lazy loading.
  static Widget optimizedPageView<T>({
    required List<T> items,
    required Widget Function(BuildContext, int) itemBuilder,
    bool shrinkWrap = false,
    ScrollPhysics? physics,
    PageController? controller,
    Widget? emptyWidget,
    String? semanticLabel,
    Axis scrollDirection = Axis.horizontal,
    bool pageSnapping = true,
  }) {
    if (items.isEmpty) {
      return emptyWidget ?? const SizedBox.shrink();
    }
    
    return Semantics(
      label: semanticLabel,
      child: PageView.builder(
        controller: controller,
        physics: physics,
        scrollDirection: scrollDirection,
        pageSnapping: pageSnapping,
        itemCount: items.length,
        itemBuilder: itemBuilder,
      ),
    );
  }
  
  /// Optimize widget rebuilds by using const constructors.
  static Widget optimizedBuilder({
    required Widget Function(BuildContext) builder,
    List<Object>? dependencies,
  }) {
    if (dependencies == null || dependencies.isEmpty) {
      return Builder(builder: builder);
    }
    
    return _OptimizedBuilder(
      builder: builder,
      dependencies: dependencies,
    );
  }
}

/// A widget that rebuilds only when its dependencies change.
class _OptimizedBuilder extends StatefulWidget {
  final Widget Function(BuildContext) builder;
  final List<Object> dependencies;
  
  const _OptimizedBuilder({
    Key? key,
    required this.builder,
    required this.dependencies,
  }) : super(key: key);
  
  @override
  _OptimizedBuilderState createState() => _OptimizedBuilderState();
}

class _OptimizedBuilderState extends State<_OptimizedBuilder> {
  late Widget _child;
  
  @override
  void initState() {
    super.initState();
    _child = widget.builder(context);
  }
  
  @override
  void didUpdateWidget(_OptimizedBuilder oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    bool shouldRebuild = widget.dependencies.length != oldWidget.dependencies.length;
    
    if (!shouldRebuild) {
      for (int i = 0; i < widget.dependencies.length; i++) {
        if (widget.dependencies[i] != oldWidget.dependencies[i]) {
          shouldRebuild = true;
          break;
        }
      }
    }
    
    if (shouldRebuild) {
      _child = widget.builder(context);
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return _child;
  }
}

