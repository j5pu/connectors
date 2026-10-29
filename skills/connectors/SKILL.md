---
name: connectors
description: Lists and diagnoses the MCPs and connectors the user relies on (`connectors`, `connectors doctor`) and updates the local WhatsApp connector (`connectors update`). Use only when the user says connectors, conectores, connectors doctor or connectors update, or asks to audit the available connectors.
---

# Connectors

The baseline of connectors and MCPs, with the safe probe for each one, lives in `connectors.json`
next to this file. It is the only authoritative list. Do not duplicate it here and do not add
requirements that are not in it. Write every report in the language the user is writing in.

The invocation authorizes only the read-only probes below and, for `connectors update`, the
bounded WhatsApp procedure in `references/whatsapp-update.md`. Never send, draft, alter, mark,
delete, move, download, save, authenticate or configure user content. Never reproduce content
returned by a probe: keep only whether the call responded and its health result.

## Modes

- `connectors`: list what is available. No probes.
- `connectors doctor`: list what is available and run one probe per baseline item.
- `connectors update`: update the local WhatsApp checkout (see the reference), then run the
  WhatsApp probe. Only WhatsApp has an update.

## Listing

1. Inspect only the tool or connector registry of the current agent session. Do not infer
   availability from project files, past chats or another platform.
2. Read `connectors.json`. For each baseline item find the matching registered server by name.
   Names vary by platform, so match on the server identifier and call each tool by its exact
   registered name. Never conclude that a server is unavailable because a guessed tool name
   failed. Never start a second copy of an MCP server from a shell as a fallback.
3. List every connector family the session has, including those outside the baseline, with name,
   status and platform. Do not list individual tools unless asked.

## Doctor

Run each probe once, in read-only mode, and discard the content. Mark every baseline item with
exactly one state from `states` in `connectors.json`:

- 🟢 operativo: the connector is visible and the safe probe succeeded.
- 🟡 presente pero no verificable: visible, but it has no safe probe (`probe: null`) or the probe
  could not be called in this runtime. Say which.
- ⚪ no disponible: not registered in this session. It may be off in this chat or not installed;
  say that this cannot be told apart from here.
- 🔴 con error: the probe was called and failed. Give the exact error, without private content.

A missing connector with `required: true` is flagged as a problem. A missing optional one is
only reported.

`icloud-mcp` iMessage probe: set the mode to local, call `list_chats` with limit 1 without
reporting the chat, and restore cloud mode in a finally-equivalent step, even after an error.
Report whether the restoration succeeded. A repeated audit must leave user data unchanged and
iCloud in cloud mode.

## Output

A compact `AUDITORÍA DE CONECTORES` (or the equivalent title in the user's language) with:

- platform and date;
- the connector families the session has;
- a table with one row per baseline item: required or optional, state, probe used and its
  non-sensitive result;
- missing or unverifiable items and their effect;
- no recommendation to install or change anything unless the user asks.

Do not write a report file. The result belongs in the conversation.
