// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'growth_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class GrowthModelAdapter extends TypeAdapter<GrowthModel> {
  @override
  final int typeId = 5;

  @override
  GrowthModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return GrowthModel(
      id: fields[0] as String,
      batchId: fields[1] as String,
      farmId: fields[2] as String,
      averageWeightKg: fields[3] as double,
      sampleSize: fields[4] as int,
      batchDay: fields[5] as int,
      date: fields[6] as DateTime,
      feedConsumedKg: fields[7] as double?,
      createdAt: fields[8] as DateTime,
      notes: fields[9] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, GrowthModel obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.batchId)
      ..writeByte(2)
      ..write(obj.farmId)
      ..writeByte(3)
      ..write(obj.averageWeightKg)
      ..writeByte(4)
      ..write(obj.sampleSize)
      ..writeByte(5)
      ..write(obj.batchDay)
      ..writeByte(6)
      ..write(obj.date)
      ..writeByte(7)
      ..write(obj.feedConsumedKg)
      ..writeByte(8)
      ..write(obj.createdAt)
      ..writeByte(9)
      ..write(obj.notes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GrowthModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
