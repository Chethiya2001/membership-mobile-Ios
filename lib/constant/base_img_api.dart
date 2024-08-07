class ApiConstantsProfileImage {
  static const String baseUrlProfile =
      'https://s3.us-east-2.amazonaws.com/classitree.sg/uploads/user/profile-image/';

  static String getProfileImageUrl(String imageName) {
    return '$baseUrlProfile$imageName';
  }
}

class ApiConstantsCoverImage {
  static const String baseUrlCover =
      'https://s3.us-east-2.amazonaws.com/classitree.sg/uploads/user/cover-photo/';

  static String getCoverImageUrl(String imageName) {
    return '$baseUrlCover$imageName';
  }
}

class ApiConstantsBlogImage {
  static const String baseUrlblog =
      'https://s3.us-east-2.amazonaws.com/classitree.sg/uploads/blog/thumbnail/';

  static String getCoverImageUrl(String imageName) {
    return '$baseUrlblog$imageName';
  }
}



