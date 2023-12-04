# CI/CD Docker Laravel dengan Gitlab use VPS Ubuntu 22.04

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

Lakukan beberapa perintah berikut ini:

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

Jalankan perintah berikut ini untuk:

```
sudo adduser gitrunner
```

```
sudo apt install acl
```

```
sudo setfacl -R -m u:gitrunner:rwx /home/aplikasi
```

```
chmod 775 -R /home/aplikasi/storage
chmod 775 -R /home/aplikasi/public
```

login ke aplikasi sebagai gitrunner:

```
sudo gitrunner
```

Jalankan perintah untuk membuat pasangan private key dan public key

```
ssh-keygen -t rsa
```

copy isi dari public key ke authorized key:

```
cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
```

## 4. Running Docker on Server & Install Lets Encrypt

```
# masuk folder, buka terminal di /home/aplikasi folder
docker-compose up -d
```

Proses install letsencrypt

```
docker exec -it webserver bash
```

```
certbot --nginx -d shop.26r.my.id -m rudihartomo100@gmail.com
```

#certbot --nginx -d shop.26r.my.id -d www.shop.26r.my.id -m rudihartomo100@gmail.com

## 5. Setting ENV Variabel

Settings > CI/CD > Variables

kemudian tambahkan variabel, misalnya diberi nama SSH_PRIVATE_KEY, dan isi didapatkan dari

```
cat ~/.ssh/id_rsa
```

## 6. Buat Runner

```
docker run -d --name gitlab-runner --restart always -v /srv/gitlab-runner/config:/etc/gitlab-runner -v /var/run/docker.sock:/var/run/docker.sock gitlab/gitlab-runner:latest
```

Daftarkan runner

```
docker exec -it gitlab-runner gitlab-runner register
```

```
sudo usermod -aG docker gitrunner
```

## 7. Buka project Laravel

### Tambahkan file .gitlab-ci.yml

```
VAR_DIREKTORI: "/var/www"
VAR_GIT_URL_TANPA_HTTP: "gitlab.com/rudihartomo/gitrunner.git"
VAR_CLONE_KEY: "xxx" # diambil dari halaman profile (lihat di bawah)
VAR_USER: "gitrunner" #user yang sudah diberi akses
VAR_IP: "xxx" #ip server
VAR_FILE_ENV: $FILE_ENV #dari point 5 di atas
VAR_FILE_HTACCESS: $FILE_HTACCESS #dari point 5 di atas
```

### Cara mendapatkan Token User

Buka halaman profile
Masuk ke menu access token:

- masukkan <code>token name</code>
- <code>expiration date</code> dikosongkan saja
- <code>select scopes</code> saya checklist semua
- Kemudian klik tombol **Create personal access token**
