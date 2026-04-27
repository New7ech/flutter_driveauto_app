// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'lecon.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Lecon _$LeconFromJson(Map<String, dynamic> json) {
  return _Lecon.fromJson(json);
}

/// @nodoc
mixin _$Lecon {
  @HiveField(0)
  String get id => throw _privateConstructorUsedError;
  @HiveField(1)
  String get titre => throw _privateConstructorUsedError;
  @HiveField(2)
  String get categorie => throw _privateConstructorUsedError;
  @HiveField(3)
  String get texteRiche => throw _privateConstructorUsedError;
  @HiveField(4)
  String? get imageUrl => throw _privateConstructorUsedError;
  @HiveField(5)
  String? get youtubeVideoId => throw _privateConstructorUsedError;
  @HiveField(6)
  bool get isCompleted => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $LeconCopyWith<Lecon> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LeconCopyWith<$Res> {
  factory $LeconCopyWith(Lecon value, $Res Function(Lecon) then) =
      _$LeconCopyWithImpl<$Res, Lecon>;
  @useResult
  $Res call({
    @HiveField(0) String id,
    @HiveField(1) String titre,
    @HiveField(2) String categorie,
    @HiveField(3) String texteRiche,
    @HiveField(4) String? imageUrl,
    @HiveField(5) String? youtubeVideoId,
    @HiveField(6) bool isCompleted,
  });
}

/// @nodoc
class _$LeconCopyWithImpl<$Res, $Val extends Lecon>
    implements $LeconCopyWith<$Res> {
  _$LeconCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? titre = null,
    Object? categorie = null,
    Object? texteRiche = null,
    Object? imageUrl = freezed,
    Object? youtubeVideoId = freezed,
    Object? isCompleted = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            titre: null == titre
                ? _value.titre
                : titre // ignore: cast_nullable_to_non_nullable
                      as String,
            categorie: null == categorie
                ? _value.categorie
                : categorie // ignore: cast_nullable_to_non_nullable
                      as String,
            texteRiche: null == texteRiche
                ? _value.texteRiche
                : texteRiche // ignore: cast_nullable_to_non_nullable
                      as String,
            imageUrl: freezed == imageUrl
                ? _value.imageUrl
                : imageUrl // ignore: cast_nullable_to_non_nullable
                      as String?,
            youtubeVideoId: freezed == youtubeVideoId
                ? _value.youtubeVideoId
                : youtubeVideoId // ignore: cast_nullable_to_non_nullable
                      as String?,
            isCompleted: null == isCompleted
                ? _value.isCompleted
                : isCompleted // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$LeconImplCopyWith<$Res> implements $LeconCopyWith<$Res> {
  factory _$$LeconImplCopyWith(
    _$LeconImpl value,
    $Res Function(_$LeconImpl) then,
  ) = __$$LeconImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @HiveField(0) String id,
    @HiveField(1) String titre,
    @HiveField(2) String categorie,
    @HiveField(3) String texteRiche,
    @HiveField(4) String? imageUrl,
    @HiveField(5) String? youtubeVideoId,
    @HiveField(6) bool isCompleted,
  });
}

/// @nodoc
class __$$LeconImplCopyWithImpl<$Res>
    extends _$LeconCopyWithImpl<$Res, _$LeconImpl>
    implements _$$LeconImplCopyWith<$Res> {
  __$$LeconImplCopyWithImpl(
    _$LeconImpl _value,
    $Res Function(_$LeconImpl) _then,
  ) : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? titre = null,
    Object? categorie = null,
    Object? texteRiche = null,
    Object? imageUrl = freezed,
    Object? youtubeVideoId = freezed,
    Object? isCompleted = null,
  }) {
    return _then(
      _$LeconImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        titre: null == titre
            ? _value.titre
            : titre // ignore: cast_nullable_to_non_nullable
                  as String,
        categorie: null == categorie
            ? _value.categorie
            : categorie // ignore: cast_nullable_to_non_nullable
                  as String,
        texteRiche: null == texteRiche
            ? _value.texteRiche
            : texteRiche // ignore: cast_nullable_to_non_nullable
                  as String,
        imageUrl: freezed == imageUrl
            ? _value.imageUrl
            : imageUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
        youtubeVideoId: freezed == youtubeVideoId
            ? _value.youtubeVideoId
            : youtubeVideoId // ignore: cast_nullable_to_non_nullable
                  as String?,
        isCompleted: null == isCompleted
            ? _value.isCompleted
            : isCompleted // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
@HiveType(typeId: 0, adapterName: 'LeconAdapter')
class _$LeconImpl implements _Lecon {
  const _$LeconImpl({
    @HiveField(0) required this.id,
    @HiveField(1) required this.titre,
    @HiveField(2) required this.categorie,
    @HiveField(3) required this.texteRiche,
    @HiveField(4) this.imageUrl,
    @HiveField(5) this.youtubeVideoId,
    @HiveField(6) this.isCompleted = false,
  });

  factory _$LeconImpl.fromJson(Map<String, dynamic> json) =>
      _$$LeconImplFromJson(json);

  @override
  @HiveField(0)
  final String id;
  @override
  @HiveField(1)
  final String titre;
  @override
  @HiveField(2)
  final String categorie;
  @override
  @HiveField(3)
  final String texteRiche;
  @override
  @HiveField(4)
  final String? imageUrl;
  @override
  @HiveField(5)
  final String? youtubeVideoId;
  @override
  @JsonKey()
  @HiveField(6)
  final bool isCompleted;

  @override
  String toString() {
    return 'Lecon(id: $id, titre: $titre, categorie: $categorie, texteRiche: $texteRiche, imageUrl: $imageUrl, youtubeVideoId: $youtubeVideoId, isCompleted: $isCompleted)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LeconImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.titre, titre) || other.titre == titre) &&
            (identical(other.categorie, categorie) ||
                other.categorie == categorie) &&
            (identical(other.texteRiche, texteRiche) ||
                other.texteRiche == texteRiche) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl) &&
            (identical(other.youtubeVideoId, youtubeVideoId) ||
                other.youtubeVideoId == youtubeVideoId) &&
            (identical(other.isCompleted, isCompleted) ||
                other.isCompleted == isCompleted));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    titre,
    categorie,
    texteRiche,
    imageUrl,
    youtubeVideoId,
    isCompleted,
  );

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$LeconImplCopyWith<_$LeconImpl> get copyWith =>
      __$$LeconImplCopyWithImpl<_$LeconImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$LeconImplToJson(this);
  }
}

abstract class _Lecon implements Lecon {
  const factory _Lecon({
    @HiveField(0) required final String id,
    @HiveField(1) required final String titre,
    @HiveField(2) required final String categorie,
    @HiveField(3) required final String texteRiche,
    @HiveField(4) final String? imageUrl,
    @HiveField(5) final String? youtubeVideoId,
    @HiveField(6) final bool isCompleted,
  }) = _$LeconImpl;

  factory _Lecon.fromJson(Map<String, dynamic> json) = _$LeconImpl.fromJson;

  @override
  @HiveField(0)
  String get id;
  @override
  @HiveField(1)
  String get titre;
  @override
  @HiveField(2)
  String get categorie;
  @override
  @HiveField(3)
  String get texteRiche;
  @override
  @HiveField(4)
  String? get imageUrl;
  @override
  @HiveField(5)
  String? get youtubeVideoId;
  @override
  @HiveField(6)
  bool get isCompleted;
  @override
  @JsonKey(ignore: true)
  _$$LeconImplCopyWith<_$LeconImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
