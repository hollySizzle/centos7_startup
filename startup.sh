#!/bin/sh -e
# package update
yum -y update || exit 1

# パスワードログインの禁止
sed -i 's/^PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config || exit 1
sed -i 's/^#PubkeyAuthentication yes/PubkeyAuthentication yes/' /etc/ssh/sshd_config || exit 1

# wheelグループはsudo時にパスワード省略
echo '%wheel ALL=(ALL) NOPASSWD: ALL' | sudo EDITOR='tee -a' visudo || exit 1

# ファイアーフォールを起動
systemctl restart firewalld.service || exit 1

# ファイアーウォールをスタートアップに登録
systemctl enable firewalld.service || exit 1

# portが閉じたので､80, 443を公開する
firewall-cmd --add-service=http --zone=public --permanent || exit 1
firewall-cmd --add-service=https --zone=public --permanent || exit 1

systemctl reload firewalld.service || exit 1

# git最新版のインストール
cd /usr/local/src
wget https://mirrors.edge.kernel.org/pub/software/scm/git/git-2.39.3.tar.gz || echo 'gitのインストールに失敗しました'
tar -zxf git-2.39.3.tar.gz
cd git-2.39.3.tar

## makeエラー用
yum install -y curl-devel
yum install -y gcc
yum install -y openssl-devel
yum install -y expat-devel
yum install -y cpan
yum install -y gettext

make prefix=/usr/local all
make prefix=/usr/local install

# dockerのインストール
yum install -y  yum-utils || exit 1
yum-config-manager --add-repo \
    https://download.docker.com/linux/centos/docker-ce.repo || exit 1
yum install -y docker-ce docker-ce-cli containerd.io || exit 1
systemctl enable docker || exit 1

# docker composeのインストール
curl -L "https://github.com/docker/compose/releases/download/2.18.1/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose || exit 1
chmod +x /usr/local/bin/docker-compose || exit 1

# /etc/ssh/sshd_configファイルを編集します
sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config || exit 1
sed -i 's/#PubkeyAuthentication yes/PubkeyAuthentication yes/' /etc/ssh/sshd_config || exit 1

# SSHサービスを再起動します
systemctl restart sshd.service || exit 1

#dockerグループが作成されていければ作成
groupadd docker || echo "docker group already exists"

# rootをdockerグループに追加
usermod -aG docker root || echo "root is already in docker group"
# /dockerディレクトリを作成
mkdir /docker || echo "/docker directory already exists"

# dockerディレクトリを :docker所有にする
chown :docker /docker || echo "/docker directory is already owned by docker group"
chmod 774 -R /docker || echo "/docker directory is already set to mode 774"

# docker以下に作成されるディレクトリとファイルを :docker 所有にする
chmod g+s /docker || echo "/docker directory is already set to group sticky bit"

echo 'スタートアップscriptsが完了しました｡'
echo 'add_admin_user.sh を実行し､ユーザーを追加してください"