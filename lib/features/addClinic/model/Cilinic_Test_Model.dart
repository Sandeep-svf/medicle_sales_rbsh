/// _id : "680741ffb31d1dc2dd693159"
/// firmName : "XYZ Chemists"
/// contactPersonName : "Jane Doe"
/// mobileNo : "9876543210"
/// emailId : "jane@xyzchemists.com"
/// gstNo : "27AAACA1234B1Z2"
/// address : "456, Park Street, Delhi"
/// yearsInBusiness : 3
/// annualTurnover : 5000000
/// createdAt : "2025-04-22T07:15:11.261Z"
/// __v : 0

class CilinicTestModel {
  CilinicTestModel({
      String? id, 
      String? firmName, 
      String? contactPersonName, 
      String? mobileNo, 
      String? emailId, 
      String? gstNo, 
      String? address, 
      num? yearsInBusiness, 
      num? annualTurnover, 
      String? createdAt, 
      num? v,}){
    _id = id;
    _firmName = firmName;
    _contactPersonName = contactPersonName;
    _mobileNo = mobileNo;
    _emailId = emailId;
    _gstNo = gstNo;
    _address = address;
    _yearsInBusiness = yearsInBusiness;
    _annualTurnover = annualTurnover;
    _createdAt = createdAt;
    _v = v;
}

  CilinicTestModel.fromJson(dynamic json) {
    _id = json['_id'];
    _firmName = json['firmName'];
    _contactPersonName = json['contactPersonName'];
    _mobileNo = json['mobileNo'];
    _emailId = json['emailId'];
    _gstNo = json['gstNo'];
    _address = json['address'];
    _yearsInBusiness = json['yearsInBusiness'];
    _annualTurnover = json['annualTurnover'];
    _createdAt = json['createdAt'];
    _v = json['__v'];
  }
  String? _id;
  String? _firmName;
  String? _contactPersonName;
  String? _mobileNo;
  String? _emailId;
  String? _gstNo;
  String? _address;
  num? _yearsInBusiness;
  num? _annualTurnover;
  String? _createdAt;
  num? _v;
CilinicTestModel copyWith({  String? id,
  String? firmName,
  String? contactPersonName,
  String? mobileNo,
  String? emailId,
  String? gstNo,
  String? address,
  num? yearsInBusiness,
  num? annualTurnover,
  String? createdAt,
  num? v,
}) => CilinicTestModel(  id: id ?? _id,
  firmName: firmName ?? _firmName,
  contactPersonName: contactPersonName ?? _contactPersonName,
  mobileNo: mobileNo ?? _mobileNo,
  emailId: emailId ?? _emailId,
  gstNo: gstNo ?? _gstNo,
  address: address ?? _address,
  yearsInBusiness: yearsInBusiness ?? _yearsInBusiness,
  annualTurnover: annualTurnover ?? _annualTurnover,
  createdAt: createdAt ?? _createdAt,
  v: v ?? _v,
);
  String? get id => _id;
  String? get firmName => _firmName;
  String? get contactPersonName => _contactPersonName;
  String? get mobileNo => _mobileNo;
  String? get emailId => _emailId;
  String? get gstNo => _gstNo;
  String? get address => _address;
  num? get yearsInBusiness => _yearsInBusiness;
  num? get annualTurnover => _annualTurnover;
  String? get createdAt => _createdAt;
  num? get v => _v;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['_id'] = _id;
    map['firmName'] = _firmName;
    map['contactPersonName'] = _contactPersonName;
    map['mobileNo'] = _mobileNo;
    map['emailId'] = _emailId;
    map['gstNo'] = _gstNo;
    map['address'] = _address;
    map['yearsInBusiness'] = _yearsInBusiness;
    map['annualTurnover'] = _annualTurnover;
    map['createdAt'] = _createdAt;
    map['__v'] = _v;
    return map;
  }

}