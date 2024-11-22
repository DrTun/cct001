enum RegisterStatus { ACTIVE, INACTIVE, ERROR }

class RegisterItem {
  final String? id;
  final String license;
  final String description;
  final DateTime? createdDate;
  final DateTime? modifiedDate;
  final RegisterStatus? status;
  final bool? active;

  RegisterItem({
    this.id,
    required this.license,
    required this.description,
    this.createdDate,
    this.modifiedDate,
    this.status,
    this.active,
  });

  static RegisterStatus _parseStatus(String status) {
    switch (status) {
      case 'ACTIVE':
        return RegisterStatus.ACTIVE;
      case 'INACTIVE':
        return RegisterStatus.INACTIVE;
      default:
        return RegisterStatus.ERROR;
    }
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> data = <String, dynamic>{};
    data["id"] = id;
    data["license"] = license;
    data["description"] = description;
    data['active'] = active;
    return data;
  }

  factory RegisterItem.fromJson(Map<String, dynamic> json) {
    return RegisterItem(
      id: json['id'] ?? '',
      license: json['license'] ?? '',
      description: json['description'] ?? '',
      createdDate: json['createdDate'] != null
          ? DateTime.parse(json['createdDate'])
          : null,
      modifiedDate: json['modifiedDate'] != null
          ? DateTime.parse(json['modifiedDate'])
          : null,
      status: _parseStatus(json['status'] ?? 'error'),
    );
  }
}
