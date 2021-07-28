import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kitchenowl/models/recipe.dart';
import 'package:kitchenowl/services/api/api_service.dart';

class RecipeListCubit extends Cubit<ListRecipeCubitState> {
  List<Recipe> shoppinglist = [];

  RecipeListCubit() : super(ListRecipeCubitState([])) {
    refresh();
  }

  String get query => (state != null && state is SearchRecipeCubitState)
      ? (state as SearchRecipeCubitState).query
      : "";

  Future<void> search(String query) {
    return refresh(query);
  }

  Future<void> refresh([String query]) async {
    if (state is SearchRecipeCubitState)
      query = query ?? (state as SearchRecipeCubitState).query;
    if (query != null && query.isNotEmpty) {
      final items = (await ApiService.getInstance().searchRecipe(query)) ?? [];
      emit(SearchRecipeCubitState(query, items));
    } else {
      this.shoppinglist = await ApiService.getInstance().getRecipes();
      emit(ListRecipeCubitState(shoppinglist));
    }
  }
}

class ListRecipeCubitState extends Equatable {
  final List<Recipe> recipes;

  ListRecipeCubitState(this.recipes);

  @override
  List<Object> get props => recipes;
}

class SearchRecipeCubitState extends ListRecipeCubitState {
  final String query;

  SearchRecipeCubitState(this.query, List<Recipe> recipes) : super(recipes);

  @override
  List<Object> get props => super.props + recipes;
}
