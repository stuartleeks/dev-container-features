
# Azure CLI Persistence (azure-cli-persistence)

Preserve ~/.azure folder across container instances (avoids needing to re-login after rebuilding)

## Example Usage

```json
"features": {
    "ghcr.io/stuartleeks/dev-container-features/azure-cli-persistence:0": {}
}
```

## Options

| Options Id | Description | Type | Default Value |
|-----|-----|-----|-----|



## Changelog

| Version | Notes                                                        |
| ------- | ------------------------------------------------------------ |
| 0.0.9   | Move marker file location out of user home dir               |
| 0.0.8   | Add logic to merge extensions when the extensions folder already exists in both old and new .azure folders (see [#36](https://github.com/stuartleeks/dev-container-features/issues/36)) (see [#36](https://github.com/stuartleeks/dev-container-features/issues/36)) |
| 0.0.7   | Add marker files to prevent double installation when a feature is [always installed](https://code.visualstudio.com/docs/devcontainers/containers#_always-installed-features) and in a devcontainer.json file. |
| 0.0.6   | Add symlink for cliextensions folder                         |
| 0.0.5   | Use lifecycle scripts                                        |
| 0.0.4   | Fix test for existing ~/.azure folder                        |
| 0.0.3   | Rename existing ~/.azure folder to ~/.azure-old if it exists |
| 0.0.1   | Initial version                                              |

---

_Note: This file was auto-generated from the [devcontainer-feature.json](https://github.com/stuartleeks/dev-container-features/blob/main/src/azure-cli-persistence/devcontainer-feature.json).  Add additional notes to a `NOTES.md`._
