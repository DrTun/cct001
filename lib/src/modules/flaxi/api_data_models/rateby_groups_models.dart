class RatebyGroups{
  final int status;
  final String message;
  final List<Rate> dataList;

  RatebyGroups({
    required this.status,
    required this.message,
    required this.dataList
  });

  factory RatebyGroups.fromjson(Map<String , dynamic> json){
    return RatebyGroups(
      status    : json["status"], 
      message   : json["message"], 
      dataList  : List<Rate>.from(json["dataList"].map((x) =>Rate.fromjson(x))),   
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['message'] = message;
    data['dataList'] = dataList.map((v) => v.toJson()).toList();
    
    return data;
  }
}

class Rate{
  final String syskey;
  final String id;
  final String name;
  final String rate;
  final String initial;
  final int waitingTime;
  final String waitingCharge;
  final String symbol;
  final int type;
  final List<Extras>? extras;

  Rate({
    required this.syskey,
    required this.id,
    required this.name,
    required this.rate,
    required this.initial,
    required this.waitingTime,
    required this.waitingCharge,
    required this.symbol,
    required this.type,
    required this.extras
  });

  factory Rate.fromjson(Map<String , dynamic> json) {
    return Rate
    (
      syskey        : json["syskey"], 
      id            : json["id"], 
      name          : json["name"], 
      rate          : json["rate"],
      initial       : json["initial"], 
      waitingTime   : json["waitingtime"], 
      waitingCharge : json["waitingcharge"], 
      symbol        : json["symbol"], 
      type          : json["type"], 
      extras        : json["extras"] != null 
      ? List<Extras>.from(json["extras"].map((x) => Extras.fromJson(x)))
      : null,
    );
  }
  Map<String,dynamic> toJson() {
    final Map<String,dynamic> data = <String,dynamic>{};
    data['syskey'] = syskey;
    data['id'] = id;
    data['name'] = name;
    data['rate'] = rate;
    data['initial'] = initial;
    data['waitingtime'] = waitingTime;
    data['waitingcharge'] = waitingCharge;
    data['symbol'] = symbol;
    data['type'] = type;
    if(extras != null){
      data['extras'] = extras!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}


class Extras{
   String name;
   String amount;
   int type;

  Extras({
    required this.name,
    required this.amount,
    required this.type
  });

  factory Extras.fromJson(Map<String , dynamic> json) {
    return Extras(
      name  : json["name"], 
      amount: json["amount"],
      type: json["type"],
      );
  }

  Map<String,dynamic> toJson() {
    final Map<String,dynamic> data = <String,dynamic>{};
    data['name'] = name;
    data['amount'] = amount;
    data['type']=type;
    return data;
  }
}

class Extra {
  final String name;
  final String amount;
  int qty; 
  int subTotal;
  String type;

  Extra({
    required this.name,
    required this.amount,
    required this.type,
     this.qty = 0, 
     this.subTotal = 0,
  });
  factory Extra.fromExtras(Extras e) {
    return Extra(
      name: e.name,
      amount: e.amount.toString(), // Ensure type match
      type: e.type.toString(), // Same logic if 'type' differs
    );
  }

   factory Extra.fromJson(Map<String , dynamic> json) {
    return Extra(
      name  : json["name"], 
      amount: json["amount"],
      type: json["type"],
      qty : json["qty"] ?? 0 ,
      subTotal: json["subtotal"] ?? 0);
  }

    // Convert Extra instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'amount': amount,
      'qty': qty,
      'type':type,
      'subtotal': subTotal
    };
  }

}
