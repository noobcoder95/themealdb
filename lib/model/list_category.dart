import 'package:themealdb/model/categories_model.dart';

class ListCategory {
  ListCategory({
      this.categories,});

  ListCategory.fromJson(dynamic json) {
    if (json['categories'] != null) {
      categories = [];
      json['categories'].forEach((v) {
        categories?.add(CategoriesModel.fromJson(v));
      });
    }
  }
  List<CategoriesModel>? categories;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (categories != null) {
      map['categories'] = categories?.map((v) => v.toJson()).toList();
    }
    return map;
  }

}