# dockerized-steam

dockerized (based on arch linux) steam client

build

    docker build -t steam-container .    

example invocation (e.g. assumes host is running X, pulseaudio, and some particular device configuration)

    docker run --rm \
        -v "${PWD}"/data:/home/steam \
        -v /dev/shm:/dev/shm \
        -v /dev/dri:/dev/dri \
        -v /tmp/.X11-unix:/tmp/.X11-unix \
        -v "${XDG_RUNTIME_DIR}/pulse:"${XDG_RUNTIME_DIR}"/pulse" \
        -e PULSE_SERVER="unix:$XDG_RUNTIME_DIR/pulse/native" \
        -e DISPLAY=$DISPLAY \
        steam-container


## technical details

this image fakes the zenity package, avoiding ~400 MB of gtk dependencies that aren't needed.

if you click on the x to exit the steam client, you'll need to manually kill the docker process. however, if you exit via Steam > Exit, it is clean.
