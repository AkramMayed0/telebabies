class OrderCustomer {
  final String nameAr;
  final String nameEn;
  final String phone;
  final String cityAr;
  final String cityEn;

  const OrderCustomer({
    required this.nameAr,
    required this.nameEn,
    required this.phone,
    required this.cityAr,
    required this.cityEn,
  });

  String name(String lang) => lang == 'ar' ? nameAr : nameEn;
  String city(String lang) => lang == 'ar' ? cityAr : cityEn;
}

class OrderItem {
  final String productId;
  final int qty;
  const OrderItem({required this.productId, required this.qty});
}

class Order {
  final String id;
  final String date;
  final String status;
  final int total;
  final List<OrderItem> items;
  final String payment;
  final bool receipt;
  final OrderCustomer? customer;

  const Order({
    required this.id,
    required this.date,
    required this.status,
    required this.total,
    required this.items,
    required this.payment,
    this.receipt = false,
    this.customer,
  });
}

class OrderStatus {
  final String ar;
  final String en;
  final int color;
  final int ink;

  const OrderStatus({
    required this.ar,
    required this.en,
    required this.color,
    required this.ink,
  });

  String label(String lang) => lang == 'ar' ? ar : en;
}
