import 'package:get/get.dart';
import 'package:my_market_clone/src/models/product.dart';

class ProductController extends GetxController {
  final RxList<Product> _products = <Product>[].obs;

  List<Product> get products => _products;

  int _nextId = 100; // 새로 등록되는 상품의 ID 시작값

  @override
  void onInit() {
    super.onInit();
    _loadInitialProducts();
  }

  void _loadInitialProducts() {
    _products.addAll([
      Product(
        id: 1,
        name: '아이폰 14 Pro 256GB',
        price: '1,200,000원',
        location: '청운효자동',
        timeAgo: '2시간 전',
        imageUrl: 'assets/images/iphone.jpg',
        chatCount: 5,
        likeCount: 12,
        status: ProductStatus.selling,
      ),
      Product(
        id: 2,
        name: '맥북 프로 M2 2022',
        price: '2,800,000원',
        location: '청운효자동',
        timeAgo: '4시간 전',
        imageUrl: 'assets/images/macbook.jpg',
        chatCount: 3,
        likeCount: 8,
        status: ProductStatus.reserved,
      ),
      Product(
        id: 3,
        name: '에어팟 프로 2세대',
        price: '380,000원',
        location: '청운효자동',
        timeAgo: '6시간 전',
        imageUrl: 'assets/images/airpods.jpg',
        chatCount: 7,
        likeCount: 15,
        status: ProductStatus.selling,
      ),
      Product(
        id: 4,
        name: '스탠드 책장 (우드)',
        price: '85,000원',
        location: '청운효자동',
        timeAgo: '1일 전',
        imageUrl: 'assets/images/bookshelf.jpg',
        chatCount: 2,
        likeCount: 4,
        status: ProductStatus.sold,
      ),
      Product(
        id: 5,
        name: 'LG 27인치 모니터',
        price: '250,000원',
        location: '청운효자동',
        timeAgo: '1일 전',
        imageUrl: 'assets/images/monitor.jpg',
        chatCount: 4,
        likeCount: 6,
        status: ProductStatus.reserved,
      ),
      Product(
        id: 6,
        name: '무선 키보드 & 마우스',
        price: '65,000원',
        location: '청운효자동',
        timeAgo: '2일 전',
        imageUrl: 'assets/images/keyboard.jpg',
        chatCount: 1,
        likeCount: 3,
        status: ProductStatus.selling,
      ),
      Product(
        id: 7,
        name: '캠핑 텐트 (4인용)',
        price: '180,000원',
        location: '청운효자동',
        timeAgo: '2일 전',
        imageUrl: 'assets/images/tent.jpg',
        chatCount: 6,
        likeCount: 10,
        status: ProductStatus.selling,
      ),
      Product(
        id: 8,
        name: '산악자전거',
        price: '450,000원',
        location: '청운효자동',
        timeAgo: '3일 전',
        imageUrl: 'assets/images/bicycle.jpg',
        chatCount: 2,
        likeCount: 5,
        status: ProductStatus.sold,
      ),
      Product(
        id: 9,
        name: '외국도서 5권 세트',
        price: '45,000원',
        location: '청운효자동',
        timeAgo: '3일 전',
        imageUrl: 'assets/images/books.jpg',
        chatCount: 3,
        likeCount: 7,
        status: ProductStatus.selling,
      ),
      Product(
        id: 10,
        name: 'GoPro Hero 11',
        price: '520,000원',
        location: '청운효자동',
        timeAgo: '4일 전',
        imageUrl: 'assets/images/gopro.jpg',
        chatCount: 8,
        likeCount: 14,
        status: ProductStatus.reserved,
      ),
    ]);
  }

  void addProduct(Product product) {
    // 새 상품을 맨 앞에 추가
    _products.insert(0, product);
  }

  int getNextId() {
    return _nextId++;
  }
}
