tag=0.10.1
docker build -f Dockerfile.$tag -t rnakato/churros:$tag . #--no-cache
#docker save -o churros-$tag.tar rnakato/churros:$tag
#singularity build -F churros.$tag.sif docker-archive://churros-$tag.tar
#exit

docker push rnakato/churros:$tag
docker tag rnakato/churros:$tag rnakato/churros:latest
docker push rnakato/churros
