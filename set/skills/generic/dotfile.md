# Dotfile

Dotfiles are configuration or marker files whose name begins with a
dot and have no traditional file extension. They serve infrastructure
roles (directory preservation, tool configuration, access control)
rather than containing application logic.

## Conventions

- Use `.keep` (not `.gitkeep`) as the directory-preservation marker.
- `.keep` files are always empty -- no content, no comments.
- When a directory that previously needed `.keep` gains real content,
  remove the `.keep` file.
