# AniVortex 5.0.1 — Reverse-engineering report

## Scope
This report documents static inspection of the supplied APK. It is not a claim that the original source repository was recovered.

## Runtime architecture evidence
- Flutter application: `lib/arm64-v8a/libapp.so`, `libflutter.so`, and `assets/flutter_assets/` are present.
- Native ABIs observed: arm64-v8a, armeabi-v7a, x86_64.
- Package/application evidence includes AniVortex domain strings and Flutter plugin channel names.
- Embedded service endpoints observed in compiled strings:
  - `https://api.anivortex.in`
  - `https://anivortex-bootstrap.pages.dev/config.json`
  - `https://anivortex.in/m/`

## Flutter assets
48 files were recovered from `assets/flutter_assets`, including:
- AniVortex logos
- catalog rank/film-roll artwork
- search artwork
- bottom navigation artwork
- watch/player controls
- Telegram artwork
- MazzardH font family and Google Sans
- Lottie animations

## Identified integrations/evidence
String/channel evidence includes Firebase Core, Firebase Messaging, Firebase Crashlytics, Google Sign-In, secure storage, local notifications, wakelock, WebView-related functionality, FFmpeg JNI and media/player-related components.

## Telegram-related behavior evidence
The binary contains strings for Telegram joining, a Telegram channel URL/config, dismissal interval state, and download/join actions.

## Important limitation
The main Flutter/Dart application logic is compiled into `libapp.so`. An APK does not contain the original Dart project in its original form. Decompiled native code cannot guarantee recovery of original comments, names, project structure, build files, or server-side implementation.

## Rebuild strategy
1. Recreate Flutter project and asset registry.
2. Reconstruct navigation and screens from asset names, strings, runtime behavior, and subsequent testing.
3. Reimplement API models/client from observed network contracts where authorized and available.
4. Reimplement authentication, persistence, downloads, player, notifications and Telegram flows.
5. Validate on Android emulator and physical device with release/profile builds.

## QA policy
No build can honestly be guaranteed bug-free before it is compiled and tested. This package is an initial scaffold; each feature should have a regression test before release.

## Additional recovered application evidence (v0.3)
The compiled Flutter binary contains strong evidence for these product behaviors and data fields:
- Search: `search response`, `search suggestion`, `Recent Searches`, `/search` and `SearchContentType`.
- Catalog/details: `title details response`, `episodes response`, `TV Episodes tab`, `episode_number`, `episode_title`, `episode_count`, `seasons`, `genres`, `cast`, `overview`, `poster_url`, `backdrop_url`.
- Playback: `stream_id`, `stream.format`, `stream.headers`, `language_options`, `subtitle_paths`, `quality`, `sources`, `stream expiry must be ISO-8601`.
- Navigation: `next_episode_id`, `previous_episode_id`, `previous_progress`, `GoHome`.
- Downloads: `anivortex_download_tasks`, `anivortex_downloads`, `download_resume`, `downloaded_bytes`, resumable downloads and quality validation.
- Auth: Google Sign-In channels and `anivortex_user_session_token`, plus `Authenticate to access`.
- Configuration validation: `api_routes`, `downloads_enabled`, SmartLink watch/download/continue-watching URLs and Telegram-join settings.

The rebuild now loads the public bootstrap configuration when available, discovers `api_routes` dynamically, and falls back to an offline-safe demo catalog when the remote service is unavailable. Exact production response schemas and authenticated/SmartLink flows still require live authorized API access or captured test traffic; they are not fabricated.
