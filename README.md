# ResumeCraft AI

A production-ready, AI-powered Resume Builder & Career Assistant mobile app built with Flutter.

---

## Features

| Feature | Free | Pro |
|---|---|---|
| Resume builder (multi-step wizard) | ✓ (2 resumes) | ✓ Unlimited |
| Resume templates | 8 | 20 |
| ATS score scanner | ✓ | ✓ Full reports |
| AI professional summary | ✓ | ✓ |
| Cover letter generator | — | ✓ |
| Job description matcher | — | ✓ |
| Mock interview prep | — | ✓ |
| AI Career Coach chat | — | ✓ |
| PDF export (no watermark) | ✗ (watermarked) | ✓ |
| Application tracker | ✓ | ✓ |
| Portfolio builder | — | ✓ |

---

## Tech Stack

- **Flutter 3.x** · Dart 3.3+ · Material 3 · Dark theme with Glassmorphism
- **State**: Provider + ChangeNotifier
- **Navigation**: GoRouter with auth guards
- **Backend**: Firebase (Auth, Firestore, Storage, Analytics, Messaging, Crashlytics)
- **AI**: OpenAI GPT-4o / GPT-4o-mini
- **Subscriptions**: RevenueCat + Stripe
- **PDF**: `pdf` + `printing` packages
- **Architecture**: Clean Architecture, Feature-Based folder structure

---

## Getting Started

### Prerequisites

- Flutter SDK ≥ 3.22
- Dart SDK ≥ 3.3
- Xcode 15+ (iOS)
- Android Studio / SDK 34+ (Android)
- Firebase project with Auth, Firestore, Storage enabled

### 1. Clone & install

```bash
git clone https://github.com/essencewaretech/resume_craft_ai.git
cd resume_craft_ai
flutter pub get
```

### 2. Firebase setup

```bash
# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Configure Firebase (creates firebase_options.dart)
flutterfire configure --project=<your-firebase-project-id>
```

### 3. Environment variables

API keys are injected at build time via `--dart-define`:

```bash
flutter run \
  --dart-define=OPENAI_API_KEY=sk-... \
  --dart-define=REVENUECAT_ANDROID_KEY=appl_... \
  --dart-define=REVENUECAT_IOS_KEY=appl_... \
  --dart-define=STRIPE_PUBLISHABLE_KEY=pk_live_...
```

For VS Code, add to `.vscode/launch.json`:

```json
{
  "configurations": [{
    "name": "ResumeCraft AI",
    "request": "launch",
    "type": "dart",
    "toolArgs": [
      "--dart-define=OPENAI_API_KEY=${env:OPENAI_API_KEY}",
      "--dart-define=REVENUECAT_ANDROID_KEY=${env:REVENUECAT_ANDROID_KEY}",
      "--dart-define=REVENUECAT_IOS_KEY=${env:REVENUECAT_IOS_KEY}",
      "--dart-define=STRIPE_PUBLISHABLE_KEY=${env:STRIPE_PUBLISHABLE_KEY}"
    ]
  }]
}
```

### 4. Run the app

```bash
flutter run
```

---

## Project Structure

```
lib/
├── core/
│   ├── constants/        # AppConstants
│   ├── router/           # GoRouter + auth guards
│   ├── theme/            # Colors, typography, Material 3 theme
│   └── widgets/          # GlassCard, GradientButton, AppWidgets
├── features/
│   ├── auth/             # Auth flow, AuthProvider, UserEntity
│   ├── onboarding/       # 5-step onboarding wizard
│   ├── home/             # Dashboard, bottom nav shell
│   ├── resume_builder/   # 8-step wizard, ResumeProvider, entities
│   ├── resume_upload/    # Upload + parse existing resume
│   ├── ats_scanner/      # ATS analysis + score breakdown
│   ├── job_matcher/      # Job description matching
│   ├── cover_letter/     # Cover letter generation
│   ├── interview_prep/   # Mock interview + AI scoring
│   ├── application_tracker/ # Kanban job tracker
│   ├── ai_coach/         # Streaming AI chat
│   ├── portfolio/        # Portfolio builder
│   ├── settings/         # Profile, preferences
│   └── subscription/     # RevenueCat paywall
├── services/
│   ├── ai/               # OpenAI GPT integration
│   ├── pdf/              # PDF generation (resume + cover letter)
│   ├── subscription/     # RevenueCat service
│   └── notifications/    # Firebase Cloud Messaging
└── main.dart
```

