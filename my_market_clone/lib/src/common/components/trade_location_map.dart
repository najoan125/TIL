import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

// 거래 장소 데이터 클래스
class TradeLocation {
  final LatLng position;
  final String name;

  TradeLocation({required this.position, required this.name});
}

class TradeLocationMap extends StatefulWidget {
  final TradeLocation? initialLocation;

  const TradeLocationMap({
    super.key,
    this.initialLocation,
  });

  @override
  State<TradeLocationMap> createState() => _TradeLocationMapState();
}

class _TradeLocationMapState extends State<TradeLocationMap> {
  final MapController _mapController = MapController();
  LatLng _selectedPosition = const LatLng(37.5665, 126.9780); // 서울 기본 위치
  LatLng? _myLocation;
  bool _isLoading = true;
  double _currentZoom = 15.0;
  bool _showLocationLabel = false; // 기존 장소명 라벨 표시 여부
  String? _currentAddress; // 현재 마커 위치 주소
  bool _isLoadingAddress = false;

  @override
  void initState() {
    super.initState();
    _initializeLocation();
  }

  // 역지오코딩으로 주소 가져오기
  Future<void> _fetchAddress(LatLng position) async {
    setState(() => _isLoadingAddress = true);

    try {
      final url = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse?format=json&lat=${position.latitude}&lon=${position.longitude}&accept-language=ko',
      );

      final response = await http.get(
        url,
        headers: {'User-Agent': 'my_market_clone/1.0'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final address = data['display_name'] as String?;

        if (mounted) {
          setState(() {
            _currentAddress = _formatAddress(address);
            _isLoadingAddress = false;
          });
        }
      } else {
        if (mounted) {
          setState(() => _isLoadingAddress = false);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingAddress = false);
      }
    }
  }

  // 주소 포맷팅 (너무 긴 주소 간략화)
  String? _formatAddress(String? fullAddress) {
    if (fullAddress == null) return null;

    // 쉼표로 구분된 주소에서 앞부분만 추출 (도로명 + 동네)
    final parts = fullAddress.split(', ');
    if (parts.length > 3) {
      // 첫 3개 부분만 사용 (예: 도로명, 동, 구)
      return parts.take(3).join(', ');
    }
    return fullAddress;
  }

  Future<void> _initializeLocation() async {
    // 기존 위치가 있으면 그 위치로 초기화
    if (widget.initialLocation != null) {
      setState(() {
        _selectedPosition = widget.initialLocation!.position;
        _showLocationLabel = true; // 기존 장소명 라벨 표시
        _isLoading = false;
      });
      _fetchAddress(_selectedPosition); // 초기 주소 조회
      _getCurrentLocationInBackground();
      return;
    }

    // 기존 위치가 없으면 현재 위치로 초기화
    await _getCurrentLocation();
  }

