// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sync_task.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SyncTaskAdapter extends TypeAdapter<SyncTask> {
  @override
  final int typeId = 1;

  @override
  SyncTask read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SyncTask()
      ..taskId = fields[0] as String
      ..action = fields[1] as String
      ..payload = fields[2] as String
      ..createdAt = fields[3] as DateTime
      ..retryCount = fields[4] as int;
  }

  @override
  void write(BinaryWriter writer, SyncTask obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.taskId)
      ..writeByte(1)
      ..write(obj.action)
      ..writeByte(2)
      ..write(obj.payload)
      ..writeByte(3)
      ..write(obj.createdAt)
      ..writeByte(4)
      ..write(obj.retryCount);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SyncTaskAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
