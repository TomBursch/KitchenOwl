import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kitchenowl/app.dart';
import 'package:kitchenowl/cubits/household_list_cubit.dart';
import 'package:kitchenowl/kitchenowl.dart';
import 'package:kitchenowl/pages/household_add_page.dart';
import 'package:kitchenowl/pages/settings_user_page.dart';
import 'package:kitchenowl/widgets/household_card.dart';

class HouseholdListPage extends StatefulWidget {
  const HouseholdListPage({super.key});

  @override
  State<HouseholdListPage> createState() => _HouseholdListPageState();
}

class _HouseholdListPageState extends State<HouseholdListPage> with RouteAware {
  late final HouseholdListCubit cubit;
  RouteObserver? routeObserver;

  @override
  void initState() {
    super.initState();
    cubit = HouseholdListCubit();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final newRouteObserver =
        RepositoryProvider.of<RouteObserver<ModalRoute>>(context);
    if (routeObserver != newRouteObserver) {
      routeObserver?.unsubscribe(this);
      newRouteObserver.subscribe(this, ModalRoute.of(context)!);
      routeObserver = newRouteObserver;
    }
  }

  @override
  void dispose() {
    routeObserver?.unsubscribe(this);
    cubit.close();
    super.dispose();
  }

  @override
  void didPopNext() {
    cubit.refresh();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: App.isOffline
          ? null
          : KitchenOwlFab(
              openBuilder: (context, _) => HouseholdAddPage(
                locale: AppLocalizations.of(context)!.localeName,
              ),
              onClosed: (data) => cubit.refresh(),
            ),
      body: RefreshIndicator(
        onRefresh: cubit.refresh,
        child: SafeArea(
          child: BlocBuilder<HouseholdListCubit, HouseholdListState>(
            bloc: cubit,
            builder: (context, state) => CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  sliver: SliverToBoxAdapter(
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            AppLocalizations.of(context)!.household, // TODO
                            style: Theme.of(context).textTheme.headlineLarge,
                          ),
                        ),
                        IconButton(
                          tooltip: AppLocalizations.of(context)!.profile,
                          onPressed: () =>
                              Navigator.of(context, rootNavigator: true).push(
                            MaterialPageRoute(
                              builder: (context) => const SettingsUserPage(),
                            ),
                          ),
                          icon: const Icon(Icons.manage_accounts_rounded),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, i) => HouseholdCard(
                        household: state.households[i],
                      ),
                      childCount: state.households.length,
                    ),
                  ),
                ),
                if (state.households.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Text(
                        AppLocalizations.of(context)!.recipeEmpty, // TODO
                        style: Theme.of(context).textTheme.titleMedium,
                        textAlign: TextAlign.center,
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
