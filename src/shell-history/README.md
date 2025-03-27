
# Shell History (shell-history)

Preserve shell history across dev container instances. Currently supports bash, zsh, and fish

## Example Usage

```json
"features": {
    "ghcr.io/stuartleeks/dev-container-features/shell-history:0": {}
}
```

## Options

| Options Id | Description | Type | Default Value |
|-----|-----|-----|-----|



## Changelog

| Version | Notes                                                               |
| ------- | ------------------------------------------------------------------- |
| 0.0.6   | Fix fish history (@eitsupi)                                         |
| 0.0.5   | Revert to updating .bashrc etc to set HISTFILE env var              |
| 0.0.4   | Use lifecycle scripts                                               |
| 0.0.3   | Set `HISTFILE_OLD` when replacing a previous `HSITFILE` value       |
| 0.0.2   | Initial work to reduce the requirement on `sudo` in `shell-history` |
| 0.0.1   | Initial version                                                     |

---

_Note: This file was auto-generated from the [devcontainer-feature.json](https://github.com/stuartleeks/dev-container-features/blob/main/src/shell-history/devcontainer-feature.json).  Add additional notes to a `NOTES.md`._
