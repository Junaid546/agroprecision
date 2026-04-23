// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sale_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SaleModelAdapter extends TypeAdapter<SaleModel> {
  @override
  final int typeId = 6;

  @override
  SaleModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SaleModel(
      id: fields[0] as String,
      batchId: fields[1] as String,
      farmId: fields[2] as String,
      birdsSold: fields[3] as int,
      pricePerKg: fields[4] as double,
      averageWeightKg: fields[5] as double,
      totalRevenue: fields[6] as double,
      saleDate: fields[7] as DateTime,
      buyerName: fields[8] as String?,
      notes: fields[9] as String?,
      createdAt: fields[10] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, SaleModel obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.batchId)
      ..writeByte(2)
      ..write(obj.farmId)
      ..writeByte(3)
      ..write(obj.birdsSold)
      ..writeByte(4)
      ..write(obj.pricePerKg)
      ..writeByte(5)
      ..write(obj.averageWeightKg)
      ..writeByte(6)
      ..write(obj.totalRevenue)
      ..writeByte(7)
      ..write(obj.saleDate)
      ..writeByte(8)
      ..write(obj.buyerName)
      ..writeByte(9)
      ..write(obj.notes)
      ..writeByte(10)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SaleModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
