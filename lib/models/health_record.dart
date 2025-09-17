import 'package:hive/hive.dart';

part 'health_record.g.dart';

@HiveType(typeId: 0)
class HealthRecord extends HiveObject {
  @HiveField(0)
  DateTime datetime;

  @HiveField(1)
  double temperature;

  @HiveField(2)
  double bloodPressure;

  @HiveField(3)
  double pulse;

  @HiveField(4)
  double spo2;

  @HiveField(5)
  double weight;

  @HiveField(6)
  double wbc;

  @HiveField(7)
  double rbc;

  @HiveField(8)
  double platelets;

  @HiveField(9)
  String comment;

  HealthRecord({
    required this.datetime,
    required this.temperature,
    required this.bloodPressure,
    required this.pulse,
    required this.spo2,
    required this.weight,
    required this.wbc,
    required this.rbc,
    required this.platelets,
    required this.comment,
  });
}
