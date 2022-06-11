for tag in 0.1.0 latest
do
    docker build -t rnakato/churros:$tag .
    docker push rnakato/churros:$tag
done
