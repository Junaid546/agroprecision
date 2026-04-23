// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'farm_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FarmModelAdapter extends TypeAdapter<FarmModel> {
  @override
  final int typeId = 0;

  @override
  FarmModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FarmModel(
      id: fields[0] as String,
      name: fields[1] as String,
      ownerName: fields[2] as String,
      location: fields[3] as String?,
      phone: fields[4] as String?,
      createdAt: fields[5] as DateTime,
      updatedAt: fields[6] as DateTime,
      shedIds: (fields[7] as List).cast<String>(),
      isSetupComplete: fields[8] as bool,
      preferences: (fields[9] as Map?)?.cast<String, dynamic>(),
    );
  }

  @override
  void write(BinaryWriter writer, FarmModel obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.ownerName)
      ..writeByte(3)
      ..write(obj.location)
      ..writeByte(4)
      ..write(obj.phone)
      ..writeByte(5)
      ..write(obj.createdAt)
      ..writeByte(6)
      ..write(obj.updatedAt)
      ..writeByte(7)
      ..write(obj.shedIds)
      ..writeByte(8)
      ..write(obj.isSetupComplete)
      ..writeByte(9)
      ..write(obj.preferences);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FarmModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
