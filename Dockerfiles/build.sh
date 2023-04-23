tag=0.9.0
docker build -f Dockerfile.$tag -t rnakato/churros:$tag . #--no-cache
exit
docker push rnakato/churros:$tag
docker tag rnakato/churros:$tag rnakato/churros:latest
docker push rnakato/churros
