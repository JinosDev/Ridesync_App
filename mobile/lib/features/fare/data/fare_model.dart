class FareBreakdownModel {
  final int total;
  final double baseFare;
  final double segmentKm;
  final double ratePerKm;
  final double classMultiplier;
  final String busClass;

  const FareBreakdownModel({
    required this.total,
    required this.baseFare,
    required this.segmentKm,
    required this.ratePerKm,
    required this.classMultiplier,
    required this.busClass,
  });

  factory FareBreakdownModel.fromJson(Map<String, dynamic> json) =>
      FareBreakdownModel(
        total:           (json['total'] as num).toInt(),
        baseFare:        (json['baseFare'] as num).toDouble(),
        segmentKm:       (json['segmentKm'] as num).toDouble(),
        ratePerKm:       (json['ratePerKm'] as num).toDouble(),
        classMultiplier: (json['classMultiplier'] as num).toDouble(),
        busClass:        json['busClass'] as String,
      );
}

class FareParams {
  final String scheduleId;
  final String fromStop;
  final String toStop;
  final String busClass;
  const FareParams({required this.scheduleId, required this.fromStop, required this.toStop, required this.busClass});
  @override bool operator ==(Object o) => o is FareParams && scheduleId == o.scheduleId && fromStop == o.fromStop && toStop == o.toStop && busClass == o.busClass;
  @override int get hashCode => Object.hash(scheduleId, fromStop, toStop, busClass);
}
