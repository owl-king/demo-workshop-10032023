create-deployment:
	kubectl create deployment hello --image=$(IMAGE):$(TAG) --port=3000
update-deployment:
	kubectl set image deployment hello hello=$(IMAGE):$(TAG)
create-service:
	kubectl create service loadbalancer hello --tcp=80:3000

