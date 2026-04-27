// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'practice.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

ChecklistItem _$ChecklistItemFromJson(Map<String, dynamic> json) {
  return _ChecklistItem.fromJson(json);
}

/// @nodoc
mixin _$ChecklistItem {
  String get id => throw _privateConstructorUsedError;
  String get task => throw _privateConstructorUsedError;
  String get detail =>
      throw _privateConstructorUsedError; // Petite explication ou conseil
  bool get isChecked => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ChecklistItemCopyWith<ChecklistItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ChecklistItemCopyWith<$Res> {
  factory $ChecklistItemCopyWith(
    ChecklistItem value,
    $Res Function(ChecklistItem) then,
  ) = _$ChecklistItemCopyWithImpl<$Res, ChecklistItem>;
  @useResult
  $Res call({String id, String task, String detail, bool isChecked});
}

/// @nodoc
class _$ChecklistItemCopyWithImpl<$Res, $Val extends ChecklistItem>
    implements $ChecklistItemCopyWith<$Res> {
  _$ChecklistItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? task = null,
    Object? detail = null,
    Object? isChecked = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            task: null == task
                ? _value.task
                : task // ignore: cast_nullable_to_non_nullable
                      as String,
            detail: null == detail
                ? _value.detail
                : detail // ignore: cast_nullable_to_non_nullable
                      as String,
            isChecked: null == isChecked
                ? _value.isChecked
                : isChecked // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ChecklistItemImplCopyWith<$Res>
    implements $ChecklistItemCopyWith<$Res> {
  factory _$$ChecklistItemImplCopyWith(
    _$ChecklistItemImpl value,
    $Res Function(_$ChecklistItemImpl) then,
  ) = __$$ChecklistItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String id, String task, String detail, bool isChecked});
}

/// @nodoc
class __$$ChecklistItemImplCopyWithImpl<$Res>
    extends _$ChecklistItemCopyWithImpl<$Res, _$ChecklistItemImpl>
    implements _$$ChecklistItemImplCopyWith<$Res> {
  __$$ChecklistItemImplCopyWithImpl(
    _$ChecklistItemImpl _value,
    $Res Function(_$ChecklistItemImpl) _then,
  ) : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? task = null,
    Object? detail = null,
    Object? isChecked = null,
  }) {
    return _then(
      _$ChecklistItemImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        task: null == task
            ? _value.task
            : task // ignore: cast_nullable_to_non_nullable
                  as String,
        detail: null == detail
            ? _value.detail
            : detail // ignore: cast_nullable_to_non_nullable
                  as String,
        isChecked: null == isChecked
            ? _value.isChecked
            : isChecked // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ChecklistItemImpl implements _ChecklistItem {
  const _$ChecklistItemImpl({
    required this.id,
    required this.task,
    required this.detail,
    this.isChecked = false,
  });

  factory _$ChecklistItemImpl.fromJson(Map<String, dynamic> json) =>
      _$$ChecklistItemImplFromJson(json);

  @override
  final String id;
  @override
  final String task;
  @override
  final String detail;
  // Petite explication ou conseil
  @override
  @JsonKey()
  final bool isChecked;

  @override
  String toString() {
    return 'ChecklistItem(id: $id, task: $task, detail: $detail, isChecked: $isChecked)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ChecklistItemImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.task, task) || other.task == task) &&
            (identical(other.detail, detail) || other.detail == detail) &&
            (identical(other.isChecked, isChecked) ||
                other.isChecked == isChecked));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, task, detail, isChecked);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ChecklistItemImplCopyWith<_$ChecklistItemImpl> get copyWith =>
      __$$ChecklistItemImplCopyWithImpl<_$ChecklistItemImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ChecklistItemImplToJson(this);
  }
}

abstract class _ChecklistItem implements ChecklistItem {
  const factory _ChecklistItem({
    required final String id,
    required final String task,
    required final String detail,
    final bool isChecked,
  }) = _$ChecklistItemImpl;

  factory _ChecklistItem.fromJson(Map<String, dynamic> json) =
      _$ChecklistItemImpl.fromJson;

