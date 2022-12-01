# kafka + neptune + redis (+elastic)
docker-compose up  -d kafka neptune redis neptune-ui
docker-compose up node-red-block-watchers # -->  http://localhost:1880/
docker-compose up node-red-amm-indexers # -->  http://localhost:1881/
docker-compose up kafka-ui # --> http://localhost:8080/