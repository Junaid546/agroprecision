// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inventory_item_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class InventoryItemModelAdapter extends TypeAdapter<InventoryItemModel> {
  @override
  final int typeId = 16;

  @override
  InventoryItemModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return InventoryItemModel(
      id: fields[0] as String,
      farmId: fields[1] as String,
      name: fields[2] as String,
      category: fields[3] as InventoryCategory,
      quantity: fields[4] as double,
      unit: fields[5] as String,
      reorderLevel: fields[6] as double,
      createdAt: fields[7] as DateTime,
      updatedAt: fields[8] as DateTime,
      isActive: fields[9] as bool,
      shedId: fields[10] as String?,
      notes: fields[11] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, InventoryItemModel obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.farmId)
      ..writeByte(2)
      ..write(obj.name)
      ..writeByte(3)
      ..write(obj.category)
      ..writeByte(4)
      ..write(obj.quantity)
      ..writeByte(5)
      ..write(obj.unit)
      ..writeByte(6)
      ..write(obj.reorderLevel)
      ..writeByte(7)
      ..write(obj.createdAt)
      ..writeByte(8)
      ..write(obj.updatedAt)
      ..writeByte(9)
      ..write(obj.isActive)
      ..writeByte(10)
      ..write(obj.shedId)
      ..writeByte(11)
      ..write(obj.notes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InventoryItemModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class InventoryCategoryAdapter extends TypeAdapter<InventoryCategory> {
  @override
  final int typeId = 12;

  @override
  InventoryCategory read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return InventoryCategory.feed;
      case 1:
        return InventoryCategory.vaccine;
      case 2:
        return InventoryCategory.medicine;
      case 3:
        return InventoryCategory.disinfectant;
      case 4:
        return InventoryCategory.litter;
      case 5:
        return InventoryCategory.other;
      default:
        return InventoryCategory.feed;
    }
  }

  @override
  void write(BinaryWriter writer, InventoryCategory obj) {
    switch (obj) {
      case InventoryCategory.feed:
        writer.writeByte(0);
        break;
      case InventoryCategory.vaccine:
        writer.writeByte(1);
        break;
      case InventoryCategory.medicine:
        writer.writeByte(2);
        break;
      case InventoryCategory.disinfectant:
        writer.writeByte(3);
        break;
      case InventoryCategory.litter:
        writer.writeByte(4);
        break;
      case InventoryCategory.other:
        writer.writeByte(5);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InventoryCategoryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
