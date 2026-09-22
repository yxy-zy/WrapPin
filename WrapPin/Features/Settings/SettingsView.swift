import SwiftUI

struct SettingsView: View {
    private static let repositoryURL = URL(
        string: "https://github.com/suversal/WrapPin"
    )!
    private static let bugReportURL = URL(
        string: "https://github.com/suversal/WrapPin/issues/new?template=bug_report.yml"
    )!
    private static let featureRequestURL = URL(
        string: "https://github.com/suversal/WrapPin/issues/new?template=feature_request.yml"
    )!
    private static let xProfileURL = URL(
        string: "https://x.com/suversal"
    )!

    @Environment(AppModel.self) private var appModel
    @Environment(\.dismiss) private var dismiss
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @ScaledMetric(relativeTo: .body) private var xLogoSize: CGFloat = 25
    @State private var isShowingDeviceSetup = false
    @State private var isReplayingOnboarding = false
    @State private var isConfirmingReset = false
    @State private var resetError: String?
    @State private var releaseUpdateStatus: ReleaseUpdateStatus = .idle

    var body: some View {
        NavigationStack {
            Form {
                Section("Appearance") {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Theme")
                            .font(.subheadline.weight(.medium))

                        themePicker
                    }
                    .padding(.vertical, 4)

                    VStack(alignment: .leading, spacing: 10) {
                        Text("Map Style")
                            .font(.subheadline.weight(.medium))

                        mapStylePicker
                    }
                    .padding(.vertical, 4)
                }

                Section("Device") {
                    NavigationLink {
                        ConnectionHealthView()
                            .environment(appModel)
                    } label: {
                        Label("Connection Health", systemImage: "stethoscope")
                    }

                    Button {
                        isShowingDeviceSetup = true
                    } label: {
                        Label {
                            pairingConnectionLabel
                        } icon: {
                            Image(systemName: "iphone.and.arrow.forward")
                        }
                    }
                    .foregroundStyle(.primary)
                }

                Section {
                    Picker("Tunnel App", selection: tunnelHandoffAppBinding) {
                        ForEach(TunnelHandoffApp.allCases) { app in
                            Text(app.title).tag(app)
                        }
                    }
                    .accessibilityHint("Selects the app to open when WrapPin cannot reach the paired iPhone.")
                } footer: {
                    if appModel.tunnelHandoffApp == .shadowrocket {
                        Text("WrapPin opens Shadowrocket only when it cannot find the paired iPhone's device connection. On mobile data, this connection may fail even with Shadowrocket on; use Wi-Fi for location simulation. The selection does not guarantee a compatible device tunnel.")
                    } else {
                        Text("On Wi-Fi, WrapPin opens LocalDevVPN if the paired iPhone is unreachable. On mobile data, it uses LocalDevVPN's connect-and-return flow before continuing. If it does not return automatically, check its tunnel and come back to WrapPin.")
                    }
                }

                Section {
                    Toggle(
                        "Share Anonymous Usage Statistics",
                        isOn: anonymousUsageStatisticsBinding
                    )

                    NavigationLink {
                        UsageStatisticsPrivacyView()
                    } label: {
                        Label("What Is Shared", systemImage: "hand.raised.fill")
                    }
                } header: {
                    Text("Privacy")
                } footer: {
                    Text("Optional and off by default. Helps estimate activity from participating installations. Locations, searches and pairing data are never included.")
                }

                Section("About") {
                    NavigationLink {
                        AboutWrapPinView()
                    } label: {
                        Label("About WrapPin", systemImage: "info.circle")
                    }

                    LabeledContent("Version", value: versionText)
                    LabeledContent("Build", value: buildNumberText)
                    LabeledContent("Built", value: buildDateText)

                    Button {
                        isReplayingOnboarding = true
                    } label: {
                        Label("Replay Introduction", systemImage: "sparkles")
                    }
                    .foregroundStyle(.primary)
                }

                Section {
                    Button {
                        Task { await checkForUpdates() }
                    } label: {
                        Label(updateCheckTitle, systemImage: updateCheckSymbol)
                    }
                    .disabled(releaseUpdateStatus == .checking)

                    updateStatusDetail
                } header: {
                    Text("Updates")
                } footer: {
                    Text("Checks the public GitHub release only when you tap it. WrapPin never sends location, pairing or diagnostic data with this request.")
                }

                Section {
                    Link(destination: Self.repositoryURL) {
                        Label("View & Star on GitHub", systemImage: "star")
                    }

                    Link(destination: Self.bugReportURL) {
                        Label("Report a Bug", systemImage: "ladybug")
                    }

                    Link(destination: Self.featureRequestURL) {
                        Label("Request a Feature", systemImage: "lightbulb")
                    }

                    Link(destination: Self.xProfileURL) {
                        Label {
                            Text("Follow Me")
                        } icon: {
                            Text(verbatim: "𝕏")
                                .font(.system(size: xLogoSize, weight: .regular))
                                .frame(width: xLogoSize, height: xLogoSize)
                                .accessibilityHidden(true)
                        }
                    }
                } header: {
                    Text("Community")
                } footer: {
                    Text("Star the repository if WrapPin helps you, or suggest an improvement. For pairing or connection problems, open Connection Health and use Copy Diagnostics. Never include pairing records, credentials or private locations.")
                }

                Section {
                    Button("Reset WrapPin", role: .destructive) {
                        isConfirmingReset = true
                    }
                } footer: {
                    Text("This clears the pairing record and local app settings, then shows onboarding again. It does not remove or change LocalDevVPN.")
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
        .preferredColorScheme(preferredColorScheme)
        .sheet(isPresented: $isShowingDeviceSetup) {
            PairingSetupView()
                .environment(appModel)
        }
        .fullScreenCover(isPresented: $isReplayingOnboarding) {
            OnboardingView(isReplay: true)
                .environment(appModel)
        }
        .confirmationDialog(
            "Reset WrapPin?",
            isPresented: $isConfirmingReset,
            titleVisibility: .visible
        ) {
            Button("Reset App", role: .destructive) {
                Task { await resetApp() }
            }
        } message: {
            Text("Your pairing record and local choices will be removed. You will return to the welcome screen.")
        }
        .alert("Reset could not finish", isPresented: isShowingResetError) {
            Button("OK", role: .cancel) {
                resetError = nil
            }
        } message: {
            Text(resetError ?? String(localized: "Please try again."))
        }
    }

    private var connectionLabel: String {
        switch appModel.connectionState {
        case .notConfigured: String(localized: "Not paired")
        case .ready: String(localized: "Ready")
        case .connecting: String(localized: "Connecting")
        case .active: String(localized: "Active")
        case .failed: String(localized: "Problem")
        }
    }

    private var preferredColorScheme: ColorScheme? {
        switch appModel.appearance {
        case .automatic: nil
        case .light: .light
        case .dark: .dark
        }
    }

    private var appearanceBinding: Binding<AppAppearance> {
        Binding(
            get: { appModel.appearance },
            set: appModel.setAppearance
        )
    }

    @ViewBuilder
    private var themePicker: some View {
        if dynamicTypeSize.isAccessibilitySize {
            Picker("Theme", selection: appearanceBinding) {
                ForEach(AppAppearance.allCases) { appearance in
                    Label(appearance.title, systemImage: appearance.systemImage)
                        .tag(appearance)
                }
            }
            .pickerStyle(.menu)
        } else {
            Picker("Theme", selection: appearanceBinding) {
                ForEach(AppAppearance.allCases) { appearance in
                    Label(appearance.title, systemImage: appearance.systemImage)
                        .tag(appearance)
                }
            }
            .pickerStyle(.segmented)
            .labelsHidden()
        }
    }

    @ViewBuilder
    private var mapStylePicker: some View {
        if dynamicTypeSize.isAccessibilitySize {
            Picker("Map Style", selection: mapStyleBinding) {
                ForEach(MapDisplayStyle.allCases) { style in
                    Text(style.title).tag(style)
                }
            }
            .pickerStyle(.menu)
        } else {
            Picker("Map Style", selection: mapStyleBinding) {
                ForEach(MapDisplayStyle.allCases) { style in
                    Text(style.title).tag(style)
                }
            }
            .pickerStyle(.segmented)
            .labelsHidden()
        }
    }

    @ViewBuilder
    private var pairingConnectionLabel: some View {
        if dynamicTypeSize.isAccessibilitySize {
            VStack(alignment: .leading, spacing: 3) {
                Text("Pairing & Connection")
                Text(connectionLabel)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        } else {
            HStack {
                Text("Pairing & Connection")
                Spacer()
                Text(connectionLabel)
                    .foregroundStyle(.secondary)
                Image(systemName: "chevron.right")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.tertiary)
            }
        }
    }

    private var mapStyleBinding: Binding<MapDisplayStyle> {
        Binding(
            get: { appModel.mapDisplayStyle },
            set: appModel.setMapDisplayStyle
        )
    }

    private var tunnelHandoffAppBinding: Binding<TunnelHandoffApp> {
        Binding(
            get: { appModel.tunnelHandoffApp },
            set: appModel.setTunnelHandoffApp
        )
    }

    private var anonymousUsageStatisticsBinding: Binding<Bool> {
        Binding(
            get: { appModel.sharesAnonymousUsageStatistics },
            set: appModel.setSharesAnonymousUsageStatistics
        )
    }

    private var versionText: String {
        let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
        return version ?? "1.0"
    }

    private var buildNumberText: String {
        let build = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String
        return build ?? "Unknown"
    }

    private var buildDateText: String {
        if
            let timestamp = Bundle.main.object(
                forInfoDictionaryKey: "WrapPinBuildTimestamp"
            ) as? String,
            let buildDate = ISO8601DateFormatter().date(from: timestamp)
        {
            return buildDate.formatted(date: .abbreviated, time: .shortened)
        }

        guard
            let executableURL = Bundle.main.executableURL,
            let values = try? executableURL.resourceValues(forKeys: [.contentModificationDateKey]),
            let buildDate = values.contentModificationDate
        else { return String(localized: "Unknown") }

        return buildDate.formatted(date: .abbreviated, time: .shortened)
    }

    private var updateCheckTitle: String {
        switch releaseUpdateStatus {
        case .checking: String(localized: "Checking for Updates…")
        default: String(localized: "Check for Updates")
        }
    }

    private var updateCheckSymbol: String {
        releaseUpdateStatus == .checking ? "arrow.triangle.2.circlepath" : "arrow.down.circle"
    }

    @ViewBuilder
    private var updateStatusDetail: some View {
        switch releaseUpdateStatus {
        case .idle, .checking:
            EmptyView()
        case .updateAvailable(let release):
            Link(destination: release.releaseURL) {
                Label(
                    String(
                        format: NSLocalizedString("Install %@", comment: ""),
                        release.version
                    ),
                    systemImage: "arrow.up.right.square"
                )
            }
            Text(
                String(
                    format: NSLocalizedString("A newer public release is available: %@.", comment: ""),
                    release.name
                )
            )
                .font(.caption)
                .foregroundStyle(.secondary)
        case .current(let release):
            Label(
                String(
                    format: NSLocalizedString("You have the latest public release (%@).", comment: ""),
                    release.version
                ),
                systemImage: "checkmark.circle"
            )
                .font(.subheadline)
                .foregroundStyle(.green)
        case .newerLocalBuild(let release):
            Link(destination: release.releaseURL) {
                Label(
                    String(
                        format: NSLocalizedString("View public release %@", comment: ""),
                        release.version
                    ),
                    systemImage: "arrow.up.right.square"
                )
            }
            Text(
                String(
                    format: NSLocalizedString("You are using a newer local test build (%@ Build %@).", comment: ""),
                    versionText,
                    buildNumberText
                )
            )
                .font(.caption)
                .foregroundStyle(.secondary)
        case .noPublishedRelease:
            Label("No public GitHub release has been published yet.", systemImage: "clock")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        case .unavailable:
            Label("Couldn’t check GitHub right now. Try again later.", systemImage: "exclamationmark.triangle")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }

    @MainActor
    private func checkForUpdates() async {
        releaseUpdateStatus = .checking

        do {
            let release = try await ReleaseUpdateChecker().latestRelease()
            if VersionComparison.isRemoteVersionNewer(release.version, than: versionText) {
                releaseUpdateStatus = .updateAvailable(release)
            } else if VersionComparison.isRemoteVersionNewer(versionText, than: release.version) {
                releaseUpdateStatus = .newerLocalBuild(release)
            } else {
                releaseUpdateStatus = .current(release)
            }
        } catch ReleaseUpdateCheckError.noPublishedRelease {
            releaseUpdateStatus = .noPublishedRelease
        } catch {
            releaseUpdateStatus = .unavailable
        }
    }

    private var isShowingResetError: Binding<Bool> {
        Binding(
            get: { resetError != nil },
            set: { if !$0 { resetError = nil } }
        )
    }

    @MainActor
    private func resetApp() async {
        do {
            try await appModel.resetApp()
            dismiss()
        } catch {
            resetError = error.localizedDescription
        }
    }
}

#Preview {
    SettingsView()
        .environment(AppModel())
}
