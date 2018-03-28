# poacpm Infrastructure

## HOW DO DEPLOYING
:warning:
**These files are provided to disclose the infrastructure configuration.
Therefore, it is impossible to create a similar environment without editing.**

### Environment
It assumes the macOS.
#### Tools
* awscli
* terraform
* kubectl
* kops

### Deploy command
**既に，Route53でpoac.pmドメインの取得と，CertificateManagerのap-northeast-1でpoac.pmと，us-east-1で\*.poac.pmを取得している**
```bash
$ brew install awscli terraform kubectl kops
$ aws configure
AWS Access Key ID [None]: AKIAIOSFODNN7EXAMPLE
AWS Secret Access Key [None]: wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY
Default region name [None]: ap-northeast-1
Default output format [None]:

$ pushd terrafrom
$ terraform apply
Apply complete!
$ popd

# VPC ID と subnet IDをcluster.yamlに書き込む...
$ pushd k8s
$ export KOPS_STATE_STORE=s3://k8s.poac.pm
$ kops create -f cluster.yaml
$ kops create secret --name k8s.poac.pm sshpublickey admin -i ~/.ssh/keys/pub/poacpm.pub
$ kops update cluster k8s.poac.pm --yes

# Wait 5 miniutes or more...
$ kops validate cluster
Your cluster k8s.poac.pm is ready

$ kubectl create -f configmap.yaml
configmap "nginx-config" created

$ export ECR_SECRET=( `aws ecr get-login --region ap-northeast-1 | awk '{print $9,$4,$6,$8}'` )
$ kubectl create secret docker-registry ecr \
   --docker-server=${ECR_SECRET[1]} \
   --docker-username=${ECR_SECRET[2]} \
   --docker-password=${ECR_SECRET[3]} \
   --docker-email=${ECR_SECRET[4]}
secret "ecr" created
$ cat ~/.aws/config | grep 'region' | awk '{printf $3}' > ./aws_default_region
$ cat ~/.aws/credentials | grep 'aws_access_key_id' | awk '{printf $3}' > ./aws_access_key_id
$ cat ~/.aws/credentials | grep 'aws_secret_access_key' | awk '{printf $3}' > ./aws_secret_access_key
$ kubectl create secret generic aws-credentials --from-file=./aws_default_region --from-file=./aws_access_key_id --from-file=./aws_secret_access_key
secret "aws-credentials" created
$ rm -rf ./aws_*

$ kubectl create -f deployment.yaml
deployment "poacpm-deployment" created
# どっち？
#deployment.extensions "poacpm-deploy" created
#deployment.extensions "route53-mapper" created

# kubernetes dashboard # route53 mappingと競合するらしい．
#$ kubectl create -f https://raw.githubusercontent.com/kubernetes/kops/master/addons/kubernetes-dashboard/v1.8.1.yaml

$ kubectl create -f service.yaml
service "poacpm-service" created

$ popd


# Route53のpoac.pmのAレコードに，LoadBalancerへのALIASを貼る
```

### Update command
```bash
$ kops rolling-update cluster k8s.poac.pm --yes
```

### Delete command
```bash
$ kubectl delete -f service.yaml
$ kubectl delete -f deployment.yaml
$ kubectl delete secret aws-credentials
$ kubectl delete secret ecr
$ kubectl delete -f configmap.yaml
$ kops delete -f cluster.yaml --state s3://k8s.poac.pm --yes
$ terraform destroy
```

## References
> [1] kopsを使ってKubernetesクラスタをAWS上で構成
https://aws.amazon.com/jp/blogs/news/configure-kubernetes-cluster-on-aws-by-kops/
