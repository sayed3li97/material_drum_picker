# Contributing to material_drum_picker

Thanks for your interest in improving this package. Contributions of all kinds
are welcome: bug reports, documentation, tests, and code.

## Code of conduct

This project follows the [Contributor Covenant](CODE_OF_CONDUCT.md). By taking
part you agree to uphold it.

## Getting started

You need the Flutter SDK (3.22 or newer; the project targets Dart 3.3 and up).

```bash
git clone https://github.com/sayed3li97/material_drum_picker.git
cd material_drum_picker
flutter pub get
```

Run the example app to try changes by hand:

```bash
cd example
flutter pub get
flutter run
```

## Before you open a pull request

Please make sure all of the following pass locally. CI runs the same checks.

```bash
# 1. Format (CI fails if this would change anything)
dart format lib test example

# 2. Static analysis with no warnings or infos
flutter analyze --fatal-infos

# 3. Unit and widget tests
flutter test --exclude-tags=golden

# 4. Golden tests (UI snapshots)
flutter test test/golden --tags=golden
```

If a change intentionally alters rendered output, update the golden baselines:

```bash
flutter test test/golden --tags=golden --update-goldens
```

Golden baselines are environment sensitive, so regenerate them on Linux to match
CI (the project uses `ubuntu-22.04`).

## Project layout

- `lib/material_drum_picker.dart` is the public barrel. Only the symbols it
  exports are part of the public API.
- `lib/src/` holds the implementation. Files under `src/widgets/internal/` and
  `src/widgets/modes/` are not exported and may change without a major version
  bump.
- `test/unit`, `test/widget`, and `test/golden` hold the test suites.
- `tool/generate_showcase.dart` renders the README screenshots and is a
  developer only tool (excluded from the published package).

## Coding guidelines

- Keep the public API documented. The package targets 100 percent dartdoc
  coverage on public members, and `pana` enforces a high bar.
- Match the surrounding style. Prefer `const`, small widgets, and clear names.
- Add or update tests for any behavior change.
- Do not introduce new runtime dependencies without discussion.

## Commit messages and pull requests

- Write a clear, imperative subject line (for example, "Add 24 hour time strip").
- Reference any related issue in the body.
- Keep pull requests focused. Smaller changes are reviewed faster.

## Releasing (maintainers)

Releases are automated. To ship a new version:

1. Update the version in `pubspec.yaml` and add a `CHANGELOG.md` entry.
2. Merge to `main`.

On merge, the `Release on merge to main` workflow checks pub.dev and, when the
version is new, tags it `vX.Y.Z`. That tag triggers `Publish to pub.dev`, which
publishes through pub.dev automated publishing (OIDC). Merging without a version
bump is a safe no-op.

pub.dev one-time setup (required for any automated publish):

- **pub.dev**: package Admin tab, enable automated publishing from GitHub
  Actions for `sayed3li97/material_drum_picker` with tag pattern `v{{version}}`.

Then pick one of two publish paths:

- **Full automation (optional secret)**: add a repository secret `RELEASE_PAT`,
  a fine-grained personal access token with `Contents: read and write` on this
  repo. With it set, merging a version bump auto tags and publishes. The token
  is needed because tags pushed by the default `GITHUB_TOKEN` cannot trigger the
  publish workflow.
- **No secret**: after merging the version bump, go to Releases, Draft a new
  release, choose or create the tag `vX.Y.Z`, and publish it. A published
  release triggers `Publish to pub.dev` directly. When `RELEASE_PAT` is absent
  the merge workflow does not fail; it logs a warning and leaves tagging to you.

You can also cut a release by hand: `git tag v1.2.0 && git push origin v1.2.0`.

## License

By contributing you agree that your contributions are licensed under the
project's [MIT license](LICENSE).