  @override
  String get id;
  @override
  String get task;
  @override
  String get detail;
  @override // Petite explication ou conseil
  bool get isChecked;
  @override
  @JsonKey(ignore: true)
  _$$ChecklistItemImplCopyWith<_$ChecklistItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

PracticeSession _$PracticeSessionFromJson(Map<String, dynamic> json) {
  return _PracticeSession.fromJson(json);
}

/// @nodoc
mixin _$PracticeSession {
  String get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  String get category =>
      throw _privateConstructorUsedError; // ex: 'Vérifications intérieures', 'Manoeuvres'
  List<ChecklistItem> get items => throw _privateConstructorUsedError;
  bool get isCompleted => throw _privateConstructorUsedError;
  String? get imageUrl => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $PracticeSessionCopyWith<PracticeSession> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PracticeSessionCopyWith<$Res> {
  factory $PracticeSessionCopyWith(
    PracticeSession value,
    $Res Function(PracticeSession) then,
  ) = _$PracticeSessionCopyWithImpl<$Res, PracticeSession>;
  @useResult
  $Res call({
    String id,
    String title,
    String description,
    String category,
    List<ChecklistItem> items,
    bool isCompleted,
    String? imageUrl,
  });
}

/// @nodoc
class _$PracticeSessionCopyWithImpl<$Res, $Val extends PracticeSession>
    implements $PracticeSessionCopyWith<$Res> {
  _$PracticeSessionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? description = null,
    Object? category = null,
    Object? items = null,
    Object? isCompleted = null,
    Object? imageUrl = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            title: null == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String,
            description: null == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String,
            category: null == category
                ? _value.category
                : category // ignore: cast_nullable_to_non_nullable
                      as String,
            items: null == items
                ? _value.items
                : items // ignore: cast_nullable_to_non_nullable
                      as List<ChecklistItem>,
            isCompleted: null == isCompleted
                ? _value.isCompleted
                : isCompleted // ignore: cast_nullable_to_non_nullable
                      as bool,
            imageUrl: freezed == imageUrl
                ? _value.imageUrl
                : imageUrl // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$PracticeSessionImplCopyWith<$Res>
    implements $PracticeSessionCopyWith<$Res> {
  factory _$$PracticeSessionImplCopyWith(
    _$PracticeSessionImpl value,
    $Res Function(_$PracticeSessionImpl) then,
  ) = __$$PracticeSessionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String title,
    String description,
    String category,
    List<ChecklistItem> items,
    bool isCompleted,
    String? imageUrl,
  });
}

/// @nodoc
class __$$PracticeSessionImplCopyWithImpl<$Res>
    extends _$PracticeSessionCopyWithImpl<$Res, _$PracticeSessionImpl>
    implements _$$PracticeSessionImplCopyWith<$Res> {
  __$$PracticeSessionImplCopyWithImpl(
    _$PracticeSessionImpl _value,
    $Res Function(_$PracticeSessionImpl) _then,
  ) : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? description = null,
    Object? category = null,
    Object? items = null,
    Object? isCompleted = null,
    Object? imageUrl = freezed,
  }) {
    return _then(
      _$PracticeSessionImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        title: null == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
        description: null == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String,
        category: null == category
            ? _value.category
            : category // ignore: cast_nullable_to_non_nullable
                  as String,
        items: null == items
            ? _value._items
            : items // ignore: cast_nullable_to_non_nullable
                  as List<ChecklistItem>,
        isCompleted: null == isCompleted
            ? _value.isCompleted
            : isCompleted // ignore: cast_nullable_to_non_nullable
                  as bool,
        imageUrl: freezed == imageUrl
            ? _value.imageUrl
            : imageUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$PracticeSessionImpl implements _PracticeSession {
  const _$PracticeSessionImpl({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required final List<ChecklistItem> items,
    this.isCompleted = false,
    this.imageUrl,
  }) : _items = items;

  factory _$PracticeSessionImpl.fromJson(Map<String, dynamic> json) =>
      _$$PracticeSessionImplFromJson(json);

  @override
  final String id;
  @override
  final String title;
  @override
  final String description;
  @override
  final String category;
  // ex: 'Vérifications intérieures', 'Manoeuvres'
  final List<ChecklistItem> _items;
  // ex: 'Vérifications intérieures', 'Manoeuvres'
  @override
  List<ChecklistItem> get items {
    if (_items is EqualUnmodifiableListView) return _items;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_items);
  }

  @override
  @JsonKey()
  final bool isCompleted;
  @override
  final String? imageUrl;

  @override
  String toString() {
    return 'PracticeSession(id: $id, title: $title, description: $description, category: $category, items: $items, isCompleted: $isCompleted, imageUrl: $imageUrl)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PracticeSessionImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.category, category) ||
                other.category == category) &&
            const DeepCollectionEquality().equals(other._items, _items) &&
            (identical(other.isCompleted, isCompleted) ||
                other.isCompleted == isCompleted) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    title,
    description,
    category,
    const DeepCollectionEquality().hash(_items),
    isCompleted,
    imageUrl,
  );

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$PracticeSessionImplCopyWith<_$PracticeSessionImpl> get copyWith =>
      __$$PracticeSessionImplCopyWithImpl<_$PracticeSessionImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$PracticeSessionImplToJson(this);
  }
}

abstract class _PracticeSession implements PracticeSession {
  const factory _PracticeSession({
    required final String id,
    required final String title,
    required final String description,
    required final String category,
    required final List<ChecklistItem> items,
    final bool isCompleted,
    final String? imageUrl,
  }) = _$PracticeSessionImpl;

  factory _PracticeSession.fromJson(Map<String, dynamic> json) =
      _$PracticeSessionImpl.fromJson;

  @override
  String get id;
  @override
  String get title;
  @override
  String get description;
  @override
  String get category;
  @override // ex: 'Vérifications intérieures', 'Manoeuvres'
  List<ChecklistItem> get items;
  @override
  bool get isCompleted;
  @override
  String? get imageUrl;
  @override
  @JsonKey(ignore: true)
  _$$PracticeSessionImplCopyWith<_$PracticeSessionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
