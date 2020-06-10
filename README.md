```
git clone https://github.com/tatref/aseprite-builder
cd aseprite-builder

docker build -t aseprite-builder .

docker run -it --rm \
  -e DISPLAY=$DISPLAY \
  -v /tmp/.X11-unix:/tmp/.X11-unix \
  -v /data:/data:rw \
  aseprite-builder
```

