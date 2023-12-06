# CI/CD Docker Laravel dengan Gitlab use VPS Ubuntu 22.04

In this tutorial main folder will be on <code>/home/app/shop</code>, change based on your preference

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
sudo apt install apt-transport-https ca-certificates curl software-properties-common
```

```
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
```

```
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
```

```
sudo apt update
```

```
apt-cache policy docker-ce
```

```
sudo apt install docker-ce
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
sudo apt install acl
```

login ke aplikasi as <code>gitrunner</code>:

```
sudo gitrunner
```

<code>create private key</code>

```
ssh-keygen -t rsa
```

copy to authorized key:

```
cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
```

## 3. Running Docker on Server & Install Lets Encrypt

Login as <code>root</code> masuk folder <code>/home/app/shop</code>

Create file <code>.env</code> (just for fisrt running, next will be replace with ci/cd variable)

```
nano .env
```

```
docker-compose up -d
```

```
sudo docker exec -it app bash
```

```
certbot certonly --webroot --webroot-path /var/www/html/public  -d shop.26r.my.id
```

```
cd /etc/letsencrypt/live/shop.26r.my.id/
```

```
sudo docker cp app:/etc/letsencrypt/live/shop.26r.my.id/ /nginx/ssl/
```

```
sudo setfacl -R -m u:gitrunner:rwx /home/app/shop/
```

```
sudo usermod -aG docker gitrunner
```

## 5. Buat Runner

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
APP_DIR
FILE_ENV
GITLAB_PAT
GIT_URL => without https or git, ex: gitlab.com/rudihartomo/laravel_docker.git
HOST_SSH
SSH_PRIVATE_KEY
USER_SSH
```

Login to server as <code>gitrunner</code> to set value <code>SSH_PRIVATE_KEY</code>

```
cat ~/.ssh/id_rsa
```

### Cara mendapatkan Token User to set value GITLAB_PAT

Profile > Access Token > Add new token

- <code>token name</code> required
- <code>expiration date</code> can be null
- <code>select scopes</code> check all based on nedeed
- **Create personal access token**
