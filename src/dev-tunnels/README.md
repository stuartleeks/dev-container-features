
# Dev Tunnels (dev-tunnels)

Set up the `devtunnel` CLI for working with [Dev Tunnels](https://learn.microsoft.com/en-us/azure/developer/dev-tunnels/overview)

## Example Usage

```json
"features": {
    "ghcr.io/stuartleeks/dev-container-features/dev-tunnels:0": {
        "version": "latest"
    }
}
```

## Options

| Options Id | Description | Type | Default Value |
|-----|-----|-----|-----|



## Changelog

| Version | Notes                                                               |
| ------- | ------------------------------------------------------------------- |
| 0.0.3   | Set `HISTFILE_OLD` when replacing a previous `HSITFILE` value       |
| 0.0.2   | Initial work to reduce the requirement on `sudo` in `shell-history` |
| 0.0.1   | Initial version                                                     |

---

_Note: This file was auto-generated from the [devcontainer-feature.json](https://github.com/stuartleeks/dev-container-features/blob/main/src/dev-tunnels/devcontainer-feature.json).  Add additional notes to a `NOTES.md`._
