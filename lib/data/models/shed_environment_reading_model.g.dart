// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shed_environment_reading_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ShedEnvironmentReadingModelAdapter
    extends TypeAdapter<ShedEnvironmentReadingModel> {
  @override
  final int typeId = 15;

  @override
  ShedEnvironmentReadingModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ShedEnvironmentReadingModel(
      id: fields[0] as String,
      farmId: fields[1] as String,
      shedId: fields[2] as String,
      recordedAt: fields[3] as DateTime,
      temperatureC: fields[4] as double,
      humidityPercent: fields[5] as double,
      ammoniaPpm: fields[6] as double?,
      co2Ppm: fields[7] as double?,
      staticPressurePa: fields[8] as double?,
      airSpeedMps: fields[9] as double?,
      feedBinLevelPercent: fields[10] as double?,
      waterLevelPercent: fields[11] as double?,
      notes: fields[12] as String?,
      createdAt: fields[13] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, ShedEnvironmentReadingModel obj) {
    writer
      ..writeByte(14)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.farmId)
      ..writeByte(2)
      ..write(obj.shedId)
      ..writeByte(3)
      ..write(obj.recordedAt)
      ..writeByte(4)
      ..write(obj.temperatureC)
      ..writeByte(5)
      ..write(obj.humidityPercent)
      ..writeByte(6)
      ..write(obj.ammoniaPpm)
      ..writeByte(7)
      ..write(obj.co2Ppm)
      ..writeByte(8)
      ..write(obj.staticPressurePa)
      ..writeByte(9)
      ..write(obj.airSpeedMps)
      ..writeByte(10)
      ..write(obj.feedBinLevelPercent)
      ..writeByte(11)
      ..write(obj.waterLevelPercent)
      ..writeByte(12)
      ..write(obj.notes)
      ..writeByte(13)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ShedEnvironmentReadingModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
