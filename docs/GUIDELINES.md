# Project Guidelines for LLM Agents

## Tech Stack
*   **Framework**: Flutter (Latest version)
*   **Language**: Dart 3+
*   **Backend**: Supabase (Auth, Database)
*   **State Management**: `setState` (Keep it simple for now). Avoid introducing Riverpod/Bloc unless explicitly requested.
*   **Navigation**: Standard Flutter `Navigator`.

## UI/UX Design
*   **Design System**: "Tennis League" aesthetic.
*   **Primary Color**: `#00DB6E` (Tennis Green).
*   **Fonts**:
    *   Headings: `GoogleFonts.spaceGrotesk` or `GoogleFonts.lexend`
    *   Body: `GoogleFonts.lexend`
*   **Styling**: Use `Container` decorations with shadows and rounded corners (`12` or `16` radius) to match the card-based design.

## Assets & Resources
*   **Static Content**: All static images, icons, and placeholder data MUST be served from the local `assets/` folder.
    *   **Do NOT** use hardcoded remote URLs (e.g., `https://lh3.googleusercontent.com/...`).
    *   **Exception**: User-uploaded content (avatars, etc.) fetched from Supabase Storage.
*   **Path**: `assets/images/` or `assets/icons/`.
*   **Configuration**: Ensure all assets are declared in `pubspec.yaml`.

## Localization
*   **Strict Rule**: All user-facing strings MUST be localized.
*   **File**: `lib/l10n/app_en.arb`.
*   **Usage**: `AppLocalizations.of(context)!.keyName`.
*   **Process**:
    1.  Add new key to `app_en.arb`.
    2.  Run `flutter gen-l10n`.
    3.  Use in code.

## Code Conventions
*   **Imports**: Prefer relative imports for files within the same feature, package imports for shared/core modules.
*   **Widgets**: Break down complex widgets into smaller private methods (`_buildComponent`) or separate widget classes if reusable.
*   **Async**: Use `async`/`await` properly. Handle loading states and errors (use SnackBar for user feedback).

## Supabase Specifics
*   **Auth**: Use `Supabase.instance.client.auth`.
*   **Database**:
    *   Tables are snake_case (e.g., `profiles`, `leagues`).
    *   Always handle permissions (RLS is enabled).
    *   Profile data is stored in a `profiles` table linked to `auth.users` via triggers.

## Backend Services & Repositories
*   **Layer Separation**: Do NOT write Supabase queries directly in widgets (e.g., `build` or `initState`).
*   **Services**: Create specific service classes (e.g., `LeagueService`, `AuthService`) in `lib/services/` to handle all data fetching and mutations.
*   **Models**: Use strongly-typed models (e.g., `League`, `Match`) with `fromJson`/`toJson`.
*   **Error Handling**: Services should catch specific exceptions and rethrow user-friendly errors or return `Result` types.
*   **Dependency Injection**: Pass services to widgets (or use `Provider`/`Riverpod` if available). for now, simple instantiation or singletons are acceptable if DI is not set up.
