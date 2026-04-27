// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'quiz.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Quiz _$QuizFromJson(Map<String, dynamic> json) {
  return _Quiz.fromJson(json);
}

/// @nodoc
mixin _$Quiz {
  @HiveField(0)
  String get id => throw _privateConstructorUsedError;
  @HiveField(1)
  String get titre => throw _privateConstructorUsedError;
  @HiveField(2)
  String get categorie => throw _privateConstructorUsedError;
  @HiveField(3)
  List<Question> get questions => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $QuizCopyWith<Quiz> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $QuizCopyWith<$Res> {
  factory $QuizCopyWith(Quiz value, $Res Function(Quiz) then) =
      _$QuizCopyWithImpl<$Res, Quiz>;
  @useResult
  $Res call({
    @HiveField(0) String id,
    @HiveField(1) String titre,
    @HiveField(2) String categorie,
    @HiveField(3) List<Question> questions,
  });
}

/// @nodoc
class _$QuizCopyWithImpl<$Res, $Val extends Quiz>
    implements $QuizCopyWith<$Res> {
  _$QuizCopyWithImpl(this._value, this._then);

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
    Object? questions = null,
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
            questions: null == questions
                ? _value.questions
                : questions // ignore: cast_nullable_to_non_nullable
                      as List<Question>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$QuizImplCopyWith<$Res> implements $QuizCopyWith<$Res> {
  factory _$$QuizImplCopyWith(
    _$QuizImpl value,
    $Res Function(_$QuizImpl) then,
  ) = __$$QuizImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @HiveField(0) String id,
    @HiveField(1) String titre,
    @HiveField(2) String categorie,
    @HiveField(3) List<Question> questions,
  });
}

/// @nodoc
class __$$QuizImplCopyWithImpl<$Res>
    extends _$QuizCopyWithImpl<$Res, _$QuizImpl>
    implements _$$QuizImplCopyWith<$Res> {
  __$$QuizImplCopyWithImpl(_$QuizImpl _value, $Res Function(_$QuizImpl) _then)
    : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? titre = null,
    Object? categorie = null,
    Object? questions = null,
  }) {
    return _then(
      _$QuizImpl(
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
        questions: null == questions
            ? _value._questions
            : questions // ignore: cast_nullable_to_non_nullable
                  as List<Question>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
@HiveType(typeId: 1, adapterName: 'QuizAdapter')
class _$QuizImpl implements _Quiz {
  const _$QuizImpl({
    @HiveField(0) required this.id,
    @HiveField(1) required this.titre,
    @HiveField(2) required this.categorie,
    @HiveField(3) required final List<Question> questions,
  }) : _questions = questions;

  factory _$QuizImpl.fromJson(Map<String, dynamic> json) =>
      _$$QuizImplFromJson(json);

  @override
  @HiveField(0)
  final String id;
  @override
  @HiveField(1)
  final String titre;
  @override
  @HiveField(2)
  final String categorie;
  final List<Question> _questions;
  @override
  @HiveField(3)
  List<Question> get questions {
    if (_questions is EqualUnmodifiableListView) return _questions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_questions);
  }

  @override
  String toString() {
    return 'Quiz(id: $id, titre: $titre, categorie: $categorie, questions: $questions)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$QuizImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.titre, titre) || other.titre == titre) &&
            (identical(other.categorie, categorie) ||
                other.categorie == categorie) &&
            const DeepCollectionEquality().equals(
              other._questions,
              _questions,
            ));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    titre,
    categorie,
    const DeepCollectionEquality().hash(_questions),
  );

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$QuizImplCopyWith<_$QuizImpl> get copyWith =>
      __$$QuizImplCopyWithImpl<_$QuizImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$QuizImplToJson(this);
  }
}

abstract class _Quiz implements Quiz {
  const factory _Quiz({
    @HiveField(0) required final String id,
    @HiveField(1) required final String titre,
    @HiveField(2) required final String categorie,
    @HiveField(3) required final List<Question> questions,
  }) = _$QuizImpl;

