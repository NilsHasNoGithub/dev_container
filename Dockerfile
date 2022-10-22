FROM archlinux

RUN --mount=type=cache,sharing=locked,target=/var/cache/pacman \
    pacman -Syyu --noconfirm --needed \
    git \
    zsh \
    sudo \
    base \
    base-devel \
    wget \
    exa \
    starship \
    neovim \
    ripgrep \
    fd \
    cuda cuda-tools \
    python python-click \
    jdk-openjdk

# Configure gpu
ENV NVIDIA_VISIBLE_DEVICES all
ENV NVIDIA_DRIVER_CAPABILITIES compute,utility

RUN useradd -m -G wheel -s /usr/bin/zsh user && \
    echo 'user:pass' | chpasswd && \
    echo '%wheel ALL=(ALL:ALL) NOPASSWD: ALL' > /etc/sudoers.d/wheelsudo

# create temporary workdir
RUN mkdir /workdir && chown user /workdir
WORKDIR /workdir

# Copy some configuration files
RUN mkdir -p /home/user/.config
COPY --chown=user ./config/zshrc /home/user/.zshrc
COPY --chown=user ./config/starship /home/user/.config/starship
COPY --chown=user ./config/condarc /home/user/.condarc

# install yay   
RUN su user -c 'git clone https://aur.archlinux.org/yay.git' && \
    cd yay && \
    su user -c 'makepkg -si --noconfirm'

# install some yay packages
RUN su user -c 'yay -S --noconfirm antigen oh-my-zsh-git'

# install minconda3 and mamba
RUN wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O miniconda.sh && \
    su user -c 'bash miniconda.sh -b -p $HOME/miniconda' && \
    su user -c '$HOME/miniconda/bin/conda init bash zsh' && \
    su user -c '$HOME/miniconda/bin/conda install -c conda-forge mamba && $HOME/miniconda/bin/mamba init bash zsh'


# install rust
RUN su user -c 'wget https://sh.rustup.rs -O rustup_install.sh && sh rustup_install.sh -y'


WORKDIR /home/user
RUN rm -rf /workdir /home/user/.cache

USER user
CMD ["/usr/bin/zsh"]