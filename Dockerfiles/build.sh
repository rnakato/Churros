for tag in 0.2.0
do
    docker build -f Dokerfile.$tag -t rnakato/churros:$tag . #--no-cache
    docker push rnakato/churros:$tag
    docker build -f Dockerfile.$tag -t rnakato/churros .
    docker push rnakato/churros
done
