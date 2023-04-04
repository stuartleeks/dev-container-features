
# Azure CLI Persistence (azure-cli-persistence)

Preserve ~/.azure folder across container instances (avoids needing to login after rebuilding)

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
| 0.0.4   | Fix test for existing ~/.azure folder                        |
| 0.0.3   | Rename existing ~/.azure folder to ~/.azure-old if it exists |
| 0.0.1   | Initial version                                              |

---

_Note: This file was auto-generated from the [devcontainer-feature.json](https://github.com/stuartleeks/dev-container-features/blob/main/src/azure-cli-persistence/devcontainer-feature.json).  Add additional notes to a `NOTES.md`._
