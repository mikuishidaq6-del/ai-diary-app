// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'health_record.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HealthRecordAdapter extends TypeAdapter<HealthRecord> {
  @override
  final int typeId = 0;

  @override
  HealthRecord read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HealthRecord(
      datetime: fields[0] as DateTime,
      temperature: fields[1] as double?,
      bloodPressure: fields[2] as double?,
      pulse: fields[3] as double?,
      spo2: fields[4] as double?,
      weight: fields[5] as double?,
      wbc: fields[6] as double?,
      rbc: fields[7] as double?,
      platelets: fields[8] as double?,
      comment: fields[9] as String,
    );
  }

  @override
  void write(BinaryWriter writer, HealthRecord obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.datetime)
      ..writeByte(1)
      ..write(obj.temperature)
      ..writeByte(2)
      ..write(obj.bloodPressure)
      ..writeByte(3)
      ..write(obj.pulse)
      ..writeByte(4)
      ..write(obj.spo2)
      ..writeByte(5)
      ..write(obj.weight)
      ..writeByte(6)
      ..write(obj.wbc)
      ..writeByte(7)
      ..write(obj.rbc)
      ..writeByte(8)
      ..write(obj.platelets)
      ..writeByte(9)
      ..write(obj.comment);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HealthRecordAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
