# GitHub Actions APK Build

This repository intentionally does not contain generated Flutter Android platform files. GitHub Actions creates the Android platform during the build so the rebuild archive stays small and portable.

## Build

1. Push the project to GitHub on the `main` branch.
2. Open **Actions → Build AniVortex APK**.
3. The workflow runs `flutter pub get`, `flutter analyze`, `flutter test`, and `flutter build apk --release`.
4. Download the artifact named **anivortex-release-apk**.

## Package ID

The workflow sets the Android application ID and namespace to:

`app.anivortex.mobile`

The displayed application name is:

`AniVortex`

## Important

The release APK is unsigned with a personal release keystore unless signing is configured in GitHub Secrets. Android can still install a debug/test-style release build produced by Flutter, but for Play Store or update-over-existing-install distribution, configure a persistent release keystore and signing secrets.
