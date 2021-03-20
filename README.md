# poacpm Infrastructure

:warning:
**These files are provided to disclose the infrastructure configuration.
Therefore, it is impossible to create the same environment without editing.**

## Environment
The host environment is assumed to be macOS.

### Tools
* awscli
* terraform
* kubectl
* kops

## Deploy
**We've already gotten the `poac.pm` domain by `Route 53`; also, we've gotten ssl certificates of `poac.pm` on `ap-northeast-1` and `*.poac.pm` on `us-east-1` by `Certificate Manager`.**

### Installation and Configuration
```bash
$ brew install awscli terraform kubectl kops
$ aws configure
AWS Access Key ID [None]: AKIAIOSFODNN7EXAMPLE
AWS Secret Access Key [None]: wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY
Default region name [None]: ap-northeast-1
Default output format [None]:
```

### terraform
```bash
$ pushd terrafrom
$ pushd dynamodb_to_es
$ pip install -r ./requirements.txt -t ./
$ popd
$ terraform init
$ terraform apply
Apply complete!

Outputs:

COMMENT = Please write VPC-ID(networkID) and Subnet-ID to k8s/cluster.yaml
es-endpoint = vpc-poacpm-2gue3ols5i62ko67jhgu2e3z4a.ap-northeast-1.es.amazonaws.com
subnet-id-priv1 = subnet-0c101901cefd94fed
subnet-id-priv2 = subnet-0cc0f30c8b1fef17b
subnet-id-pub3 = subnet-04d969767b991ae4e
subnet-id-pub4 = subnet-0375a1a3a0c48de67
vpc-id = vpc-062b9b76b4b690aa5

$ export AWS_ES_ENDPOINT='https://vpc-poacpm-2gue3ols5i62ko67jhgu2e3z4a.ap-northeast-1.es.amazonaws.com'
$ popd
```

**Write `VPC-ID`(networkID) and `Subnet-ID` to [`cluster.yaml`](/k8s/cluster.yaml)...**
### kubernetes
#### Cluster
```bash
$ cd k8s
$ export KOPS_STATE_STORE=s3://k8s.poac.pm
$ kops create -f cluster.yaml
$ kops create secret --name k8s.poac.pm sshpublickey admin -i ~/.ssh/keys/pub/poacpm.pub
$ kops update cluster k8s.poac.pm --yes
```

*Wait 5 miniutes or more...*
```bash
$ kops validate cluster
Your cluster k8s.poac.pm is ready
```

#### Config-Map
```bash
$ kubectl create -f configmap.yaml
configmap "nginx-config" created
```

#### Secrets
```bash
$ export ECR_SECRET=( `aws ecr get-login --region ap-northeast-1 | awk '{print $9,$4,$6,$8}'` )
$ kubectl create secret docker-registry ecr \
   --docker-server=${ECR_SECRET[1]} \
   --docker-username=${ECR_SECRET[2]} \
   --docker-password=${ECR_SECRET[3]} \
   --docker-email=${ECR_SECRET[4]}
secret "ecr" created
```
```bash
$ cat ~/.aws/config | grep 'region' | awk '{printf $3}' > ./aws_default_region
$ cat ~/.aws/credentials | grep 'aws_access_key_id' | awk '{printf $3}' > ./aws_access_key_id
$ cat ~/.aws/credentials | grep 'aws_secret_access_key' | awk '{printf $3}' > ./aws_secret_access_key
$ kubectl create secret generic aws-credentials --from-file=./aws_default_region --from-file=./aws_access_key_id --from-file=./aws_secret_access_key
secret "aws-credentials" created
$ rm -f ./aws_*
```
```bash
$ printf 'https://hooks.slack.com/services/AAAAAAA/BBBBBBBB/CCCCCCCCCCCCCCCCCCCC' > ./slack_webhook_url
$ kubectl create secret generic slack-secrets --from-file=./slack_webhook_url
secret "slack-secrets" created
$ rm -f ./slack_webhook_url
```
```bash
$ printf $AWS_ES_ENDPOINT > ./aws_es_endpoint
$ kubectl create secret generic aws-es-endpoint --from-file=./aws_es_endpoint
secret "aws-es-endpoint" created
$ rm -f ./aws_es_endpoint
```
```bash
$ printf $GITHUB_CLIENT_ID > ./github_client_id
$ printf $GITHUB_CLIENT_SECRET > ./github_client_secret
$ printf $GITHUB_REDIRECT_URI > ./github_redirect_uri
$ kubectl create secret generic github-oauth --from-file=./github_client_id --from-file=./github_client_secret --from-file=./github_redirect_uri
$ rm -f ./github_*
```

#### Deployments
```bash
$ kubectl create -f deployment.yaml
deployment.extensions "poacpm-deploy" created
deployment.extensions "external-dns" created
```

*kubernetes dashboard*
```bash
$ kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/master/src/deploy/recommended/kubernetes-dashboard.yaml
secret "kubernetes-dashboard-certs" created
serviceaccount "kubernetes-dashboard" created
role.rbac.authorization.k8s.io "kubernetes-dashboard-minimal" created
rolebinding.rbac.authorization.k8s.io "kubernetes-dashboard-minimal" created
deployment.apps "kubernetes-dashboard" created
service "kubernetes-dashboard" created
```

#### Services
```bash
$ kubectl create -f service.yaml
service "poacpm-service" created
```

#### Upload the necessary files to CodeBuild.
```bash
$ aws s3 cp ~/.kube/config s3://secret.poac.pm/.kube/config
```


## Tips
```bash
$ kubectl get pods
$ kubectl describe pod <PODID>
# Delete evicted pods
$ kubectl get pods | grep Evicted | awk '{print $1}' | xargs kubectl delete pod
```


## Update
```bash
$ kops rolling-update cluster k8s.poac.pm --yes
```

## Delete
```bash
$ kubectl delete -f service.yaml
$ kubectl delete -f https://raw.githubusercontent.com/kubernetes/kops/master/addons/kubernetes-dashboard/v1.8.1.yaml
$ kubectl delete -f deployment.yaml
$ kubectl delete secret slack-secrets
$ kubectl delete secret aws-credentials
$ kubectl delete secret ecr
$ kubectl delete -f configmap.yaml
$ kops delete -f cluster.yaml --state s3://k8s.poac.pm --yes
$ aws s3 rm s3://k8s.poac.pm/ --exclude '*' --include '*' --recursive
$ aws s3 rm s3://secret.poac.pm/.kube/config
$ terraform destroy
```


## References
> [1] kopsを使ってKubernetesクラスタをAWS上で構成
https://aws.amazon.com/jp/blogs/news/configure-kubernetes-cluster-on-aws-by-kops/
