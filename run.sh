#/bin/bash

sudo docker run -it --runtime=nvidia -e DISPLAY=$DISPLAY -v/tmp/.X11-unix:/tmp/.X11-unix tf-1.12