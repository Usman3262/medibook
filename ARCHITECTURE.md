# MediBook Clean Architecture Guide

## Overview

This project uses **Feature-First Clean Architecture**, ensuring strict separation of concerns and maximum code reusability.

## Architecture Layers

### 1. Domain Layer (Core Business Logic)
**Location**: `features/[feature]/domain/`

**Responsibility**: Contains the core business logic that is independent of any framework or implementation details.

**Contents**:
- **Entities**: Pure Dart classes representing business objects
- **Repositories**: Abstract interfaces defining data contracts
- **UseCases**: Business logic operations

**Key Rules**:
- NO dependencies on external packages
- NO knowledge of Firebase, Dio, or any framework
- Entities are immutable
- No JSON serialization here

**Example**:
```dart
// domain/entities/user_entity.dart
class UserEntity {
  final String id;
  final String email;
  
  UserEntity({required this.id, required this.email});
}

// domain/repositories/user_repository.dart
abstract class UserRepository {
  Future<(UserEntity?, Failure?)> getUser(String id);
}

// domain/usecases/get_user.dart
class GetUser {
  final UserRepository repository;
  GetUser(this.repository);
  
  Future<(UserEntity?, Failure?)> call(String id) {
    return repository.getUser(id);
  }
}
```

### 2. Data Layer (Implementation Details)
**Location**: `features/[feature]/data/`

**Responsibility**: Handles all data operations - API calls, local storage, Firestore, R2.

**Contents**:
- **Models**: DTOs with JSON serialization (extends Entities)
- **DataSources**: Remote (API/Firebase) and Local (SharedPrefs/Hive)
- **Repositories**: Concrete implementations of domain repositories

**Key Rules**:
- Converts between DTOs and Entities
- Handles error mapping
- Implements retry logic
- Manages caching

**Example**:
```dart
// data/models/user_model.dart
class UserModel extends UserEntity {
  UserModel({
    required String id,
    required String email,
  }) : super(id: id, email: email);
  
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      email: json['email'],
    );
  }
  
  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
  };
}

// data/datasources/user_remote_datasource.dart
class UserRemoteDataSource {
  final ApiClient apiClient;
  
  Future<UserModel> getUser(String id) async {
    final response = await apiClient.get('/users/$id');
    return UserModel.fromJson(response.data);
  }
}

// data/repositories/user_repository_impl.dart
class UserRepositoryImpl implements UserRepository {
  final UserRemoteDataSource remoteDataSource;
  
  @override
  Future<(UserEntity?, Failure?)> getUser(String id) async {
    try {
      final model = await remoteDataSource.getUser(id);
      return (model, null);
    } catch (e) {
      return (null, ServerFailure(message: e.toString()));
    }
  }
}
```

### 3. Presentation Layer (UI & State)
**Location**: `features/[feature]/presentation/`

**Responsibility**: UI components and state management.

**Contents**:
- **Pages**: Full-screen widgets (Screens)
- **Widgets**: Reusable UI components
- **State**: Riverpod controllers/notifiers

**Key Rules**:
- Pages are dumb - only render UI
- All logic in controllers
- One controller per page/feature
- Controllers handle loading/error/success states
- No direct API calls
- No business logic in build()

**Example**:
```dart
// presentation/state/user_controller.dart
@riverpod
class UserController extends _$UserController {
  @override
  Future<UserEntity?> build(String userId) async {
    final getUser = ref.watch(getUserProvider);
    final (user, failure) = await getUser(userId);
    
    if (failure != null) throw Exception(failure.message);
    return user;
  }
  
  Future<void> refreshUser(String userId) async {
    ref.invalidate(userControllerProvider(userId));
  }
}

// presentation/pages/user_page.dart
class UserPage extends ConsumerWidget {
  final String userId;
  
  const UserPage({required this.userId});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(userControllerProvider(userId));
    
    return state.when(
      data: (user) => UserContent(user: user),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => ErrorWidget(error: error.toString()),
    );
  }
}

// presentation/widgets/user_card.dart
class UserCard extends StatelessWidget {
  final UserEntity user;
  
  const UserCard({required this.user});
  
  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(user.email),
      ),
    );
  }
}
```

## Data Flow

```
┌─────────────────────────────────────────────────────────┐
│                   PRESENTATION LAYER                     │
│  (Pages, Widgets, Controllers - Riverpod)               │
│  - UI rendering                                         │
│  - State management                                     │
│  - Event handling                                       │
└────────────────┬────────────────────────────────────────┘
                 │ calls
                 ▼
┌─────────────────────────────────────────────────────────┐
│                    DOMAIN LAYER                          │
│  (Entities, Repositories, UseCases)                     │
│  - Business logic                                       │
│  - Use case definitions                                │
└────────────────┬────────────────────────────────────────┘
                 │ implements
                 ▼
┌─────────────────────────────────────────────────────────┐
│                     DATA LAYER                           │
│  (Models, DataSources, Repository Implementations)      │
│  - API calls (Dio)                                      │
│  - Firebase operations                                 │
│  - Local storage (SharedPrefs, Hive)                   │
│  - Cloudflare R2 (file storage)                        │
│  - Data mapping & transformation                       │
└─────────────────────────────────────────────────────────┘
```

## Dependency Injection Setup

All dependencies are registered in `lib/di/injection.dart`:

```dart
// Core services
getIt.registerSingleton<ApiClient>(ApiClient());
getIt.registerSingleton<CloudflareR2Client>(...);
getIt.registerSingleton<FirebaseAuth>(...);

// Repositories
getIt.registerSingleton<UserRepository>(UserRepositoryImpl(...));

// UseCases
getIt.registerSingleton<GetUser>(GetUser(getIt()));

// Controllers are lazily created by Riverpod
```

