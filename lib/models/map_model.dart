class MapModel {
  final int id;
  final String house_no;
  final String road_name;
  final String postcode;
  final String area_name;
  final String region;
  final String district;
  final double latitude;
  final double longitude;

  MapModel({
    required this.id,
    required this.house_no,
    required this.road_name,
    required this.postcode,
    required this.area_name,
    required this.region,
    required this.district,
    required this.latitude,
    required this.longitude,
  });

  factory MapModel.fromJson(Map<String, dynamic> json) {
    return MapModel(
      id: json['id'],
      house_no: json['house_no'].toString(),
      road_name: json['road_name']?.toString() ?? '',
      area_name: json['area_name']?.toString() ?? '',
      region: json['region']?.toString() ?? '',
      postcode: json['postcode']?.toString() ?? '',
      district: json['district']?.toString() ?? '',
      latitude: json['latitude'] is String
          ? double.parse(json['latitude'])
          : json['latitude'].toDouble(),
      longitude: json['longitude'] is String
          ? double.parse(json['longitude'])
          : json['longitude'].toDouble(),
    );
  }

  String toFullAddress() {
    return '$house_no, $road_name, $area_name, $district, $region';
  }
}
