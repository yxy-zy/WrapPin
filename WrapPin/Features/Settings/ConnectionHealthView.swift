import SwiftUI
import UIKit

struct ConnectionHealthView: View {
    @Environment(AppModel.self) private var appModel
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @State private var diagnostics = ConnectionDiagnosticsCoordinator()
    @State private var isShowingDeviceSetup = false
    @State private var didCopyDiagnostics = false

    var body: some View {
        List {
            Section("Connection Health") {
                healthRow(
                    title: String(localized: "Pairing"),
                    value: pairingValue,
                    symbol: pairingSymbol,
                    color: pairingColor
                )

                healthRow(
                    title: String(localized: "Device Tunnel"),
                    value: localDevVPNValue,
                    symbol: localDevVPNSymbol,
                    color: localDevVPNColor
                )

                healthRow(
                    title: String(localized: "Location Session"),
                    value: sessionValue,
                    symbol: sessionSymbol,
                    color: sessionColor
                )

                healthRow(
                    title: String(localized: "Background Session"),
                    value: backgroundSessionValue,
                    symbol: backgroundSessionSymbol,
                    color: backgroundSessionColor
                )

                healthRow(
                    title: String(localized: "Connection Stage"),
                    value: appModel.deviceSession.connectionStage.title,
                    symbol: "point.3.connected.trianglepath.dotted",
                    color: sessionColor
                )

                if let endpointSource = appModel.deviceSession.endpointSource {
                    healthRow(
                        title: String(localized: "Device Address"),
                        value: endpointSource.title,
                        symbol: "network",
                        color: .secondary
                    )
                }

                if case .active = appModel.deviceSession.phase,
                   !appModel.deviceSession.backgroundKeepAlive.started {
                    Label(
                        "The current simulation can still work in the foreground, but background continuity is unavailable. Check Location access for WrapPin in Settings.",
                        systemImage: "exclamationmark.triangle.fill"
                    )
                    .font(.subheadline)
                    .foregroundStyle(.orange)
                    .accessibilityElement(children: .combine)
                }
            }

            Section("Restoration") {
                Text(appModel.deviceSession.restorationStatus)
                Text("An inactive session means WrapPin's worker has ended. Other apps may need time to acquire a fresh real location.")
                    .foregroundStyle(.secondary)
            }

            Section("Current Location") {
                LabeledContent("Place", value: activeTarget?.name ?? String(localized: "None"))
                LabeledContent("Coordinates", value: coordinatesValue)

                if let activeTarget, !activeTarget.subtitle.isEmpty {
                    LabeledContent("Area", value: activeTarget.subtitle)
                }
            }

            Section {
                Button {
                    Task { await runConnectionCheck() }
                } label: {
                    HStack {
                        Label("Run Connection Check", systemImage: "stethoscope")
                        Spacer()
                        if diagnostics.state == .running {
                            ProgressView()
                        }
                    }
                }
                .disabled(diagnostics.state == .running)

                if let resultMessage {
                    Label(resultMessage, systemImage: resultSymbol)
                        .font(.subheadline)
                        .foregroundStyle(resultColor)
                }

                if let lastFailureMessage = appModel.deviceSession.lastFailureMessage {
                    VStack(alignment: .leading, spacing: 6) {
                        Label("Last session error", systemImage: "exclamationmark.triangle.fill")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.orange)
                        Text(lastFailureMessage)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                        Text("Check the selected tunnel app, then run the connection check or try starting the location again.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .accessibilityElement(children: .combine)
                }

                if let lastChecked = diagnostics.lastChecked {
                    LabeledContent(
                        "Last checked",
                        value: lastChecked.formatted(date: .omitted, time: .shortened)
                    )
                    .font(.caption)
                    .foregroundStyle(.secondary)
                }
            } header: {
                Text("Connection Check")
            } footer: {
                Text("This checks the saved pairing record and whether the paired iPhone is reachable through a compatible device tunnel. It cannot inspect another app's VPN switch or change your location.")
            }

            Section {
                Button {
                    UIPasteboard.general.string = diagnosticsText
                    didCopyDiagnostics = true
                } label: {
                    Label(
                        didCopyDiagnostics ? "Diagnostics Copied" : "Copy Diagnostics",
                        systemImage: didCopyDiagnostics ? "checkmark" : "doc.on.doc"
                    )
                }
                .foregroundStyle(didCopyDiagnostics ? .green : .primary)
            } header: {
                Text("Support")
            } footer: {
                Text("Copies status, local tunnel endpoints and network error codes. It never includes locations, searches, pairing records, PINs, device names or account credentials.")
            }

            Section("Other VPNs") {
                Text("Another VPN may affect local device connections. Keep a compatible device tunnel enabled when starting a location session; a regular proxy alone may not work.")
                if appModel.tunnelHandoffApp == .shadowrocket {
                    Text("Shadowrocket on mobile data may not expose the device connection WrapPin needs. Use Wi-Fi if the connection check fails.")
                        .foregroundStyle(.secondary)
                }
            }

            Section("Help") {
                Button {
                    isShowingDeviceSetup = true
                } label: {
                    Label("Pairing & Connection", systemImage: "iphone.and.arrow.forward")
                }
                .foregroundStyle(.primary)

                Link(destination: appModel.selectedTunnelAppInstallURL) {
                    Label(
                        String(format: NSLocalizedString("Get %@", comment: ""), appModel.tunnelHandoffApp.title),
                        systemImage: "arrow.up.right.square"
                    )
                }
            }
        }
        .navigationTitle("Connection Health")
        .navigationBarTitleDisplayMode(.inline)
        .onDisappear {
            diagnostics.cancel()
        }
        .sheet(isPresented: $isShowingDeviceSetup) {
            PairingSetupView()
                .environment(appModel)
        }
    }

    private var activeTarget: LocationTarget? {
        if case .active(let target) = appModel.deviceSession.phase {
            return target
        }
        return nil
    }

    private var coordinatesValue: String {
        guard let activeTarget else { return String(localized: "None") }
        return String(format: "%.5f, %.5f", activeTarget.latitude, activeTarget.longitude)
    }

    private var pairingValue: String {
        switch appModel.pairingStatus {
        case .checking: String(localized: "Checking")
        case .importing: String(localized: "Importing")
        case .notPaired: String(localized: "Not paired")
        case .paired: String(localized: "Ready")
        case .failed: String(localized: "Problem")
        }
    }

    private var pairingSymbol: String {
        switch appModel.pairingStatus {
        case .checking, .importing: "arrow.triangle.2.circlepath"
        case .notPaired: "exclamationmark.circle"
        case .paired: "checkmark.circle.fill"
        case .failed: "xmark.circle.fill"
        }
    }

    private var pairingColor: Color {
        switch appModel.pairingStatus {
        case .checking, .importing: .blue
        case .notPaired: .orange
        case .paired: .green
        case .failed: .red
        }
    }

    private var localDevVPNValue: String {
        switch diagnostics.state {
        case .notRun:
            if case .active = appModel.deviceSession.phase { return String(localized: "Connected") }
            return String(localized: "Not checked")
        case .running: return String(localized: "Checking")
        case .passed: return String(localized: "Reachable")
        case .failed: return String(localized: "Not reachable")
        }
    }

    private var localDevVPNSymbol: String {
        switch diagnostics.state {
        case .notRun:
            if case .active = appModel.deviceSession.phase { return "checkmark.circle.fill" }
            return "questionmark.circle"
        case .running: return "arrow.triangle.2.circlepath"
        case .passed: return "checkmark.circle.fill"
        case .failed: return "xmark.circle.fill"
        }
    }

    private var localDevVPNColor: Color {
        switch diagnostics.state {
        case .notRun:
            if case .active = appModel.deviceSession.phase { return .green }
            return .secondary
        case .running: return .blue
        case .passed: return .green
        case .failed: return .red
        }
    }

    private var sessionValue: String {
        switch appModel.deviceSession.phase {
        case .idle: String(localized: "Inactive")
        case .openingLocalDevVPN: String(localized: "Opening tunnel app")
        case .discovering: String(localized: "Finding this iPhone")
        case .connecting: String(localized: "Connecting")
        case .active: String(localized: "Active")
        case .stopping: String(localized: "Stopping")
        case .failed: String(localized: "Failed")
        }
    }

    private var sessionSymbol: String {
        switch appModel.deviceSession.phase {
        case .idle: "pause.circle"
        case .openingLocalDevVPN, .discovering, .connecting: "arrow.triangle.2.circlepath"
        case .active: "location.circle.fill"
        case .stopping: "stop.circle"
        case .failed: "exclamationmark.triangle.fill"
        }
    }

    private var sessionColor: Color {
        switch appModel.deviceSession.phase {
        case .idle: .secondary
        case .openingLocalDevVPN, .discovering, .connecting, .stopping: .blue
        case .active: .green
        case .failed: .red
        }
    }

    private var backgroundSessionValue: String {
        appModel.deviceSession.backgroundKeepAlive.status.title
    }

    private var backgroundSessionSymbol: String {
        switch appModel.deviceSession.backgroundKeepAlive.status {
        case .receivingUpdates: "location.circle.fill"
        case .awaitingAuthorization, .starting: "arrow.triangle.2.circlepath"
        case .denied, .restricted, .servicesDisabled, .missingBackgroundMode, .failed:
            "exclamationmark.triangle.fill"
        case .locationUnavailable: "location.slash.circle"
        case .idle, .stopped: "pause.circle"
        }
    }

    private var backgroundSessionColor: Color {
        switch appModel.deviceSession.backgroundKeepAlive.status {
        case .receivingUpdates: .green
        case .awaitingAuthorization, .starting: .blue
        case .denied, .restricted, .servicesDisabled, .missingBackgroundMode, .failed: .orange
        case .locationUnavailable: .orange
        case .idle, .stopped: .secondary
        }
    }

    private var resultMessage: String? {
        switch diagnostics.state {
        case .notRun, .running: nil
        case .passed(let message), .failed(let message): message
        }
    }

    private var resultSymbol: String {
        switch diagnostics.state {
        case .passed: "checkmark.circle.fill"
        case .failed: "exclamationmark.triangle.fill"
        case .notRun, .running: "circle"
        }
    }

    private var resultColor: Color {
        switch diagnostics.state {
        case .passed: .green
        case .failed: .red
        case .notRun, .running: .secondary
        }
    }

    private func healthRow(
        title: String,
        value: String,
        symbol: String,
        color: Color
    ) -> some View {
        Group {
            if dynamicTypeSize.isAccessibilitySize {
                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: symbol)
                        .foregroundStyle(color)
                        .frame(width: 22)
                    VStack(alignment: .leading, spacing: 3) {
                        Text(title)
                        Text(value)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
            } else {
                HStack(spacing: 12) {
                    Image(systemName: symbol)
                        .foregroundStyle(color)
                        .frame(width: 22)
                    Text(title)
                    Spacer()
                    Text(value)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(title), \(value)")
    }

    @MainActor
    private func runConnectionCheck() async {
        do {
            let pairingRecord = try await appModel.pairingService.pairingRecordData()
            diagnostics.run(
                pairingRecord: pairingRecord,
                sessionPhase: appModel.deviceSession.phase,
                tunnelHandoffApp: appModel.tunnelHandoffApp
            )
        } catch {
            diagnostics.run(
                pairingRecord: nil,
                sessionPhase: appModel.deviceSession.phase,
                tunnelHandoffApp: appModel.tunnelHandoffApp
            )
        }
    }

    private var diagnosticsText: String {
        let appVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
            ?? String(localized: "Unknown")
        let build = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String
            ?? String(localized: "Unknown")
        let checked = diagnostics.lastChecked?.formatted(date: .numeric, time: .standard)
            ?? String(localized: "Not run")

        return """
        WrapPin Diagnostics
        Generated: \(Date().formatted(date: .numeric, time: .standard))
        App: \(appVersion) (\(build))
        iOS: \(UIDevice.current.systemVersion)
        Pairing: \(pairingValue)
        Tunnel app: \(appModel.tunnelHandoffApp.title)
        Last pairing failure stage (this launch): \(appModel.onDevicePairing.lastFailureStage?.rawValue ?? "None")
        Device tunnel: \(localDevVPNValue)
        Session: \(sessionValue)
        Background session: \(appModel.deviceSession.backgroundKeepAlive.status.rawValue)
        Background session started: \(appModel.deviceSession.backgroundKeepAlive.started)
        Last session issue stage (this launch): \(appModel.deviceSession.lastFailureStage?.rawValue ?? "None")
        Last session issue disposition: \(appModel.deviceSession.lastFailureDisposition?.rawValue ?? "None")
        Restoration: \(appModel.deviceSession.restorationStatus)
        Last connection check: \(checked)
        Connection check result: \(diagnosticResultStatus)
        Appearance: \(appModel.appearance.title)
        Map style: \(appModel.mapDisplayStyle.title)
        Connection log:
        \(appModel.deviceSession.connectionLog.joined(separator: "\n"))
        Location data: Not included
        """
    }

    private var diagnosticResultStatus: String {
        switch diagnostics.state {
        case .notRun: "Not run"
        case .running: "Running"
        case .passed: "Passed"
        case .failed: "Failed"
        }
    }
}

#Preview {
    NavigationStack {
        ConnectionHealthView()
            .environment(AppModel())
    }
}
