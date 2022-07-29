import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:kitchenowl/cubits/planner_cubit.dart';
import 'package:kitchenowl/enums/update_enum.dart';
import 'package:kitchenowl/kitchenowl.dart';
import 'package:kitchenowl/models/item.dart';
import 'package:kitchenowl/models/recipe.dart';
import 'package:kitchenowl/pages/item_selection_page.dart';
import 'package:kitchenowl/pages/recipe_page.dart';
import 'package:kitchenowl/widgets/recipe_card.dart';
import 'package:responsive_builder/responsive_builder.dart';

class PlannerPage extends StatefulWidget {
  const PlannerPage({Key? key}) : super(key: key);

  @override
  _PlannerPageState createState() => _PlannerPageState();
}

class _PlannerPageState extends State<PlannerPage> {
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cubit = BlocProvider.of<PlannerCubit>(context);
    final int crossAxisCount = getValueForScreenType<int>(
      context: context,
      mobile: 3,
      tablet: 6,
      desktop: 9,
    );

    final weekdayMapping = {
      0: DateTime.monday,
      1: DateTime.tuesday,
      2: DateTime.wednesday,
      3: DateTime.thursday,
      4: DateTime.friday,
      5: DateTime.saturday,
      6: DateTime.sunday,
    };

    return SafeArea(
      child: Scrollbar(
        child: RefreshIndicator(
          onRefresh: cubit.refresh,
          child: BlocBuilder<PlannerCubit, PlannerCubitState>(
            bloc: cubit,
            builder: (context, state) => CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverToBoxAdapter(
                    child: Container(
                      height: 80,
                      alignment: Alignment.centerLeft,
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              AppLocalizations.of(context)!.plannerTitle,
                              style: Theme.of(context).textTheme.headline5,
                            ),
                          ),
                          if (state.plannedRecipes.isNotEmpty)
                            InkWell(
                              borderRadius: BorderRadius.circular(50),
                              child:
                                  const Icon(Icons.add_shopping_cart_rounded),
                              onTap: () =>
                                  _openItemSelectionPage(context, cubit),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
                if (state.plannedRecipes.isEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Icon(Icons.no_food_rounded),
                          const SizedBox(height: 16),
                          Text(AppLocalizations.of(context)!.plannerEmpty),
                        ],
                      ),
                    ),
                  ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverToBoxAdapter(
                    child: Wrap(
                      crossAxisAlignment: WrapCrossAlignment.end,
                      alignment: WrapAlignment.start,
                      children: [
                        for (final recipe in state.getPlannedWithoutDay())
                          KitchenOwlFractionallySizedBox(
                            widthFactor: (1 / crossAxisCount),
                            child: AspectRatio(
                              aspectRatio: 1,
                              child: SelectableButtonCard(
                                key: Key(recipe.name),
                                title: recipe.name,
                                selected: true,
                                onPressed: () {
                                  cubit.remove(recipe);
                                },
                                onLongPressed: () => _openRecipePage(
                                  context,
                                  cubit,
                                  recipe,
                                ),
                              ),
                            ),
                          ),
                        for (int day = 0; day < 7; day++)
                          for (final recipe in state.getPlannedOfDay(day))
                            KitchenOwlFractionallySizedBox(
                              widthFactor: (1 / crossAxisCount),
                              widthSubstract: (crossAxisCount - 1) * 4,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  if (recipe == state.getPlannedOfDay(day)[0])
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 8),
                                      child: Text(
                                        '${DateFormat.E().dateSymbols.STANDALONEWEEKDAYS[weekdayMapping[day]! % 7]}:',
                                        style: Theme.of(context)
                                            .textTheme
                                            .headline6,
                                      ),
                                    ),
                                  AspectRatio(
                                    aspectRatio: 1,
                                    child: SelectableButtonCard(
                                      key: Key(
                                        recipe.name,
                                      ),
                                      title: recipe.name,
                                      selected: true,
                                      onPressed: () {
                                        cubit.remove(
                                          recipe,
                                          day,
                                        );
                                      },
                                      onLongPressed: () => _openRecipePage(
                                        context,
                                        cubit,
                                        recipe,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                      ],
                    ),
                  ),
                ),
                if (state.recentRecipes.isNotEmpty) ...[
                  SliverPadding(
                    padding: const EdgeInsets.all(16),
                    sliver: SliverToBoxAdapter(
                      child: Text(
                        '${AppLocalizations.of(context)!.recipesRecent}:',
                        style: Theme.of(context).textTheme.headline6,
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: getValueForScreenType(
                        context: context,
                        mobile: 240,
                        tablet: 250,
                        desktop: 300,
                      ),
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemExtent: getValueForScreenType(
                          context: context,
                          mobile: 190,
                          tablet: 200,
                          desktop: 250,
                        ),
                        itemBuilder: (context, i) => RecipeCard(
                          recipe: state.recentRecipes[i],
                          onLongPressed: () {
                            cubit.add(state.recentRecipes[i]);
                          },
                          onPressed: () => _openRecipePage(
                            context,
                            cubit,
                            state.recentRecipes[i],
                          ),
                        ),
                        itemCount: state.recentRecipes.length,
                        scrollDirection: Axis.horizontal,
                      ),
                    ),
                  ),
                ],
                if (state.suggestedRecipes.isNotEmpty) ...[
                  SliverPadding(
                    padding: const EdgeInsets.all(16),
                    sliver: SliverToBoxAdapter(
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              '${AppLocalizations.of(context)!.recipesSuggested}:',
                              style: Theme.of(context).textTheme.headline6,
                            ),
                          ),
                          InkWell(
                            borderRadius: BorderRadius.circular(50),
                            onTap: cubit.refreshSuggestions,
                            child: const Icon(Icons.refresh),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: ListView.builder(
                      itemBuilder: (context, i) => RecipeCard(
                        recipe: state.suggestedRecipes[i],
                        onLongPressed: () {
                          cubit.add(state.suggestedRecipes[i]);
                        },
                        onPressed: () => _openRecipePage(
                          context,
                          cubit,
                          state.suggestedRecipes[i],
                        ),
                      ),
                      itemCount: state.suggestedRecipes.length,
                      scrollDirection: Axis.horizontal,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _openRecipePage(
    BuildContext context,
    PlannerCubit cubit,
    Recipe recipe,
  ) async {
    final res = await Navigator.of(context).push<UpdateEnum>(
      MaterialPageRoute(
        builder: (context) => RecipePage(
          recipe: recipe,
          updateOnPlanningEdit: true,
        ),
      ),
    );
    if (res == UpdateEnum.updated || res == UpdateEnum.deleted) {
      cubit.refresh();
    }
  }

  Future<void> _openItemSelectionPage(
    BuildContext context,
    PlannerCubit cubit,
  ) async {
    await Navigator.of(context).push<List<RecipeItem>>(
      MaterialPageRoute(
        builder: (context) => ItemSelectionPage(
          selectText: AppLocalizations.of(context)!.addNumberIngredients,
          recipes: cubit.state.plannedRecipes,
          title: AppLocalizations.of(context)!.addItemTitle,
          handleResult: (res) async {
            if (res.isNotEmpty) {
              await cubit.addItemsToList(res);
            }

            return res;
          },
        ),
      ),
    );
  }
}
