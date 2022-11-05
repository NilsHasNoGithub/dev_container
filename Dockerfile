FROM archlinux

ARG USER_ID=1000

# RUN --mount=type=cache,sharing=locked,target=/var/cache/pacman \
RUN pacman -Syyu --noconfirm --needed \
    git \
    zsh \
    sudo \
    base \
    base-devel \
    wget \
    exa \
    starship \
    neovim \
    tmux \
    trash-cli \
    ripgrep \
    fd \
    libgl \
    zoxide \
    openssh \
    cuda cuda-tools \
    nodejs
    # python python-click \
    # jdk-openjdk

# Configure gpu
ENV NVIDIA_VISIBLE_DEVICES all
ENV NVIDIA_DRIVER_CAPABILITIES compute,utility


RUN useradd -m -G wheel -s /usr/bin/zsh user -u ${USER_ID} && \
    chsh -s /usr/bin/zsh root && \
    echo 'user:pass' | chpasswd && \
    echo 'root:pass' | chpasswd && \
    echo '%wheel ALL=(ALL:ALL) NOPASSWD: ALL' > /etc/sudoers.d/wheelsudo

# create temporary workdir
RUN mkdir /workdir && chown user /workdir
WORKDIR /workdir

# Copy some configuration files
RUN mkdir -p /home/user/.config /root/.config

COPY --chown=user ./config/zshrc /home/user/.zshrc
COPY --chown=user ./config/starship /home/user/.config/starship
COPY --chown=user ./config/condarc /home/user/.condarc

COPY ./config/zshrc /root/.zshrc
COPY ./config/starship /root/.config/starship
COPY ./config/condarc /root/.condarc

COPY ./config/sshd_config /etc/ssh/sshd_config

# Generate hostkeys for sshd
RUN ssh-keygen -A

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
    su user -c '$HOME/miniconda/bin/conda install -c conda-forge mamba && $HOME/miniconda/bin/mamba init bash zsh' && \
    /home/user/miniconda/bin/conda init bash zsh && \
    /home/user/miniconda/bin/mamba init bash zsh


# install rust
RUN su user -c 'wget https://sh.rustup.rs -O rustup_install.sh && sh rustup_install.sh -y'


WORKDIR /home/user
RUN rm -rf /workdir /home/user/.cache

# USER user
CMD ["/usr/bin/zsh"]
