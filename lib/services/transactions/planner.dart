import 'package:kitchenowl/models/recipe.dart';
import 'package:kitchenowl/services/api/api_service.dart';
import 'package:kitchenowl/services/storage/temp_storage.dart';
import 'package:kitchenowl/services/transaction.dart';

class TransactionPlannerGetPlannedRecipes extends Transaction<List<Recipe>> {
  TransactionPlannerGetPlannedRecipes({DateTime? timestamp})
      : super.internal(
            timestamp ?? DateTime.now(), "TransactionPlannerGetPlannedRecipes");

  @override
  Future<List<Recipe>> runLocal() async {
    final recipes = await TempStorage.getInstance().readRecipes() ?? const [];
    recipes.retainWhere((e) => e.isPlanned);
    return recipes;
  }

  @override
  Future<List<Recipe>> runOnline() async {
    return await ApiService.getInstance().getPlannedRecipes() ?? const [];
  }
}

class TransactionPlannerGetRecentPlannedRecipes
    extends Transaction<List<Recipe>> {
  TransactionPlannerGetRecentPlannedRecipes({DateTime? timestamp})
      : super.internal(timestamp ?? DateTime.now(),
            "TransactionPlannerGetRecentPlannedRecipes");

  @override
  Future<List<Recipe>> runLocal() async {
    return [];
  }

  @override
  Future<List<Recipe>> runOnline() async {
    return await ApiService.getInstance().getRecentPlannedRecipes() ?? const [];
  }
}

class TransactionPlannerGetSuggestedRecipes extends Transaction<List<Recipe>> {
  TransactionPlannerGetSuggestedRecipes({DateTime? timestamp})
      : super.internal(timestamp ?? DateTime.now(),
            "TransactionPlannerGetSuggestedRecipes");

  @override
  Future<List<Recipe>> runLocal() async {
    return const [];
  }

  @override
  Future<List<Recipe>> runOnline() async {
    return await ApiService.getInstance().getSuggestedRecipes() ?? const [];
  }
}

class TransactionPlannerAddRecipe extends Transaction<bool> {
  final Recipe recipe;

  TransactionPlannerAddRecipe({required this.recipe, DateTime? timestamp})
      : super.internal(
            timestamp ?? DateTime.now(), "TransactionPlannerAddRecipe");

  factory TransactionPlannerAddRecipe.fromJson(
          Map<String, dynamic> map, DateTime timestamp) =>
      TransactionPlannerAddRecipe(
        recipe: Recipe.fromJson(map['recipe']),
        timestamp: timestamp,
      );

  @override
  bool get saveTransaction => true;

  @override
  Map<String, dynamic> toJson() => super.toJson()
    ..addAll({
      "recipe": recipe.toJsonWithId(),
    });

  @override
  Future<bool> runLocal() async {
    return true;
  }

  @override
  Future<bool> runOnline() {
    return ApiService.getInstance().addPlannedRecipe(recipe);
  }
}

class TransactionPlannerRemoveRecipe extends Transaction<bool> {
  final Recipe recipe;

  TransactionPlannerRemoveRecipe({required this.recipe, DateTime? timestamp})
      : super.internal(
            timestamp ?? DateTime.now(), "TransactionPlannerRemoveRecipe");

  factory TransactionPlannerRemoveRecipe.fromJson(
          Map<String, dynamic> map, DateTime timestamp) =>
      TransactionPlannerRemoveRecipe(
        recipe: Recipe.fromJson(map['recipe']),
        timestamp: timestamp,
      );

  @override
  bool get saveTransaction => true;

  @override
  Map<String, dynamic> toJson() => super.toJson()
    ..addAll({
      "recipe": recipe.toJsonWithId(),
    });

  @override
  Future<bool> runLocal() async {
    return true;
  }

  @override
  Future<bool> runOnline() {
    return ApiService.getInstance().removePlannedRecipe(recipe);
  }
}

class TransactionPlannerRefreshSuggestedRecipes
    extends Transaction<List<Recipe>> {
  TransactionPlannerRefreshSuggestedRecipes({DateTime? timestamp})
      : super.internal(timestamp ?? DateTime.now(),
            "TransactionPlannerRefreshSuggestedRecipes");

  @override
  Future<List<Recipe>> runLocal() async {
    return const [];
  }

  @override
  Future<List<Recipe>> runOnline() async {
    return await ApiService.getInstance().refreshSuggestedRecipes() ?? const [];
  }
}