cd /var/lib/wise2c/harbor/harbor
docker-compose -f docker-compose.yml -f docker-compose.chartmuseum.yml -f docker-compose.clair.yml start
