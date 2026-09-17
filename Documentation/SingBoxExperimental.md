# sing-box loopback reflection experiment

This experiment tests only the upstream sing-box 1.12+ TUN
`loopback_address` implementation. Upstream documents `10.7.0.1` as providing
the same behavior as SideStore/StosVPN. An open iOS graphical-client report
also says this option may not work, so real-device verification is required.

The stable LocalDevVPN mode is unchanged. The experiment does not modify
Pairing, Pair Verify, RSD, Developer Session, or LocationSimulation.

## Minimal reflection profile

Use sing-box 1.12 or later with this direct-only profile first. A proxy node is
intentionally excluded so it cannot affect the reflection result.

```json
{
  "log": {
    "level": "info"
  },
  "dns": {
    "servers": [
      {
        "type": "local",
        "tag": "local"
      }
    ],
    "final": "local"
  },
  "inbounds": [
    {
      "type": "tun",
      "tag": "tun-in",
      "address": [
        "172.18.0.1/30",
        "fdfe:dcba:9876::1/126"
      ],
      "auto_route": true,
      "strict_route": true,
      "loopback_address": [
        "10.7.0.1"
      ]
    }
  ],
  "outbounds": [
    {
      "type": "direct",
      "tag": "direct"
    }
  ],
  "route": {
    "auto_detect_interface": true,
    "final": "direct"
  }
}
```

## Acceptance test

1. Turn LocalDevVPN off and start this sing-box profile.
2. Select **sing-box Experimental** in WrapPin.
3. Start a location session.
4. Pass requires `10.7.0.1:<discovered-port>` TCP ready, followed by Pair
   Verify, RSD, Developer Session, and LocationSimulation success.
5. If reflection is not ready within 10 seconds, stop at that layer. Do not
   change pairing or any higher protocol.