## State Management with Riverpod

### Simple Async State
```dart
@riverpod
Future<UserEntity?> getUser(GetUserRef ref, String id) async {
  final useCase = ref.watch(getUserProvider);
  final (user, failure) = await useCase(id);
  if (failure != null) throw Exception(failure.message);
  return user;
}
```

### Stateful Controller
```dart
@riverpod
class UserController extends _$UserController {
  @override
  Future<UserEntity?> build(String id) async {
    // Initial state
  }
  
  Future<void> updateUser(UserEntity user) async {
    // Modify state
  }
  
  void clearState() {
    ref.invalidate(userControllerProvider(id));
  }
}
```

### Using in Widget
```dart
class MyWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch for changes
    final state = ref.watch(userControllerProvider('123'));
    
    // Call methods
    final controller = ref.read(userControllerProvider('123').notifier);
    
    return state.when(
      data: (user) => Text(user.name),
      loading: () => const LoadingWidget(),
      error: (error, stack) => Text('Error: $error'),
    );
  }
}
```

## Error Handling

### Failure Classes
```dart
abstract class Failure {
  final String message;
}

class ServerFailure extends Failure {}
class NetworkFailure extends Failure {}
class AuthFailure extends Failure {}
```

### Try-Catch Pattern
```dart
Future<(UserEntity?, Failure?)> getUser(String id) async {
  try {
    final user = await remoteDataSource.getUser(id);
    return (user, null);
  } on ServerException catch (e) {
    return (null, ServerFailure(message: e.message));
  } on NetworkException catch (e) {
    return (null, NetworkFailure(message: e.message));
  } catch (e) {
    return (null, UnexpectedFailure(message: e.toString()));
  }
}
```

### In Controllers
```dart
@riverpod
class MyController extends _$MyController {
  @override
  Future<Entity> build() async {
    try {
      return await fetchData();
    } catch (e, stack) {
      throw Exception('Failed to load data: $e');
    }
  }
}
```

## File Organization Best Practices

### 1. One Entity Per File
```
domain/entities/
├── user_entity.dart
├── doctor_entity.dart
└── appointment_entity.dart
```

### 2. One Model Per File
```
data/models/
├── user_model.dart
├── doctor_model.dart
└── appointment_model.dart
```

### 3. Separate DataSources
```
data/datasources/
├── user_remote_datasource.dart
├── user_local_datasource.dart
└── [other_datasources]
```

### 4. One Repository Implementation
```
data/repositories/
├── user_repository_impl.dart
├── doctor_repository_impl.dart
└── [other_repositories]
```

### 5. One Page Per Feature
```
presentation/pages/
├── user_page.dart
└── user_detail_page.dart
```

### 6. Feature Widgets
```
presentation/widgets/
├── user_card.dart
├── user_list_item.dart
└── [other_widgets]
```

### 7. State Management
```
presentation/state/
├── user_controller.dart
├── user_provider.dart
└── [other_controllers]
```

## Cross-Feature Communication

### Using Shared Domain
```
shared/
├── models/    # Shared data models
├── services/  # Shared services
└── repositories/  # Shared domain logic
```

### NO Direct Feature Imports
❌ WRONG:
```dart
import 'features/auth/presentation/pages/login_page.dart';  // From home feature
```

✅ CORRECT:
```dart
// Use routing instead
ref.push('/login');
```

## Testing Structure

```
test/
├── features/
│   ├── auth/
│   │   ├── domain/
│   │   │   └── repositories/
│   │   │       └── auth_repository_test.dart
│   │   ├── data/
│   │   │   ├── models/
│   │   │   │   └── user_model_test.dart
│   │   │   └── datasources/
│   │   │       └── user_remote_datasource_test.dart
│   │   └── presentation/
│   │       └── state/
│   │           └── auth_controller_test.dart
│   └── [other features]
├── core/
│   ├── theme/
│   ├── utils/
│   └── network/
└── shared/
```

## Performance Optimization

### 1. Caching Strategy
```dart
// Cache API responses
class UserRepositoryImpl extends UserRepository {
  final Map<String, UserModel> _cache = {};
  
  @override
  Future<UserEntity?> getUser(String id) async {
    if (_cache.containsKey(id)) {
      return _cache[id];
    }
    final user = await remoteDataSource.getUser(id);
    _cache[id] = user;
    return user;
  }
}
```

### 2. Lazy Loading
```dart
@riverpod
Future<List<UserEntity>> users(UsersRef ref) async {
  final page = ref.watch(userPageProvider);
  return ref.watch(getUsersProvider(page).future);
}
```

### 3. Code Splitting
Keep files small to enable tree-shaking and faster builds.

## Common Patterns

### Pattern: Login Flow
1. User enters credentials
2. Page calls controller method
3. Controller calls LoginUser usecase
4. UseCase calls repository
5. Repository calls Firebase Auth
6. Response flows back through layers
7. Controller updates state
8. UI rebuilds based on state

### Pattern: List With Pagination
1. UserId watches page number from Riverpod state
2. Controller fetches paginated data
3. Repository handles offset calculation
4. API datasource makes request
5. Models convert to entities
6. Controller combines with existing list
7. UI displays with infinite scroll

### Pattern: Error Recovery
1. ApiClient catches DioException
2. Maps to AppException
3. Repository catches and returns Failure
4. Controller catches and logs
5. UI shows error message
6. User can retry by calling controller method again

## Summary

| Layer | Purpose | Technology |
|-------|---------|-----------|
| **Domain** | Business logic | Pure Dart |
| **Data** | Data access | Firebase, Dio, Hive |
| **Presentation** | UI & State | Flutter, Riverpod |

**Key Principle**: Each layer depends on the layer below it, creating a unidirectional dependency graph that enables testing and flexibility.
