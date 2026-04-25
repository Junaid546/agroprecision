// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inventory_transaction_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class InventoryTransactionModelAdapter
    extends TypeAdapter<InventoryTransactionModel> {
  @override
  final int typeId = 17;

  @override
  InventoryTransactionModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return InventoryTransactionModel(
      id: fields[0] as String,
      farmId: fields[1] as String,
      itemId: fields[2] as String,
      type: fields[3] as InventoryTransactionType,
      quantityChange: fields[4] as double,
      unit: fields[5] as String,
      date: fields[6] as DateTime,
      createdAt: fields[7] as DateTime,
      batchId: fields[8] as String?,
      shedId: fields[9] as String?,
      notes: fields[10] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, InventoryTransactionModel obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.farmId)
      ..writeByte(2)
      ..write(obj.itemId)
      ..writeByte(3)
      ..write(obj.type)
      ..writeByte(4)
      ..write(obj.quantityChange)
      ..writeByte(5)
      ..write(obj.unit)
      ..writeByte(6)
      ..write(obj.date)
      ..writeByte(7)
      ..write(obj.createdAt)
      ..writeByte(8)
      ..write(obj.batchId)
      ..writeByte(9)
      ..write(obj.shedId)
      ..writeByte(10)
      ..write(obj.notes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InventoryTransactionModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class InventoryTransactionTypeAdapter
    extends TypeAdapter<InventoryTransactionType> {
  @override
  final int typeId = 13;

  @override
  InventoryTransactionType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return InventoryTransactionType.restock;
      case 1:
        return InventoryTransactionType.usage;
      case 2:
        return InventoryTransactionType.adjustment;
      case 3:
        return InventoryTransactionType.treatment;
      default:
        return InventoryTransactionType.restock;
    }
  }

  @override
  void write(BinaryWriter writer, InventoryTransactionType obj) {
    switch (obj) {
      case InventoryTransactionType.restock:
        writer.writeByte(0);
        break;
      case InventoryTransactionType.usage:
        writer.writeByte(1);
        break;
      case InventoryTransactionType.adjustment:
        writer.writeByte(2);
        break;
      case InventoryTransactionType.treatment:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InventoryTransactionTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
