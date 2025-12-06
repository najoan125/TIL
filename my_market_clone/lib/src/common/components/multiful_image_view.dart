import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';

class MultifulImageView extends StatefulWidget {
  final int maxCount;
  final List<AssetEntity>? initialSelection;

  const MultifulImageView({
    super.key,
    this.maxCount = 10,
    this.initialSelection,
  });

  @override
  State<MultifulImageView> createState() => _MultifulImageViewState();
}

class _MultifulImageViewState extends State<MultifulImageView> {
  List<AssetEntity> _images = [];
  final List<AssetEntity> _selectedImages = [];
  final Map<String, Uint8List> _thumbnailCache = {};
  bool _isLoading = true;
  bool _hasPermission = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialSelection != null) {
      _selectedImages.addAll(widget.initialSelection!);
    }
    _loadImages();
  }

  Future<void> _loadImages() async {
    final PermissionState permission =
        await PhotoManager.requestPermissionExtend();

    if (!permission.isAuth) {
      setState(() {
        _hasPermission = false;
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _hasPermission = true;
    });

    // 최근 이미지 앨범 가져오기
    final List<AssetPathEntity> albums = await PhotoManager.getAssetPathList(
      type: RequestType.image,
      filterOption: FilterOptionGroup(
        imageOption: const FilterOption(
          sizeConstraint: SizeConstraint(ignoreSize: true),
        ),
        orders: [
          const OrderOption(type: OrderOptionType.createDate, asc: false),
        ],
      ),
    );

    if (albums.isNotEmpty) {
      // 첫 번째 앨범(최근 항목)에서 이미지 가져오기
      final List<AssetEntity> images = await albums.first.getAssetListRange(
        start: 0,
        end: 100,
      );

      setState(() {
        _images = images;
        _isLoading = false;
      });

      // 썸네일 미리 로드 (백그라운드)
      _preloadThumbnails(images);
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _preloadThumbnails(List<AssetEntity> images) async {
    for (final image in images) {
      if (!_thumbnailCache.containsKey(image.id)) {
        final bytes = await image.thumbnailDataWithSize(
          const ThumbnailSize(300, 300),
        );
        if (bytes != null && mounted) {
          _thumbnailCache[image.id] = bytes;
          // 첫 번째 배치(화면에 보이는 부분)는 setState로 업데이트
          if (_thumbnailCache.length <= 12) {
            setState(() {});
          }
        }
      }
    }
  }

  void _toggleSelection(AssetEntity image) {
    setState(() {
      if (_selectedImages.contains(image)) {
        _selectedImages.remove(image);
      } else {
        if (_selectedImages.length < widget.maxCount) {
          _selectedImages.add(image);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('최대 ${widget.maxCount}장까지 선택할 수 있습니다.')),
          );
        }
      }
    });
  }

  int _getSelectionIndex(AssetEntity image) {
    final index = _selectedImages.indexOf(image);
    return index == -1 ? -1 : index + 1;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff212123),
      appBar: AppBar(
        backgroundColor: const Color(0xff212123),
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.close, color: Colors.white),
        ),
        title: const Text(
          '최근 항목',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Colors.white,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _selectedImages.isEmpty
                ? null
                : () => Navigator.of(context).pop(_selectedImages),
            child: Text(
              '완료',
              style: TextStyle(
                color: _selectedImages.isEmpty
                    ? Colors.white38
                    : const Color(0xffFF6F0F),
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: Colors.white24, height: 1),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xffFF6F0F)),
      );
    }

    if (!_hasPermission) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.photo_library, color: Colors.white54, size: 64),
            const SizedBox(height: 16),
            const Text(
              '사진 접근 권한이 필요합니다',
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => PhotoManager.openSetting(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xffFF6F0F),
              ),
              child: const Text(
                '설정으로 이동',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      );
    }

    if (_images.isEmpty) {
      return const Center(
        child: Text(
          '이미지가 없습니다',
          style: TextStyle(color: Colors.white70, fontSize: 16),
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(2),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 2,
        mainAxisSpacing: 2,
      ),
      itemCount: _images.length,
      itemBuilder: (context, index) {
        final image = _images[index];
        final selectionIndex = _getSelectionIndex(image);
        final isSelected = selectionIndex != -1;

        return GestureDetector(
          onTap: () => _toggleSelection(image),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // 이미지 썸네일 (캐시 사용)
              _ImageThumbnail(
                image: image,
                cache: _thumbnailCache,
              ),
              // 선택 오버레이
              if (isSelected)
                Container(
                  color: Colors.black.withValues(alpha: 0.3),
                ),
              // 선택 인디케이터
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected
                        ? const Color(0xffFF6F0F)
                        : Colors.transparent,
                    border: Border.all(
                      color: isSelected ? const Color(0xffFF6F0F) : Colors.white,
                      width: 2,
                    ),
                  ),
                  child: isSelected
                      ? Center(
                          child: Text(
                            '$selectionIndex',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                      : null,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// 별도의 StatefulWidget으로 분리하여 개별 이미지만 다시 빌드되도록 함
class _ImageThumbnail extends StatefulWidget {
  final AssetEntity image;
  final Map<String, Uint8List> cache;

  const _ImageThumbnail({
    required this.image,
    required this.cache,
  });

  @override
  State<_ImageThumbnail> createState() => _ImageThumbnailState();
}

class _ImageThumbnailState extends State<_ImageThumbnail> {
  Uint8List? _bytes;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadThumbnail();
  }

  Future<void> _loadThumbnail() async {
    // 캐시에서 먼저 확인
    if (widget.cache.containsKey(widget.image.id)) {
      setState(() {
        _bytes = widget.cache[widget.image.id];
        _isLoading = false;
      });
      return;
    }

    // 캐시에 없으면 로드
    final bytes = await widget.image.thumbnailDataWithSize(
      const ThumbnailSize(300, 300),
    );

    if (bytes != null && mounted) {
      widget.cache[widget.image.id] = bytes;
      setState(() {
        _bytes = bytes;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading || _bytes == null) {
      return Container(color: const Color(0xff2a2a2c));
    }

    return Image.memory(
      _bytes!,
      fit: BoxFit.cover,
      gaplessPlayback: true, // 이미지 전환 시 깜빡임 방지
    );
  }
}
