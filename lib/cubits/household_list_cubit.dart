import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kitchenowl/models/household.dart';
import 'package:kitchenowl/services/transaction_handler.dart';
import 'package:kitchenowl/services/transactions/household.dart';

class HouseholdListCubit extends Cubit<HouseholdListState> {
  HouseholdListCubit() : super(const LoadingHouseholdListState([])) {
    refresh();
  }

  Future<void> refresh() async {
    Future<List<Household>?> households = TransactionHandler.getInstance()
        .runTransaction(TransactionHouseholdGetAll());

    emit(HouseholdListState(
      await households ?? [],
    ));
  }
}

class HouseholdListState extends Equatable {
  final List<Household> households;

  const HouseholdListState(
    this.households,
  );

  HouseholdListState copyWith({
    List<Household>? households,
  }) =>
      HouseholdListState(
        households ?? this.households,
      );

  @override
  List<Object?> get props => [households];
}

class LoadingHouseholdListState extends HouseholdListState {
  const LoadingHouseholdListState(super.households);

  @override
  HouseholdListState copyWith({
    List<Household>? households,
  }) =>
      LoadingHouseholdListState(
        households ?? this.households,
      );
}