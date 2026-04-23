// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shed_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ShedModelAdapter extends TypeAdapter<ShedModel> {
  @override
  final int typeId = 1;

  @override
  ShedModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ShedModel(
      id: fields[0] as String,
      farmId: fields[1] as String,
      name: fields[2] as String,
      capacity: fields[3] as int,
      areaSqMeters: fields[4] as double?,
      activeBatchId: fields[5] as String?,
      createdAt: fields[6] as DateTime,
      notes: fields[7] as String?,
      isActive: fields[8] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, ShedModel obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.farmId)
      ..writeByte(2)
      ..write(obj.name)
      ..writeByte(3)
      ..write(obj.capacity)
      ..writeByte(4)
      ..write(obj.areaSqMeters)
      ..writeByte(5)
      ..write(obj.activeBatchId)
      ..writeByte(6)
      ..write(obj.createdAt)
      ..writeByte(7)
      ..write(obj.notes)
      ..writeByte(8)
      ..write(obj.isActive);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ShedModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
