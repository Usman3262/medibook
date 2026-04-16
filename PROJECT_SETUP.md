# MediBook - Medical Booking Flutter App

A professional Flutter application for booking dermatology appointments with Firebase backend and Cloudflare R2 for file storage.

## Project Architecture

This project follows **Feature-First Clean Architecture** with strict separation of concerns:

### Folder Structure

```
lib/
├── core/                      # Global shared utilities
│   ├── config/               # App configuration & constants
│   ├── error/                # Failures and exceptions
│   ├── network/              # API & R2 clients
│   ├── theme/                # App theming & colors
│   ├── utils/                # Validators, extensions, helpers
│   └── widgets/              # Reusable UI components
│
├── features/                 # Feature modules (Auth, Home, Doctor, etc.)
│   ├── auth/
│   │   ├── data/            # Models, datasources, repositories impl
│   │   ├── domain/          # Entities, abstract repos, use cases
│   │   └── presentation/    # UI pages, widgets, state management
│   ├── home/
│   ├── doctor/
│   ├── booking/
│   ├── payment/
│   ├── review/
│   ├── profile/
│   ├── settings/
│   └── chat/
│
├── shared/                   # Cross-feature domain logic
│
├── routes/                   # Navigation setup (GoRouter)
│
├── di/                       # Dependency injection
│
└── main.dart                 # App entry point
```

## Architecture Rules (STRICT)

### Layer Dependencies
- **presentation** → can depend on domain only
- **data** → can depend on domain only
- **domain** → MUST NOT depend on anything

### Naming Conventions
- Models: `*Model` (e.g., `UserModel`)
- Entities: Pure Dart classes (e.g., `UserEntity`)
- UseCases: Verb-based (e.g., `LoginUser`, `GetProfile`)
- Repositories: Abstract in domain, implementation in data

### Key Rules
- UI must be dumb (no business logic)
- Controllers handle all state management via Riverpod
- No API calls directly in widgets
- No hardcoded colors/styles (use AppTheme)
- Max file size: 100 lines
- Max function size: 30 lines
- Controllers max: 250 lines
- Widget files max: 300 lines
- Forms use `GlobalKey<FormState>`

## Setup Instructions

### 1. Firebase Setup

#### Android Configuration
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Create a new project or select existing
3. Add Android app
4. Download `google-services.json`
5. Place it in `android/app/`

#### iOS Configuration
1. Add iOS app in Firebase Console
2. Download `GoogleService-Info.plist`
3. Add to Xcode project

#### Web Configuration
1. Get Firebase SDK scripts from console
2. Add to `web/index.html`

### 2. Cloudflare R2 Configuration

