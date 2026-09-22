# WrapPin releases

The entries below describe upstream releases. This experiment has not been released or physically validated.

## 1.0.8 (Build 15)

- Created: 22 September 2026
- Package: `WrapPin-1.0.8-build15.ipa`
- Build: optimized unsigned Xcode Release Archive, arm64 iPhone executable
- Requires: iOS 27.0 or later
- Xcode: 27.0 (`27A266a`)
- Distribution: unsigned IPA for SideStore or another user-side signing tool
- SHA-256: `c05c943b0274879286363e504c95c23a8cba0f4cf74c228a61a9e7243ad6e218`
- Changes: adds a LocalDevVPN/Shadowrocket handoff choice and clearer Wi-Fi/cellular tunnel guidance. It does not read another app's VPN switch or change location accuracy.
- Verification: localization, native failure classification, background-session lifecycle, tunnel-handoff policy and route-recovery checks passed. The Release Archive and IPA payload, identity, arm64 architecture, unsigned state, privacy manifest and legal resources were checked. The user reported that the preceding Build 14 candidate looked okay; the final Build 15 IPA has not received a separate physical-device acceptance test.
- Known issue: Shadowrocket on cellular may not expose the paired-device connection; use Wi-Fi or LocalDevVPN. LocalDevVPN on cellular retains its app handoff on each new session. Optional anonymous telemetry is inactive in this public-source build because its ingestion identifiers are blank.
- Publication: pending GitHub Release `v1.0.8`.

See [the 1.0.8 build notes](../Documentation/Release-1.0.8.md) for details.

## 1.0.7 (Build 11)

- Created: 21 September 2026
- Package: `WrapPin-1.0.7-build11.ipa`
- Build: optimized unsigned Xcode Release Archive, arm64 iPhone executable
- Requires: iOS 27.0 or later
- Xcode: 27.0 (`27A266a`)
- Distribution: unsigned IPA for SideStore or another user-side signing tool
- SHA-256: `070199959d635c1dda049fd2186c8800920dd167648272788a65bc60db2e86fc`
- Changes: adds driving-route preview and constant-speed location simulation, with mode/speed recovery.
- Publication: GitHub Release `v1.0.7`.

See [the 1.0.7 build notes](../Documentation/Release-1.0.7.md) for details.

## 1.0.6 (Build 9)

- Created: 17 September 2026
- Package: `WrapPin-1.0.6-build9.ipa`
- Build: optimized unsigned Xcode Release Archive, arm64 iPhone executable
- Requires: iOS 27.0 or later
- Xcode: 27.0 (`27A266a`)
- Distribution: unsigned IPA for SideStore or another user-side signing tool
- SHA-256: `3ac594075b005162bcd3bd7521400b5d96cceeb7db046882060c0f1bc3a0d499`
- Changes: removes the SideStore-sensitive `BGTaskScheduler` dependency from pairing and location startup, adds a Core Location background keep-alive for active simulations, and reports background-session health in Connection Health.
- Verification: localization, native failure classification, background-session lifecycle, Xcode Release Archive, IPA payload, version, architecture, unsigned state, privacy manifest and legal resources were checked. Basic SideStore physical-device testing found no major problem; more affected-device coverage remains welcome.
- Known issue: this release does not change map coordinates or claim to fix the previously observed walking or mainland-China map offset.
- Publication: GitHub Release `v1.0.6`.

See [the 1.0.6 build notes](../Documentation/Release-1.0.6.md) for details.

## 1.0.5 (Build 6)

- Created: 15 September 2026
- Package: `WrapPin-1.0.5-build6.ipa`
- Build: optimized unsigned Xcode Release Archive, arm64 iPhone executable
- Requires: iOS 27.0 or later
- Xcode: 27.0 (`27A266a`)
- Distribution: unsigned IPA for SideStore or another user-side signing tool
- SHA-256: `723fb61fe08ce9cb7fa99b98875838c3a2770cc61470bd4e9a97efe8728df00b`
- Changes: improves worldwide map-selection address resolution, prevents unresolved loading text from entering saved places, refreshes older unresolved entries, and shows exact coordinates when no readable address is available.
- Verification: Xcode Release Archive, localization, native failure checks, IPA payload, version, architecture, unsigned state, privacy manifest and legal resources were checked. The address-resolution changes passed a SideStore physical-device test.
- Publication: GitHub Release `v1.0.5`.

