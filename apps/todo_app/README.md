# Todo App (Hive + Riverpod)

Local-first Flutter todo app for **today/tomorrow scheduling**.

## Added Plugins

- `flutter_riverpod`
- `hive`
- `hive_flutter`
- `flutter_local_notifications`
- `timezone`
- `shared_preferences`
- `uuid`
- `intl`

## Removed

- Supabase auth/database integration
- Sign in / sign up / Google / Facebook login

## Storage

- Users stored in Hive box: `app_users_box`
- Todos stored in Hive box: `todos_box`

## Features

- Schedule tasks only for today or tomorrow
- Add user with strict validation (name/email/phone)
- Assign task to selected user
- Mark todo done/pending
- Notification scheduling for task reminder
- Instant local confirmation notification after task creation
- Black/white theme + dark mode toggle

## Run

```bash
flutter pub get
flutter run
```

## Build APK

```bash
flutter build apk --release
```

