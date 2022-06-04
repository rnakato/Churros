for tag in 2022.06 latest
do
    docker build -t rnakato/churros:$tag .
    docker push rnakato/churros:$tag
done
