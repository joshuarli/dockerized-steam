FROM archlinux/base

# zenity, a steam.sh required dependency, depends on ~400 MB of gtk cruft that will inflate the image size
# https://bugs.archlinux.org/task/40434
# https://github.com/ValveSoftware/steam-for-linux/issues/5560

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

# there are a few options here, including patchingsteam.sh post-install and subsequently removing zenity,
# but by far the easiest way is to supply pacman with a dummy zenity package that provides zenity as a noop.

# grep, sudo, and fakeroot are required for makepkg
# note: makepkg doesn't require tar, it will fallback to bsdtar
RUN pacman --noconfirm -Syu grep sudo fakeroot

# makepkg can't be run as root, but requires a sudo-enabled user
RUN useradd --system --create-home builder && \
    echo "builder ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

USER builder
COPY zenity-fake /tmp/zenity-fake
RUN cd /tmp/zenity-fake && \
    sudo chown -R builder:builder . && \
    PKGEXT=".pkg.tar" makepkg -cs --noconfirm && \
    sudo pacman --noconfirm -U *.pkg.tar

# low hanging fruit to save more space: ttf-liberation for ttf-font
RUN sudo sed -i '/#\[multilib\]/,/#Include = \/etc\/pacman.d\/mirrorlist/ s/#//' /etc/pacman.conf && \
    sudo pacman --noconfirm -Syu ttf-liberation steam

# used by steam.sh
USER root
RUN pacman --noconfirm -S util-linux file gawk diffutils pciutils tar

# cleanup
RUN rm -rf \
        /usr/share/doc \
        /usr/share/i18n \
        /usr/share/info \
        /usr/share/locale \
        /usr/share/man \
        /usr/share/terminfo \
        /usr/share/zoneinfo \
        /tmp/zenity-fake && \
    sudo userdel -r builder && \
    sudo pacman --noconfirm -Rs sudo fakeroot

RUN useradd steam
USER steam
ENV HOME /home/steam
CMD steam
