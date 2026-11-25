# Week 13 — CI/CD and Automation

A Flutter project with a GitHub Actions CI/CD pipeline that automatically runs checks and builds on every push or pull request to `main`.

## CI/CD Pipeline

Workflow file: `.github/workflows/flutter-ci.yml`

### Checks performed on every push/PR

| Step | Command | Purpose |
|------|---------|---------|
| Format | `dart format --output=none --set-exit-if-changed .` | Ensures consistent code style |
| Analyze | `flutter analyze --fatal-infos` | Static analysis, catches errors and warnings |
| Test | `flutter test --coverage` | Runs widget tests |
| Build APK | `flutter build apk --release` | Produces installable Android package |
| Build AAB | `flutter build appbundle --release` | Produces Google Play distribution format |

Artifacts (APK + AAB) are stored for 7 days and can be downloaded from the Actions tab.

## Versioning

Current version: `1.0.0+1`

Format: `major.minor.patch+buildNumber`
- **major** — incompatible changes
- **minor** — new features, backward compatible
- **patch** — bug fixes
- **build number** — incremented on each new upload

Next version would be `1.0.1+2` for a bug fix, or `1.1.0+2` for a new feature.

## Security Risks

| Risk | Status |
|------|--------|
| No signing key — APK is unsigned (debug-equivalent release) | ⚠️ Remaining |
| No secrets in repository | ✅ Safe |
| Workflow only triggers on `main` branch | ✅ Safe |
| Fork PRs do not receive repository secrets | ✅ Handled by GitHub |
| `--dart-define` values can be extracted from client binary | ⚠️ Remaining |

For signed releases, a keystore must be stored in GitHub Actions Secrets and injected only in a restricted release workflow — never exposed to pull request workflows.

## Reflection

**What problem was detected automatically before changes were merged?**  
Deprecated API usage (`package:flutter/material.dart`) was flagged by `flutter analyze`, prompting an update to `analysis_options.yaml` to handle version differences between local and CI environments.

**What information would help investigate a failed build?**  
Step-by-step logs in the Actions tab, Gradle build output, and the specific file/line reported by the analyzer or test runner.

**What still needs approval or manual review before a release?**  
APK signing with a production keystore, version bump in `pubspec.yaml`, and a human review of the artifact before distributing to users.
