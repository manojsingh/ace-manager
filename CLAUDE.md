# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Ace Manager is a Flutter mobile app for tennis league management. It uses Supabase for backend (auth, Postgres DB with RLS) and targets iOS, Android, web, macOS, Windows, and Linux.

## Commands

```bash
flutter pub get          # Install dependencies
flutter gen-l10n         # Generate localization files (run after editing app_en.arb)
flutter analyze          # Run linter
flutter run              # Run app (add -d <device> for specific device)
flutter build ios        # Build for iOS
flutter build apk        # Build for Android
```

## Architecture

### Directory Structure
- `lib/models/` - Data models with `fromJson()`/`toJson()` methods mapping to Supabase tables
- `lib/services/` - Business logic layer (singleton pattern via `ServiceName.instance`)
- `lib/screens/` - UI pages; `league/` and `admin/` subdirectories for feature grouping
- `lib/l10n/` - Localization; `app_en.arb` is the source file
- `lib/core/constants.dart` - Supabase credentials and app constants
- `sqls/` - Supabase database migration scripts

### Key Patterns

**Service Layer**: All Supabase operations go through services, never directly in widgets.
```dart
final leagues = await LeagueService.instance.getMyLeagues();
```

**State Management**: Uses `setState` in StatefulWidgets. Avoid Riverpod/Bloc unless explicitly requested.

**Localization**: All user-facing strings must be localized.
```dart
AppLocalizations.of(context)!.keyName
```
Add keys to `lib/l10n/app_en.arb`, then run `flutter gen-l10n`.

**Navigation**: Standard Flutter `Navigator` with direct page instantiation.

### Database

Tables use snake_case (`profiles`, `leagues`, `league_sessions`, `matches`, `match_participants`, `session_participants`, `clubs`, `courts`, `notifications`). RLS is enabled on all tables. SQL migrations live in `sqls/`.

## Design System

- **Primary color**: `#00DB6E` (Tennis Green)
- **Fonts**: `GoogleFonts.spaceGrotesk` for headings, `GoogleFonts.lexend` for body
- **Styling**: Card-based with shadows, rounded corners (12 or 16 radius)
- **Assets**: Use only local assets from `assets/images/` (exception: user-uploaded content from Supabase Storage)

## Key Constraints

- No hardcoded remote URLs for static content
- No Supabase queries directly in widgets - use services
- Strong typing required - use models, not dynamic maps
- Error handling via SnackBar for user feedback
