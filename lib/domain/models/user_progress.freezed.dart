// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_progress.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

UserProgress _$UserProgressFromJson(Map<String, dynamic> json) {
  return _UserProgress.fromJson(json);
}

/// @nodoc
mixin _$UserProgress {
  String get userId => throw _privateConstructorUsedError;
  double get globalScore => throw _privateConstructorUsedError;
  int get totalLessonsCompleted => throw _privateConstructorUsedError;
  int get totalQuizzesPassed => throw _privateConstructorUsedError;
  List<String> get completedLessonIds => throw _privateConstructorUsedError;
  DateTime? get nextPracticalLessonDate => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $UserProgressCopyWith<UserProgress> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserProgressCopyWith<$Res> {
  factory $UserProgressCopyWith(
    UserProgress value,
    $Res Function(UserProgress) then,
  ) = _$UserProgressCopyWithImpl<$Res, UserProgress>;
  @useResult
  $Res call({
    String userId,
    double globalScore,
    int totalLessonsCompleted,
    int totalQuizzesPassed,
    List<String> completedLessonIds,
    DateTime? nextPracticalLessonDate,
  });
}

/// @nodoc
class _$UserProgressCopyWithImpl<$Res, $Val extends UserProgress>
    implements $UserProgressCopyWith<$Res> {
  _$UserProgressCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? globalScore = null,
    Object? totalLessonsCompleted = null,
    Object? totalQuizzesPassed = null,
    Object? completedLessonIds = null,
    Object? nextPracticalLessonDate = freezed,
  }) {
    return _then(
      _value.copyWith(
            userId: null == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                      as String,
            globalScore: null == globalScore
                ? _value.globalScore
                : globalScore // ignore: cast_nullable_to_non_nullable
                      as double,
            totalLessonsCompleted: null == totalLessonsCompleted
                ? _value.totalLessonsCompleted
                : totalLessonsCompleted // ignore: cast_nullable_to_non_nullable
                      as int,
            totalQuizzesPassed: null == totalQuizzesPassed
                ? _value.totalQuizzesPassed
                : totalQuizzesPassed // ignore: cast_nullable_to_non_nullable
                      as int,
            completedLessonIds: null == completedLessonIds
                ? _value.completedLessonIds
                : completedLessonIds // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            nextPracticalLessonDate: freezed == nextPracticalLessonDate
                ? _value.nextPracticalLessonDate
                : nextPracticalLessonDate // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$UserProgressImplCopyWith<$Res>
    implements $UserProgressCopyWith<$Res> {
  factory _$$UserProgressImplCopyWith(
    _$UserProgressImpl value,
    $Res Function(_$UserProgressImpl) then,
  ) = __$$UserProgressImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String userId,
    double globalScore,
    int totalLessonsCompleted,
    int totalQuizzesPassed,
    List<String> completedLessonIds,
    DateTime? nextPracticalLessonDate,
  });
}

/// @nodoc
class __$$UserProgressImplCopyWithImpl<$Res>
    extends _$UserProgressCopyWithImpl<$Res, _$UserProgressImpl>
    implements _$$UserProgressImplCopyWith<$Res> {
  __$$UserProgressImplCopyWithImpl(
    _$UserProgressImpl _value,
    $Res Function(_$UserProgressImpl) _then,
  ) : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? globalScore = null,
    Object? totalLessonsCompleted = null,
    Object? totalQuizzesPassed = null,
    Object? completedLessonIds = null,
    Object? nextPracticalLessonDate = freezed,
  }) {
    return _then(
      _$UserProgressImpl(
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String,
        globalScore: null == globalScore
            ? _value.globalScore
            : globalScore // ignore: cast_nullable_to_non_nullable
                  as double,
        totalLessonsCompleted: null == totalLessonsCompleted
            ? _value.totalLessonsCompleted
            : totalLessonsCompleted // ignore: cast_nullable_to_non_nullable
                  as int,
        totalQuizzesPassed: null == totalQuizzesPassed
            ? _value.totalQuizzesPassed
            : totalQuizzesPassed // ignore: cast_nullable_to_non_nullable
                  as int,
        completedLessonIds: null == completedLessonIds
            ? _value._completedLessonIds
            : completedLessonIds // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        nextPracticalLessonDate: freezed == nextPracticalLessonDate
            ? _value.nextPracticalLessonDate
            : nextPracticalLessonDate // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$UserProgressImpl implements _UserProgress {
  const _$UserProgressImpl({
    required this.userId,
    required this.globalScore,
    required this.totalLessonsCompleted,
    required this.totalQuizzesPassed,
    required final List<String> completedLessonIds,
    this.nextPracticalLessonDate,
  }) : _completedLessonIds = completedLessonIds;

  factory _$UserProgressImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserProgressImplFromJson(json);

  @override
  final String userId;
  @override
  final double globalScore;
  @override
  final int totalLessonsCompleted;
  @override
  final int totalQuizzesPassed;
  final List<String> _completedLessonIds;
  @override
  List<String> get completedLessonIds {
    if (_completedLessonIds is EqualUnmodifiableListView)
      return _completedLessonIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_completedLessonIds);
  }

  @override
  final DateTime? nextPracticalLessonDate;

  @override
  String toString() {
    return 'UserProgress(userId: $userId, globalScore: $globalScore, totalLessonsCompleted: $totalLessonsCompleted, totalQuizzesPassed: $totalQuizzesPassed, completedLessonIds: $completedLessonIds, nextPracticalLessonDate: $nextPracticalLessonDate)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserProgressImpl &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.globalScore, globalScore) ||
                other.globalScore == globalScore) &&
            (identical(other.totalLessonsCompleted, totalLessonsCompleted) ||
                other.totalLessonsCompleted == totalLessonsCompleted) &&
            (identical(other.totalQuizzesPassed, totalQuizzesPassed) ||
                other.totalQuizzesPassed == totalQuizzesPassed) &&
            const DeepCollectionEquality().equals(
              other._completedLessonIds,
              _completedLessonIds,
            ) &&
            (identical(
                  other.nextPracticalLessonDate,
                  nextPracticalLessonDate,
                ) ||
                other.nextPracticalLessonDate == nextPracticalLessonDate));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    userId,
    globalScore,
    totalLessonsCompleted,
    totalQuizzesPassed,
    const DeepCollectionEquality().hash(_completedLessonIds),
    nextPracticalLessonDate,
  );

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$UserProgressImplCopyWith<_$UserProgressImpl> get copyWith =>
      __$$UserProgressImplCopyWithImpl<_$UserProgressImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UserProgressImplToJson(this);
  }
}

abstract class _UserProgress implements UserProgress {
  const factory _UserProgress({
    required final String userId,
    required final double globalScore,
    required final int totalLessonsCompleted,
    required final int totalQuizzesPassed,
    required final List<String> completedLessonIds,
    final DateTime? nextPracticalLessonDate,
  }) = _$UserProgressImpl;

  factory _UserProgress.fromJson(Map<String, dynamic> json) =
      _$UserProgressImpl.fromJson;

  @override
  String get userId;
  @override
  double get globalScore;
  @override
  int get totalLessonsCompleted;
  @override
  int get totalQuizzesPassed;
  @override
  List<String> get completedLessonIds;
  @override
  DateTime? get nextPracticalLessonDate;
  @override
  @JsonKey(ignore: true)
  _$$UserProgressImplCopyWith<_$UserProgressImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
