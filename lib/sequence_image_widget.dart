import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class SequenceImageWidget extends StatefulWidget {
  final int start;
  final int end;
  final UrlBuilder urlBuilder;
  final OnController? onController;
  final Duration? duration;

  const SequenceImageWidget({
    Key? key,
    required this.start,
    required this.end,
    required this.urlBuilder,
    this.onController,
    this.duration,
  }) : super(key: key);

  @override
  State<SequenceImageWidget> createState() => _SequenceImageWidgetState();
}

typedef OnController = void Function(AnimationController controller);
typedef UrlBuilder = String Function(int index);

class _SequenceImageWidgetState extends State<SequenceImageWidget>
    with TickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<int> _animation;
  ImageProvider? _placeholder;

  @override
  void initState() {
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration ?? const Duration(seconds: 1),
    );
    _animation = IntTween(
      begin: widget.start,
      end: widget.end,
    ).animate(_controller);
    widget.onController?.call(_controller);

    for (int i = widget.start; i <= widget.end; i++) {
      DefaultCacheManager().getImageFile(widget.urlBuilder(i));
    }
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      builder: (BuildContext context, Widget? child) => CachedNetworkImage(
        imageUrl: widget.urlBuilder(_animation.value),
        imageBuilder: (context, imageProvider) {
          _placeholder = imageProvider;
          return Image(image: imageProvider);
        },
        placeholder: (context, url) => Stack(
          children: [
            if (_placeholder != null) Image(image: _placeholder!),
          ],
        ),
        errorWidget: (context, url, error) => const Icon(Icons.error),
      ),
      animation: _animation,
    );
  }
}