---

## Building for Release

### Android

```bash
flutter build appbundle --release \
  --dart-define=OPENAI_API_KEY=$OPENAI_API_KEY \
  --dart-define=REVENUECAT_ANDROID_KEY=$REVENUECAT_ANDROID_KEY \
  --dart-define=STRIPE_PUBLISHABLE_KEY=$STRIPE_PUBLISHABLE_KEY
```

The `.aab` file is at `build/app/outputs/bundle/release/app-release.aab`.

### iOS

```bash
flutter build ipa --release \
  --dart-define=OPENAI_API_KEY=$OPENAI_API_KEY \
  --dart-define=REVENUECAT_IOS_KEY=$REVENUECAT_IOS_KEY \
  --dart-define=STRIPE_PUBLISHABLE_KEY=$STRIPE_PUBLISHABLE_KEY
```

Then open Xcode → distribute via App Store Connect or Transporter.

---

## RevenueCat Setup

1. Create a project at [app.revenuecat.com](https://app.revenuecat.com)
2. Add your iOS App Store / Google Play credentials
3. Create products matching `AppConstants.proMonthlyId` and `AppConstants.proYearlyId`
4. Create an Entitlement named `pro` linked to both products
5. Set webhook URL to `https://<region>-<project>.cloudfunctions.net/revenueCatWebhook`

---

## Firebase Cloud Functions

```bash
cd functions
npm install
firebase deploy --only functions
```

Set the webhook secret:
```bash
firebase functions:config:set revenuecat.webhook_secret="YOUR_SECRET"
```

---

## Running Tests

```bash
# Unit tests
flutter test test/unit/

# Widget tests
flutter test test/widget/

# All tests with coverage
flutter test --coverage
```

---

## CI/CD

GitHub Actions workflow at `.github/workflows/ci.yml` runs on every push to `main`:

1. `analyze` — lint + format check
2. `test` — unit + widget tests with coverage
3. `build-android` — release AAB with keystore signing
4. `build-ios` — release IPA with certificate signing
5. `deploy-play-store` — uploads to Internal track
6. `deploy-testflight` — uploads to TestFlight

### Required GitHub Secrets

| Secret | Description |
|---|---|
| `OPENAI_API_KEY` | OpenAI API key |
| `REVENUECAT_ANDROID_KEY` | RevenueCat Android public key |
| `REVENUECAT_IOS_KEY` | RevenueCat iOS public key |
| `STRIPE_PUBLISHABLE_KEY` | Stripe publishable key |
| `ANDROID_KEYSTORE_BASE64` | Base64-encoded keystore file |
| `ANDROID_KEYSTORE_PASSWORD` | Keystore password |
| `ANDROID_KEY_ALIAS` | Key alias |
| `ANDROID_KEY_PASSWORD` | Key password |
| `PLAY_STORE_SERVICE_ACCOUNT_JSON` | Google Play service account JSON |
| `IOS_DISTRIBUTION_CERT_BASE64` | Apple distribution cert (p12) |
| `IOS_DISTRIBUTION_CERT_PASSWORD` | Cert password |
| `IOS_PROVISIONING_PROFILE_BASE64` | Base64-encoded provisioning profile |
| `APP_STORE_CONNECT_API_KEY_ID` | App Store Connect API key ID |
| `APP_STORE_CONNECT_ISSUER_ID` | App Store Connect issuer ID |

---

## Database

See `docs/FIRESTORE_SCHEMA.md` for full Firestore collections, field types, security rules, and required indexes.

---

## License

© 2025 EssenceWare Tech. All rights reserved.
