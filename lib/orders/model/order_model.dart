import 'package:cloud_firestore/cloud_firestore.dart';

class OrderModel {
  final String id;
  final String userId;
  final List<OrderItemModel> items;
  final OrderAddressModel address;
  final double subTotal;
  final double deliveryCharge;
  final double totalAmount;
  final String orderStatus;
  final String paymentStatus;
  final String paymentMethod;
  final String? razorpayOrderId;
  final String? razorpayPaymentId;
  final DateTime createdAt;

  const OrderModel({
    required this.id,
    required this.userId,
    required this.items,
    required this.address,
    required this.subTotal,
    required this.deliveryCharge,
    required this.totalAmount,
    required this.orderStatus,
    required this.paymentStatus,
    required this.paymentMethod,
    this.razorpayOrderId,
    this.razorpayPaymentId,
    required this.createdAt,
  });

  factory OrderModel.fromMap(
    String id,
    Map<String, dynamic> map,
  ) {
    final rawItems = map['items'];

    final items = rawItems is List
        ? rawItems
            .whereType<Map>()
            .map(
              (item) => OrderItemModel.fromMap(
                Map<String, dynamic>.from(item),
              ),
            )
            .toList()
        : <OrderItemModel>[];

    final rawAddress = map['address'];

    final address = rawAddress is Map
        ? OrderAddressModel.fromMap(
            Map<String, dynamic>.from(
              rawAddress,
            ),
          )
        : const OrderAddressModel(
            name: '',
            phone: '',
            house: '',
            street: '',
            city: '',
            state: '',
            pincode: '',
          );

    return OrderModel(
      id: id,
      userId: _parseString(
        map['userId'],
      ),
      items: items,
      address: address,
      subTotal: _parseDouble(
        map['subTotal'],
      ),
      deliveryCharge: _parseDouble(
        map['deliveryCharge'],
      ),
      totalAmount: _parseDouble(
        map['totalAmount'],
      ),
      orderStatus: _parseString(
        map['orderStatus'],
        defaultValue: 'pending',
      ),
      paymentStatus: _parseString(
        map['paymentStatus'],
        defaultValue: 'pending',
      ),
      paymentMethod: _parseString(
        map['paymentMethod'],
      ),
      razorpayOrderId: _parseNullableString(
        map['razorpayOrderId'],
      ),
      razorpayPaymentId: _parseNullableString(
        map['razorpayPaymentId'],
      ),
      createdAt: _parseDateTime(
        map['createdAt'],
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'items': items
          .map(
            (item) => item.toMap(),
          )
          .toList(),
      'address': address.toMap(),
      'subTotal': subTotal,
      'deliveryCharge': deliveryCharge,
      'totalAmount': totalAmount,
      'orderStatus': orderStatus,
      'paymentStatus': paymentStatus,
      'paymentMethod': paymentMethod,
      'razorpayOrderId': razorpayOrderId,
      'razorpayPaymentId': razorpayPaymentId,
      'createdAt': Timestamp.fromDate(
        createdAt,
      ),
    };
  }

  static String _parseString(
    dynamic value, {
    String defaultValue = '',
  }) {
    if (value is String) {
      return value;
    }

    return defaultValue;
  }

  static String? _parseNullableString(
    dynamic value,
  ) {
    if (value is! String) {
      return null;
    }

    final result = value.trim();

    return result.isEmpty ? null : result;
  }

  static double _parseDouble(
    dynamic value,
  ) {
    if (value is num) {
      return value.toDouble();
    }

    if (value is String) {
      return double.tryParse(value) ?? 0;
    }

    return 0;
  }

  static DateTime _parseDateTime(
    dynamic value,
  ) {
    if (value is Timestamp) {
      return value.toDate();
    }

    if (value is DateTime) {
      return value;
    }

    if (value is String) {
      return DateTime.tryParse(value) ??
          DateTime.now();
    }

    return DateTime.now();
  }
}

class OrderItemModel {
  final String productId;
  final String name;
  final String imageUrl;
  final double price;
  final int quantity;

  const OrderItemModel({
    required this.productId,
    required this.name,
    required this.imageUrl,
    required this.price,
    required this.quantity,
  });

  factory OrderItemModel.fromMap(
    Map<String, dynamic> map,
  ) {
    return OrderItemModel(
      productId: _parseString(
        map['productId'],
      ),
      name: _parseString(
        map['name'],
      ),
      imageUrl: _parseString(
        map['imageUrl'],
      ),
      price: _parseDouble(
        map['price'],
      ),
      quantity: _parseInt(
        map['quantity'],
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'name': name,
      'imageUrl': imageUrl,
      'price': price,
      'quantity': quantity,
    };
  }

  double get totalPrice =>
      price * quantity;

  static String _parseString(
    dynamic value,
  ) {
    return value is String ? value : '';
  }

  static double _parseDouble(
    dynamic value,
  ) {
    if (value is num) {
      return value.toDouble();
    }

    if (value is String) {
      return double.tryParse(value) ?? 0;
    }

    return 0;
  }

  static int _parseInt(
    dynamic value,
  ) {
    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    if (value is String) {
      return int.tryParse(value) ?? 0;
    }

    return 0;
  }
}

class OrderAddressModel {
  final String name;
  final String phone;
  final String house;
  final String street;
  final String city;
  final String state;
  final String pincode;

  const OrderAddressModel({
    required this.name,
    required this.phone,
    required this.house,
    required this.street,
    required this.city,
    required this.state,
    required this.pincode,
  });

  factory OrderAddressModel.fromMap(
    Map<String, dynamic> map,
  ) {
    return OrderAddressModel(
      name: _parseString(
        map['name'],
      ),
      phone: _parseString(
        map['phone'],
      ),
      house: _parseString(
        map['house'],
      ),
      street: _parseString(
        map['street'],
      ),
      city: _parseString(
        map['city'],
      ),
      state: _parseString(
        map['state'],
      ),
      pincode: _parseString(
        map['pincode'],
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'phone': phone,
      'house': house,
      'street': street,
      'city': city,
      'state': state,
      'pincode': pincode,
    };
  }

  static String _parseString(
    dynamic value,
  ) {
    return value is String ? value : '';
  }
}