app_version = v0.1
app_name = simple-jwt-api
image_name = fullstackdeveloper/$(app_name):$(app_version)

build:
	@docker build -t $(image_name) .

run:
	docker run --detach -p 80:8080 --name $(app_name) --env-file=env_file $(image_name)

kill:
	@echo 'Killing container...'
	@docker ps | grep $(app_name) | awk '{print $$1}' | xargs docker kill