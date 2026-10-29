# WhatsApp: bridge, token and monitor

Read this when the WhatsApp probe or the update shows something unexpected.

- The bridge is the service that actually keeps the WhatsApp connection. The monitor is a
  separate, optional LaunchAgent that runs every 60 seconds. It checks that the bridge is
  reachable, that the authenticated API health call answers, the connection state, and the log
  evidence that a QR relink is needed.
- A monitor job in `waiting` or `inactive` between its runs is normal. A recent nonzero exit is not.
- If the monitor log says it cannot read `.bridge-token`, mark the monitor 🟡. Its `set -e`
  script exits before the health, disconnect and QR checks, so those notifications are lost. That
  does not invalidate the pairing or stop a healthy bridge.
- In that case verify the bridge on its own with a local authenticated health probe and report
  only the HTTP result and the `connected` boolean, never the token or the body. If the bridge is
  `200` and connected, the impact is the loss of automatic alerts, not of service. Do not re-pair.
  Look for a matching upstream issue and say whether one was found.
- Known case, fixed upstream: the macOS sandbox/TCC denial when reading `.bridge-token` was issue
  #249 and was fixed in release 0.7.0 (PR #250, merged 2026-09-23). The fix is a fail-soft
  `... 2>/dev/null) || TOKEN=""` read plus persisting the resolved token in `launchd.env`.
  On 0.7.0 or later, the same symptom is a new problem: investigate it fresh and do not attribute
  it to #249.
- An ordinary update only fast-forwards the checkout and rebuilds and reloads the bridge binary.
  It never re-runs `scripts/install-launchd-macos.sh`, so it does not redeploy
  `~/Library/Application Support/whatsapp-mcp/monitor-whatsapp-bridge.sh`,
  `run-whatsapp-bridge.sh` or `launchd.env`. After a release that touched the installer
  (0.6.0 → 0.7.0 did), the installed monitor script keeps the old code until the installer is
  re-run separately. The installer rewrites `launchd.env` and both plists and restarts the jobs
  immediately, so it needs the user's explicit approval each time.
- `launchctl print` can return a successful exit code while its text says the service is missing.
  Verify stop and restart from the returned service text.
- If the agent's shell is denied permission by macOS to control the user LaunchAgents, use a local
  terminal tool that runs on the user's Mac, and run short, separately verified commands.
