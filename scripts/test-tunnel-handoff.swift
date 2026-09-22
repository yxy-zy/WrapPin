import Foundation

@main
enum TunnelHandoffCheck {
    static func main() {
        let choices = TunnelHandoffApp.allCases
        precondition(choices == [.localDevVPN, .shadowrocket])
        precondition(choices.map(\.launchURL.scheme) == ["localdevvpn", "shadowrocket"])
        precondition(TunnelHandoffApp.localDevVPN.launchURL.host == "enable")
        precondition(TunnelHandoffApp.localDevVPN.launchURL.query == "scheme=wrappin")
        precondition(TunnelHandoffApp.shadowrocket.launchURL.host == nil)
        precondition(TunnelHandoffApp.shadowrocket.launchURL.query == nil)

        let stored = TunnelHandoffApp.shadowrocket.rawValue
        precondition(TunnelHandoffApp(rawValue: stored) == .shadowrocket)
        precondition(TunnelHandoffApp(rawValue: "unknown") ?? .localDevVPN == .localDevVPN)

        precondition(TunnelHandoffPolicy.offersMobileDataWorkaround(for: .localDevVPN))
        precondition(!TunnelHandoffPolicy.offersMobileDataWorkaround(for: .shadowrocket))
        precondition(TunnelHandoffPolicy.requiresLocalDevVPNCellularHandoff(
            app: .localDevVPN, isWiFiPathKnown: true, isWiFiSatisfied: false
        ))
        precondition(!TunnelHandoffPolicy.requiresLocalDevVPNCellularHandoff(
            app: .localDevVPN, isWiFiPathKnown: true, isWiFiSatisfied: true
        ))
        precondition(!TunnelHandoffPolicy.requiresLocalDevVPNCellularHandoff(
            app: .shadowrocket, isWiFiPathKnown: true, isWiFiSatisfied: false
        ))
        precondition(!TunnelHandoffPolicy.requiresLocalDevVPNCellularHandoff(
            app: .localDevVPN, isWiFiPathKnown: false, isWiFiSatisfied: false
        ))

        print("Tunnel handoff: LocalDevVPN callback, Shadowrocket launch, selection and mobile guidance passed")
    }
}
