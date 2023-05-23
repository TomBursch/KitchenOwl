import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kitchenowl/services/api/api_service.dart';

class ServerInfoCubit extends Cubit<ServerInfoState> {
  ServerInfoCubit() : super(const DisconnectedServerInfoState()) {
    ApiService.getInstance().addInfoListener(updateState);
  }

  void updateState() {
    Map<String, dynamic>? data = ApiService.getInstance().serverInfoMap;
    if (data == null) {
      emit(const DisconnectedServerInfoState());
    } else {
      emit(
        ConnectedServerInfoState.fromJson(
          data,
        ),
      );
    }
  }
}

abstract class ServerInfoState extends Equatable {
  const ServerInfoState();
}

class DisconnectedServerInfoState extends ServerInfoState {
  const DisconnectedServerInfoState();

  @override
  List<Object?> get props => [];
}

class ConnectedServerInfoState extends ServerInfoState {
  final int version;
  final int minFrontendVersion;
  final String? privacyPolicyUrl;
  final bool openRegistration;

  const ConnectedServerInfoState({
    required this.version,
    required this.minFrontendVersion,
    this.privacyPolicyUrl,
    this.openRegistration = false,
  });

  factory ConnectedServerInfoState.fromJson(Map<String, dynamic> data) =>
      ConnectedServerInfoState(
        version: data["version"],
        minFrontendVersion: data["min_frontend_version"],
        privacyPolicyUrl: data["privacy_policy"],
        openRegistration: data["open_registration"] ?? false,
      );

  @override
  List<Object?> get props =>
      [version, minFrontendVersion, privacyPolicyUrl, openRegistration];
}
