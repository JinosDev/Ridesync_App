class ScheduleModel {
  final String scheduleId;
  final String routeId;
  final String busId;
  final String operatorId;
  final DateTime departureTime;
  final String status; // "scheduled" | "active" | "completed" | "cancelled"
  final int delayMinutes;
  final String? currentStop;
  final Map<String, dynamic> seatMap; // seat number → null (available) or uid (booked)

  // Denormalized route info (returned by API)
  final String? routeName;
  final String? startPoint;
  final String? endPoint;
  final String? busClass; // "AC" | "NonAC"
  final int? capacity;

  const ScheduleModel({
    required this.scheduleId,
    required this.routeId,
    required this.busId,
    required this.operatorId,
    required this.departureTime,
    required this.status,
    required this.delayMinutes,
    required this.seatMap,
    this.currentStop,
    this.routeName,
    this.startPoint,
    this.endPoint,
    this.busClass,
    this.capacity,
  });

  int get availableSeats => seatMap.values.where((v) => v == null).length;
  int get bookedSeats    => seatMap.values.where((v) => v != null).length;

  factory ScheduleModel.fromJson(Map<String, dynamic> json) => ScheduleModel(
    scheduleId:    json['scheduleId'] as String,
    routeId:       json['routeId'] as String,
    busId:         json['busId'] as String,
    operatorId:    json['operatorId'] as String,
    departureTime: DateTime.parse(json['departureTime'] as String),
    status:        json['status'] as String,
    delayMinutes:  (json['delayMinutes'] as num?)?.toInt() ?? 0,
    seatMap:       Map<String, dynamic>.from(json['seatMap'] as Map? ?? {}),
    currentStop:   json['currentStop'] as String?,
    routeName:     json['routeName'] as String?,
    startPoint:    json['startPoint'] as String?,
    endPoint:      json['endPoint'] as String?,
    busClass:      json['busClass'] as String?,
    capacity:      (json['capacity'] as num?)?.toInt(),
  );
}
