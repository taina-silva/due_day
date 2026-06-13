// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'transaction_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

TransactionModel _$TransactionModelFromJson(Map<String, dynamic> json) {
  return _TransactionModel.fromJson(json);
}

/// @nodoc
mixin _$TransactionModel {
  String get id => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  String get type => throw _privateConstructorUsedError;
  double get amount => throw _privateConstructorUsedError;
  bool get paid => throw _privateConstructorUsedError;
  bool get isRecurring => throw _privateConstructorUsedError;
  @TimestampConverter()
  DateTime get createdAt => throw _privateConstructorUsedError;
  String? get category => throw _privateConstructorUsedError;
  String? get accountFrom => throw _privateConstructorUsedError;
  String? get accountTo => throw _privateConstructorUsedError;
  @NullableTimestampConverter()
  DateTime? get dueDate => throw _privateConstructorUsedError;
  @NullableTimestampConverter()
  DateTime? get paidDate => throw _privateConstructorUsedError;
  String? get frequency => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;
  String? get parentRecurringId => throw _privateConstructorUsedError;

  /// Serializes this TransactionModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TransactionModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TransactionModelCopyWith<TransactionModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TransactionModelCopyWith<$Res> {
  factory $TransactionModelCopyWith(
    TransactionModel value,
    $Res Function(TransactionModel) then,
  ) = _$TransactionModelCopyWithImpl<$Res, TransactionModel>;
  @useResult
  $Res call({
    String id,
    String userId,
    String type,
    double amount,
    bool paid,
    bool isRecurring,
    @TimestampConverter() DateTime createdAt,
    String? category,
    String? accountFrom,
    String? accountTo,
    @NullableTimestampConverter() DateTime? dueDate,
    @NullableTimestampConverter() DateTime? paidDate,
    String? frequency,
    String? notes,
    String? parentRecurringId,
  });
}

/// @nodoc
class _$TransactionModelCopyWithImpl<$Res, $Val extends TransactionModel>
    implements $TransactionModelCopyWith<$Res> {
  _$TransactionModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TransactionModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? type = null,
    Object? amount = null,
    Object? paid = null,
    Object? isRecurring = null,
    Object? createdAt = null,
    Object? category = freezed,
    Object? accountFrom = freezed,
    Object? accountTo = freezed,
    Object? dueDate = freezed,
    Object? paidDate = freezed,
    Object? frequency = freezed,
    Object? notes = freezed,
    Object? parentRecurringId = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            userId: null == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                      as String,
            type: null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                      as String,
            amount: null == amount
                ? _value.amount
                : amount // ignore: cast_nullable_to_non_nullable
                      as double,
            paid: null == paid
                ? _value.paid
                : paid // ignore: cast_nullable_to_non_nullable
                      as bool,
            isRecurring: null == isRecurring
                ? _value.isRecurring
                : isRecurring // ignore: cast_nullable_to_non_nullable
                      as bool,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            category: freezed == category
                ? _value.category
                : category // ignore: cast_nullable_to_non_nullable
                      as String?,
            accountFrom: freezed == accountFrom
                ? _value.accountFrom
                : accountFrom // ignore: cast_nullable_to_non_nullable
                      as String?,
            accountTo: freezed == accountTo
                ? _value.accountTo
                : accountTo // ignore: cast_nullable_to_non_nullable
                      as String?,
            dueDate: freezed == dueDate
                ? _value.dueDate
                : dueDate // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            paidDate: freezed == paidDate
                ? _value.paidDate
                : paidDate // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            frequency: freezed == frequency
                ? _value.frequency
                : frequency // ignore: cast_nullable_to_non_nullable
                      as String?,
            notes: freezed == notes
                ? _value.notes
                : notes // ignore: cast_nullable_to_non_nullable
                      as String?,
            parentRecurringId: freezed == parentRecurringId
                ? _value.parentRecurringId
                : parentRecurringId // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$TransactionModelImplCopyWith<$Res>
    implements $TransactionModelCopyWith<$Res> {
  factory _$$TransactionModelImplCopyWith(
    _$TransactionModelImpl value,
    $Res Function(_$TransactionModelImpl) then,
  ) = __$$TransactionModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String userId,
    String type,
    double amount,
    bool paid,
    bool isRecurring,
    @TimestampConverter() DateTime createdAt,
    String? category,
    String? accountFrom,
    String? accountTo,
    @NullableTimestampConverter() DateTime? dueDate,
    @NullableTimestampConverter() DateTime? paidDate,
    String? frequency,
    String? notes,
    String? parentRecurringId,
  });
}

