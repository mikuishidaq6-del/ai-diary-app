import 'package:hive/hive.dart';

part 'health_record.g.dart';

@HiveType(typeId: 0)
class HealthRecord extends HiveObject {
  @HiveField(0)
  DateTime datetime;

  @HiveField(1)
  double? temperature; // ← nullable に変更
  @HiveField(2)
  double? bloodPressure;
  @HiveField(3)
  double? pulse;
  @HiveField(4)
  double? spo2;
  @HiveField(5)
  double? weight;
  @HiveField(6)
  double? wbc;
  @HiveField(7)
  double? rbc;
  @HiveField(8)
  double? platelets;

  @HiveField(9)
  String comment;

  HealthRecord({
    required this.datetime,
    this.temperature,
    this.bloodPressure,
    this.pulse,
    this.spo2,
    this.weight,
    this.wbc,
    this.rbc,
    this.platelets,
    required this.comment,
  });
}
