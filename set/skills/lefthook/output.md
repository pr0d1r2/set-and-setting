# Lefthook: output

Configure lefthook to show only failures. Add to lefthook.yml:

```yaml
output:
  - failure
```

This keeps git hooks silent on success. Developers only see output when something breaks.
