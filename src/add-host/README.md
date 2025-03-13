
# Add Host (add-host)

Add a hosts file entry in the dev container.

## Example Usage

```json
"features": {
    "ghcr.io/stuartleeks/dev-container-features/add-host:1": {}
}
```

## Options

| Options Id | Description | Type | Default Value |
|-----|-----|-----|-----|
| host_name | Host name to add to the container's hosts file | string | host.docker.internal |
| host_ip | The IP Address to associate with the host name | string | - |


## Changelog

| Version | Notes                                                               |
| ------- | ------------------------------------------------------------------- |
| 1.0.3   | Handle no sudo, switch to poststart script                          |
| 1.0.1   | Initial version                                                     |

---

_Note: This file was auto-generated from the [devcontainer-feature.json](https://github.com/stuartleeks/dev-container-features/blob/main/src/add-host/devcontainer-feature.json).  Add additional notes to a `NOTES.md`._
