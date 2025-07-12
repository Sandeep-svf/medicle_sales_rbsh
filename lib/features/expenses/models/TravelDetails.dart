class TravelDetail {
  final String from;
  final String to;
  final double km;

  TravelDetail({
    required this.from,
    required this.to,
    required this.km,
  });

  factory TravelDetail.fromJson(Map<String, dynamic> json) {
    return TravelDetail(
      from: json['from'],
      to: json['to'],
      km: (json['km'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
    'from': from,
    'to': to,
    'km': km,
  };
}
