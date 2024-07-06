FROM ubuntu:latest

# General configuration arguments.
ARG IDE_CONFIG_URL
ARG SHELL_CONFIG_URL
ARG GIT_EMAIL
ARG GIT_NAME
ARG ADD_SQL_IDE=false

# Language specific arguments.
ARG DOTNET_VERSION

RUN apt-get update
RUN apt-get upgrade -y
RUN apt-get install git make python3 pip cargo ripgrep curl -y

# Add NVM for Node management
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
RUN ["/bin/bash", "-c", ". /root/.nvm/nvm.sh && source /root/.bashrc && nvm install --lts"]

# Add neovim.  We cannot use the apt package as we need a more recent version.
RUN set -e; \
    if [ -n "$IDE_CONFIG_URL" ]; then \
    curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux64.tar.gz && \
    tar -C . -xzf nvim-linux64.tar.gz && \
    mv nvim-linux64/ ~/.local/ && \
    rm -rf nvim-linux64.tar.gz && \
    rm -rf nvim-linux64 && \
    echo 'export PATH="$PATH:~/.local/bin"' >> ~/.bashrc && \
    curl -LO $IDE_CONFIG_URL && \
    tar -C . -xzf v1.0.0.tar.gz && \
    mv dotfiles-1.0.0/.config/ /root/.config/ && \
    rm -rf dotfiles-1.0.0 && \
    rm -rf v1.0.0.tar.gz \
    else \
    echo IDE Setup Skipped.; \
    fi

# Add Starship for shell customization.
RUN if [ $SHELL_CONFIG_URL ]; then \
    su -c "sh <(curl -sS https://starship.rs/install.sh) -y" && \
    echo 'eval "$(starship init bash)"' >> ~/.bashrc && \
    mkdir -p /root/.config && \
    curl -L $SHELL_CONFIG_URL > /root/.config/starship.toml; \
    fi

# Configure git
RUN if [ $GIT_EMAIL && $GIT_NAME ]; then \
    git config --global user.email "$GIT_EMAIL" && \
    git config --global user.name "$GIT_NAME"; \
    fi
# To use SSH mount your host ssh key to the container
# -v ~/.ssh/github:/root/.ssh

# Harlequin (SQL IDE for the terminal)
RUN if [ "$ADD_SQL_IDE" = "true" ]; then pip install harlequin-postgres; fi

# Begin language specific dependencies

# Install dotnet sdk
RUN if [ $DOTNET_VERSION ]; then apt install -y dotnet-sdk-$DOTNET_VERSION; fi

WORKDIR /app
