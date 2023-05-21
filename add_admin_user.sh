#!/bin/bash -x

# ユーザーの作成
echo "ユーザーを作成します"
read -p "ユーザー名: " username
read -sp "パスワード: " password
echo

# 一般ユーザーを作成します
sudo useradd $username || exit 1
sudo echo $password | passwd --stdin $username || exit 1

# ユーザーをwheelグループに追加します
sudo usermod -aG wheel $username || echo 'ユーザーをwheelグループに追加出来ませんでした'

# SSHサービスを再起動します
sudo systemctl restart sshd.service || echo 'sshd.serviceが再起動できません'

read -p "sshの公開鍵を入力してください " ssh_open_key

sudo cd /home/$username

# ~/.ssh/authorized_keysファイルに公開鍵の内容を追記します
sudo mkdir .ssh || echo ".ssh directory already exists"
sudo chown -R $username:$username .ssh
sudo echo $ssh_open_key | tee -a .ssh/authorized_keys || echo 'authorized_keysの操作に失敗しました'
sudo chown -R $username:$username .ssh

# 所有者以外のアクセスを許可しないようにパーミッションを変更します
sudo chmod 700 .ssh/ || echo '.sshの権限変更に失敗しました'
sudo chmod 600 .ssh/authorized_keys || echo '.ssh/authorized_keysの権限変更に失敗しました'

# ユーザーをdockerグループに追加
sudo usermod -aG docker $username || echo 'ユーザーをdockerグループに追加出来ません'

echo "ユーザー作成が完了しました"