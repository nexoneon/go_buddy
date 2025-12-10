import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:ui_web' as ui_web;

/// A widget that displays network images on web using HTML img element
/// This bypasses Flutter's Image.network CORS issues on web
class WebImage extends StatefulWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget Function(BuildContext, Object, StackTrace?)? errorBuilder;
  final Widget Function(BuildContext)? loadingBuilder;

  const WebImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.errorBuilder,
    this.loadingBuilder,
  });

  @override
  State<WebImage> createState() => _WebImageState();
}

class _WebImageState extends State<WebImage> {
  late String _viewId;
  bool _isLoading = true;
  bool _hasError = false;
  Object? _error;

  @override
  void initState() {
    super.initState();
    _viewId =
        'web-image-${widget.imageUrl.hashCode}-${DateTime.now().millisecondsSinceEpoch}';
    _registerView();
  }

  @override
  void didUpdateWidget(WebImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imageUrl != widget.imageUrl) {
      _viewId =
          'web-image-${widget.imageUrl.hashCode}-${DateTime.now().millisecondsSinceEpoch}';
      _isLoading = true;
      _hasError = false;
      _error = null;
      _registerView();
    }
  }

  void _registerView() {
    // Register the view factory
    ui_web.platformViewRegistry.registerViewFactory(_viewId, (int viewId) {
      final img = html.ImageElement()
        ..src = widget.imageUrl
        ..style.width = '100%'
        ..style.height = '100%'
        ..style.objectFit = _getObjectFit(widget.fit)
        ..crossOrigin = 'anonymous';

      img.onLoad.listen((_) {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _hasError = false;
          });
        }
      });

      img.onError.listen((event) {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _hasError = true;
            _error = Exception('Failed to load image');
          });
        }
      });

      return img;
    });
  }

  String _getObjectFit(BoxFit fit) {
    switch (fit) {
      case BoxFit.contain:
        return 'contain';
      case BoxFit.cover:
        return 'cover';
      case BoxFit.fill:
        return 'fill';
      case BoxFit.fitWidth:
        return 'scale-down';
      case BoxFit.fitHeight:
        return 'scale-down';
      case BoxFit.none:
        return 'none';
      case BoxFit.scaleDown:
        return 'scale-down';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError && widget.errorBuilder != null) {
      return widget.errorBuilder!(context, _error!, null);
    }

    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: Stack(
        children: [
          HtmlElementView(viewType: _viewId),
          if (_isLoading && widget.loadingBuilder != null)
            widget.loadingBuilder!(context),
          if (_isLoading && widget.loadingBuilder == null)
            const Center(child: CircularProgressIndicator(strokeWidth: 2)),
        ],
      ),
    );
  }
}

/// A cross-platform network image widget
/// Uses WebImage on web and Image.network on mobile/desktop
class CrossPlatformNetworkImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget Function(BuildContext, Object, StackTrace?)? errorBuilder;
  final Widget Function(BuildContext, Widget, ImageChunkEvent?)? loadingBuilder;

  const CrossPlatformNetworkImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.errorBuilder,
    this.loadingBuilder,
  });

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return WebImage(
        imageUrl: imageUrl,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: errorBuilder,
        loadingBuilder: loadingBuilder != null
            ? (ctx) => loadingBuilder!(ctx, const SizedBox.shrink(), null)
            : null,
      );
    }

    return Image.network(
      imageUrl,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: errorBuilder,
      loadingBuilder: loadingBuilder,
    );
  }
}