See [the 1.0.5 build notes](../Documentation/Release-1.0.5.md) for details.

## 1.0.4 (Build 5)

- Created: 15 September 2026
- Package: `WrapPin-1.0.4-build5.ipa`
- Build: optimized unsigned Xcode Release Archive, arm64 iPhone executable
- Requires: iOS 27.0 or later
- Xcode: 27.0 (`27A266a`)
- Distribution: unsigned IPA for SideStore or another user-side signing tool
- SHA-256: `a887d4a8f86bf51317eb47ad65475f1b71487cd101f905984429276aaa99a037`
- Changes: aligns the X profile icon with the other Community icons, changes the Chinese label to “关注我”, and refreshes the README.
- Verification: Xcode Release Archive completed and the IPA payload, version, architecture, unsigned state, required legal resources, Chinese label and X profile URL were checked. Physical-device installation and visual acceptance remain pending.
- Publication: GitHub Release `v1.0.4`.

See [the 1.0.4 build notes](../Documentation/Release-1.0.4.md) for details.

## 1.0.3 (Build 4)

- Created: 15 September 2026
- Package: `WrapPin-1.0.3-build4.ipa`
- Build: optimized unsigned Xcode Release Archive, arm64 iPhone executable
- Requires: iOS 27.0 or later
- Xcode: 27.0 (`27A266a`)
- Distribution: unsigned IPA for SideStore or another user-side signing tool
- SHA-256: `bee2a4f7d29f69d844dc005239c67efbf07276b4a6a1ba206a3ddced4caec605`
- Changes: adds an X profile link to the Community section in Settings.
- Verification: Xcode Release Archive completed and the IPA payload, version, architecture, unsigned state, required legal resources and X profile entry were checked. Physical-device installation is delegated to the release tester.

See [the 1.0.3 release notes](../Documentation/Release-1.0.3.md) for details.

## 1.0.2 (Build 3)

- Created: 14 September 2026
- Package: `WrapPin-1.0.2-build3.ipa`
- Build: optimized unsigned Xcode Release Archive, arm64 iPhone executable
- Requires: iOS 27.0 or later
- Xcode: 27.0 (`27A266a`)
- Distribution: unsigned IPA for SideStore or another user-side signing tool
- SHA-256: `68c8fe1d5ec67f8a0e38108775590036bfe38c294880740d532c0267371b5937`
- Replaces: 1.0.1 Build 2, which SideStore rejected with `SideSign.Archive.Error 1`.
- Verification: Xcode Release Archive completed and the IPA payload, version, architecture and unsigned state were checked. Physical-device installation is delegated to the release tester.

See [the 1.0.2 release notes](../Documentation/Release-1.0.2.md) for details.

## 1.0.0 (Build 1)

- Created: 14 September 2026
- Package: `WrapPin-1.0.0-build1.ipa`
- Build: optimized unsigned Release, arm64 iPhone executable
- Requires: iOS 27.0 or later
- Xcode: 27.0 (`27A266a`)
- Distribution: unsigned IPA for SideStore or another user-side signing tool
- SHA-256: `de371230f51cf16f2309926bc5c504eb67dbdd3640ca30b35d02aedc741f19d6`
- Verified: native iPhone and Apple Silicon simulator bridge builds, localization coverage, failure classification, unsigned Release build, IPA payload integrity, version identity, privacy manifest and legal resources.
- Remaining acceptance: install the final 1.0.0 IPA on a physical iPhone before announcing it as fully released.

See [the 1.0.0 release notes](../Documentation/Release-1.0.0.md) for details.
