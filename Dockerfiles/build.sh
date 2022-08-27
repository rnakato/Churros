for tag in 0.2.0
do
    docker build -f Dockerfile.$tag -t rnakato/churros:$tag . #--no-cache
    docker push rnakato/churros:$tag
    docker tag rnakato/churros:$tag rnakato/churros:latest
    docker push rnakato/churros
done
