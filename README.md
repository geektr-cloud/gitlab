# GeekTR Cloud Develop Utils Stack

https://git.geektr.co
https://npm.geektr.co

## Npm Usage

```bash
npm set @gtr:registry https://npm.geektr.co
npm set @gtr-pri:registry https://npm.geektr.co
npm set @gtr-infra:registry https://npm.geektr.co
```

## Network

Gitlab:

`git.geektr.co` cname => `git.endpoints.geektr.co` nat cross vpn => `local-vm`

NPM:

`npm.geektr.co` cname => `git.endpoints.geektr.co` nat cross vpn => `local-vm`

## Deploy

secret

`geektr.co/gitlab.infra/$ID/gitlab`

```
ID=geektr.co

EXT_SMTP_PASSWORD=
EXT_AWS_ACCESS_KEY_ID=
EXT_AWS_SECRET_ACCESS_KEY=
```

`geektr.co/gitlab.infra/$ID/verdaccio`

```
ID=geektr.co

EXT_GITLAB_GROUP=
EXT_GITLAB_HOST=
EXT_GITLAB_OAUTH_CLIENT_ID=
EXT_GITLAB_OAUTH_CLIENT_SECRET=
```

service

```bash
read ID

# Network
ssh -p 2222 git.geektr.co "docker network create -d overlay --attachable gitlab_net"

# Gitlab
ssh -p 2222 git.geektr.co <<EOF
docker volume create gitlab.conf
docker volume create gitlab.logs
docker volume create gitlab.data
EOF

ssh -p 2222 git.geektr.co "docker config create gitlab.omnibus-config -" <gitlab/omnibus_config.rb

i vault env envsubst geektr.co/gitlab.infra/$ID/gitlab <gitlab/secret.env | ssh -p 2222 git.geektr.co "docker secret create gitlab.env -"

ssh -p 2222 git.geektr.co "docker stack deploy --compose-file - gitlab" <gitlab/stack.yml

# Caddy
# ssh -p 2222 git.geektr.co "docker stack rm caddy"
# ssh -p 2222 git.geektr.co "docker config rm caddy.caddyfile"
ssh -p 2222 git.geektr.co "docker volume create caddy.data"
ssh -p 2222 git.geektr.co "docker config create caddy.caddyfile -" <caddy/Caddyfile
ssh -p 2222 git.geektr.co "docker stack deploy --compose-file - caddy" <caddy/stack.yml

# Verdaccio
ssh -p 2222 git.geektr.co "docker volume create verdaccio.data"
ssh -p 2222 git.geektr.co "docker config create verdaccio.config -" <verdaccio/config.yaml
i vault env envsubst geektr.co/gitlab.infra/$ID/verdaccio <verdaccio/secret.env | ssh -p 2222 git.geektr.co "docker secret create verdaccio.env -"
ssh -p 2222 git.geektr.co "docker stack deploy --compose-file - verdaccio" <verdaccio/stack.yml

# Gitlab Runner
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
# docker run
```
