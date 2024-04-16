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

# Add Lunar Vim for code IDE.
# First add neovim as Lunar Vim depends on it.  We cannot use the apt package as we need a more recent version.
# Then install LunarVim and the users configuration.
RUN if [ $IDE_CONFIG_URL ]; then \
    curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux64.tar.gz && \
    tar -C . -xzf nvim-linux64.tar.gz && \
    mv nvim-linux64/ ~/.local/ && \
    rm -rf nvim-linux64.tar.gz && \
    rm -rf nvim-linux64 && \
    echo 'export PATH="$PATH:~/.local/bin"' >> ~/.bashrc && \
    LV_BRANCH='release-1.3/neovim-0.9' su -c "bash <(curl -s https://raw.githubusercontent.com/lunarvim/lunarvim/release-1.3/neovim-0.9/utils/installer/install.sh) --no-install-dependencies" && \
    curl -L "$IDE_CONFIG_URL" > /root/.config/lvim/config.lua; \
    else \
    echo IDE Setup Skipped.; \
    fi

# Add Starship for shell customization.
RUN if [ $SHELL_CONFIG_URL ]; then \
    su -c "sh <(curl -sS https://starship.rs/install.sh) -y" && \
    echo 'eval "$(starship init bash)"' >> ~/.bashrc && \
    mkdir -p /root/.config && \
    curl -L "https://raw.githubusercontent.com/mtt-wlsn/dotfiles/main/starship.toml" > /root/.config/starship.toml; \
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

# Install dotnet debugger
RUN if [ $DOTNET_VERSION && $IDE_CONFIG_URL ]; then \
    curl -LO https://github.com/Samsung/netcoredbg/releases/download/3.1.0-1031/netcoredbg-linux-amd64.tar.gz && \
    tar -C . -xzf netcoredbg-linux-amd64.tar.gz && \
    mv netcoredbg ~/.local/bin/ && \
    rm -rf netcoredbg-linux-amd64.tar.gz; \
    fi

WORKDIR /app
