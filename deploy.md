# Deploy Step

## Cluster

<!-- TODO: init k3s and vault and load cluster secret -->

## Vault

secret

`geektr.co/gitlab.infra/geektr.co/gitlab`

```
EXT_SMTP_PASSWORD=
EXT_AWS_ACCESS_KEY_ID=
EXT_AWS_SECRET_ACCESS_KEY=
```

`geektr.co/gitlab.infra/geektr.co/verdaccio`

```
EXT_GITLAB_GROUP=
EXT_GITLAB_HOST=
EXT_GITLAB_OAUTH_CLIENT_ID=
EXT_GITLAB_OAUTH_CLIENT_SECRET=
```

## HTTPS

```bash
kubectl apply -f https://github.com/jetstack/cert-manager/releases/download/v1.11.1/cert-manager.yaml
kubectl get pods --namespace cert-manager
kubectl apply -f acme
```

## Namespace

```bash
kubectl apply -f manifest.yaml
kubectl get namespaces
kubectl get pods
```

## Verdaccio

```bash
kubectl create --namespace gitlab configmap verdaccio-config --from-file verdaccio/config.yaml

i vault env load geektr.co/gitlab.infra/geektr.co/verdaccio
kubectl create --namespace gitlab secret generic verdaccio-env \
  --from-literal=EXT_GITLAB_GROUP=${EXT_GITLAB_GROUP} \
  --from-literal=EXT_GITLAB_HOST=${EXT_GITLAB_HOST} \
  --from-literal=EXT_GITLAB_OAUTH_CLIENT_ID=${EXT_GITLAB_OAUTH_CLIENT_ID} \
  --from-literal=EXT_GITLAB_OAUTH_CLIENT_SECRET=${EXT_GITLAB_OAUTH_CLIENT_SECRET}
kubectl apply -f verdaccio/manifest.yaml
```

## GitLab

```bash
kubectl create --namespace gitlab configmap gitlab-config --from-file gitlab/gitlab.rb

i vault env load geektr.co/gitlab.infra/geektr.co/gitlab
kubectl create --namespace gitlab secret generic gitlab-env \
  --from-literal=EXT_SMTP_PASSWORD=${EXT_SMTP_PASSWORD} \
  --from-literal=EXT_AWS_ACCESS_KEY_ID=${EXT_AWS_ACCESS_KEY_ID} \
  --from-literal=EXT_AWS_SECRET_ACCESS_KEY=${EXT_AWS_SECRET_ACCESS_KEY}

kubectl apply -f gitlab/manifest.yaml
```

## Gitlab Runner

<!-- TODO: k8s as runner -->

```bash
docker volume create gitlab-runner-config
REGISTRATION_TOKEN="$(i vault json geektr.co/gitlab.infra/$ID/gitlab-runner | jq -r '.REGISTRATION_TOKEN')"
docker run --rm -it -v gitlab-runner-config:/etc/gitlab-runner gitlab/gitlab-runner:latest register \
  --url "https://git.geektr.co" \
  --registration-token "$REGISTRATION_TOKEN" \
  --description "Commom gitlab runner" \
  --executor "docker" \
  --tag-list "commom,docker,debian,linux,vm" \
  --run-untagged="true" \
  --locked="false" \
  --docker-image "debian:bullseye" \
  --non-interactive

docker run -d --name gitlab-runner --restart always \
  --env TZ=Asia/Shanghai \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v gitlab-runner-config:/etc/gitlab-runner \
  gitlab/gitlab-runner:latest

docker pull gitlab/gitlab-runner:latest
docker stop gitlab-runner && docker rm gitlab-runner
```
