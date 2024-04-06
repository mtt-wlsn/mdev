FROM ubuntu:latest

RUN apt-get update
RUN apt-get upgrade -y
RUN apt-get install git make python3 pip cargo ripgrep curl -y

# Add NVM for Node management
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
RUN ["/bin/bash", "-c", ". /root/.nvm/nvm.sh && source /root/.bashrc && nvm install --lts"]

# Add Lunar Vim for code IDE.
# First add neovim as Lunar Vim depends on it.  We cannot use the apt package as we need a more recent version.
RUN curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux64.tar.gz
RUN tar -C . -xzf nvim-linux64.tar.gz
RUN mv nvim-linux64/ ~/.local/
RUN rm -rf nvim-linux64.tar.gz
RUN rm -rf nvim-linux64
RUN echo 'export PATH="$PATH:~/.local/bin"' >> ~/.bashrc
# Then install Lunar Vim
RUN LV_BRANCH='release-1.3/neovim-0.9' su -c "bash <(curl -s https://raw.githubusercontent.com/lunarvim/lunarvim/release-1.3/neovim-0.9/utils/installer/install.sh) --no-install-dependencies"
RUN curl -L "https://raw.githubusercontent.com/mtt-wlsn/dotfiles/main/config.lua" > /root/.config/lvim/config.lua


# Add Starship for shell customization.
RUN su -c "sh <(curl -sS https://starship.rs/install.sh) -y"
RUN echo 'eval "$(starship init bash)"' >> ~/.bashrc
RUN curl -L "https://raw.githubusercontent.com/mtt-wlsn/dotfiles/main/starship.toml" > /root/.config/starship.toml

# Configure git
RUN git config --global user.email "matt@mttwlsn.com"
RUN git config --global user.name "Matt Wilson"
# To use SSH mount your host ssh key to the container
# -v ~/.ssh/github:/root/.ssh

# # Harlequin (SQL IDE for the terminal)
RUN pip install harlequin-postgres

# Add other system dependencies

WORKDIR /app