  Future<void> _getCurrentLocationInBackground() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return;
      }

      if (permission == LocationPermission.deniedForever) return;

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _myLocation = LatLng(position.latitude, position.longitude);
      });
    } catch (e) {
      // 위치 가져오기 실패해도 무시
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() => _isLoading = false);
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() => _isLoading = false);
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() => _isLoading = false);
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _selectedPosition = LatLng(position.latitude, position.longitude);
        _myLocation = _selectedPosition;
        _isLoading = false;
      });
      _fetchAddress(_selectedPosition); // 초기 주소 조회
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _onConfirmLocation() {
    _showLocationNameDialog();
  }

  void _showLocationNameDialog() {
    final TextEditingController nameController = TextEditingController(
      text: widget.initialLocation?.name ?? '',
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xff212123),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            '장소명 입력',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: TextField(
            controller: nameController,
            autofocus: true,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: '예: 스타벅스 강남역점 앞',
              hintStyle: const TextStyle(color: Colors.white54),
              filled: true,
              fillColor: const Color(0xff2a2a2c),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                '취소',
                style: TextStyle(color: Colors.white54),
              ),
            ),
            TextButton(
              onPressed: () {
                if (nameController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('장소명을 입력해주세요.')),
                  );
                  return;
                }

                final location = TradeLocation(
                  position: _selectedPosition,
                  name: nameController.text.trim(),
                );

                Navigator.pop(context); // 다이얼로그 닫기
                Navigator.pop(context, location); // 결과 반환
              },
              child: const Text(
                '등록',
                style: TextStyle(
                  color: Color(0xffFF6F0F),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _moveToMyLocation() {
    if (_myLocation != null) {
      _mapController.move(_myLocation!, _currentZoom);
    } else {
      _getCurrentLocation().then((_) {
        if (_myLocation != null) {
          _mapController.move(_myLocation!, _currentZoom);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff212123),
      appBar: AppBar(
        backgroundColor: const Color(0xff212123),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: Colors.white),
        ),
        title: const Text(
          '거래 희망 장소',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Colors.white,
          ),
        ),
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: Colors.white24, height: 1),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xffFF6F0F)),
            )
          : Stack(
              children: [
                // 지도
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: _selectedPosition,
                    initialZoom: _currentZoom,
                    onPositionChanged: (position, hasGesture) {
                      if (position.center != null) {
                        setState(() {
                          _selectedPosition = position.center!;
                          // 지도를 움직이면 라벨 숨김
                          if (hasGesture && _showLocationLabel) {
                            _showLocationLabel = false;
                          }
                        });
                      }
                      if (position.zoom != null) {
                        _currentZoom = position.zoom!;
                      }
                    },
                    // 지도 이동이 끝났을 때 주소 조회
                    onMapEvent: (event) {
                      if (event is MapEventMoveEnd) {
                        _fetchAddress(_selectedPosition);
                      }
                    },
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.my_market_clone',
                    ),
                    // 내 위치 마커 (파란색)
                    if (_myLocation != null)
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: _myLocation!,
                            width: 20,
                            height: 20,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.blue,
                                shape: BoxShape.circle,
                                border:
                                    Border.all(color: Colors.white, width: 3),
                              ),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
                // 중앙 고정 마커
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 40),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // 장소명 라벨 (기존 위치가 있고 아직 이동 안했을 때)
                        if (_showLocationLabel &&
                            widget.initialLocation != null)
                          Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xff212123),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  blurRadius: 8,
                                  color: Colors.black.withValues(alpha: 0.3),
                                ),
                              ],
                            ),
                            child: Text(
                              widget.initialLocation!.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        Icon(
                          Icons.location_on,
                          color: const Color(0xffFF6F0F),
                          size: 50,
                          shadows: [
                            Shadow(
                              blurRadius: 10,
                              color: Colors.black.withValues(alpha: 0.3),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                // 안내 메시지
                Positioned(
                  top: 16,
                  left: 16,
                  right: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xff212123).withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      '지도를 움직여 거래 희망 장소를 선택하세요',
                      style: TextStyle(color: Colors.white, fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                // 현재 위치로 이동 버튼
                Positioned(
                  bottom: 16,
                  right: 16,
                  child: FloatingActionButton.small(
                    heroTag: 'myLocation',
                    backgroundColor: const Color(0xff212123),
                    onPressed: _moveToMyLocation,
                    child: const Icon(Icons.my_location, color: Colors.white),
                  ),
                ),
              ],
            ),
      // 주소 표시 및 선택 완료 버튼
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Color(0xff212123),
          border: Border(top: BorderSide(color: Color(0xff3C3C3E))),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 주소 표시 영역
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: const Color(0xff2a2a2c),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      color: Color(0xffFF6F0F),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _isLoadingAddress
                          ? const Text(
                              '주소를 불러오는 중...',
                              style: TextStyle(
                                color: Colors.white54,
                                fontSize: 14,
                              ),
                            )
                          : Text(
                              _currentAddress ?? '주소를 불러올 수 없습니다',
                              style: TextStyle(
                                color: _currentAddress != null
                                    ? Colors.white
                                    : Colors.white54,
                                fontSize: 14,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                    ),
                  ],
                ),
              ),
              // 선택 완료 버튼
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _onConfirmLocation,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xffFF6F0F),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    '선택 완료',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
