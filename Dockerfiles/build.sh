tag=0.9.1
docker build -f Dockerfile.$tag -t rnakato/churros:$tag . #--no-cache
docker push rnakato/churros:$tag
docker tag rnakato/churros:$tag rnakato/churros:latest
docker push rnakato/churros
