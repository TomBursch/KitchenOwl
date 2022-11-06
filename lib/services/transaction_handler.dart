import 'package:kitchenowl/app.dart';
import 'package:kitchenowl/services/transaction.dart';
import 'package:kitchenowl/services/api/api_service.dart';
import 'package:kitchenowl/services/storage/transaction_storage.dart';

class TransactionHandler {
  static TransactionHandler? _instance;

  TransactionHandler._internal();
  static TransactionHandler getInstance() {
    _instance ??= TransactionHandler._internal();

    return _instance!;
  }

  Future<void> runOpenTransactions() async {
    if (!ApiService.getInstance().isConnected()) {
      ApiService.getInstance().refresh();
    }
    if (ApiService.getInstance().isConnected()) {
      final transactions =
          await TransactionStorage.getInstance().readTransactions();
      final now = DateTime.now();
      for (final t in transactions) {
        if (t is! ErrorTransaction && t.timestamp.difference(now).inDays < 3) {
          t.runOnline();
        }
      }
      TransactionStorage.getInstance().clearTransactions();
    }
  }

  Future<T> runTransaction<T>(Transaction<T> t) async {
    if (!ApiService.getInstance().isConnected()) {
      await ApiService.getInstance().refresh();
    }
    if (!App.isForcedOffline && ApiService.getInstance().isConnected()) {
      T? res = await t.runOnline();
      if (res != null && (res is! bool || res)) return res;
    }
    if (t.saveTransaction) {
      await TransactionStorage.getInstance().addTransaction(t);
    }

    return t.runLocal();
  }
}
