# AniVortex 5.0.1 — Full Rebuild v1

This project is a clean-room Flutter rebuild based on the supplied AniVortex 5.0.1 APK's observable UI assets and compiled-runtime evidence.

## Implemented
- Home/catalog with remote bootstrap + offline fallback
- Search with debounce, recent searches and trending-search artwork
- Details screen with metadata and seasons/episodes
- Watch screen with API source discovery, HTTP headers, video_player playback, quality/source selection, subtitle-track metadata and playback speed
- Episode selection
- Direct-file download manager with application storage, progress and resume via HTTP Range when the server supports it
- Downloads screen with pause/delete actions
- Persistent settings: notifications, autoplay, subtitles and 18+ preference
- Config-driven authentication URL and Telegram URL hooks
- SmartLink/config route support
- Original recovered AniVortex fonts, logos, icons and Lottie assets

## Important
The original APK contains compiled Flutter/Dart code, not the original Dart project. Private backend implementation, server secrets, Firebase credentials and undocumented API routes cannot be guaranteed to be recovered from the APK. The client therefore reads the bootstrap configuration and `api_routes` dynamically rather than inventing private endpoints.

The supplied build environment does not contain Flutter/Dart/Android SDK, so this archive has not been compiled or run here. On a machine with Flutter installed:

```bash
flutter create .
flutter pub get
flutter analyze
flutter test
flutter build apk --release
```

If `flutter create .` asks to overwrite project files, keep the `lib/`, `assets/`, `test/`, `pubspec.yaml` and `docs/` from this rebuild while accepting the generated Android/iOS platform scaffolding.

## GitHub Actions

A ready-to-run workflow is included at `.github/workflows/build.yml`. It generates the Android platform, sets package ID `app.anivortex.mobile`, runs `flutter pub get`, `flutter analyze`, `flutter test`, builds `app-release.apk`, verifies the file, and uploads it as the `anivortex-release-apk` artifact.