#### Setup R2 Bucket
1. Go to [Cloudflare Dashboard](https://dash.cloudflare.com/)
2. Navigate to R2 → Create bucket
3. Name it `medibook`
4. Create an API token:
   - Go to Account Settings → API Tokens
   - Create custom token with R2 permissions
   - Copy Account ID, Access Key ID, Secret Access Key

#### Update Configuration
Edit `lib/core/config/app_config.dart`:
```dart
static const String r2AccountId = 'YOUR_ACCOUNT_ID';
static const String r2AccessKeyId = 'YOUR_ACCESS_KEY_ID';
static const String r2SecretAccessKey = 'YOUR_SECRET_ACCESS_KEY';
```

Update `lib/di/injection.dart`:
```dart
getIt.registerSingleton<CloudflareR2Client>(
  CloudflareR2Client(
    accountId: AppConfig.r2AccountId,
    accessKeyId: AppConfig.r2AccessKeyId,
    secretAccessKey: AppConfig.r2SecretAccessKey,
    bucketName: AppConfig.r2BucketName,
  ),
);
```

### 3. Environment Variables

Create a `.env` file:
```
FIREBASE_PROJECT_ID=your_project_id
R2_ACCOUNT_ID=your_account_id
R2_ACCESS_KEY_ID=your_access_key
R2_SECRET_ACCESS_KEY=your_secret_key
```

Never commit `.env` file.

### 4. Flutter Setup

```bash
# Get dependencies
flutter pub get

# Run the app
flutter run

# Build release
flutter build apk    # Android
flutter build ios    # iOS
flutter build web    # Web
```

## Dependencies

### State Management
- **flutter_riverpod**: Reactive state management

### Networking
- **dio**: HTTP client
- **aws_s3**: S3-compatible requests

### Storage
- **firebase_core**: Firebase setup
- **firebase_auth**: User authentication
- **cloud_firestore**: Database
- **shared_preferences**: Local storage
- **hive**: Local database

### Routing
- **go_router**: Navigation

### DI
- **get_it**: Service locator

### UI
- **google_fonts**: Typography
- **cupertino_icons**: Icons

### Validation
- **form_field_validator**: Form validation

## Feature Development Template

### 1. Create Entity (Domain Layer)
```dart
// lib/features/[feature]/domain/entities/[entity].dart
class MyEntity {
  final String id;
  final String name;
  
  MyEntity({
    required this.id,
    required this.name,
  });
}
```

### 2. Create Repository Interface (Domain)
```dart
// lib/features/[feature]/domain/repositories/[repository].dart
abstract class MyRepository {
  Future<(MyEntity?, Failure?)> getEntity(String id);
}
```

### 3. Create Model (Data Layer)
```dart
// lib/features/[feature]/data/models/[model].dart
class MyModel {
  final String id;
  
  MyModel.fromJson(Map<String, dynamic> json)
    : id = json['id'];
  
  MyEntity toEntity() => MyEntity(id: id);
}
```

### 4. Create Datasource
```dart
// lib/features/[feature]/data/datasources/[datasource].dart
class MyRemoteDataSource {
  final ApiClient apiClient;
  
  Future<MyModel> getEntity(String id) async {
    final response = await apiClient.get('/entities/$id');
    return MyModel.fromJson(response.data);
  }
}
```

### 5. Implement Repository
```dart
// lib/features/[feature]/data/repositories/[repository]_impl.dart
class MyRepositoryImpl extends MyRepository {
  final MyRemoteDataSource remoteDataSource;
  
  @override
  Future<(MyEntity?, Failure?)> getEntity(String id) async {
    try {
      final model = await remoteDataSource.getEntity(id);
      return (model.toEntity(), null);
    } catch (e) {
      return (null, ServerFailure(message: e.toString()));
    }
  }
}
```

### 6. Create UseCase
```dart
// lib/features/[feature]/domain/usecases/get_entity.dart
class GetEntity {
  final MyRepository repository;
  
  GetEntity(this.repository);
  
  Future<(MyEntity?, Failure?)> call(String id) {
    return repository.getEntity(id);
  }
}
```

### 7. Create Controller (Riverpod)
```dart
// lib/features/[feature]/presentation/state/[entity]_controller.dart
@riverpod
class MyController extends _$MyController {
  @override
  Future<MyEntity?> build(String id) async {
    final useCase = ref.watch(getEntityProvider);
    final (entity, failure) = await useCase(id);
    if (failure != null) {
      throw Exception(failure.message);
    }
    return entity;
  }
}
```

### 8. Create Page
```dart
// lib/features/[feature]/presentation/pages/[page].dart
class MyPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(myControllerProvider('id'));
    
    return state.when(
      data: (entity) => Text(entity.name),
      loading: () => const CircularProgressIndicator(),
      error: (err, stack) => Text('Error: $err'),
    );
  }
}
```

## Icon Assets

All icon placeholders are in `assets/icons/` as `.txt` files. Replace them with actual PNG files from Figma:
- `logo.txt` → `logo.png`
- `home_icon.txt` → `home_icon.png`
- etc.

## Cloudflare R2 Usage Example

```dart
// Upload file
final r2Client = getIt<CloudflareR2Client>();
await r2Client.uploadFile(
  filePath: 'users/profile/$userId.jpg',
  fileBytes: imageBytes,
  fileName: 'profile.jpg',
  contentType: 'image/jpeg',
);

// Get public URL
final url = r2Client.getPublicUrl('users/profile/$userId.jpg');

// Delete file
await r2Client.deleteFile('users/profile/$userId.jpg');
```

## Firebase Firestore Collections Structure

```
users/
  {userId}/
    - email
    - fullName
    - phoneNumber
    - profileImageUrl
    - dateOfBirth
    - gender
    - createdAt
    - updatedAt

doctors/
  {doctorId}/
    - name
    - specialty
    - experience
    - rating
    - imageUrl
    - availability
    - createdAt

appointments/
  {appointmentId}/
    - userId
    - doctorId
    - dateTime
    - duration
    - status
    - amount
    - notes
    - createdAt

reviews/
  {reviewId}/
    - userId
    - doctorId
    - appointmentId
    - rating
    - comment
    - createdAt
```

## Common Commands

```bash
# Generate code
flutter pub run build_runner build

# Run with specific target
flutter run -t lib/main.dart

# Clean project
flutter clean
flutter pub get

# Format code
dart format lib/

# Analyze code
flutter analyze
```

## Troubleshooting

### Firebase Issues
- Ensure `google-services.json` is in correct location
- Check Firebase rules allow read/write
- Verify API keys in config

### Cloudflare R2 Issues
- Check credentials in `app_config.dart`
- Verify bucket name and permissions
- Check network connectivity

### Riverpod Issues
- Clear build cache: `flutter clean`
- Rebuild: `flutter pub get && flutter pub run build_runner build`

## Contributing

Follow the strict architecture rules:
1. Respect layer dependencies
2. Keep files under size limits
3. Use consistent naming
4. No cross-feature imports (use shared)
5. Always use theme colors
6. Use validators for forms

## License

MediBook © 2024 - All rights reserved
