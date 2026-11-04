
# Power Platform CLI (with persistence) (powerapps-cli)

Install the Power Platform CLI (pac) and preserve configuration and authentication across container rebuilds

## Example Usage

```json
"features": {
    "ghcr.io/stuartleeks/dev-container-features/powerapps-cli:0": {}
}
```

## Options

| Options Id | Description | Type | Default Value |
|-----|-----|-----|-----|


## Persistence

The feature installs [.NET 10 via the dotnet feature](https://github.com/devcontainers/features/tree/main/src/dotnet) and installs `Microsoft.PowerApps.CLI.Tool`, making `pac` available on `PATH` for all users.

The following directories are symlinked to a container-specific Docker volume mounted at `/dc/powerapps-cli`:

| Directory | Volume directory |
| --------- | ---------------- |
| `$HOME/.local/share/Microsoft/PowerAppsCli` | `/dc/powerapps-cli/data` |
| `$HOME/.config/Microsoft/PowerAppsCli` | `/dc/powerapps-cli/config` |

Existing directories are backed up with an `-old` suffix and their contents copied into the volume without overwriting persisted files. Persistence is configured for the dev container's remote user during `onCreateCommand`.

The volume contains authentication data. Treat it as sensitive; deleting the volume removes the persisted configuration and authentication.

See Microsoft's [installation documentation](https://learn.microsoft.com/en-us/power-platform/developer/howto/install-cli-net-tool) for details. Some `pac` commands are Windows-only and are not available in Linux dev containers.

## Changelog

| Version | Notes |
| ------- | ----- |
| 0.0.1 | Initial version |


---

_Note: This file was auto-generated from the [devcontainer-feature.json](https://github.com/stuartleeks/dev-container-features/blob/main/src/powerapps-cli/devcontainer-feature.json).  Add additional notes to a `NOTES.md`._
