

class ExtrasModel {
  String tripID;
  String name;
  String subTotal;
  String amount;
  String  qty;
  String type;

  ExtrasModel({
    required this.tripID,
    required this.name,
    required this.subTotal,
    required this.amount,
    required this.qty,
    required this.type,
  });

  factory ExtrasModel.fromJson(Map<String, dynamic> json) {
    return ExtrasModel(
      tripID: json['trip_id'],
      name: json['name'],
      subTotal: json['sub_total'],
      amount: json['amount'],
      qty: json['qty'],
      type: json['type'],
    );
  }

    factory ExtrasModel.fromMap(Map<String, dynamic> map) {
    return ExtrasModel(
      tripID: map['trip_id'] ?? "",
      name: map['name'] ?? "",
      subTotal: map['sub_total'],
      amount: map['amount'],
      qty: map['qty'],
      type: map['type'],

    );
  }

  Map<String, dynamic> toJson() {
    return {
      'trip_id': tripID,
      'name':name,
      'sub_total':subTotal,
      'amount':amount,
      'qty':qty,
      'type':type,
    };
  }
}
