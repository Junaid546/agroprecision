// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'health_treatment_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HealthTreatmentModelAdapter extends TypeAdapter<HealthTreatmentModel> {
  @override
  final int typeId = 18;

  @override
  HealthTreatmentModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HealthTreatmentModel(
      id: fields[0] as String,
      farmId: fields[1] as String,
      shedId: fields[2] as String,
      batchId: fields[3] as String?,
      type: fields[4] as TreatmentType,
      title: fields[5] as String,
      scheduledDate: fields[6] as DateTime,
      completedDate: fields[7] as DateTime?,
      quantityUsed: fields[8] as double?,
      unit: fields[9] as String?,
      inventoryItemId: fields[10] as String?,
      notes: fields[11] as String?,
      createdAt: fields[12] as DateTime,
      isCompleted: fields[13] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, HealthTreatmentModel obj) {
    writer
      ..writeByte(14)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.farmId)
      ..writeByte(2)
      ..write(obj.shedId)
      ..writeByte(3)
      ..write(obj.batchId)
      ..writeByte(4)
      ..write(obj.type)
      ..writeByte(5)
      ..write(obj.title)
      ..writeByte(6)
      ..write(obj.scheduledDate)
      ..writeByte(7)
      ..write(obj.completedDate)
      ..writeByte(8)
      ..write(obj.quantityUsed)
      ..writeByte(9)
      ..write(obj.unit)
      ..writeByte(10)
      ..write(obj.inventoryItemId)
      ..writeByte(11)
      ..write(obj.notes)
      ..writeByte(12)
      ..write(obj.createdAt)
      ..writeByte(13)
      ..write(obj.isCompleted);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HealthTreatmentModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class TreatmentTypeAdapter extends TypeAdapter<TreatmentType> {
  @override
  final int typeId = 14;

  @override
  TreatmentType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return TreatmentType.vaccination;
      case 1:
        return TreatmentType.medication;
      case 2:
        return TreatmentType.supportiveCare;
      case 3:
        return TreatmentType.disinfection;
      default:
        return TreatmentType.vaccination;
    }
  }

  @override
  void write(BinaryWriter writer, TreatmentType obj) {
    switch (obj) {
      case TreatmentType.vaccination:
        writer.writeByte(0);
        break;
      case TreatmentType.medication:
        writer.writeByte(1);
        break;
      case TreatmentType.supportiveCare:
        writer.writeByte(2);
        break;
      case TreatmentType.disinfection:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TreatmentTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
