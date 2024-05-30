// map_model.dart
class MapModel {
  MapModel({
    required this.id,
    required this.house_no,
    required this.road_name,
    required this.postcode,
    required this.area_name,
    required this.region,
    required this.latitude,
    required this.longitude,
    required this.district,
  });

  late final int id;
  late final String house_no;
  late final String road_name;
  late final dynamic postcode; // Using dynamic to handle both int and String
  late final String area_name;
  late final String region;
  late final String district;
  late final double latitude;
  late final double longitude;

  MapModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    house_no = json['house_no'];
    road_name = json['road_name'];
    postcode = json['postcode']; // Assuming postcode can be either int or string
    area_name = json['area_name'];
    region = json['region'];
    district = json['district'];
    latitude = json['latitude'] is String
        ? double.parse(json['latitude'])
        : json['latitude'].toDouble();
    longitude = json['longitude'] is String
        ? double.parse(json['longitude'])
        : json['longitude'].toDouble();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['house_no'] = house_no;
    data['road_name'] = road_name;
    data['postcode'] = postcode;
    data['area_name'] = area_name;
    data['region'] = region;
    data['latitude'] = latitude;
    data['longitude'] = longitude;
    data['district'] = district;
    return data;
  }
}
