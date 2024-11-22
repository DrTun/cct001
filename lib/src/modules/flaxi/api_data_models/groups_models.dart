
class GroupsModels {
  final int status;
  final String message;
  final List<Group>? dataList;

  GroupsModels({
    required this.status,
    required this.message,
    required this.dataList,
  });

  factory GroupsModels.fromJson(Map<String, dynamic> json) {
    return GroupsModels(
      status: json['status'],
      message: json['message'],
      dataList: json['dataList'] != null
          ? List<Group>.from(json['dataList'].map((x) => Group.fromJson(x)))
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['message'] = message;
    if (dataList != null) {
      data['dataList'] = dataList!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Group {
  final String syskey;
  final String id;
  final String name;
  final int isAdmin;
  final String balance;
  final int type;
  final int feeType;
  final String fee;
  final String notiAmount;
  final String restrictAmount;


  Group({
    required this.syskey,
    required this.id,
    required this.name,
    required this.isAdmin,
    required this.balance,
    required this.type,
    required this.feeType,
    required this.fee,
    required this.notiAmount,
    required this.restrictAmount
  });

  factory Group.fromJson(Map<String, dynamic> json) {
    return Group(
      syskey: json['syskey'],
      id: json['id'] ?? "",
      name: json['name'] ?? "",
      isAdmin: json['isadmin'] ?? 0,
      balance: json['balance'] ?? '0',
      type: json['type'] ?? 0,
      feeType: json['fee_type'] ?? 0,
      fee: json['fee'] ?? '0',
      notiAmount: json['noti_amount'] ?? '0',
      restrictAmount: json['restrict_amount'] ?? '0',
    );
  }
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['syskey'] = syskey;
    data['id'] = id;
    data['name'] = name;
    data['isadmin'] = isAdmin;
    data['balance'] = balance;
    data['type'] = type;
    data['fee_type'] = feeType;
    data['fee'] = fee;
    data['noti_amount'] = notiAmount;
    data['restrict_amount'] = restrictAmount;
    return data;
  }
}