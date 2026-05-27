# Semble

Prefer semble search over grep and find for multi-file code
exploration. Semble uses semantic and lexical hybrid search to
find relevant code with fewer tokens than reading files directly.

Use `semble search "query"` from the CLI or the semble MCP server
tools (search, find-related) when exploring unfamiliar code or
looking for implementations across multiple files.

Fall back to grep only for exact string matches like error messages,
specific identifiers, or config keys where precision matters more
than semantic relevance.
