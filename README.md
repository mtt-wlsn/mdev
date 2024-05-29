## Overview

mdev is a little experiment at creating a complete developer environment from a dockerfile.

## How to use

1. Download the `dockerfile`.
2. Build the image by running the following docker build command with your own argument values:
   ```bash
   docker build \
       -t mdev \
       --build-arg IDE_CONFIG_URL="https://github.com/mtt-wlsn/dotfiles/tree/main/.config/nvim" \
       --build-arg SHELL_CONFIG_URL="https://raw.githubusercontent.com/mtt-wlsn/dotfiles/main/starship.toml" \
       --build-arg GIT_EMAIL="matt@mttwlsn.com" \
       --build-arg GIT_NAME="Matt Wilson" \
       --build-arg ADD_SQL_IDE=true \
       --build-arg DOTNET_VERSION=8.0 \
       .
   ```
3. Use the image by running the following commands:

   ```bash
   docker run -itd --rm --name mdev \
       --mount type=bind,source=./,target=/app \
       -v ~/.ssh/github:/root/.ssh \
       mdev \

   docker attach mdev
   ```
