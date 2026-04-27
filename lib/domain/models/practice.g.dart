// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'practice.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ChecklistItemImpl _$$ChecklistItemImplFromJson(Map<String, dynamic> json) =>
    _$ChecklistItemImpl(
      id: json['id'] as String,
      task: json['task'] as String,
      detail: json['detail'] as String,
      isChecked: json['isChecked'] as bool? ?? false,
    );

Map<String, dynamic> _$$ChecklistItemImplToJson(_$ChecklistItemImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'task': instance.task,
      'detail': instance.detail,
      'isChecked': instance.isChecked,
    };

_$PracticeSessionImpl _$$PracticeSessionImplFromJson(
  Map<String, dynamic> json,
) => _$PracticeSessionImpl(
  id: json['id'] as String,
  title: json['title'] as String,
  description: json['description'] as String,
  category: json['category'] as String,
  items: (json['items'] as List<dynamic>)
      .map((e) => ChecklistItem.fromJson(e as Map<String, dynamic>))
      .toList(),
  isCompleted: json['isCompleted'] as bool? ?? false,
  imageUrl: json['imageUrl'] as String?,
);

Map<String, dynamic> _$$PracticeSessionImplToJson(
  _$PracticeSessionImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'description': instance.description,
  'category': instance.category,
  'items': instance.items,
  'isCompleted': instance.isCompleted,
  'imageUrl': instance.imageUrl,
};
