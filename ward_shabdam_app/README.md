# Wardhabdam

Flutter client for Wardhabdam citizen services.

## Development

Install Flutter, then run:

```sh
flutter pub get
flutter analyze
flutter test
flutter run --dart-define=API_BASE_URL=https://your-api-domain.com
```

`API_BASE_URL` is required and must be supplied at build or run time. Use an HTTPS URL for staging or production. Android rejects cleartext HTTP endpoints.

## Android release signing

Create `android/key.properties` locally and do not commit it:

```properties
storeFile=release-keystore.jks
storePassword=your-store-password
keyAlias=your-key-alias
keyPassword=your-key-password
```

Place the keystore at the path specified by `storeFile`, relative to the `android` directory, then build:

```sh
flutter build apk --release --dart-define=API_BASE_URL=https://api.example.com
```

Release builds fail when `android/key.properties` is missing instead of falling back to the debug key.