/// @nodoc
class __$$TransactionModelImplCopyWithImpl<$Res>
    extends _$TransactionModelCopyWithImpl<$Res, _$TransactionModelImpl>
    implements _$$TransactionModelImplCopyWith<$Res> {
  __$$TransactionModelImplCopyWithImpl(
    _$TransactionModelImpl _value,
    $Res Function(_$TransactionModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of TransactionModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? type = null,
    Object? amount = null,
    Object? paid = null,
    Object? isRecurring = null,
    Object? createdAt = null,
    Object? category = freezed,
    Object? accountFrom = freezed,
    Object? accountTo = freezed,
    Object? dueDate = freezed,
    Object? paidDate = freezed,
    Object? frequency = freezed,
    Object? notes = freezed,
    Object? parentRecurringId = freezed,
  }) {
    return _then(
      _$TransactionModelImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String,
        type: null == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as String,
        amount: null == amount
            ? _value.amount
            : amount // ignore: cast_nullable_to_non_nullable
                  as double,
        paid: null == paid
            ? _value.paid
            : paid // ignore: cast_nullable_to_non_nullable
                  as bool,
        isRecurring: null == isRecurring
            ? _value.isRecurring
            : isRecurring // ignore: cast_nullable_to_non_nullable
                  as bool,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        category: freezed == category
            ? _value.category
            : category // ignore: cast_nullable_to_non_nullable
                  as String?,
        accountFrom: freezed == accountFrom
            ? _value.accountFrom
            : accountFrom // ignore: cast_nullable_to_non_nullable
                  as String?,
        accountTo: freezed == accountTo
            ? _value.accountTo
            : accountTo // ignore: cast_nullable_to_non_nullable
                  as String?,
        dueDate: freezed == dueDate
            ? _value.dueDate
            : dueDate // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        paidDate: freezed == paidDate
            ? _value.paidDate
            : paidDate // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        frequency: freezed == frequency
            ? _value.frequency
            : frequency // ignore: cast_nullable_to_non_nullable
                  as String?,
        notes: freezed == notes
            ? _value.notes
            : notes // ignore: cast_nullable_to_non_nullable
                  as String?,
        parentRecurringId: freezed == parentRecurringId
            ? _value.parentRecurringId
            : parentRecurringId // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$TransactionModelImpl extends _TransactionModel {
  const _$TransactionModelImpl({
    required this.id,
    required this.userId,
    required this.type,
    required this.amount,
    required this.paid,
    required this.isRecurring,
    @TimestampConverter() required this.createdAt,
    this.category,
    this.accountFrom,
    this.accountTo,
    @NullableTimestampConverter() this.dueDate,
    @NullableTimestampConverter() this.paidDate,
    this.frequency,
    this.notes,
    this.parentRecurringId,
  }) : super._();

  factory _$TransactionModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$TransactionModelImplFromJson(json);

  @override
  final String id;
  @override
  final String userId;
  @override
  final String type;
  @override
  final double amount;
  @override
  final bool paid;
  @override
  final bool isRecurring;
  @override
  @TimestampConverter()
  final DateTime createdAt;
  @override
  final String? category;
  @override
  final String? accountFrom;
  @override
  final String? accountTo;
  @override
  @NullableTimestampConverter()
  final DateTime? dueDate;
  @override
  @NullableTimestampConverter()
  final DateTime? paidDate;
  @override
  final String? frequency;
  @override
  final String? notes;
  @override
  final String? parentRecurringId;

  @override
  String toString() {
    return 'TransactionModel(id: $id, userId: $userId, type: $type, amount: $amount, paid: $paid, isRecurring: $isRecurring, createdAt: $createdAt, category: $category, accountFrom: $accountFrom, accountTo: $accountTo, dueDate: $dueDate, paidDate: $paidDate, frequency: $frequency, notes: $notes, parentRecurringId: $parentRecurringId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TransactionModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.amount, amount) || other.amount == amount) &&
            (identical(other.paid, paid) || other.paid == paid) &&
            (identical(other.isRecurring, isRecurring) ||
                other.isRecurring == isRecurring) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.accountFrom, accountFrom) ||
                other.accountFrom == accountFrom) &&
            (identical(other.accountTo, accountTo) ||
                other.accountTo == accountTo) &&
            (identical(other.dueDate, dueDate) || other.dueDate == dueDate) &&
            (identical(other.paidDate, paidDate) ||
                other.paidDate == paidDate) &&
            (identical(other.frequency, frequency) ||
                other.frequency == frequency) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.parentRecurringId, parentRecurringId) ||
                other.parentRecurringId == parentRecurringId));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    userId,
    type,
    amount,
    paid,
    isRecurring,
    createdAt,
    category,
    accountFrom,
    accountTo,
    dueDate,
    paidDate,
    frequency,
    notes,
    parentRecurringId,
  );

  /// Create a copy of TransactionModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TransactionModelImplCopyWith<_$TransactionModelImpl> get copyWith =>
      __$$TransactionModelImplCopyWithImpl<_$TransactionModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$TransactionModelImplToJson(this);
  }
}

abstract class _TransactionModel extends TransactionModel {
  const factory _TransactionModel({
    required final String id,
    required final String userId,
    required final String type,
    required final double amount,
    required final bool paid,
    required final bool isRecurring,
    @TimestampConverter() required final DateTime createdAt,
    final String? category,
    final String? accountFrom,
    final String? accountTo,
    @NullableTimestampConverter() final DateTime? dueDate,
    @NullableTimestampConverter() final DateTime? paidDate,
    final String? frequency,
    final String? notes,
    final String? parentRecurringId,
  }) = _$TransactionModelImpl;
  const _TransactionModel._() : super._();

  factory _TransactionModel.fromJson(Map<String, dynamic> json) =
      _$TransactionModelImpl.fromJson;

  @override
  String get id;
  @override
  String get userId;
  @override
  String get type;
  @override
  double get amount;
  @override
  bool get paid;
  @override
  bool get isRecurring;
  @override
  @TimestampConverter()
  DateTime get createdAt;
  @override
  String? get category;
  @override
  String? get accountFrom;
  @override
  String? get accountTo;
  @override
  @NullableTimestampConverter()
  DateTime? get dueDate;
  @override
  @NullableTimestampConverter()
  DateTime? get paidDate;
  @override
  String? get frequency;
  @override
  String? get notes;
  @override
  String? get parentRecurringId;

  /// Create a copy of TransactionModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TransactionModelImplCopyWith<_$TransactionModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
