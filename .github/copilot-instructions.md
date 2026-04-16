# 🚨 Flutter Project Rules (STRICT)

## Architecture
- Follow Feature-First + Clean Architecture
- Each feature must have: data / domain / presentation
- NO cross-feature imports (except via shared or domain abstractions)

## Layer Rules
- presentation → can depend on domain
- data → can depend on domain
- domain → MUST NOT depend on anything

## Naming
- Models → *Model
- Entities → pure Dart, no JSON
- UseCases → verb-based (LoginUser, GetProfile)
- Repositories → abstract in domain, impl in data

## UI Rules
- UI must be dumb (no business logic)
- Use controllers (Riverpod/Bloc) for logic
- No API calls directly in widgets

## State Management
- Prefer Riverpod
- Controllers must:
  - expose immutable state
  - handle loading/error/success states

## Networking
- Use a single API client (Dio)
- All API calls go through data layer
- No hardcoded URLs

## Validation
- All forms must use centralized validators
- No inline validation logic in UI

## Theming
- Use only AppTheme (no hardcoded colors/styles)
- Use Theme.of(context)

## Reusability
- Common widgets → core/widgets
- Feature widgets → feature/presentation/widgets

## Error Handling
- Use Failure classes (domain)
- No raw exceptions in UI

## File Size Limits
- Widget file < 300 lines
- Controller < 250 lines
- Split aggressively

- NEVER use hardcoded colors
- ALWAYS use AppColors or Theme.of(context)
- ALL styling must come from AppTheme

- NEVER write inline validation inside widgets
- ALWAYS use Validators class
- Forms must use GlobalKey<FormState>

- NO direct Dio usage in features
- ALWAYS go through ApiClient
- API logic only inside data/datasources

- Controllers must manage loading/error/success
- UI must ONLY read state
- No business logic in UI

- Pages → only layout + state binding
- Widgets → reusable UI blocks
- NO API calls in UI
- NO business logic in build()




folder structure:
lib/
│
├── core/                     # Global shared stuff
│   ├── config/              # App config (env, constants)
│   ├── network/             # Dio/HTTP clients, interceptors
│   ├── error/               # Exceptions, failure models
│   ├── utils/               # Helpers, formatters
│   ├── theme/               # App theme, colors, typography
│   └── widgets/             # Reusable UI components
│
├── features/                # Feature-first architecture
│   ├── auth/
│   │   ├── data/
│   │   │   ├── models/      # DTOs (API models)
│   │   │   ├── datasources/ # API/local storage
│   │   │   └── repositories/
│   │   │
│   │   ├── domain/
│   │   │   ├── entities/    # Core business models
│   │   │   ├── repositories/# Abstract contracts
│   │   │   └── usecases/    # Business logic
│   │   │
│   │   ├── presentation/
│   │   │   ├── pages/       # Screens
│   │   │   ├── widgets/     # Feature-specific widgets
│   │   │   └── state/       # Bloc / Riverpod / Cubit
│   │   │
│   │   └── auth_module.dart
│   │
│   ├── home/
│   ├── profile/
│   ├── chat/
│   └── ...
│
├── shared/                  # Cross-feature reusable domain logic
│   ├── models/
│   ├── services/
│   └── repositories/
│
├── routes/                  # Navigation (GoRouter / AutoRoute)
│   └── app_router.dart
│
├── di/                      # Dependency Injection (get_it / injectable)
│   └── injection.dart
│
└── main.dart