class SalesListModel {
  String? sId;
  String? doctorName;
  String? salesRep;
  String? callNotes;
  Null? user;
  String? userName;
  String? dateTime;
  String? createdAt;
  String? updatedAt;
  int? iV;

  SalesListModel(
      {this.sId,
        this.doctorName,
        this.salesRep,
        this.callNotes,
        this.user,
        this.userName,
        this.dateTime,
        this.createdAt,
        this.updatedAt,
        this.iV});

  SalesListModel.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    doctorName = json['doctorName'];
    salesRep = json['salesRep'];
    callNotes = json['callNotes'];
    user = json['user'];
    userName = json['userName'];
    dateTime = json['dateTime'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['doctorName'] = this.doctorName;
    data['salesRep'] = this.salesRep;
    data['callNotes'] = this.callNotes;
    data['user'] = this.user;
    data['userName'] = this.userName;
    data['dateTime'] = this.dateTime;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    data['__v'] = this.iV;
    return data;
  }
}