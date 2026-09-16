# Clash Mi experimental connection mode

This build tests one narrow question: whether the existing Remote Pairing
discovery and location-session path can use Clash Mi's configured local
loopback path while LocalDevVPN is off.

It does not change the pairing protocol, Bonjour service type, Remote Pairing
port, RSD handshake, developer service, location simulation, or LocalDevVPN
mode. The only behavioral difference is that `Clash Mi Experimental` does not
open `localdevvpn://enable` when discovery or reachability is unavailable.

## Test procedure

1. In Clash Mi, enable the profile that configures `tun.loopback-address` with
   `10.7.0.1`.
2. Confirm Clash Mi can proxy ordinary internet traffic.
3. Turn LocalDevVPN off.
4. In WrapPin, open **Settings → Connection Mode** and choose **Clash Mi
   Experimental**.
5. Start a fixed location. Do not change pairing, coordinates, or network
   settings between a LocalDevVPN control test and this experiment.
6. Open **Settings → Connection Health → Copy Diagnostics** after the attempt.

The copied report contains only the selected connection mode and stage log. It
does not contain the pairing record, pairing PIN, credentials, device name, or
location data.

## Result classification

| Last log stage | Meaning |
| --- | --- |
| `[DISCOVERY]` with no service found | Bonjour/mDNS discovery did not reach the existing service path. |
| `[DISCOVERY]` reachability failure | A matching service was announced, but its advertised address or the existing `10.7.0.1` fallback could not accept TCP. |
| `[PAIRING]` failure | The existing Remote Pair Verify rejected or could not validate the saved pairing. |
| `[RSD]` failure | Pairing/tunnel reached the RSD service-directory step but it did not complete. |
| `[DEVELOPER]` failure | RSD completed but the developer service could not be created. |
| `[LOCATION]` failure | The developer service was reached but the location-simulation operation failed. |

If the log reaches `[LOCATION] Simulated location was accepted by the device.`,
the experiment is successful. Stop there: no network-layer rewrite is needed.
