for tag in 0.1.0 latest
do
    docker build -t rnakato/churros:$tag . #--no-cache
    docker push rnakato/churros:$tag
done
