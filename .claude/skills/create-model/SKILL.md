# Standard Procedure: Create Model (create_model.md)

This guide describes how to implement a data model in **DueDay** using `freezed` and `json_serializable` for type-safety and automated parsing.

---

## 🛠️ Model Creation Pattern

### Rule 1: Freezed annotation
Use the `@freezed` annotation to make models immutable and automatically generate equality methods (`==`, `hashCode`), `toString()`, and `copyWith`.

### Rule 2: Serialization
Decorate models with `@JsonSerializable()` (using the `@freezed` syntax) to automate JSON and Firestore parsing.

### Rule 3: Entity mapping helpers
A model must always supply conversion methods to map it to and from its pure domain entity:
- `factory Model.fromEntity(Entity entity)`
- `Entity toEntity()`

---

## 📝 Freezed Model Template

```dart
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:due_day/features/accounts/domain/entities/account_entity.dart';

part '../../skills/account_model.freezed.dart';
part '../../skills/account_model.g.dart';

@freezed
class AccountModel with _$AccountModel {
  const AccountModel._(); // Required for custom methods like toEntity()

  const factory AccountModel({
    required String id,
    required String userId,
    required String name,
    required String type,
    required double balance,
    @JsonKey(name: 'created_at') required DateTime createdAt,
  }) = _AccountModel;

  // JSON Deserializer
  factory AccountModel.fromJson(Map<String, dynamic> json) =>
      _$AccountModelFromJson(json);

  // Map Entity to Model
  factory AccountModel.fromEntity(AccountEntity entity) {
    return AccountModel(
      id: entity.id,
      userId: entity.userId,
      name: entity.name,
      type: entity.type,
      balance: entity.balance,
      createdAt: entity.createdAt,
    );
  }

  // Map Model to Entity
  AccountEntity toEntity() {
    return AccountEntity(
      id: id,
      userId: userId,
      name: name,
      type: type,
      balance: balance,
      createdAt: createdAt,
    );
  }
}
```

---

## ⚡ Running Code Generation

After creating or updating a model, run the build command to generate the `.freezed.dart` and `.g.dart` files:
```bash
fvm flutter pub run build_runner build --delete-conflicting-outputs
```
