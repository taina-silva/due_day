// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'transaction_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$TransactionModel {

 String get id; String get userId; String get type; double get amount; bool get paid; bool get isRecurring;@TimestampConverter() DateTime get createdAt; String? get category; String? get accountFrom; String? get accountTo;@NullableTimestampConverter() DateTime? get dueDate;@NullableTimestampConverter() DateTime? get paidDate; String? get frequency; String? get notes; String? get parentRecurringId;
/// Create a copy of TransactionModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TransactionModelCopyWith<TransactionModel> get copyWith => _$TransactionModelCopyWithImpl<TransactionModel>(this as TransactionModel, _$identity);

  /// Serializes this TransactionModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TransactionModel&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.type, type) || other.type == type)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.paid, paid) || other.paid == paid)&&(identical(other.isRecurring, isRecurring) || other.isRecurring == isRecurring)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.category, category) || other.category == category)&&(identical(other.accountFrom, accountFrom) || other.accountFrom == accountFrom)&&(identical(other.accountTo, accountTo) || other.accountTo == accountTo)&&(identical(other.dueDate, dueDate) || other.dueDate == dueDate)&&(identical(other.paidDate, paidDate) || other.paidDate == paidDate)&&(identical(other.frequency, frequency) || other.frequency == frequency)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.parentRecurringId, parentRecurringId) || other.parentRecurringId == parentRecurringId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,type,amount,paid,isRecurring,createdAt,category,accountFrom,accountTo,dueDate,paidDate,frequency,notes,parentRecurringId);

@override
String toString() {
  return 'TransactionModel(id: $id, userId: $userId, type: $type, amount: $amount, paid: $paid, isRecurring: $isRecurring, createdAt: $createdAt, category: $category, accountFrom: $accountFrom, accountTo: $accountTo, dueDate: $dueDate, paidDate: $paidDate, frequency: $frequency, notes: $notes, parentRecurringId: $parentRecurringId)';
}


}

