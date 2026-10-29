# connectors

A skill that lists and diagnoses the MCPs and connectors you rely on, and updates the local
WhatsApp connector.

## Use

Say one of these in a chat:

- `connectors`: list the connectors the current session has.
- `connectors doctor`: run one safe, read-only probe per connector and report 🟢 operativo,
  🟡 presente pero no verificable, ⚪ no disponible or 🔴 con error. A missing required connector
  is flagged as a problem.
- `connectors update`: update the local WhatsApp checkout with a safe procedure (stop the
  services, fast-forward, run the tests, restart and check health). It does nothing if the
  checkout is already on the remote version.

## Install

```
/plugin install connectors --marketplace j5pu/connectors
```

## The list of connectors

The baseline lives in `skills/connectors/connectors.json`: for each connector, whether it is
required, and the probe to run. Edit that file to add or remove connectors. The skill itself does
not repeat the list.

## How the probes run

The skill runs inside an agent session and probes what that session has registered, both local
MCP servers and account connectors reached by URL. A connector that is off in that chat is
reported as not available; from inside the chat that cannot be told apart from not installed.
Claude Code and Cowork can expose different sets, so the result depends on where it runs.

Probes never send, change or read private content, and the report never shows what a probe
returns.

## Tests

`tests/run.sh` checks the JSON files, the skill frontmatter, that every required connector has a
probe, and that the WhatsApp checkout path exists on this machine.

## License

MIT
