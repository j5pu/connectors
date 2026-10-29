# WhatsApp update (`connectors update`)

Only the `whatsapp` connector has an update. The checkout path and the remote are in
`connectors.json` (`whatsapp_checkout`, `whatsapp_remote`). Use that checkout and no other copy.
The MCP is `<checkout>/whatsapp-mcp-server`, launched by `uv --directory … run --frozen main.py`.
`--frozen` stops normal starts from rewriting `uv.lock`; report drift if a client still uses the
older command, and do not edit any platform configuration unless the user asks.

`launchd` controls only the Go bridge and the monitor. The Python MCP process belongs to the
agent application, so a successful update must say whether the application needs a restart.
Never kill or restart an application or an unknown process automatically.

## Decide first

Read the SHA of `origin/main` with a read-only remote query and compare it with local `HEAD`.
If they match, report that WhatsApp is already on the remote version and do not stop a service,
reset `uv.lock`, pull, build or run tests. If the remote is unreachable or cannot be compared
safely, say so and do not start an update. Only a different, verified remote SHA enters the
procedure.

## Procedure

Run short, separately verified commands. Never one opaque compound update script.

1. Verify only that the two per-user plist files are valid (`plutil -lint`):
   `com.whatsapp-mcp.bridge-monitor` and `com.whatsapp-mcp.bridge`. Stop the monitor first, then the
   bridge, with `launchctl bootout gui/<uid>/<label>`. Do not inspect, pull, reset, build or test
   before both are stopped. Verify the stop from the text of `launchctl print`, not its exit code:
   `state = running` blocks repository work; `waiting`, `inactive` or an absent service means
   stopped; `SIGTERMed` right after `bootout` is transitional, so wait and read again.
2. Record the current commit and the version in `server.json`. Check that the branch is `main`.
   A clean tree may continue. If the only change is `whatsapp-mcp-server/uv.lock`, continue with
   step 3. Any other modified, added, deleted, renamed or untracked path is a stop: reload the
   existing bridge, verify it, and report the update as skipped with the changed paths only.
3. Only if `uv.lock` was the sole change: `git reset --hard HEAD`, then
   `git pull --ff-only origin main`. Never merge, rebase, stash or clean. Record the candidate
   commit and require the same version in `server.json` and `whatsapp-mcp-server/pyproject.toml`.
4. Before restart, run the basic regression set without changing the lockfile: frozen `uv` sync,
   frozen Python tests, frozen Python lint, Go tests and a Go bridge build.
5. List what the pull changed: `git diff --name-only <old> <new>`. If it includes
   `scripts/install-launchd-macos.sh`, `scripts/uninstall-launchd-macos.sh` or anything the
   installer writes into `~/Library/Application Support/whatsapp-mcp/` or `~/Library/LaunchAgents/`,
   stop and ask the user. An ordinary update does not redeploy those installed copies, and
   re-running the installer is a separate step that needs the user's explicit approval.
6. Enable, bootstrap and kickstart the two existing plists. Check that both are loaded and have
   `RunAtLoad=true`. The bridge must end `running`; the monitor may be `waiting` or `inactive`
   between its 60-second runs. Do an authenticated health check against
   `http://127.0.0.1:8080/api/health` using the token from `whatsapp-bridge/store/.bridge-token`
   without printing the token or the body. Accept a `200` with `connected: true`.

## State that must never be touched

`whatsapp-bridge/store/whatsapp.db` holds the pairing and history, and
`whatsapp-bridge/store/.bridge-token` is the bridge token. A Git reset cannot remove either. Never
delete, move, reset or re-pair them as part of an update or audit.

## Rollback and report

If the pull, the version check, the tests or the restart fail after the checkout changed, restore
the recorded commit with `git reset --hard <previous>`, repeat the frozen dependency check and the
bridge build, then load and verify the previous bridge. Report the old connector as 🟢 only if its
post-rollback health check passes, and the candidate as `🟡 actualización fallida y revertida`. If
restoration or the old health fails, report 🔴 and never claim a running previous version without
verifying it.

On success report `🟢 WhatsApp actualizado, versión <old> → <new>` with the bridge and
launch-at-login checks shown separately. If the application's MCP process predates the update,
report `🟡 MCP pendiente de reiniciar la aplicación`, not a false end-to-end green.
