// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'city.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CityModelAdapter extends TypeAdapter<CityModel> {
  @override
  final int typeId = 3;

  @override
  CityModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CityModel(
      id: fields[0] as int,
      name: fields[1] as String,
      latitude: fields[2] as double,
      longitude: fields[3] as double,
    );
  }

  @override
  void write(BinaryWriter writer, CityModel obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.latitude)
      ..writeByte(3)
      ..write(obj.longitude);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CityModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
