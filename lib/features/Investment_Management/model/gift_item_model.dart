class GiftItem {
  String itemName;
  int quantity;
  double value;

  GiftItem({
    required this.itemName,
    required this.quantity,
    required this.value,
  });

  Map<String, dynamic> toJson() {
    return {
      "itemName": itemName,
      "quantity": quantity,
      "value": value,
    };
  }
}