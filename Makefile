build-image:
	docker build -t $(IMAGE):$(TAG) .
build-image-m1:
	docker buildx build --platform linux/amd64  -t $(IMAGE):$(TAG) .
push-image:
	docker push $(IMAGE):$(TAG)
create-deployment:
	kubectl create deployment $(DEPLOYMENT_NAME) --image=$(IMAGE):$(TAG) --port=3000
update-deployment:
	kubectl set image deployment $(DEPLOYMENT_NAME) $(CONTAINER_NAME)=$(IMAGE):$(TAG)
create-service:
	kubectl create service loadbalancer $(SERVICE_NAME) --tcp=80:3000

