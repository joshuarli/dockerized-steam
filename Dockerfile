FROM archlinux/base

RUN sed -i '/#\[multilib\]/,/#Include = \/etc\/pacman.d\/mirrorlist/ s/#//' /etc/pacman.conf && \
    pacman --noconfirm -Syu ttf-liberation steam

# zenity depends on a lot of cruft that will inflate the image size
# for example: --ignore adobe-source-code-pro-fonts results in
# warning: ignoring package adobe-source-code-pro-fonts-2.030ro+1.050it-5
# warning: cannot resolve "adobe-source-code-pro-fonts", a dependency of "gsettings-desktop-schemas"
# warning: cannot resolve "gsettings-desktop-schemas", a dependency of "glib-networking"
# warning: cannot resolve "glib-networking", a dependency of "libsoup"
# warning: cannot resolve "libsoup", a dependency of "rest"
# warning: cannot resolve "rest", a dependency of "gtk3"
# warning: cannot resolve "gtk3", a dependency of "webkit2gtk"
# warning: cannot resolve "webkit2gtk", a dependency of "zenity"
# warning: cannot resolve "zenity", a dependency of "steam"

# the low hanging fruit: ttf-liberation for ttf-font

# used by steam.sh
RUN pacman --noconfirm -S util-linux file grep gawk diffutils pciutils

RUN echo 'steam ALL = NOPASSWD: ALL' >> /etc/sudoers && \
    useradd steam

USER steam
ENV HOME /home/steam

CMD steam
