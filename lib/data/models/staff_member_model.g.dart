// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'staff_member_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class StaffMemberModelAdapter extends TypeAdapter<StaffMemberModel> {
  @override
  final int typeId = 19;

  @override
  StaffMemberModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return StaffMemberModel(
      id: fields[0] as String,
      farmId: fields[1] as String,
      name: fields[2] as String,
      role: fields[3] as String,
      phone: fields[4] as String?,
      isActive: fields[5] as bool,
      createdAt: fields[6] as DateTime,
      notes: fields[7] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, StaffMemberModel obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.farmId)
      ..writeByte(2)
      ..write(obj.name)
      ..writeByte(3)
      ..write(obj.role)
      ..writeByte(4)
      ..write(obj.phone)
      ..writeByte(5)
      ..write(obj.isActive)
      ..writeByte(6)
      ..write(obj.createdAt)
      ..writeByte(7)
      ..write(obj.notes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StaffMemberModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
