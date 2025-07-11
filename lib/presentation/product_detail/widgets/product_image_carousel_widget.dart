import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ProductImageCarouselWidget extends StatefulWidget {
  final List<String> images;
  final int currentIndex;
  final Function(int) onImageChanged;

  const ProductImageCarouselWidget({
    super.key,
    required this.images,
    required this.currentIndex,
    required this.onImageChanged,
  });

  @override
  State<ProductImageCarouselWidget> createState() =>
      _ProductImageCarouselWidgetState();
}

class _ProductImageCarouselWidgetState
    extends State<ProductImageCarouselWidget> {
  late PageController _pageController;
  final TransformationController _transformationController =
      TransformationController();

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _transformationController.dispose();
    super.dispose();
  }

  void _onImageTap(String imageUrl) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => _FullScreenImageView(
          images: widget.images,
          initialIndex: widget.currentIndex,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40.h,
      width: double.infinity,
      child: Stack(
        children: [
          // Image Carousel
          PageView.builder(
            controller: _pageController,
            onPageChanged: widget.onImageChanged,
            itemCount: widget.images.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () => _onImageTap(widget.images[index]),
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 4.w),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: InteractiveViewer(
                      transformationController: _transformationController,
                      minScale: 1.0,
                      maxScale: 3.0,
                      child: CustomImageWidget(
                        imageUrl: widget.images[index],
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),

          // Image Indicators
          if (widget.images.length > 1)
            Positioned(
              bottom: 2.h,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  widget.images.length,
                  (index) => Container(
                    margin: EdgeInsets.symmetric(horizontal: 1.w),
                    width: widget.currentIndex == index ? 8.w : 2.w,
                    height: 1.h,
                    decoration: BoxDecoration(
                      color: widget.currentIndex == index
                          ? AppTheme.lightTheme.colorScheme.primary
                          : Colors.white.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
            ),

          // Zoom Reset Button
          Positioned(
            top: 2.h,
            right: 6.w,
            child: Container(
              padding: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: GestureDetector(
                onTap: () {
                  _transformationController.value = Matrix4.identity();
                },
                child: CustomIconWidget(
                  iconName: 'zoom_out_map',
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FullScreenImageView extends StatefulWidget {
  final List<String> images;
  final int initialIndex;

  const _FullScreenImageView({
    required this.images,
    required this.initialIndex,
  });

  @override
  State<_FullScreenImageView> createState() => _FullScreenImageViewState();
}

class _FullScreenImageViewState extends State<_FullScreenImageView> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: CustomIconWidget(
            iconName: 'close',
            color: Colors.white,
            size: 24,
          ),
        ),
        title: Text(
          '${_currentIndex + 1} of ${widget.images.length}',
          style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
            color: Colors.white,
          ),
        ),
      ),
      body: PageView.builder(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        itemCount: widget.images.length,
        itemBuilder: (context, index) {
          return InteractiveViewer(
            minScale: 1.0,
            maxScale: 5.0,
            child: Center(
              child: CustomImageWidget(
                imageUrl: widget.images[index],
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.contain,
              ),
            ),
          );
        },
      ),
    );
  }
}
