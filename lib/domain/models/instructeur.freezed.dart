// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'instructeur.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Instructeur _$InstructeurFromJson(Map<String, dynamic> json) {
  return _Instructeur.fromJson(json);
}

/// @nodoc
mixin _$Instructeur {
  String get id => throw _privateConstructorUsedError;
  String get nom => throw _privateConstructorUsedError;
  String get prenom => throw _privateConstructorUsedError;
  String get telephone => throw _privateConstructorUsedError;
  String? get photoUrl => throw _privateConstructorUsedError;
  double get noteMoyenne => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $InstructeurCopyWith<Instructeur> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $InstructeurCopyWith<$Res> {
  factory $InstructeurCopyWith(
    Instructeur value,
    $Res Function(Instructeur) then,
  ) = _$InstructeurCopyWithImpl<$Res, Instructeur>;
  @useResult
  $Res call({
    String id,
    String nom,
    String prenom,
    String telephone,
    String? photoUrl,
    double noteMoyenne,
  });
}

/// @nodoc
class _$InstructeurCopyWithImpl<$Res, $Val extends Instructeur>
    implements $InstructeurCopyWith<$Res> {
  _$InstructeurCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? nom = null,
    Object? prenom = null,
    Object? telephone = null,
    Object? photoUrl = freezed,
    Object? noteMoyenne = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            nom: null == nom
                ? _value.nom
                : nom // ignore: cast_nullable_to_non_nullable
                      as String,
            prenom: null == prenom
                ? _value.prenom
                : prenom // ignore: cast_nullable_to_non_nullable
                      as String,
            telephone: null == telephone
                ? _value.telephone
                : telephone // ignore: cast_nullable_to_non_nullable
                      as String,
            photoUrl: freezed == photoUrl
                ? _value.photoUrl
                : photoUrl // ignore: cast_nullable_to_non_nullable
                      as String?,
            noteMoyenne: null == noteMoyenne
                ? _value.noteMoyenne
                : noteMoyenne // ignore: cast_nullable_to_non_nullable
                      as double,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$InstructeurImplCopyWith<$Res>
    implements $InstructeurCopyWith<$Res> {
  factory _$$InstructeurImplCopyWith(
    _$InstructeurImpl value,
    $Res Function(_$InstructeurImpl) then,
  ) = __$$InstructeurImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String nom,
    String prenom,
    String telephone,
    String? photoUrl,
    double noteMoyenne,
  });
}

/// @nodoc
class __$$InstructeurImplCopyWithImpl<$Res>
    extends _$InstructeurCopyWithImpl<$Res, _$InstructeurImpl>
    implements _$$InstructeurImplCopyWith<$Res> {
  __$$InstructeurImplCopyWithImpl(
    _$InstructeurImpl _value,
    $Res Function(_$InstructeurImpl) _then,
  ) : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? nom = null,
    Object? prenom = null,
    Object? telephone = null,
    Object? photoUrl = freezed,
    Object? noteMoyenne = null,
  }) {
    return _then(
      _$InstructeurImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        nom: null == nom
            ? _value.nom
            : nom // ignore: cast_nullable_to_non_nullable
                  as String,
        prenom: null == prenom
            ? _value.prenom
            : prenom // ignore: cast_nullable_to_non_nullable
                  as String,
        telephone: null == telephone
            ? _value.telephone
            : telephone // ignore: cast_nullable_to_non_nullable
                  as String,
        photoUrl: freezed == photoUrl
            ? _value.photoUrl
            : photoUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
        noteMoyenne: null == noteMoyenne
            ? _value.noteMoyenne
            : noteMoyenne // ignore: cast_nullable_to_non_nullable
                  as double,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$InstructeurImpl implements _Instructeur {
  const _$InstructeurImpl({
    required this.id,
    required this.nom,
    required this.prenom,
    required this.telephone,
    this.photoUrl,
    required this.noteMoyenne,
  });

  factory _$InstructeurImpl.fromJson(Map<String, dynamic> json) =>
      _$$InstructeurImplFromJson(json);

  @override
  final String id;
  @override
  final String nom;
  @override
  final String prenom;
  @override
  final String telephone;
  @override
  final String? photoUrl;
  @override
  final double noteMoyenne;

  @override
  String toString() {
    return 'Instructeur(id: $id, nom: $nom, prenom: $prenom, telephone: $telephone, photoUrl: $photoUrl, noteMoyenne: $noteMoyenne)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$InstructeurImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.nom, nom) || other.nom == nom) &&
            (identical(other.prenom, prenom) || other.prenom == prenom) &&
            (identical(other.telephone, telephone) ||
                other.telephone == telephone) &&
            (identical(other.photoUrl, photoUrl) ||
                other.photoUrl == photoUrl) &&
            (identical(other.noteMoyenne, noteMoyenne) ||
                other.noteMoyenne == noteMoyenne));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    nom,
    prenom,
    telephone,
    photoUrl,
    noteMoyenne,
  );

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$InstructeurImplCopyWith<_$InstructeurImpl> get copyWith =>
      __$$InstructeurImplCopyWithImpl<_$InstructeurImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$InstructeurImplToJson(this);
  }
}

abstract class _Instructeur implements Instructeur {
  const factory _Instructeur({
    required final String id,
    required final String nom,
    required final String prenom,
    required final String telephone,
    final String? photoUrl,
    required final double noteMoyenne,
  }) = _$InstructeurImpl;

  factory _Instructeur.fromJson(Map<String, dynamic> json) =
      _$InstructeurImpl.fromJson;

  @override
  String get id;
  @override
  String get nom;
  @override
  String get prenom;
  @override
  String get telephone;
  @override
  String? get photoUrl;
  @override
  double get noteMoyenne;
  @override
  @JsonKey(ignore: true)
  _$$InstructeurImplCopyWith<_$InstructeurImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
