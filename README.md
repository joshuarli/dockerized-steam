# dockerized-steam

dockerized (based on arch linux) steam client

build

    docker build -t steam-container .    

example invocation (e.g. assumes host is running X, pulseaudio, and some particular device configuration)

    mkdir "${PWD}/steam-data"
    docker run --rm \
        -v "${PWD}/steam-data:/home/steam" \
        -v /dev/shm:/dev/shm \
        --shm-size=512M \
        -v /tmp/.X11-unix:/tmp/.X11-unix \
        -e DISPLAY="$DISPLAY" \
        -v /dev/dri:/dev/dri \
        -v "${XDG_RUNTIME_DIR}/pulse:${XDG_RUNTIME_DIR}/pulse" \
        -e PULSE_SERVER="unix:${XDG_RUNTIME_DIR}/pulse/native" \
        steam-container

this invocation carries a few assumptions (tweak for your own machine):

- you have a tmpfs mounted at `/dev/shm`; steam requires this
    - adjust `--shm-size` to taste; docker by default limits this to 64M, which isn't enough to run games with lots of media assets
- host machine is running X and pulseaudio, with some conventions regarding devices and ipc
    - if you haven't already, add yourself to the X acl: `xhost +SI:localuser:$(whoami)`


## technical details

this image fakes the zenity package, avoiding ~400 MB of gtk dependencies that aren't needed.

if you click on the x to exit the steam client, you'll need to manually kill the docker process. however, if you exit via Steam > Exit, it is clean.
