import Darwin
import Foundation

enum NetServiceEndpointResolver {
    static func diagnosticAddressSummaries(from addresses: [Data]?) -> [String] {
        guard let addresses else { return [] }

        return addresses.compactMap { address in
            address.withUnsafeBytes { buffer -> String? in
                guard
                    let baseAddress = buffer.baseAddress,
                    buffer.count >= MemoryLayout<sockaddr>.size
                else { return nil }

                let socketAddress = baseAddress.assumingMemoryBound(to: sockaddr.self)
                let family = Int32(socketAddress.pointee.sa_family)
                guard family == AF_INET || family == AF_INET6 else { return nil }

                var hostBuffer = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                let result = getnameinfo(
                    socketAddress,
                    socklen_t(buffer.count),
                    &hostBuffer,
                    socklen_t(hostBuffer.count),
                    nil,
                    0,
                    NI_NUMERICHOST
                )
                guard result == 0 else { return nil }

                let host = String(cString: hostBuffer)
                let familyName = family == AF_INET ? "IPv4" : "IPv6"
                let scope = host.lowercased().hasPrefix("fe80:") ? ", link-local" : ""
                return "\(familyName) \(host)\(scope)"
            }
        }
    }

    static func preferredHost(
        from addresses: [Data]?,
        fallback: String
    ) -> (host: String, usedFallback: Bool) {
        // Remote pairing is performed from the iPhone itself through
        // LocalDevVPN. Bonjour can also advertise the Mac-facing USB/Wi-Fi
        // address (for example 169.254.x.x). That endpoint accepts TCP but
        // rejects the phone's Remote Pair Verify session, so only accept a
        // discovered address on LocalDevVPN's device subnet. Otherwise use
        // the stable LocalDevVPN peer address.
        guard let host = numericHosts(from: addresses).first(where: {
            $0 == fallback || $0.hasPrefix("10.7.0.")
        }) else {
            return (fallback, true)
        }

        return (host, host == fallback)
    }

    static func numericHosts(from addresses: [Data]?) -> [String] {
        guard let addresses else { return [] }

        let candidates = addresses.compactMap { address -> (host: String, rank: Int)? in
            address.withUnsafeBytes { buffer in
                guard
                    let baseAddress = buffer.baseAddress,
                    buffer.count >= MemoryLayout<sockaddr>.size
                else { return nil }

                let socketAddress = baseAddress.assumingMemoryBound(to: sockaddr.self)
                let family = Int32(socketAddress.pointee.sa_family)
                guard family == AF_INET || family == AF_INET6 else { return nil }

                var hostBuffer = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                let result = getnameinfo(
                    socketAddress,
                    socklen_t(buffer.count),
                    &hostBuffer,
                    socklen_t(hostBuffer.count),
                    nil,
                    0,
                    NI_NUMERICHOST
                )
                guard result == 0 else { return nil }

                let host = String(cString: hostBuffer)
                    .split(separator: "%", maxSplits: 1)
                    .first
                    .map(String.init) ?? ""
                guard !host.isEmpty, !host.lowercased().hasPrefix("fe80:") else { return nil }

                let rank: Int
                if host.hasPrefix("10.7.0.") {
                    rank = 0
                } else if family == AF_INET {
                    rank = 1
                } else {
                    rank = 2
                }
                return (host, rank)
            }
        }

        var seen = Set<String>()
        return candidates
            .sorted { lhs, rhs in lhs.rank < rhs.rank }
            .map(\.host)
            .filter { seen.insert($0).inserted }
    }
}
