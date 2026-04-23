// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mortality_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MortalityModelAdapter extends TypeAdapter<MortalityModel> {
  @override
  final int typeId = 4;

  @override
  MortalityModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MortalityModel(
      id: fields[0] as String,
      batchId: fields[1] as String,
      farmId: fields[2] as String,
      count: fields[3] as int,
      date: fields[4] as DateTime,
      cause: fields[5] as String?,
      notes: fields[6] as String?,
      createdAt: fields[7] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, MortalityModel obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.batchId)
      ..writeByte(2)
      ..write(obj.farmId)
      ..writeByte(3)
      ..write(obj.count)
      ..writeByte(4)
      ..write(obj.date)
      ..writeByte(5)
      ..write(obj.cause)
      ..writeByte(6)
      ..write(obj.notes)
      ..writeByte(7)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MortalityModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
