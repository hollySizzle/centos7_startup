# centos7_startup
centos7の初期設定･git2インストール･dockerインストールを行うスクリプト

# Install
OSインストール後､rootユーザーで以下を実行  
~~~
mkdir /root/centos7_startup_scripts
~~~

~~~
wget --no-check-certificate https://github.com/hollySizzle/centos7_startup/archive/refs/heads/main.zip -P /root/centos7_startup_scripts
~~~
~~~
unzip -j main.zip
~~~
~~~
rm -rf main.zip
~~~

# HowTo
## サーバーセットアップ
rootユーザーで以下を実行
~~~
sh /root/centos7_startup_scripts/startup.sh
~~~
  
## adminユーザー追加
rootユーザーで以下を実行
~~~
sh /root/centos7_startup_scripts/add_admin_user.sh
~~~
