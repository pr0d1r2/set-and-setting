# Just: modularity

Do not store embedded shell in just files but rather extract them to
separate shell files and prepend with bash where used.

The recipe body is the invocation and nothing else:

```just
bash scripts/just/<module>/<script>.sh
```
