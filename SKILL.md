# Feature/Screen Implementation Guideline (AVO App)

This guideline defines the step-by-step architecture and implementation pattern for adding any new feature or screen in the AVO App. It ensures clean architecture, responsive design, robust state management, and seamless localization.

---

## Phase 1: Foundation

### 1. Folder Structure
For any new feature (e.g., `doctor`), organize it under `lib/app/features/<feature_name>/` using the following three-layer structure:
* **`data/`**: Containing feature models (e.g., `schedule_model.dart`), and repository implementation (e.g., `doctor_repository_impl.dart`).
* **`domain/`**: Containing the repository interface/contract (e.g., `doctor_repository.dart`) and entities (if necessary).
* **`presentation/`**: Organized as:
  * `screens/` (or `view/screen/`): Containing the main entry point screen widgets.
  * `widgets/`: Local widgets specific to this feature.
  * `cubit/` (or `bloc/`): Logic and state management classes.

### 2. Data Modeling
* Define the Model class under `data/`.
* Implement standard `fromJson` and `toJson` methods.
* **Important**: When fetching list data from Firebase Realtime Database (RTDB), the key must be manually injected into the model class inside `fromJson` as the `'id'` attribute:
  ```dart
  id: json['id']?.toString() ?? '',
  ```

### 3. Repository Contract & API
* Define the repository abstract interface inside the `domain/` layer.
* Implement the repository inside the `data/` layer using the central network/database consumer (`Dio` or `FirebaseConsumer`).
* Avoid bulk updates; prefer single resource CRUD actions (e.g. `addResource`, `updateResource`, `deleteResource`).
* If new endpoints are required, define them in `endpoints.dart`.

---

## Phase 2: Logic & Dependency Injection

### 1. Cubit / BLoC
* Create Cubit states (e.g., `Initial`, `Loading`, `Loaded`, `Error`, and specific `ActionSuccess` states).
* Implement the Cubit class.
* Keep all form controllers, inputs, selection states, and logic inside the Cubit to preserve pure stateless UI. All these form fields must be implemented inside the cubit.
* Dispose of any `TextEditingController`s inside the Cubit's `close()` method.

### 2. Service Locator (Dependency Injection)
* Register the Repository and Cubit inside `service_locator.dart` as singletons or lazy singletons:
  ```dart
  sl.registerLazySingleton<DoctorRepository>(() => DoctorRepositoryImpl(consumer: sl()));
  sl.registerFactory(() => AddDoctorCubit(repository: sl()));
  ```

### 3. Routing
* Register the new screen routes inside `app_router.dart` (or `router_generator.dart`).
* Wrap the screen page builder with `BlocProvider` to supply the Cubit instance to the UI tree.

---

## Phase 3: Assets & Localization

### 1. Localization
* Add English strings to `assets/translations/en.json`.
* Add Arabic strings to `assets/translations/ar.json`.
* Update `lib/app/core/Language/locale_keys.g.dart` to expose the new keys under `LocaleKeys`.
* Consume translations in the UI using `LocaleKeys.your_key.tr()`.

### 2. Custom Icons & Assets
* Register new icons in `app_icons.dart`.
* Register new images in `app_images.dart`.
* Register new raw assets in `app_assets.dart`.

---

## Phase 4: UI Development & Styling

### 1. Modularization
* Break large pages into smaller widgets and store them inside the feature's local `widgets/` directory.
* Reuse shared widgets from the global widgets directories, such as `MainButton`, `LoadingIndicatorWidget`, and `CustomTextFormField`.

### 2. Layout & Drawer
* If the screen is a main page, include the `CustomDrawer` inside the `Scaffold` and use `Builder` to control opening.
* Implement exit/pop validation wrapping using `AppExitPopScope` around the root to prevent accidental app closures on back buttons.

### 3. Responsive Styling
* Use `ScreenUtil` extension methods (`.w`, `.h`, `.r`, `.sp`) for all UI dimensions:
  - Width: `width: 10.w`
  - Height: `height: 12.h`
  - Border Radius: `borderRadius: BorderRadius.circular(10.r)`
  - Font Size: `fontSize: 16.sp`
* Use themes via `Theme.of(context)` or `context.colorScheme`. Avoid hardcoded colors.

### 4. Time Validation
* Always validate time orders (e.g. `startTime` must be before `endTime`). Compare using minute-based representation (e.g. `hour * 60 + minute`).

---

## Objective
Deliver high-performance, fully responsive, cleanly modularized, and maintainable screens adhering to clean architecture.
