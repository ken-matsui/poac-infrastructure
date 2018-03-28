# poacpm Infrastructure

## HOW DO DEPLOYING
:warning:
**These files are provided to disclose the infrastructure configuration.
Therefore, it is impossible to create a similar environment without editing.**

### Environment
It assumes the macOS environment.
#### Tools
* awscli
* terraform
* kubectl
* kops

### Deploy command
```bash
$ brew install awscli terraform kubectl kops
$ aws configure

$ export KOPS_STATE_STORE=s3://k8s.poac.pm

$ kops create -f cluster.yaml
$ kops create secret --name k8s.poac.pm sshpublickey admin -i ~/.ssh/keys/pub/poacpm.pub
$ kops update cluster k8s.poac.pm --yes
# Update command
$ kops rolling-update cluster k8s.poac.pm --yes

# Wait 5 miniutes or more...
$ kops validate cluster
...
Your cluster k8s.poac.pm is ready

$ kubectl create -f configmap.yaml
configmap "nginx-config" created

$ export ECR_SECRET=( `aws ecr get-login --region ap-northeast-1 | awk '{print $9,$4,$6,$8}'` )
$ kubectl create secret docker-registry ecr \
   --docker-server=${ECR_SECRET[1]} \
   --docker-username=${ECR_SECRET[2]} \
   --docker-password=${ECR_SECRET[3]} \
   --docker-email=${ECR_SECRET[4]}
$ kubectl create -f deployment.yaml
deployment "poacpm-deployment" created

# kubernetes dashboard # route53 mappingと競合するらしい．
$ kubectl create -f https://raw.githubusercontent.com/kubernetes/kops/master/addons/kubernetes-dashboard/v1.8.1.yaml

$ kubectl create -f service.yaml
service "poacpm-service" created
```

## Delete command
```bash
$ kubectl delete -f service.yaml
$ kubectl delete -f deployment.yaml
$ kubectl delete -f configmap.yaml
$ kops delete -f cluster.yaml --state s3://k8s.poac.pm --yes
```

## References
> [1] kopsを使ってKubernetesクラスタをAWS上で構成
https://aws.amazon.com/jp/blogs/news/configure-kubernetes-cluster-on-aws-by-kops/
