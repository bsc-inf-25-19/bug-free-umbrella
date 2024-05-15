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
  late final int postcode;
  late final String area_name;
  late final String region;
  late final String district;
  late final double latitude;
  late final double longitude;

  MapModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    house_no = json['house_no'];
    road_name = json['road_name'];
    postcode = json['postcode'];
    area_name = json['area_name'];
    region = json['region'];
    latitude = json['latitude'];
    longitude = json['longitude'];
    district = json['district'];
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
