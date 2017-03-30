create-machine:
	docker-machine create --driver virtualbox registry-machine

destroy-machine:
	docker-machine rm -y registry-machine

generate-certificates:
	openssl req -newkey rsa:2048 -nodes -sha256 -keyout domain.key -x509 -days 365 -out domain.crt

start-registry-linux:
	docker-machine scp domain.crt registry-machine:~
	docker-machine scp domain.key registry-machine:~
	docker `docker-machine config registry-machine` run -d -p 5000:5000 \
		-v /home/docker/:/certs/ \
                -e REGISTRY_HTTP_TLS_CERTIFICATE=/certs/domain.crt \
                -e REGISTRY_HTTP_TLS_KEY=/certs/domain.key \
                registry:2


start-registry:
	docker `docker-machine config registry-machine` run -d -p 5000:5000 \
		-v `pwd`:/certs/ \
		-e REGISTRY_HTTP_TLS_CERTIFICATE=/certs/domain.crt \
		-e REGISTRY_HTTP_TLS_KEY=/certs/domain.key \
		registry:2


try-push-image:
	$(info Make sure you have added this certificates to the docker deamon)
	docker pull alpine
	docker tag alpine `docker-machine ip registry-machine`:5000/alpine
	docker push `docker-machine ip registry-machine`:5000/alpine
