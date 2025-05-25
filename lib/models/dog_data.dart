class Location {
  final String city;
  final String state;
  final String? postcode;

  Location({
    required this.city,
    required this.state,
    this.postcode,
  });

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      city: json['city'],
      state: json['state'],
      postcode: json['postcode'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'city': city,
      'state': state,
      if (postcode != null) 'postcode': postcode,
    };
  }
}

class DogData {
  final String id;
  final String name;
  final Location location;
  final String age;
  final String sex;
  final String breed;
  final String description;
  final String url;
  final String photo;
  final String croppedPhoto;
  final List<double>? dogEmbedding;
  final double? similarity;

  DogData({
    required this.id,
    required this.name,
    required this.location,
    required this.age,
    required this.sex,
    required this.breed,
    required this.description,
    required this.url,
    required this.photo,
    required this.croppedPhoto,
    this.dogEmbedding,
    this.similarity,
  });

  factory DogData.fromJson(Map<String, dynamic> json) {
    return DogData(
      id: json['id'],
      name: json['name'],
      location: Location.fromJson(json['location']),
      age: json['age'],
      sex: json['sex'],
      breed: json['breed'],
      description: json['description'],
      url: json['url'],
      photo: json['primary_photo'],
      croppedPhoto: json['primary_photo_cropped'],
      dogEmbedding: json['dog_embedding'] != null
          ? List<double>.from(json['dog_embedding'])
          : null,
      similarity: json['similarity'] != null
          ? (json['similarity'] as num).toDouble()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'location': location.toJson(),
      'age': age,
      'sex': sex,
      'breed': breed,
      'description': description,
      'url': url,
      'primary_photo': photo,
      'primary_photo_cropped': croppedPhoto,
      if (dogEmbedding != null) 'dogEmbedding': dogEmbedding,
      if (similarity != null) 'similarity': similarity,
    };
  }

  // String get imageSource => photo ?? 'assets/images/carousel/$imageName.jpg';
}
