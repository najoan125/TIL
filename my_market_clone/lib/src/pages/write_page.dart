import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:photo_manager/photo_manager.dart';
import 'dart:typed_data';

import 'package:my_market_clone/src/common/components/app_font.dart';
import 'package:my_market_clone/src/common/components/multiful_image_view.dart';
import 'package:my_market_clone/src/common/components/trade_location_map.dart';
import 'package:my_market_clone/src/controllers/product_controller.dart';
import 'package:my_market_clone/src/models/product.dart';

class WritePage extends StatefulWidget {
  const WritePage({super.key});

  @override
  State<WritePage> createState() => _WritePageState();
}

class _WritePageState extends State<WritePage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  bool _isPriceSuggestionEnabled = false;
  String? _selectedCategory;
  TradeLocation? _selectedLocation;
  final List<AssetEntity> _selectedImages = [];
  final Map<String, Uint8List> _imageBytes = {};
  static const int _maxImages = 10;

  final List<String> _categories = [
    '디지털기기',
    '생활가전',
    '가구/인테리어',
    '유아동',
    '생활/가공식품',
    '유아도서',
    '스포츠/레저',
    '여성잡화',
    '여성의류',
    '남성패션/잡화',
    '게임/취미',
    '뷰티/미용',
    '반려동물용품',
    '도서/티켓/음반',
    '식물',
    '기타 중고물품',
  ];

  // 폼 유효성 검사
  bool get _isFormValid {
    final hasImages = _selectedImages.isNotEmpty;
    final hasTitle = _titleController.text.trim().isNotEmpty;
    // 나눔이거나 가격이 입력되어 있으면 유효
    final hasPrice =
        _isPriceSuggestionEnabled || _priceController.text.trim().isNotEmpty;
    return hasImages && hasTitle && hasPrice;
  }

  @override
  void initState() {
    super.initState();
    // 텍스트 변경 시 버튼 상태 업데이트
    _titleController.addListener(_onFormChanged);
    _priceController.addListener(_onFormChanged);
  }

  void _onFormChanged() {
    setState(() {});
  }

  Future<void> _submitProduct() async {
    final productController = Get.find<ProductController>();

    // 첫 번째 이미지의 바이트 데이터 가져오기
    Uint8List? imageBytes;
    if (_selectedImages.isNotEmpty) {
      final firstImage = _selectedImages.first;
      // 캐시에서 가져오거나 새로 로드
      imageBytes = _imageBytes[firstImage.id] ??
          await firstImage.thumbnailDataWithSize(
            const ThumbnailSize(200, 200),
          );
    }

    // 가격 포맷팅
    String priceText;
    if (_isPriceSuggestionEnabled) {
      priceText = '나눔';
    } else {
      final price = _priceController.text.trim();
      priceText = '${_formatPrice(price)}원';
    }

    // 새 상품 생성
    final newProduct = Product(
      id: productController.getNextId(),
      name: _titleController.text.trim(),
      price: priceText,
      location: _selectedLocation?.name ?? '청운효자동',
      timeAgo: '방금 전',
      imageBytes: imageBytes,
      category: _selectedCategory,
      description: _descriptionController.text.trim(),
    );

    // 컨트롤러에 상품 추가
    productController.addProduct(newProduct);

    // 화면 닫기
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  // 가격에 천 단위 콤마 추가
  String _formatPrice(String price) {
    if (price.isEmpty) return '0';
    final number = int.tryParse(price.replaceAll(',', '')) ?? 0;
    return number.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
  }

  @override
  void dispose() {
    _titleController.removeListener(_onFormChanged);
    _priceController.removeListener(_onFormChanged);
    _titleController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    final result = await Navigator.of(context).push<List<AssetEntity>>(
      MaterialPageRoute(
        builder: (context) => MultifulImageView(
          maxCount: _maxImages,
          initialSelection: _selectedImages,
        ),
      ),
    );

    if (result != null && result.isNotEmpty) {
      // 이미지 바이트 데이터 미리 로드
      for (final image in result) {
        if (!_imageBytes.containsKey(image.id)) {
          final bytes = await image.thumbnailDataWithSize(
            const ThumbnailSize(200, 200),
          );
          if (bytes != null) {
            _imageBytes[image.id] = bytes;
          }
        }
      }

      setState(() {
        _selectedImages.clear();
        _selectedImages.addAll(result);
      });
    }
  }

  void _removeImage(int index) {
    setState(() {
      final id = _selectedImages[index].id;
      _imageBytes.remove(id);
      _selectedImages.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: const Icon(Icons.close, color: Colors.white),
        ),
        title: const Text(
          '내 물건 팔기',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Colors.white,
          ),
        ),
        elevation: 0,
        backgroundColor: const Color(0xff212123),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: Colors.white24, height: 1),
        ),
      ),
      body: Column(
        children: [
          // 자식 위젯이 남은 공간을 차지하도록 확장
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image Picker Section
                  SizedBox(
                    height: 88,
                    child: Row(
                      children: [
                        // Fixed add button
                        _buildImageAddButton(),
                        const SizedBox(width: 8),
                        // Scrollable image list
                        Expanded(
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: _selectedImages.length,
                            itemBuilder: (context, index) =>
                                _buildImageThumbnail(index),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Title Input
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xff2a2a2c),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        hintText: '제목',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        hintStyle: TextStyle(color: Colors.white54),
                      ),
                      style: const TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Category Dropdown
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xff2a2a2c),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                      ),
                      title: Text(
                        _selectedCategory ?? '카테고리 선택',
                        style: TextStyle(
                          color: _selectedCategory == null
                              ? Colors.white54
                              : Colors.white,
                          fontSize: 16,
                        ),
                      ),
                      trailing: const Icon(
                        Icons.chevron_right,
                        color: Colors.white,
                      ),
                      onTap: _showCategorySheet,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Price Input
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xff2a2a2c),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _priceController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              hintText: _isPriceSuggestionEnabled
                                  ? '₩ 0'
                                  : '₩ 가격 (선택사항)',
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 12,
                              ),
                              hintStyle: const TextStyle(color: Colors.white54),
                            ),
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                            ),
                            onChanged: (value) {
                              // 가격 입력 시 나눔 체크 해제
                              if (value.isNotEmpty &&
                                  _isPriceSuggestionEnabled) {
                                setState(() {
                                  _isPriceSuggestionEnabled = false;
                                });
                              }
                            },
                          ),
                        ),
                        // Price Suggestion Checkbox
                        Row(
                          children: [
                            SizedBox(
                              height: 24,
                              width: 24,
                              child: Checkbox(
                                value: _isPriceSuggestionEnabled,
                                onChanged: (value) {
                                  setState(() {
                                    _isPriceSuggestionEnabled = value ?? false;
                                    // 나눔 체크 시 가격 초기화
                                    if (_isPriceSuggestionEnabled) {
                                      _priceController.clear();
                                    }
                                  });
                                },
                                activeColor: const Color(0xffFF6F0F),
                                checkColor: Colors.white,
                                side: const BorderSide(color: Colors.white54),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              '나눔',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Description Input
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xff2a2a2c),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextField(
                      controller: _descriptionController,
                      maxLines: 6,
                      decoration: const InputDecoration(
                        hintText:
                            '청운효자동에 올릴 게시물 내용을 작성해주세요.\n(판매 금지 물품은 게시가 제한될 수 있어요.)',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(16),
                        hintStyle: TextStyle(color: Colors.white54),
                      ),
                      style: const TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Location Selection
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xff2a2a2c),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                      ),
                      leading: Icon(
                        Icons.location_on_outlined,
                        color: _selectedLocation != null
                            ? const Color(0xffFF6F0F)
                            : Colors.white54,
                      ),
                      title: Text(
                        _selectedLocation?.name ?? '거래 희망 장소',
                        style: TextStyle(
                          color: _selectedLocation == null
                              ? Colors.white54
                              : Colors.white,
                          fontSize: 16,
                        ),
                      ),
                      trailing: _selectedLocation != null
                          ? GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedLocation = null;
                                });
                              },
                              child: const Icon(
                                Icons.close,
                                color: Colors.white54,
                                size: 20,
                              ),
                            )
                          : const Icon(
                              Icons.chevron_right,
                              color: Colors.white,
                            ),
                      onTap: _openLocationMap,
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
          // Complete Button
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isFormValid ? _submitProduct : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xffFF6F0F),
                  disabledBackgroundColor: const Color(0xff3C3C3E),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  '완료',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: _isFormValid ? Colors.white : Colors.white38,
                  ),
                ),
              ),
            ),
          ),

          // 하단 키보드 툴박스
          Container(
            height: 40,
            padding: const EdgeInsets.symmetric(
              horizontal: 30,
            ), // 좌우 방향으로 같은 값의 여백
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: Color(0xff3C3C3E))),
            ), // 테두리 한쪽 정의(top에만 테두리 정의)
            child: Row(
              // 주축 정렬. Row이므로 왼쪽이 start
              // spaceBetween은 첫번째와 마지막 children이 양 끝에, 나머지는 균등 간격
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    SvgPicture.asset('assets/svg/icons/photo_small.svg'),
                    // const 컴파일 타임 상수(미리 메모리에 올려두고 재사용), 성능 최적화, 불변성 보장
                    const SizedBox(width: 10),
                    // 미리 만들어둔 AppFont 클래스(common/components)
                    AppFont('${_selectedImages.length}/10', size: 13, color: Colors.white),
                  ],
                ),
                GestureDetector(
                  onTap: FocusScope.of(context).unfocus,
                  behavior: HitTestBehavior.translucent,
                  child: SvgPicture.asset('assets/svg/icons/keyboard-down.svg'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageAddButton() {
    return GestureDetector(
      onTap: _pickImages,
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white24),
          borderRadius: BorderRadius.circular(8),
          color: const Color(0xff2a2a2c),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.camera_alt, color: Colors.white54, size: 28),
            const SizedBox(height: 4),
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: '${_selectedImages.length}',
                    style: const TextStyle(
                      color: Color(0xffFF6F0F),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const TextSpan(
                    text: '/10',
                    style: TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageWidget(int index) {
    final id = _selectedImages[index].id;
    final bytes = _imageBytes[id];

    if (bytes != null) {
      return Image.memory(
        bytes,
        width: 80,
        height: 80,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildErrorPlaceholder();
        },
      );
    }

    // 바이트 데이터가 없으면 FutureBuilder로 로드
    return FutureBuilder<Uint8List?>(
      future: _selectedImages[index].thumbnailDataWithSize(
        const ThumbnailSize(200, 200),
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done &&
            snapshot.data != null) {
          // 캐시에 저장
          _imageBytes[id] = snapshot.data!;
          return Image.memory(
            snapshot.data!,
            width: 80,
            height: 80,
            fit: BoxFit.cover,
          );
        }
        return _buildErrorPlaceholder();
      },
    );
  }

  Widget _buildErrorPlaceholder() {
    return Container(
      color: const Color(0xff2a2a2c),
      child: const Icon(Icons.broken_image, color: Colors.white54),
    );
  }

  Widget _buildImageThumbnail(int index) {
    return Padding(
      padding: const EdgeInsets.only(right: 8, top: 4),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              width: 80,
              height: 80,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _buildImageWidget(index),
                  if (index == 0)
                    Align(
                      alignment: Alignment.bottomLeft,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: const BoxDecoration(
                          color: Color(0xffFF6F0F),
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(8),
                            topRight: Radius.circular(8),
                          ),
                        ),
                        child: const Text(
                          '대표',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          Positioned(
            top: -4,
            right: -4,
            child: GestureDetector(
              onTap: () => _removeImage(index),
              child: Container(
                width: 20,
                height: 20,
                decoration: const BoxDecoration(
                  color: Colors.black87,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, color: Colors.white, size: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showCategorySheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return _CategorySheet(
          categories: _categories,
          onSelected: (category) {
            setState(() {
              _selectedCategory = category;
            });
          },
        );
      },
    );
  }

  Future<void> _openLocationMap() async {
    final result = await Navigator.push<TradeLocation>(
      context,
      MaterialPageRoute(
        builder: (context) => TradeLocationMap(
          initialLocation: _selectedLocation,
        ),
      ),
    );

    if (result != null) {
      setState(() {
        _selectedLocation = result;
      });
    }
  }
}

// 카테고리 선택 바텀시트 (드래그로 확장 가능)
class _CategorySheet extends StatefulWidget {
  final List<String> categories;
  final Function(String) onSelected;

  const _CategorySheet({required this.categories, required this.onSelected});

  @override
  State<_CategorySheet> createState() => _CategorySheetState();
}

class _CategorySheetState extends State<_CategorySheet> {
  double _sheetHeight = 0.5; // 초기 높이 (화면의 50%)
  final double _minHeight = 0.3;
  final double _maxHeight = 0.9;

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 100),
      height: screenHeight * _sheetHeight,
      decoration: const BoxDecoration(
        color: Color(0xff212123),
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        children: [
          // 드래그 핸들
          GestureDetector(
            onVerticalDragUpdate: (details) {
              setState(() {
                _sheetHeight -= details.primaryDelta! / screenHeight;
                _sheetHeight = _sheetHeight.clamp(_minHeight, _maxHeight);
              });
            },
            onVerticalDragEnd: (details) {
              // 아래로 빠르게 스와이프하면 닫기
              if (details.primaryVelocity != null &&
                  details.primaryVelocity! > 500) {
                Navigator.pop(context);
                return;
              }

              // 최소 높이에 가까우면 닫기
              if (_sheetHeight <= 0.35) {
                Navigator.pop(context);
                return;
              }

              // 스냅: 중간 지점 기준으로 50% 또는 90%로
              setState(() {
                if (_sheetHeight > 0.7) {
                  _sheetHeight = _maxHeight;
                } else {
                  _sheetHeight = 0.5;
                }
              });
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              color: Colors.transparent,
              child: Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
          ),
          const Text(
            '카테고리 선택',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          // 리스트는 독립적으로 스크롤
          Expanded(
            child: ListView.builder(
              itemCount: widget.categories.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(
                    widget.categories[index],
                    style: const TextStyle(color: Colors.white),
                  ),
                  onTap: () {
                    widget.onSelected(widget.categories[index]);
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
