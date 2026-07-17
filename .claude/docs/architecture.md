# Architecture & Principles (architecture.md)

This document describes the architectural framework of the **DueDay** project. It outlines design choices, layer separation, dependencies, SOLID principles, and patterns that must be adhered to.

---

## 🏗️ 1. Architecture: Clean Architecture + BLoC

DueDay employs **Clean Architecture**, separating the project into three distinct layers. Dependencies must strictly flow inwards (Presentation ➔ Domain 🠔 Data). The core domain layer has zero external dependencies, protecting it from external frameworks or database changes.

```
┌────────────────────────────────────────────────────────┐
│  PRESENTATION LAYER (UI / BLoC / Pages / Widgets)      │
│  → Depends on: Domain Layer                            │
└──────────────────────────┬─────────────────────────────┘
                           │ (Invokes Use Cases)
                           ▼
┌────────────────────────────────────────────────────────┐
│  DOMAIN LAYER (Business Logic / Use Cases / Entities)  │
│  → Pure Dart: Depends on nothing                       │
└──────────────────────────▲─────────────────────────────┘
                           │ (Implements Repository contract)
                           │
┌────────────────────────────────────────────────────────┐
│  DATA LAYER (Repositories / DataSources / Models)      │
│  → Depends on: Domain Layer                            │
└────────────────────────────────────────────────────────┘
```

### 1.1. Domain Layer (`domain`)
The innermost layer of the application. It is written in pure Dart with **zero references** to Flutter, Firebase, or external plugins (except formatting libraries like `Equatable` or functional libraries like `fpdart`).
- **Entities (`domain/entities`)**: Immutable business objects. They must extend `Equatable` for value comparison and use `const` constructors alongside `copyWith`.
- **Use Cases (`domain/usecases`)**: Classes implementing a single business logic behavior. They are callable classes implementing the `call(...)` method, returning a `Future<Either<Failure, T>>`.
- **Repositories (`domain/repositories`)**: Abstract interfaces defining the contractual requirements of data retrieval. The domain layer specifies *what* it needs, not *how* it is retrieved.

### 1.2. Data Layer (`data`)
Implements the interfaces defined in the domain layer and interacts with external frameworks, APIs, and databases.
- **Models (`data/models`)**: Concrete implementations of domain entities that add serialization and deserialization (JSON, Firestore). Built using the `freezed` and `json_serializable` packages. Models must implement:
  - `factory Model.fromEntity(Entity entity)`
  - `Entity toEntity()`
- **DataSources (`data/datasources`)**: Raw data access classes.
  - *Remote DataSources:* Talk to Firebase Services (Auth, Firestore, Cloud Messaging). They throw raw exceptions (e.g., `ServerException`).
  - *Local DataSources:* Handle local storage operations (e.g., `FlutterSecureStorage`). They throw `CacheException`.
- **Repositories (`data/repositories`)**: Concrete implementations of domain repository interfaces. They orchestrate DataSources, catch thrown exceptions (like `ServerException` or `CacheException`), and convert them into structured failures (`ServerFailure`, `CacheFailure`) returned inside an `Either<Failure, T>` wrapper.

### 1.3. Presentation Layer (`presentation`)
Contains user interfaces and handles state transitions.
- **BLoC (`presentation/bloc`)**: Manages UI state using the `flutter_bloc` library. Recovers user actions (Events), executes Domain Use Cases, and broadcasts UI updates (States). Both Events and States must extend `Equatable`.
- **Pages (`presentation/pages`)**: Primary screens bound to routes. They listen to the BLoC's state transitions and rebuild the UI.
- **Widgets (`presentation/widgets`)**: Small, modular, reusable visual blocks.

---

## 🛠️ 2. SOLID Principles in DueDay

- **Single Responsibility Principle (S):** Each class does exactly one thing. A UseCase performs a single action (e.g., `AddAccount`). A DataSource executes basic network or cache fetches. A widget represents a single component.
- **Open/Closed Principle (O):** We extend functionality by adding new implementations rather than modifying existing ones. E.g., we can support another login method by implementing a new DataSource/Repository without changing the Core Domain.
- **Liskov Substitution Principle (L):** Implementations of repositories must perfectly fulfill their interfaces so that the Domain and Presentation layers can consume them interchangeably.
- **Interface Segregation Principle (I):** Keep repository interfaces clean and focused on specific domains. Avoid bloated contract files.
- **Dependency Inversion Principle (D):** Higher-level layers (Domain/Presentation) do not depend on low-level implementation details (Data/Firebase). They rely on abstractions. Dependency injection is managed globally via **GetIt**.

---

## 🧩 3. Clean Design Rules & Anti-Patterns

### ✅ Keep It Simple, Stupid (KISS)
- **Do not create redundant database tables or repositories for data aggregation.** E.g., for screens like the Dashboard, do not create a separate "Dashboard" repository or Firestore collection. Instead, the `DashboardBloc` should inject `GetAccounts` and `GetTransactions` usecases and calculate the aggregated values (Current Balance, Projected Balance) internally.

### ❌ Anti-Patterns to Avoid
- **No Direct UI Database Calls:** Never query Firestore, Auth, or Local Storage directly from a page or widget.
- **No UseCase-to-UseCase Dependencies:** UseCases must remain isolated. If a business workflow requires multiple UseCases, orchestrate them inside the BLoC or create an orchestrating UseCase.
- **No Raw Exceptions in UI:** Never allow `try-catch` blocks on a page to capture Firebase errors. All exceptions must be resolved inside the Data Repositories and wrapped in `Either`.
- **No Custom State Engines:** Stick to `flutter_bloc` to preserve state flow structure.