  factory _Quiz.fromJson(Map<String, dynamic> json) = _$QuizImpl.fromJson;

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
  List<Question> get questions;
  @override
  @JsonKey(ignore: true)
  _$$QuizImplCopyWith<_$QuizImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Question _$QuestionFromJson(Map<String, dynamic> json) {
  return _Question.fromJson(json);
}

/// @nodoc
mixin _$Question {
  @HiveField(0)
  String get id => throw _privateConstructorUsedError;
  @HiveField(1)
  String get texte => throw _privateConstructorUsedError;
  @HiveField(2)
  List<String> get options => throw _privateConstructorUsedError;
  @HiveField(3)
  int get correctAnswerIndex => throw _privateConstructorUsedError;
  @HiveField(4)
  String? get explication => throw _privateConstructorUsedError;
  @HiveField(5)
  String? get imageUrl => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $QuestionCopyWith<Question> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $QuestionCopyWith<$Res> {
  factory $QuestionCopyWith(Question value, $Res Function(Question) then) =
      _$QuestionCopyWithImpl<$Res, Question>;
  @useResult
  $Res call({
    @HiveField(0) String id,
    @HiveField(1) String texte,
    @HiveField(2) List<String> options,
    @HiveField(3) int correctAnswerIndex,
    @HiveField(4) String? explication,
    @HiveField(5) String? imageUrl,
  });
}

/// @nodoc
class _$QuestionCopyWithImpl<$Res, $Val extends Question>
    implements $QuestionCopyWith<$Res> {
  _$QuestionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? texte = null,
    Object? options = null,
    Object? correctAnswerIndex = null,
    Object? explication = freezed,
    Object? imageUrl = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            texte: null == texte
                ? _value.texte
                : texte // ignore: cast_nullable_to_non_nullable
                      as String,
            options: null == options
                ? _value.options
                : options // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            correctAnswerIndex: null == correctAnswerIndex
                ? _value.correctAnswerIndex
                : correctAnswerIndex // ignore: cast_nullable_to_non_nullable
                      as int,
            explication: freezed == explication
                ? _value.explication
                : explication // ignore: cast_nullable_to_non_nullable
                      as String?,
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
abstract class _$$QuestionImplCopyWith<$Res>
    implements $QuestionCopyWith<$Res> {
  factory _$$QuestionImplCopyWith(
    _$QuestionImpl value,
    $Res Function(_$QuestionImpl) then,
  ) = __$$QuestionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @HiveField(0) String id,
    @HiveField(1) String texte,
    @HiveField(2) List<String> options,
    @HiveField(3) int correctAnswerIndex,
    @HiveField(4) String? explication,
    @HiveField(5) String? imageUrl,
  });
}

/// @nodoc
class __$$QuestionImplCopyWithImpl<$Res>
    extends _$QuestionCopyWithImpl<$Res, _$QuestionImpl>
    implements _$$QuestionImplCopyWith<$Res> {
  __$$QuestionImplCopyWithImpl(
    _$QuestionImpl _value,
    $Res Function(_$QuestionImpl) _then,
  ) : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? texte = null,
    Object? options = null,
    Object? correctAnswerIndex = null,
    Object? explication = freezed,
    Object? imageUrl = freezed,
  }) {
    return _then(
      _$QuestionImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        texte: null == texte
            ? _value.texte
            : texte // ignore: cast_nullable_to_non_nullable
                  as String,
        options: null == options
            ? _value._options
            : options // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        correctAnswerIndex: null == correctAnswerIndex
            ? _value.correctAnswerIndex
            : correctAnswerIndex // ignore: cast_nullable_to_non_nullable
                  as int,
        explication: freezed == explication
            ? _value.explication
            : explication // ignore: cast_nullable_to_non_nullable
                  as String?,
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
@HiveType(typeId: 2, adapterName: 'QuestionAdapter')
class _$QuestionImpl implements _Question {
  const _$QuestionImpl({
    @HiveField(0) required this.id,
    @HiveField(1) required this.texte,
    @HiveField(2) required final List<String> options,
    @HiveField(3) required this.correctAnswerIndex,
    @HiveField(4) this.explication,
    @HiveField(5) this.imageUrl,
  }) : _options = options;

  factory _$QuestionImpl.fromJson(Map<String, dynamic> json) =>
      _$$QuestionImplFromJson(json);

  @override
  @HiveField(0)
  final String id;
  @override
  @HiveField(1)
  final String texte;
  final List<String> _options;
  @override
  @HiveField(2)
  List<String> get options {
    if (_options is EqualUnmodifiableListView) return _options;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_options);
  }

  @override
  @HiveField(3)
  final int correctAnswerIndex;
  @override
  @HiveField(4)
  final String? explication;
  @override
  @HiveField(5)
  final String? imageUrl;

  @override
  String toString() {
    return 'Question(id: $id, texte: $texte, options: $options, correctAnswerIndex: $correctAnswerIndex, explication: $explication, imageUrl: $imageUrl)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$QuestionImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.texte, texte) || other.texte == texte) &&
            const DeepCollectionEquality().equals(other._options, _options) &&
            (identical(other.correctAnswerIndex, correctAnswerIndex) ||
                other.correctAnswerIndex == correctAnswerIndex) &&
            (identical(other.explication, explication) ||
                other.explication == explication) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    texte,
    const DeepCollectionEquality().hash(_options),
    correctAnswerIndex,
    explication,
    imageUrl,
  );

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$QuestionImplCopyWith<_$QuestionImpl> get copyWith =>
      __$$QuestionImplCopyWithImpl<_$QuestionImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$QuestionImplToJson(this);
  }
}

abstract class _Question implements Question {
  const factory _Question({
    @HiveField(0) required final String id,
    @HiveField(1) required final String texte,
    @HiveField(2) required final List<String> options,
    @HiveField(3) required final int correctAnswerIndex,
    @HiveField(4) final String? explication,
    @HiveField(5) final String? imageUrl,
  }) = _$QuestionImpl;

  factory _Question.fromJson(Map<String, dynamic> json) =
      _$QuestionImpl.fromJson;

  @override
  @HiveField(0)
  String get id;
  @override
  @HiveField(1)
  String get texte;
  @override
  @HiveField(2)
  List<String> get options;
  @override
  @HiveField(3)
  int get correctAnswerIndex;
  @override
  @HiveField(4)
  String? get explication;
  @override
  @HiveField(5)
  String? get imageUrl;
  @override
  @JsonKey(ignore: true)
  _$$QuestionImplCopyWith<_$QuestionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
