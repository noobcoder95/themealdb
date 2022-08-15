class ItemModel {
  late List<Meals> meals;

  ItemModel({required this.meals});

  ItemModel.fromJson(Map<String, dynamic> json) {
    if (json['meals'] != null) {
      meals = [];
      json['meals'].forEach((v) {
        meals.add(Meals.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.meals != null) {
      data['meals'] = this.meals.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Meals {
  String idMeal = '';
  String strMeal = '';
  String strMealThumb = '';
  String type = '';
  String? strCategory;
  String? strArea;
  String? strYoutube;
  String? strInstructions;
  List<String> strIngredients = [];
  List<String> strMeasures = [];


  Meals({
    required this.idMeal,
    required this.strMeal,
    required this.strMealThumb,
    required this.type,
    required this.strIngredients,
    required this.strMeasures,
    this.strCategory,
    this.strArea,
    this.strYoutube,
    this.strInstructions
  });

  Meals.fromJson(Map<String, dynamic> json) {

    for(int i = 1; i < 20; i++)
    {
      if(json['strIngredient$i'] != null && json['strIngredient$i'].toString().isNotEmpty)
      {
        strIngredients.add(json['strIngredient$i']);
      }
      if(json['strMeasure$i'] != null && json['strMeasure$i'].toString().isNotEmpty)
      {
        strMeasures.add(json['strMeasure$i']);
      }
    }

    idMeal = json['idMeal'];
    strMeal = json['strMeal'];
    strCategory = json['strCategory'];
    strArea = json['strArea'];
    strYoutube = json['strYoutube'];
    strInstructions = json['strInstructions'];
    strMealThumb = json['strMealThumb'];
    type = json['type'] ?? '';
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();

    for(int i = 1; i < 20; i++)
    {
      if(data['strIngredient$i'] != null && data['strIngredient$i'].toString().isNotEmpty)
      {
        this.strIngredients.add(data['strIngredient$i']);
      }
      if(data['strMeasure$i'] != null && data['strMeasure$i'].toString().isNotEmpty)
      {
        this.strMeasures.add(data['strMeasure$i']);
      }
    }

    data['idMeal'] = this.idMeal;
    data['strMeal'] = this.strMeal;
    data['strCategory'] = this.strCategory;
    data['strArea'] = this.strArea;
    data['strYoutube'] = this.strYoutube;
    data['strInstructions'] = this.strInstructions;
    data['strMealThumb'] = this.strMealThumb;
    data['type'] = this.type;
    return data;
  }
}
