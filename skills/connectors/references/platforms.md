# Platform notes

Use the tools registered in the current session and call each probe by its exact registered name.

## Codex

Inspect the active tool registry and call the registered tools directly. Names seen so far:
`mcp__apple_mail__health_check`, `mcp__icloud_mcp__check_auth_status`, `mcp__icloud_mcp__set_mode`,
`mcp__icloud_mcp__list_chats`, `mcp__iwork_mcp__numbers_list_documents`,
`mcp__whatsapp__list_chats` and `mcp__desktop_commander__get_config`. If a registered tool cannot
be called, report that probe as unavailable in this runtime; do not label the server down or
suggest a restart.

## Claude

Use an equivalent dedicated health or status call when the connector offers one. For the native
`Read and Send iMessages` connector use only a safe availability check; if there is none, do not
read a conversation to prove health. The native connector is preferred when it is available.

## ChatGPT Work

The probes in `connectors.json` apply as they are. Discard all source content returned.

## Platform configuration

The WhatsApp MCP should launch with `uv --directory <checkout>/whatsapp-mcp-server run --frozen
main.py`. An existing client may still use the older command without `--frozen`. Report that
drift; do not edit any platform configuration unless the user expressly asks.
