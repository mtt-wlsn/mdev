# FROM node:20-alpine
FROM alpine:latest
RUN apk update

# Add Lunar Vim for code IDE.
RUN apk add nodejs npm yarn git make cargo ripgrep neovim alpine-sdk bash curl python3 py3-pip lazygit
RUN LV_BRANCH='release-1.3/neovim-0.9' su -c "bash <(curl -s https://raw.githubusercontent.com/lunarvim/lunarvim/release-1.3/neovim-0.9/utils/installer/install.sh) --no-install-dependencies"
ENV PATH="${PATH}:/root/.local/bin"
# TODO - Add lunar vim configuration file.

# Add Starship for shell customization.
RUN su -c "sh <(curl -sS https://starship.rs/install.sh) -y"
RUN echo 'eval "$(starship init bash)"'> ~/.bashrc
# TODO - Add startship configuration.

# Configure git
RUN apk add openssh-client
RUN git config --global user.email "matt@mttwlsn.com"
RUN git config --global user.name "Matt Wilson"
RUN mkdir ~/.ssh && ssh-keyscan github.com >> ~/.ssh/known_hosts
# To use SSH mount your host ssh key to the container
# -v ~/.ssh/github:/root/.ssh

# Add other system dependencies

WORKDIR /app

CMD ["bash"]
