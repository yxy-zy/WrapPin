# Changelog

All notable public changes to WrapPin are recorded here.

## [Unreleased]

### Shadowrocket loopback experiment (Build 17)

- Ported upstream's tunnel-app selection and handoff to the verified LocalDevVPN baseline.
- Retained the existing pairing, RSD, developer session, and location simulation paths.
- Requires physical-device validation; Shadowrocket must expose the local pairing endpoint.
- Added privacy-limited endpoint, TCP and native-session-stage diagnostics.

## [1.0.8] - 2026-09-22 (upstream)

### Added

- Added a Settings choice for LocalDevVPN or Shadowrocket as the tunnel app to open when WrapPin cannot reach the paired iPhone.

### Improved

- Check the paired-device connection before opening the selected app on Wi-Fi, and avoid another app handoff once that connection is reachable for the current attempt.
- Keep LocalDevVPN's existing cellular connect-and-return flow. Give Shadowrocket users a Wi-Fi recommendation when its device connection cannot be established on cellular.
- Clarified connection guidance and diagnostics: WrapPin checks the paired-device tunnel, not another app's VPN switch.

## [1.0.6] - 2026-09-17
### Improved

- Kept on-device pairing alive while switching to Settings without making pairing depend on `BGTaskScheduler` registration.
- Started the native location worker directly and used Core Location only as a privacy-preserving background keep-alive while a simulation is active.
- Added a background-session status to Connection Health so permission and delivery problems are visible without collecting coordinates.

### Fixed

- Avoided SideStore runtime bundle-identifier changes blocking pairing or location startup through mismatched background-task identifiers.

## [1.0.5] - 2026-09-15

### Improved

- Added locale-aware Apple Maps reverse geocoding with one retry for transient or empty results.
- Re-resolve older unresolved favourites and history entries when they are selected, while preserving custom favourite names.
- Show an exact latitude and longitude when Apple Maps cannot provide a readable address.

### Fixed

- Prevented temporary “Finding nearby address…” text from being saved by disabling location actions until address resolution completes.
- Ensured an empty reverse-geocoding response reaches a stable fallback instead of leaving the loading text indefinitely.
- Documented the reliable local-file SideStore installation flow to avoid remote filename and bundle-identifier mismatches.

## [1.0.4] - 2026-09-15

### Changed

- Increased the X profile icon to match the visual scale of the other Community rows.
- Changed the Simplified Chinese X profile label from “follow我” to “关注我”.
- Updated the README with the current feature set, validation status and release progress.

## [1.0.3] - 2026-09-15

### Added

- Added an X profile link to the Community section so users can follow the WrapPin maintainer directly from Settings.

## [1.0.0] - 2026-09-14

First stable WrapPin release, based on Roam Control 0.9.2 Beta 3 and maintained as an unofficial community fork.

### Added

- Complete Simplified Chinese interface, connection guidance, diagnostics and documentation.
- Fixed-location and walking-route simulation with favourites, history, recovery and real-location restoration.
- Dedicated light and dark WrapPin app icons.
- In-app links for GitHub Stars, bug reports and feature requests.

### Improved

- Kept long-running on-device pairing alive while iOS continued-processing tasks remain active.
- Rejected USB and Wi-Fi `169.254.x.x` link-local service addresses and preferred the LocalDevVPN endpoint for saved sessions.
- Added clearer connection stages, endpoint sources, retry guidance and privacy-preserving diagnostics.
- Kept Apple signing identifiers, analytics credentials and other private build values outside the repository.
- Unified the project directory, Xcode project, target, scheme, app, native bridge, bundle identifier, URL scheme, scripts and documentation under the WrapPin name.

### Validation

- Simplified Chinese localization coverage and native failure classification checks pass.
- The native Rust bridge builds for arm64 iPhone and arm64 Apple Silicon simulator.
- Unsigned Release build and IPA integrity checks pass for version `1.0.0` Build `1`.
- Earlier candidates passed physical-device installation and core usage testing; the final 1.0 package should still be installed once before public release.

[Unreleased]: https://github.com/suversal/WrapPin/commits/main
[1.0.8]: https://github.com/suversal/WrapPin/releases/tag/v1.0.8
[1.0.6]: https://github.com/suversal/WrapPin/releases/tag/v1.0.6
[1.0.5]: https://github.com/suversal/WrapPin/releases/tag/v1.0.5
[1.0.4]: https://github.com/suversal/WrapPin/releases/tag/v1.0.4
[1.0.3]: https://github.com/suversal/WrapPin/releases/tag/v1.0.3
[1.0.0]: https://github.com/suversal/WrapPin/releases/tag/v1.0.0
