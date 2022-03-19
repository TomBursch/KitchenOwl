import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:intl/intl.dart';
import 'package:kitchenowl/app.dart';
import 'package:kitchenowl/cubits/recipe_cubit.dart';
import 'package:kitchenowl/cubits/settings_cubit.dart';
import 'package:kitchenowl/enums/update_enum.dart';
import 'package:kitchenowl/models/recipe.dart';
import 'package:kitchenowl/pages/recipe_add_update_page.dart';
import 'package:kitchenowl/kitchenowl.dart';
import 'package:kitchenowl/widgets/select_dialog.dart';
import 'package:kitchenowl/widgets/shopping_item.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';

class RecipePage extends StatefulWidget {
  final Recipe recipe;
  final bool updateOnPlanningEdit;

  const RecipePage({
    Key? key,
    required this.recipe,
    this.updateOnPlanningEdit = false,
  }) : super(key: key);

  @override
  _RecipePageState createState() => _RecipePageState();
}

class _RecipePageState extends State<RecipePage> {
  late RecipeCubit cubit;

  @override
  void initState() {
    super.initState();
    cubit = RecipeCubit(widget.recipe);
  }

  @override
  void dispose() {
    cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final int crossAxisCount = getValueForScreenType<int>(
      context: context,
      mobile: 3,
      tablet: 6,
      desktop: 9,
    );

    return BlocBuilder<RecipeCubit, RecipeState>(
      bloc: cubit,
      builder: (conext, state) => Scaffold(
        appBar: AppBar(
          title: Text(state.recipe.name),
          leading: BackButton(
            onPressed: () => Navigator.of(context).pop(cubit.state.updateState),
          ),
          actions: [
            if (!App.isOffline(context))
              IconButton(
                onPressed: () async {
                  final res = await Navigator.of(context)
                      .push<UpdateEnum>(MaterialPageRoute(
                    builder: (context) => AddUpdateRecipePage(
                      recipe: state.recipe,
                    ),
                  ));
                  if (res == UpdateEnum.updated) {
                    cubit.setUpdateState(UpdateEnum.updated);
                    cubit.refresh();
                  }
                  if (res == UpdateEnum.deleted) {
                    Navigator.of(context).pop(UpdateEnum.deleted);
                  }
                },
                icon: const Icon(Icons.edit),
              ),
          ],
        ),
        body: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints.expand(width: 1600),
            child: CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      Wrap(
                        runSpacing: 7,
                        spacing: 5,
                        children: [
                          if ((state.recipe.time) > 0)
                            Chip(
                              avatar: const Icon(
                                Icons.alarm_rounded,
                                color: Colors.white,
                              ),
                              label: Text(
                                state.recipe.time.toString() +
                                    " " +
                                    AppLocalizations.of(context)!.minutesAbbrev,
                                style: const TextStyle(color: Colors.white),
                              ),
                              backgroundColor:
                                  Theme.of(context).colorScheme.secondary,
                              elevation: 3,
                            ),
                          ...state.recipe.tags
                              .map((e) => Chip(label: Text(e.name)))
                              .toList(),
                        ],
                      ),
                      const SizedBox(height: 8),
                      MarkdownBody(
                        data: state.recipe.description,
                        styleSheet: MarkdownStyleSheet.fromTheme(
                          Theme.of(context),
                        ).copyWith(
                          blockquoteDecoration: BoxDecoration(
                            color: Theme.of(context).cardTheme.color ??
                                Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(2.0),
                          ),
                        ),
                        imageBuilder: (uri, title, alt) => CachedNetworkImage(
                          imageUrl: uri.toString(),
                          placeholder: (context, url) =>
                              const CircularProgressIndicator(),
                          errorWidget: (context, url, error) =>
                              const Icon(Icons.error),
                        ),
                        onTapLink: (text, href, title) async {
                          if (href != null && await canLaunch(href)) {
                            await launch(href);
                          }
                        },
                      ),
                    ]),
                  ),
                ),
                if (state.recipe.items.where((e) => !e.optional).isNotEmpty)
                  SliverPadding(
                    padding: const EdgeInsets.all(16),
                    sliver: SliverToBoxAdapter(
                      child: Text(
                        AppLocalizations.of(context)!.items + ':',
                        style: Theme.of(context).textTheme.headline6,
                      ),
                    ),
                  ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverGrid(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      mainAxisSpacing: 4,
                      crossAxisSpacing: 4,
                      childAspectRatio: 1,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, i) => ShoppingItemWidget(
                        onPressed: cubit.itemSelected,
                        selected: state.selectedItems.contains(state
                            .recipe.items
                            .where((e) => !e.optional)
                            .elementAt(i)),
                        item: state.recipe.items
                            .where((e) => !e.optional)
                            .elementAt(i),
                      ),
                      childCount:
                          state.recipe.items.where((e) => !e.optional).length,
                    ),
                  ),
                ),
                if (state.recipe.items.where((e) => e.optional).isNotEmpty)
                  SliverPadding(
                    padding: const EdgeInsets.all(16),
                    sliver: SliverToBoxAdapter(
                      child: Text(
                        AppLocalizations.of(context)!.itemsOptional + ':',
                        style: Theme.of(context).textTheme.headline6,
                      ),
                    ),
                  ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverGrid(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      mainAxisSpacing: 4,
                      crossAxisSpacing: 4,
                      childAspectRatio: 1,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, i) => ShoppingItemWidget(
                        onPressed: cubit.itemSelected,
                        selected: state.selectedItems.contains(state
                            .recipe.items
                            .where((e) => e.optional)
                            .elementAt(i)),
                        item: state.recipe.items
                            .where((e) => e.optional)
                            .elementAt(i),
                      ),
                      childCount:
                          state.recipe.items.where((e) => e.optional).length,
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverToBoxAdapter(
                    child: BlocBuilder<RecipeCubit, RecipeState>(
                      bloc: cubit,
                      builder: (conext, state) => ElevatedButton(
                        child: Text(
                          AppLocalizations.of(context)!.addNumberIngredients(
                            state.selectedItems.length,
                          ),
                        ),
                        onPressed: state.selectedItems.isEmpty
                            ? null
                            : () async {
                                await cubit.addItemsToList();
                                Navigator.of(context).pop(UpdateEnum.unchanged);
                              },
                      ),
                    ),
                  ),
                ),
                if (BlocProvider.of<SettingsCubit>(context)
                        .state
                        .serverSettings
                        .featurePlanner ??
                    false)
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    sliver: SliverToBoxAdapter(
                      child: Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              child: Text(
                                AppLocalizations.of(context)!
                                    .addRecipeToPlanner,
                              ),
                              onPressed: () async {
                                await cubit.addRecipeToPlanner(null);
                                Navigator.of(context).pop(
                                  widget.updateOnPlanningEdit
                                      ? UpdateEnum.updated
                                      : UpdateEnum.unchanged,
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            child: const Icon(Icons.calendar_month_rounded),
                            onPressed: () async {
                              final weekdayMapping = {
                                0: DateTime.monday,
                                1: DateTime.tuesday,
                                2: DateTime.wednesday,
                                3: DateTime.thursday,
                                4: DateTime.friday,
                                5: DateTime.saturday,
                                6: DateTime.sunday,
                              };
                              int? day = await showDialog<int>(
                                context: context,
                                builder: (context) => SelectDialog(
                                  title: AppLocalizations.of(context)!
                                      .addRecipeToPlanner,
                                  cancelText:
                                      AppLocalizations.of(context)!.cancel,
                                  options: weekdayMapping.entries
                                      .map(
                                        (e) => SelectDialogOption(
                                          e.key,
                                          DateFormat.E()
                                              .dateSymbols
                                              .STANDALONEWEEKDAYS[e.value % 7],
                                        ),
                                      )
                                      .toList(),
                                ),
                              );
                              if (day != null) {
                                await cubit
                                    .addRecipeToPlanner(day >= 0 ? day : null);
                                Navigator.of(context).pop(
                                  widget.updateOnPlanningEdit
                                      ? UpdateEnum.updated
                                      : UpdateEnum.unchanged,
                                );
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
