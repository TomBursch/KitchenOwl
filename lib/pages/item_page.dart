import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kitchenowl/app.dart';
import 'package:kitchenowl/cubits/item_edit_cubit.dart';
import 'package:kitchenowl/enums/update_enum.dart';
import 'package:kitchenowl/models/category.dart';
import 'package:kitchenowl/models/household.dart';
import 'package:kitchenowl/models/item.dart';
import 'package:kitchenowl/kitchenowl.dart';
import 'package:kitchenowl/models/shoppinglist.dart';
import 'package:kitchenowl/models/update_value.dart';
import 'package:kitchenowl/pages/icon_selection_page.dart';
import 'package:kitchenowl/widgets/recipe_item.dart';

class ItemPage<T extends Item> extends StatefulWidget {
  final T item;
  final Household? household;
  final ShoppingList? shoppingList;
  final List<Category> categories;
  final bool isDescriptionEditable;

  const ItemPage({
    super.key,
    required this.item,
    this.shoppingList,
    this.household,
    this.categories = const [],
    this.isDescriptionEditable = true,
  });

  @override
  _ItemPageState createState() => _ItemPageState<T>();
}

enum _ItemAction {
  changeIcon,
  delete;
}

class _ItemPageState<T extends Item> extends State<ItemPage<T>> {
  final TextEditingController descController = TextEditingController();

  late ItemEditCubit<T> cubit;

  @override
  void initState() {
    super.initState();
    if (widget.item is ItemWithDescription) {
      descController.text = (widget.item as ItemWithDescription).description;
    }
    cubit = ItemEditCubit<T>(
      household: widget.household,
      item: widget.item,
      shoppingList: widget.shoppingList,
    );
  }

  @override
  void dispose() {
    cubit.close();
    descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (cubit.hasChanged()) {
          await cubit.saveItem();
          if (!mounted) return false;
          Navigator.of(context)
              .pop(UpdateValue<T>(UpdateEnum.updated, cubit.item));

          return false;
        }

        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.item.name),
          actions: [
            if (widget.item is! RecipeItem && !App.isOffline)
              PopupMenuButton(
                itemBuilder: (BuildContext context) =>
                    <PopupMenuEntry<_ItemAction>>[
                  PopupMenuItem<_ItemAction>(
                    value: _ItemAction.changeIcon,
                    child: Text(AppLocalizations.of(context)!.changeIcon),
                  ),
                  PopupMenuItem<_ItemAction>(
                    value: _ItemAction.delete,
                    child: Text(AppLocalizations.of(context)!.delete),
                  ),
                ],
                onSelected: (value) async {
                  switch (value) {
                    case _ItemAction.changeIcon:
                      final icon = await Navigator.of(context)
                          .push<Nullable<String?>>(MaterialPageRoute(
                        builder: (context) => IconSelectionPage(
                          oldIcon: cubit.state.icon,
                          name: cubit.state.name,
                        ),
                      ));
                      if (icon != null) cubit.setIcon(icon.value);
                      break;
                    case _ItemAction.delete:
                      final confirmed = await askForConfirmation(
                        context: context,
                        title: Text(
                          AppLocalizations.of(context)!.itemDelete,
                        ),
                        content: Text(
                          AppLocalizations.of(context)!
                              .itemDeleteConfirmation(widget.item.name),
                        ),
                      );
                      if (confirmed) {
                        await cubit.deleteItem();
                        if (!mounted) return;
                        Navigator.of(context)
                            .pop(const UpdateValue<Item>(UpdateEnum.deleted));
                      }
                      break;
                  }
                },
              ),
          ],
        ),
        body: Scrollbar(
          child: RefreshIndicator(
            onRefresh: cubit.refresh,
            child: CustomScrollView(
              slivers: [
                if (widget.isDescriptionEditable &&
                    widget.item is ItemWithDescription)
                  SliverPadding(
                    padding: const EdgeInsets.all(16),
                    sliver: SliverToBoxAdapter(
                      child: TextField(
                        autofocus: true,
                        controller: descController,
                        onChanged: (s) => cubit.setDescription(s),
                        textCapitalization: TextCapitalization.sentences,
                        decoration: InputDecoration(
                          border: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(14)),
                          ),
                          labelText: AppLocalizations.of(context)!.description,
                          // suffix: IconButton(
                          //   onPressed: () {
                          //     if (descController.text.isNotEmpty) {
                          //       cubit.setDescription('');
                          //       descController.clear();
                          //     }
                          //     FocusScope.of(context).unfocus();
                          //   },
                          //   icon: Icon(
                          //     Icons.close,
                          //     color: Colors.grey,
                          //   ),
                          // ),
                        ),
                      ),
                    ),
                  ),
                if (widget.item is! RecipeItem)
                  SliverPadding(
                    padding: EdgeInsets.only(
                      top: (widget.isDescriptionEditable &&
                              widget.item is ItemWithDescription)
                          ? 0
                          : 16,
                      bottom: 16,
                      left: 16,
                      right: 16,
                    ),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate(
                        [
                          Text(
                            AppLocalizations.of(context)!.category,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          Row(
                            children: [
                              Expanded(
                                child:
                                    BlocBuilder<ItemEditCubit, ItemEditState>(
                                  bloc: cubit,
                                  buildWhen: (prev, curr) =>
                                      prev.category != curr.category,
                                  builder: (context, state) =>
                                      DropdownButton<Category?>(
                                    value: state.category,
                                    isExpanded: true,
                                    items: [
                                      for (final e in widget.categories)
                                        DropdownMenuItem(
                                          value: e,
                                          child: Text(e.name),
                                        ),
                                      DropdownMenuItem(
                                        value: null,
                                        child: Text(
                                          AppLocalizations.of(context)!.none,
                                        ),
                                      ),
                                    ],
                                    onChanged: !App.isOffline
                                        ? cubit.setCategory
                                        : null,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                if (widget.item is! RecipeItem)
                  BlocBuilder<ItemEditCubit, ItemEditState>(
                    bloc: cubit,
                    builder: (context, state) {
                      return SliverPadding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, i) {
                              if (i == 0) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: Text(
                                    '${AppLocalizations.of(context)!.usedIn}:',
                                    style:
                                        Theme.of(context).textTheme.titleLarge,
                                  ),
                                );
                              }
                              i = i - 1;

                              return RecipeItemWidget(
                                recipe: state.recipes[i],
                                onUpdated: cubit.refresh,
                                description: state.recipes[i].isPlanned &&
                                        state.recipes[i].items.isNotEmpty &&
                                        state.recipes[i].items.first.description
                                            .isNotEmpty
                                    ? Text(
                                        state
                                            .recipes[i].items.first.description,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall,
                                      )
                                    : null,
                              );
                            },
                            childCount: state.recipes.isEmpty
                                ? 0
                                : state.recipes.length + 1,
                          ),
                        ),
                      );
                    },
                  ),
                SliverToBoxAdapter(
                  child:
                      SizedBox(height: MediaQuery.of(context).padding.bottom),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
