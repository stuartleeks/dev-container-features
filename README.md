# Dev Container Features

This repo is my place for my custom dev container features - see [containers.dev/features](https://containers.dev/features) for more.

I make no guarantee that features here won't break with updates etc, but I use [stuartleeks/dev-container-features-playground](https://github.com/stuartleeks/dev-container-features-playground) for experimenting with features.



If you want to create your own features, see <https://github.com/devcontainers/feature-template>

| Feature                                                      | Description                                                       |
| ------------------------------------------------------------ | ----------------------------------------------------------------- |
| [azure-cli-persistence](src/azure-cli-persistence/README.md) | Preserve `~/.azure` folder across instances (avoids extra logins) |
| [add-host](src/add-host/README.md)                           | Add a host name/ip to the dev container hosts file                |
| [dev-tunnels](src/dev-tunnels/README.md)                     | Set up the `devtunnel` CLI for working with Dev Tunnels           |
| [shell-history](src/shell-history/README.md)                 | Preserve shell history across dev container instances/rebuilds    |

