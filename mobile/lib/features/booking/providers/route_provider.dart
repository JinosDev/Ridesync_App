import 'package:flutter_riverpod/flutter_riverpod.dart';

class RouteProvider extends StateNotifier<AsyncValue<List<dynamic>>> {
  RouteProvider() : super(const AsyncValue.data([]));
}

final routeProvider = StateNotifierProvider((ref) => RouteProvider());
