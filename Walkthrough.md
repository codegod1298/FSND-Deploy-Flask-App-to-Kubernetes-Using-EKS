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

1. Create a Kubernetes (EKS) Cluster

```bash
$ eksctl create cluster --name simple-jwt-api --tags "type=education,usage=full stack developer nanodegree" --nodegroup-name full-stack-developer
```

2. Check the status of the cluster

```bash
$ kubectl get nodes
```

3. Set Up an IAM Role for the Cluster

**Create an IAM role that CodeBuild can use to interact with EKS**

```bash
for /f %i in ('aws sts get-caller-identity --query Account --output text') do set ACCOUNT_ID=%i
```

```bash
set TRUST="{ \"Version\": \"2012-10-17\", \"Statement\": [ { \"Effect\": \"Allow\", \"Principal\": { \"AWS\": \"arn:aws:iam::%ACCOUNT_ID%:root\" }, \"Action\": \"sts:AssumeRole\" } ] }"
```

```bash
aws iam create-role --role-name UdacityFlaskDeployCBKubectlRole --assume-role-policy-document %TRUST% --output text --query 'Role.Arn'
```

```bash
set EKS_DESCRIBE="{ \"Version\": \"2012-10-17\", \"Statement\": [ { \"Effect\": \"Allow\", \"Action\": [ \"eks:Describe*\", \"ssm:GetParameters\" ], \"Resource\": \"*\" } ] }"
```

```bash
echo %EKS_DESCRIBE%
```

```bash
aws iam put-role-policy --role-name UdacityFlaskDeployCBKubectlRole --policy-name eks-describe --policy-document %EKS_DESCRIBE%
```

```bash
kubectl get -n kube-system configmap/aws-auth -o yaml > %USERPROFILE%\AppData\Local\Temp\aws-auth-patch.yml
```

In the data/mapRoles section of this document add, replacing <ACCOUNT_ID> with your account id:

```bash
echo %ACCOUNT_ID%
```

```yaml
- rolearn: arn:aws:iam::<ACCOUNT_ID>:role/UdacityFlaskDeployCBKubectlRole
    username: build
    groups:
      - system:masters
```

Now update your cluster's configmap:

Important: Use Git BASH to perform this execution

```bash
kubectl patch configmap/aws-auth -n kube-system --patch "$(cat $USERPROFILE/AppData/Local/Temp/aws-auth-patch.yml)"
```

4. Delete the cluster

```bash
$ eksctl delete cluster simple-jwt-api
```

My post https://knowledge.udacity.com/questions/195608