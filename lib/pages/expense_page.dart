import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:kitchenowl/app.dart';
import 'package:kitchenowl/cubits/expense_cubit.dart';
import 'package:kitchenowl/enums/update_enum.dart';
import 'package:kitchenowl/models/expense.dart';
import 'package:kitchenowl/models/user.dart';
import 'package:kitchenowl/pages/expense_add_update_page.dart';
import 'package:kitchenowl/kitchenowl.dart';
import 'package:collection/collection.dart';

class ExpensePage extends StatefulWidget {
  final Expense expense;
  final List<User> users;

  const ExpensePage({Key? key, required this.expense, required this.users})
      : super(key: key);

  @override
  _ExpensePageState createState() => _ExpensePageState();
}

class _ExpensePageState extends State<ExpensePage> {
  late ExpenseCubit cubit;

  @override
  void initState() {
    super.initState();
    cubit = ExpenseCubit(widget.expense, widget.users);
  }

  @override
  void dispose() {
    cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pop(cubit.state.updateState);

        return false;
      },
      child: BlocBuilder<ExpenseCubit, ExpenseCubitState>(
        bloc: cubit,
        builder: (conext, state) => Scaffold(
          body: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints.expand(width: 1600),
              child: CustomScrollView(
                slivers: [
                  SliverAppBar(
                    flexibleSpace: FlexibleImageSpaceBar(
                      title: state.expense.name,
                      imageUrl: state.expense.image,
                    ),
                    expandedHeight: state.expense.image.isNotEmpty ? 160 : null,
                    pinned: true,
                    leading: BackButton(
                      onPressed: () =>
                          Navigator.of(context).pop(cubit.state.updateState),
                    ),
                    actions: [
                      if (!App.isOffline)
                        LoadingIconButton(
                          onPressed: () async {
                            final res = await Navigator.of(context)
                                .push<UpdateEnum>(MaterialPageRoute(
                              builder: (context) => AddUpdateExpensePage(
                                expense: state.expense,
                                users: state.users,
                              ),
                            ));
                            if (res == UpdateEnum.updated) {
                              cubit.setUpdateState(UpdateEnum.updated);
                              await cubit.refresh();
                            }
                            if (res == UpdateEnum.deleted) {
                              if (!mounted) return;
                              Navigator.of(context).pop(UpdateEnum.deleted);
                            }
                          },
                          icon: const Icon(Icons.edit),
                        ),
                    ],
                  ),
                  SliverList(
                    delegate: SliverChildListDelegate(
                      [
                        const SizedBox(height: 16),
                        Text(
                          AppLocalizations.of(context)!.expenseAmount,
                          style: Theme.of(context).textTheme.subtitle1,
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          NumberFormat.simpleCurrency()
                              .format(state.expense.amount),
                          style: Theme.of(context).textTheme.headline2,
                          textAlign: TextAlign.center,
                        ),
                        if (state.expense.category != null)
                          ListTile(
                            title: Text(
                              "${AppLocalizations.of(context)!.category} ${state.expense.category!}",
                            ),
                          ),
                        ListTile(
                          title: Text(
                            "${AppLocalizations.of(context)!.expensePaidBy} ${state.users.firstWhereOrNull(
                                  (e) => e.id == state.expense.paidById,
                                )?.name ?? AppLocalizations.of(context)!.other}",
                          ),
                          trailing: state.expense.createdAt != null
                              ? Text(
                                  DateFormat.yMMMMEEEEd()
                                      .format(state.expense.createdAt!),
                                )
                              : null,
                        ),
                        const SizedBox(height: 24),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  '${AppLocalizations.of(context)!.expensePaidFor}:',
                                  style: Theme.of(context).textTheme.subtitle1,
                                ),
                              ),
                              Text(AppLocalizations.of(context)!.expenseFactor),
                            ],
                          ),
                        ),
                        const Divider(indent: 16, endIndent: 16),
                      ],
                    ),
                  ),
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, i) => ListTile(
                        title: Text(
                          state.users
                                  .firstWhereOrNull(
                                    (e) =>
                                        e.id == state.expense.paidFor[i].userId,
                                  )
                                  ?.name ??
                              AppLocalizations.of(context)!.other,
                        ),
                        subtitle: Text(NumberFormat.simpleCurrency().format(
                          (state.expense.amount *
                              state.expense.paidFor[i].factor /
                              state.expense.paidFor
                                  .fold(0, (p, v) => p + v.factor)),
                        )),
                        trailing: Text(
                          state.expense.paidFor[i].factor.toString(),
                        ),
                      ),
                      childCount: state.expense.paidFor.length,
                    ),
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
      ),
    );
  }
}
