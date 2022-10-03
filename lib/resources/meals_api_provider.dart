import 'dart:async';
import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:themealdb/model/list_category.dart';
import '../model/item_model.dart';

class MealsApiProvider {
  final Dio client = Dio();

  final String _baseUrl = 'https://www.themealdb.com/api/json/v1/1';

  Future<ItemModel> fetchMeals(String type) async {
    Response response;
    response = await client.get("$_baseUrl/filter.php?c=$type");
    if (response.statusCode == 200) {
      return ItemModel.fromJson(response.data);
    } else {
      throw Exception('Failed to load list meals');
    }
  }

  Future<ListCategory> fetchCategory() async{
    Response response;
    response = await client.get("$_baseUrl/categories.php");
    if (response.statusCode == 200) {
      return ListCategory.fromJson(response.data);
    } else {
      throw Exception('Failed to load list meals');
    }
  }

  Future<ItemModel> fetchDetail(String id) async {
    Response response;
    response = await client.get("$_baseUrl/lookup.php?i=$id");
    if (response.statusCode == 200) {
      log(response.data.toString());
      return ItemModel.fromJson(response.data);
    } else {
      throw Exception('Failed to load detail meals');
    }
  }

  Future<ItemModel> searchMeals(String name) async {
    final response = await client.get("$_baseUrl/search.php?s=$name");
    if (response.statusCode == 200) {
      return ItemModel.fromJson(response.data);
    } else {
      throw Exception('Failed to load $name meals');
    }
  }
}