/// @nodoc
abstract mixin class $TransactionModelCopyWith<$Res>  {
  factory $TransactionModelCopyWith(TransactionModel value, $Res Function(TransactionModel) _then) = _$TransactionModelCopyWithImpl;
@useResult
$Res call({
 String id, String userId, String type, double amount, bool paid, bool isRecurring,@TimestampConverter() DateTime createdAt, String? category, String? accountFrom, String? accountTo,@NullableTimestampConverter() DateTime? dueDate,@NullableTimestampConverter() DateTime? paidDate, String? frequency, String? notes, String? parentRecurringId
});




}
/// @nodoc
class _$TransactionModelCopyWithImpl<$Res>
    implements $TransactionModelCopyWith<$Res> {
  _$TransactionModelCopyWithImpl(this._self, this._then);

  final TransactionModel _self;
  final $Res Function(TransactionModel) _then;

/// Create a copy of TransactionModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? userId = null,Object? type = null,Object? amount = null,Object? paid = null,Object? isRecurring = null,Object? createdAt = null,Object? category = freezed,Object? accountFrom = freezed,Object? accountTo = freezed,Object? dueDate = freezed,Object? paidDate = freezed,Object? frequency = freezed,Object? notes = freezed,Object? parentRecurringId = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,paid: null == paid ? _self.paid : paid // ignore: cast_nullable_to_non_nullable
as bool,isRecurring: null == isRecurring ? _self.isRecurring : isRecurring // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,category: freezed == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String?,accountFrom: freezed == accountFrom ? _self.accountFrom : accountFrom // ignore: cast_nullable_to_non_nullable
as String?,accountTo: freezed == accountTo ? _self.accountTo : accountTo // ignore: cast_nullable_to_non_nullable
as String?,dueDate: freezed == dueDate ? _self.dueDate : dueDate // ignore: cast_nullable_to_non_nullable
as DateTime?,paidDate: freezed == paidDate ? _self.paidDate : paidDate // ignore: cast_nullable_to_non_nullable
as DateTime?,frequency: freezed == frequency ? _self.frequency : frequency // ignore: cast_nullable_to_non_nullable
as String?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,parentRecurringId: freezed == parentRecurringId ? _self.parentRecurringId : parentRecurringId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [TransactionModel].
extension TransactionModelPatterns on TransactionModel {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TransactionModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TransactionModel() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TransactionModel value)  $default,){
final _that = this;
switch (_that) {
case _TransactionModel():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TransactionModel value)?  $default,){
final _that = this;
switch (_that) {
case _TransactionModel() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String userId,  String type,  double amount,  bool paid,  bool isRecurring, @TimestampConverter()  DateTime createdAt,  String? category,  String? accountFrom,  String? accountTo, @NullableTimestampConverter()  DateTime? dueDate, @NullableTimestampConverter()  DateTime? paidDate,  String? frequency,  String? notes,  String? parentRecurringId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TransactionModel() when $default != null:
return $default(_that.id,_that.userId,_that.type,_that.amount,_that.paid,_that.isRecurring,_that.createdAt,_that.category,_that.accountFrom,_that.accountTo,_that.dueDate,_that.paidDate,_that.frequency,_that.notes,_that.parentRecurringId);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String userId,  String type,  double amount,  bool paid,  bool isRecurring, @TimestampConverter()  DateTime createdAt,  String? category,  String? accountFrom,  String? accountTo, @NullableTimestampConverter()  DateTime? dueDate, @NullableTimestampConverter()  DateTime? paidDate,  String? frequency,  String? notes,  String? parentRecurringId)  $default,) {final _that = this;
switch (_that) {
case _TransactionModel():
return $default(_that.id,_that.userId,_that.type,_that.amount,_that.paid,_that.isRecurring,_that.createdAt,_that.category,_that.accountFrom,_that.accountTo,_that.dueDate,_that.paidDate,_that.frequency,_that.notes,_that.parentRecurringId);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String userId,  String type,  double amount,  bool paid,  bool isRecurring, @TimestampConverter()  DateTime createdAt,  String? category,  String? accountFrom,  String? accountTo, @NullableTimestampConverter()  DateTime? dueDate, @NullableTimestampConverter()  DateTime? paidDate,  String? frequency,  String? notes,  String? parentRecurringId)?  $default,) {final _that = this;
switch (_that) {
case _TransactionModel() when $default != null:
return $default(_that.id,_that.userId,_that.type,_that.amount,_that.paid,_that.isRecurring,_that.createdAt,_that.category,_that.accountFrom,_that.accountTo,_that.dueDate,_that.paidDate,_that.frequency,_that.notes,_that.parentRecurringId);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TransactionModel extends TransactionModel {
  const _TransactionModel({required this.id, required this.userId, required this.type, required this.amount, required this.paid, required this.isRecurring, @TimestampConverter() required this.createdAt, this.category, this.accountFrom, this.accountTo, @NullableTimestampConverter() this.dueDate, @NullableTimestampConverter() this.paidDate, this.frequency, this.notes, this.parentRecurringId}): super._();
  factory _TransactionModel.fromJson(Map<String, dynamic> json) => _$TransactionModelFromJson(json);

@override final  String id;
@override final  String userId;
@override final  String type;
@override final  double amount;
@override final  bool paid;
@override final  bool isRecurring;
@override@TimestampConverter() final  DateTime createdAt;
@override final  String? category;
@override final  String? accountFrom;
@override final  String? accountTo;
@override@NullableTimestampConverter() final  DateTime? dueDate;
@override@NullableTimestampConverter() final  DateTime? paidDate;
@override final  String? frequency;
@override final  String? notes;
@override final  String? parentRecurringId;

/// Create a copy of TransactionModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TransactionModelCopyWith<_TransactionModel> get copyWith => __$TransactionModelCopyWithImpl<_TransactionModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TransactionModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TransactionModel&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.type, type) || other.type == type)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.paid, paid) || other.paid == paid)&&(identical(other.isRecurring, isRecurring) || other.isRecurring == isRecurring)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.category, category) || other.category == category)&&(identical(other.accountFrom, accountFrom) || other.accountFrom == accountFrom)&&(identical(other.accountTo, accountTo) || other.accountTo == accountTo)&&(identical(other.dueDate, dueDate) || other.dueDate == dueDate)&&(identical(other.paidDate, paidDate) || other.paidDate == paidDate)&&(identical(other.frequency, frequency) || other.frequency == frequency)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.parentRecurringId, parentRecurringId) || other.parentRecurringId == parentRecurringId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,type,amount,paid,isRecurring,createdAt,category,accountFrom,accountTo,dueDate,paidDate,frequency,notes,parentRecurringId);

@override
String toString() {
  return 'TransactionModel(id: $id, userId: $userId, type: $type, amount: $amount, paid: $paid, isRecurring: $isRecurring, createdAt: $createdAt, category: $category, accountFrom: $accountFrom, accountTo: $accountTo, dueDate: $dueDate, paidDate: $paidDate, frequency: $frequency, notes: $notes, parentRecurringId: $parentRecurringId)';
}


}

/// @nodoc
abstract mixin class _$TransactionModelCopyWith<$Res> implements $TransactionModelCopyWith<$Res> {
  factory _$TransactionModelCopyWith(_TransactionModel value, $Res Function(_TransactionModel) _then) = __$TransactionModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String userId, String type, double amount, bool paid, bool isRecurring,@TimestampConverter() DateTime createdAt, String? category, String? accountFrom, String? accountTo,@NullableTimestampConverter() DateTime? dueDate,@NullableTimestampConverter() DateTime? paidDate, String? frequency, String? notes, String? parentRecurringId
});




}
/// @nodoc
class __$TransactionModelCopyWithImpl<$Res>
    implements _$TransactionModelCopyWith<$Res> {
  __$TransactionModelCopyWithImpl(this._self, this._then);

  final _TransactionModel _self;
  final $Res Function(_TransactionModel) _then;

/// Create a copy of TransactionModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? userId = null,Object? type = null,Object? amount = null,Object? paid = null,Object? isRecurring = null,Object? createdAt = null,Object? category = freezed,Object? accountFrom = freezed,Object? accountTo = freezed,Object? dueDate = freezed,Object? paidDate = freezed,Object? frequency = freezed,Object? notes = freezed,Object? parentRecurringId = freezed,}) {
  return _then(_TransactionModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,paid: null == paid ? _self.paid : paid // ignore: cast_nullable_to_non_nullable
as bool,isRecurring: null == isRecurring ? _self.isRecurring : isRecurring // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,category: freezed == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String?,accountFrom: freezed == accountFrom ? _self.accountFrom : accountFrom // ignore: cast_nullable_to_non_nullable
as String?,accountTo: freezed == accountTo ? _self.accountTo : accountTo // ignore: cast_nullable_to_non_nullable
as String?,dueDate: freezed == dueDate ? _self.dueDate : dueDate // ignore: cast_nullable_to_non_nullable
as DateTime?,paidDate: freezed == paidDate ? _self.paidDate : paidDate // ignore: cast_nullable_to_non_nullable
as DateTime?,frequency: freezed == frequency ? _self.frequency : frequency // ignore: cast_nullable_to_non_nullable
as String?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,parentRecurringId: freezed == parentRecurringId ? _self.parentRecurringId : parentRecurringId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
