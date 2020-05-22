Walkthrough
===========


## To Containerize the application

1. Create the Dockerfile

```bash
$ touch Dockerfile
```

```yaml
FROM python:stretch

COPY . /app

WORKDIR /app

RUN python -m pip install -U pip
RUN python -m pip install -r requirements.txt

ENTRYPOINT [ "gunicorn", "--bind", ":8080", "main:APP" ]
```

2. Create a file to declare the environment variables

```bash
$ touch env_file
```

```bash
JWT_SECRET=supersecret
LOG_LEVEL=WARNING
```

3. Create the docker image

```bash
$ docker build -t fullstackdeveloper/jwt-api-test:v0 .
```

4. Run the container

```bash
$ docker run --name jwt-api-test --env-file=env_file -p 80:8080 -d fullstackdeveloper/jwt-api-test:v0
```

5. Test the endpoints

Below command needs to be fixed when running in Windows host (https://github.com/stedolan/jq/wiki/FAQ#windows)

```bash
$ set TOKEN=`curl --location --request POST '192.168.99.101:80/auth' --header 'Content-Type: application/json' --data-raw '{"email": "filipebzerra@gmail.com", "password": "fbspwd"}' | jq -r ".token"`
```

```bash
$ curl --location --request GET '192.168.99.101:80/contents' --header "Authorization: Bearer ${TOKEN}" | jq .
```

## To Deploy the container

1. Create the cluster

```bash
$ eksctl create cluster --name simple-jwt-api --tags "type=education,usage=full stack developer nanodegree" --nodegroup-name full-stack-developer
```

2. Check the status of the cluster

```bash
$ kubectl get nodes
```

3. Delete the cluster

```bash
$ eksctl delete cluster simple-jwt-api
```