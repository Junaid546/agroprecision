// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'batch_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BatchModelAdapter extends TypeAdapter<BatchModel> {
  @override
  final int typeId = 2;

  @override
  BatchModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BatchModel(
      id: fields[0] as String,
      shedId: fields[1] as String,
      farmId: fields[2] as String,
      batchNumber: fields[3] as String,
      initialCount: fields[4] as int,
      initialCostPerBird: fields[5] as double,
      startDate: fields[6] as DateTime,
      endDate: fields[7] as DateTime?,
      status: fields[8] as BatchStatus,
      notes: fields[9] as String?,
      createdAt: fields[10] as DateTime,
      updatedAt: fields[11] as DateTime,
      breed: fields[12] as String?,
      targetWeightKg: fields[13] as double?,
      targetDays: fields[14] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, BatchModel obj) {
    writer
      ..writeByte(15)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.shedId)
      ..writeByte(2)
      ..write(obj.farmId)
      ..writeByte(3)
      ..write(obj.batchNumber)
      ..writeByte(4)
      ..write(obj.initialCount)
      ..writeByte(5)
      ..write(obj.initialCostPerBird)
      ..writeByte(6)
      ..write(obj.startDate)
      ..writeByte(7)
      ..write(obj.endDate)
      ..writeByte(8)
      ..write(obj.status)
      ..writeByte(9)
      ..write(obj.notes)
      ..writeByte(10)
      ..write(obj.createdAt)
      ..writeByte(11)
      ..write(obj.updatedAt)
      ..writeByte(12)
      ..write(obj.breed)
      ..writeByte(13)
      ..write(obj.targetWeightKg)
      ..writeByte(14)
      ..write(obj.targetDays);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BatchModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class BatchStatusAdapter extends TypeAdapter<BatchStatus> {
  @override
  final int typeId = 8;

  @override
  BatchStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return BatchStatus.active;
      case 1:
        return BatchStatus.completed;
      case 2:
        return BatchStatus.cancelled;
      default:
        return BatchStatus.active;
    }
  }

  @override
  void write(BinaryWriter writer, BatchStatus obj) {
    switch (obj) {
      case BatchStatus.active:
        writer.writeByte(0);
        break;
      case BatchStatus.completed:
        writer.writeByte(1);
        break;
      case BatchStatus.cancelled:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BatchStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
