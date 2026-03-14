class BookingModel {
  final String bookingId;
  final String passengerId;
  final String scheduleId;
  final String fromStop;
  final String toStop;
  final String seatNo;
  final double fare;
  final FareBreakdown fareBreakdown;
  final String status; // "confirmed" | "cancelled" | "completed"
  final DateTime bookedAt;

  const BookingModel({
    required this.bookingId,
    required this.passengerId,
    required this.scheduleId,
    required this.fromStop,
    required this.toStop,
    required this.seatNo,
    required this.fare,
    required this.fareBreakdown,
    required this.status,
    required this.bookedAt,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) => BookingModel(
    bookingId:     json['bookingId'] as String,
    passengerId:   json['passengerId'] as String? ?? '',
    scheduleId:    json['scheduleId'] as String,
    fromStop:      json['fromStop'] as String,
    toStop:        json['toStop'] as String,
    seatNo:        json['seatNo'] as String,
    fare:          (json['fare'] as num).toDouble(),
    fareBreakdown: FareBreakdown.fromJson(json['fareBreakdown'] as Map<String, dynamic>),
    status:        json['status'] as String,
    bookedAt:      DateTime.parse(json['bookedAt'] as String),
  );

  Map<String, dynamic> toJson() => {
    'bookingId':     bookingId,
    'passengerId':   passengerId,
    'scheduleId':    scheduleId,
    'fromStop':      fromStop,
    'toStop':        toStop,
    'seatNo':        seatNo,
    'fare':          fare,
    'fareBreakdown': fareBreakdown.toJson(),
    'status':        status,
    'bookedAt':      bookedAt.toIso8601String(),
  };
}

class FareBreakdown {
  final double baseFare;
  final double segmentKm;
  final double ratePerKm;
  final double classMultiplier;
  final String busClass;

  const FareBreakdown({
    required this.baseFare,
    required this.segmentKm,
    required this.ratePerKm,
    required this.classMultiplier,
    required this.busClass,
  });

  double get total => baseFare + (segmentKm * ratePerKm * classMultiplier);

  factory FareBreakdown.fromJson(Map<String, dynamic> json) => FareBreakdown(
    baseFare:        (json['baseFare'] as num).toDouble(),
    segmentKm:       (json['segmentKm'] as num).toDouble(),
    ratePerKm:       (json['ratePerKm'] as num).toDouble(),
    classMultiplier: (json['classMultiplier'] as num).toDouble(),
    busClass:        json['busClass'] as String,
  );

  Map<String, dynamic> toJson() => {
    'baseFare': baseFare, 'segmentKm': segmentKm,
    'ratePerKm': ratePerKm, 'classMultiplier': classMultiplier, 'busClass': busClass,
  };
}
