git clone 
git clone https://github.com/tatref/aseprite-builder
cd aseprite-builder
docker build -t aseprite-builder .

docker create --name aseprite-builder aseprite-builder
docker cp aseprite-builder:aseprite/build/bin/aseprite aseprite.bin


aseprite.bin requires ./data from the git repo https://github.com/aseprite/aseprite.git
