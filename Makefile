build-image:
	docker build -t $(IMAGE):$(TAG) .
build-image-m1:
	docker buildx build --platform linux/amd64  -t $(IMAGE):$(TAG) .
push-image:
	docker push $(IMAGE):$(TAG)
create-deployment:
	kubectl create deployment hello --image=$(IMAGE):$(TAG) --port=3000
update-deployment:
	kubectl set image deployment hello hello-nodejs=$(IMAGE):$(TAG)
create-service:
	kubectl create service loadbalancer hello --tcp=80:3000

