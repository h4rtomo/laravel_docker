# CI/CD Docker Laravel dengan Gitlab use VPS Ubuntu 22.04

In this tutorial main folder will be on <code>/home/app/shop</code>, change based on your preference and domain [shop.26r.my.id](shop.26r.my.id)

## 1. Enable SSH Public Key

SSH on VPS provider

```
nano /etc/ssh/sshd_config
```

Set <code>PasswordAuthentication </code> to <b>yes</b>

```
PasswordAuthentication yes
```

Reload SSH service

```
sudo service sshd reload
```

## 2. Install Docker

```
sudo apt update
```

```
sudo apt install apt-transport-https ca-certificates curl software-properties-common gnupg acl certbot
```

```
sudo install -m 0755 -d /etc/apt/keyrings
```

```
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
```

```
sudo chmod a+r /etc/apt/keyrings/docker.gpg
```

```
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
```

```
sudo apt update
```

```
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```

```
sudo systemctl status docker
```

```
sudo usermod -aG docker ${USER}
```

```
su - ${USER}
```

```
groups
```

## 3. Create SSH key Di Server untuk Deploy

Add <code>gitrunner</code> user

```
sudo adduser gitrunner
```

```
sudo usermod -aG docker gitrunner
```

login as <code>gitrunner</code>:

```
su - gitrunner
```

<code>create private key</code>

```
ssh-keygen -t rsa
```

copy to authorized key:

```
cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
```

```
cat ~/.ssh/id_rsa.pub
```

Add this ssh_key to <code>Profile</code> > <code>Preferences</code> > <code>SSH Keys</code> > <code>Add new key</code>

## 3. Running Docker on Server & Install Lets Encrypt

Login as <code>root</code>

```
mkdir -p /home/app/shop
```

```
cd /home/app/shop
```

```
sudo setfacl -R -m u:gitrunner:rwx /home/app/shop/
```

Login as <code>gitrunner</code>

```
su - gitrunner
```

```
cd /home/app/shop/
```

```
git clone git@gitlab.com:rudihartomo/laravel_docker.git .
```

Create file <code>.env</code> (just for fisrt running, next will be replace with ci/cd variable)

```
cp laravel-app/.env.example laravel-app/.env && nano laravel-app/.env
```

Login as <code>root</code>

```
mkdir -p /etc/letsencrypt/
```

```
sudo docker compose up -d
```

```
sudo setfacl -R -m u:gitrunner:rwx /home/app/shop/
```

check domain is it running? [shop.26r.my.id](http://shop.26r.my.id)
usually folder vendor not created <code>docker exec -it app bash </code> and run <code>composer install<code>

```
docker exec -it app bash
```

```
composer install
```

```
sudo chown -R www-data:www-data /var/www/html
```

### install ssl certificate

```
certbot certonly --webroot --webroot-path /home/app/shop/laravel-app/public -d shop.26r.my.id
```

check folder <code>/etc/letsencrypt/</code>

```
cd /home/app/shop
```

```
docker cp nginx/conf_ssl/app.conf nginx:/etc/nginx/conf.d/app.conf
```

```
docker exec nginx nginx -t
```

```
docker exec nginx /etc/init.d/nginx reload
```

check ssl is it running? [shop.26r.my.id](https://shop.26r.my.id)

```
sudo usermod -aG docker gitrunner
```

## 5. Buat Runner

### create new runner project

Go to <code>Settings > <code>CI /CD</code> > <code>Runners</code> > <code>Expand</code> > <code>New Project Runner</code>

```
docker run -d --name gitlab-runner --restart always -v /var/run/docker.sock:/var/run/docker.sock -v gitlab-runner-config:/etc/gitlab-runner gitlab/gitlab-runner:latest
```

### Register runner

```
docker exec -it gitlab-runner gitlab-runner register
```

## 6. Setting ENV Variabel

<code>Settings</code> > <code>CI/CD</code> > <code>Variables</code> > <code>Expand</code> > <code>Add Variables</code>

```
APP_DIR => in this tutorial use /home/app/shop
FILE_ENV => file .env
GITLAB_PAT
GIT_URL => without https or git, ex: gitlab.com/rudihartomo/laravel_docker.git
HOST_SSH
SSH_PRIVATE_KEY
USER_SSH => in this tutorial use  gitrunner
```

### generate value SSH_PRIVATE_KEY

Login to server as <code>gitrunner</code>

```
su - gitrunner
```

```
cat ~/.ssh/id_rsa
```

### generate value GITLAB_PAT

Profile > Access Token > Add new token

- <code>token name</code> required
- <code>expiration date</code> can be null
- <code>select scopes</code> check all based on nedeed
- **Create personal access token**
