class VnPayRequestDto {
  final String vnpOrderInfo;
  final String invoiceCode;
  final int price;
  final String ipClient;

  VnPayRequestDto({
    required this.vnpOrderInfo,
    required this.invoiceCode,
    required this.price,
    required this.ipClient,
  });

  Map<String, dynamic> toJson() {
    return {
      'vnp_OrderInfo': vnpOrderInfo,
      'invoiceCode': invoiceCode,
      'price': price,
      'ipClient': ipClient,
    };
  }

  factory VnPayRequestDto.fromJson(Map<String, dynamic> json) {
    return VnPayRequestDto(
      vnpOrderInfo: json['vnp_OrderInfo'],
      invoiceCode: json['invoiceCode'],
      price: json['price'],
      ipClient: json['ipClient'],
    );
  }
}
