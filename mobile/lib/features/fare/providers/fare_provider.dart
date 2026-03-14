import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/fare_repository.dart';
import '../data/fare_model.dart';

final fareRepositoryProvider = Provider((ref) => FareRepository());

final fareProvider = FutureProvider.family<FareBreakdownModel, FareParams>((ref, params) {
  return ref.watch(fareRepositoryProvider).getFareEstimate(
    scheduleId: params.scheduleId,
    fromStop:   params.fromStop,
    toStop:     params.toStop,
    busClass:   params.busClass,
  );
});
