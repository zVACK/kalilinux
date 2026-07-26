```bash
docker build -t xrdp .

docker run -d -p 3389:3389 -v xrdp-ameer-home:/home/Ameer --name xrdp-root-wine-audio xrdp
