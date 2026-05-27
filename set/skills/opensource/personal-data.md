# Open-source: personal data

No personally identifiable information in tracked source files. The
repo must be safe to publish without redaction.

## What counts as PII

- Real email addresses, phone numbers, physical addresses
- Real IP addresses (operator workstations, home networks)
- Usernames tied to real identity (beyond git author in commits)
- API keys, OAuth tokens, session cookies

## Where PII lives (safely)

- `secrets/` -- gitignored, never tracked
- Config allowlists -- gitignored, contain operator IPs
- `.claude/` -- gitignored, contains session state
- Git commit author -- acceptable (public contribution record)

## Safe patterns in source

- `user@example.com` -- example domain, not real
- `192.168.1.100` -- placeholder in `.example` files
- `*.local` -- mDNS hostnames, not identifying

## Before adding new documentation or examples

Use `example.com`, `example.org` (RFC 2606 reserved domains) for
email examples. Use `192.168.1.x` or `10.0.0.x` for IP examples.
Never embed real hostnames, domains, or IPs from the operator's
network in tracked files.
