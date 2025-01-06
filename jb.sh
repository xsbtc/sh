#!/bin/bash

# 检查是否以root用户运行脚本
if [ "$(id -u)" != "0" ]; then
    echo "此脚本需要以root用户权限运行。"
    echo "请尝试使用 'sudo -i' 命令切换到root用户，然后再次运行此脚本。"
    exit 1
fi

# 节点安装功能
function install_node() {
apt update
apt install screen unzip -y

# 安装GO
wget https://go.dev/dl/go1.22.1.linux-amd64.tar.gz -P /tmp/
tar -C /usr/local -xzf /tmp/go1.22.1.linux-amd64.tar.gz
echo "export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin" >> ~/.bashrc
export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin
go version

wget https://github.com/spectre-project/spectred/releases/download/v0.3.14/spectred-v0.3.14-linux-x86_64.zip
unzip spectred-v0.3.14-linux-x86_64.zip
cd ~/bin
./spectred --utxoindex &
SPECTRED_PID=$!
sleep 3
kill $SPECTRED_PID
cd #HOME
wget https://spectre-network.org/downloads/legacy/datadir2.zip
unzip datadir2.zip -d ./.spectred/spectre-mainnet
cd ~/bin
screen -dmS spe bash -c './spectred --utxoindex'

read -p "请输入挖矿钱包地址: " wallet_addr

read -p "请输入挖矿CPU核心数: " cpu_core


screen -dmS spewa bash -c "./spectreminer --miningaddr='$wallet_addr' --workers='$cpu_core' --rpcserver=spr.tw-pool.com:14001"

echo "====================== 安装完成 请使用screen -r spe 查看运行情况 ==========================="

}

function miner() {
cd ~/bin

read -p "请输入挖矿钱包地址: " wallet_addr
read -p "请输入挖矿CPU核心数: " cpu_core

screen -dmS spewa bash -c "./spectreminer --miningaddr='$wallet_addr' --workers='$cpu_core' --rpcserver=spr.tw-pool.com:14001"
echo "====================== 启动挖矿节点完成 请使用screen -r spewa 查看运行情况 ==========================="
}
# 主菜单
function main_menu() {
    clear
    echo "脚本以及教程由推特用户大赌哥 @y95277777 编写，免费开源，请勿相信收费"
    echo "================================================================"
    echo "节点社区 Telegram 群组:https://t.me/niuwuriji"
    echo "节点社区 Telegram 频道:https://t.me/niuwuriji"
    echo "节点社区 Discord 社群:https://discord.gg/GbMV5EcNWF"
    echo "请选择要执行的操作:"
    echo "1. 安装常规节点"
    echo "2. 启动挖矿节点"
    read -p "请输入选项(1): " OPTION

    case $OPTION in
    1) install_node ;;
    2) miner ;;
    *) echo "无效选项" ;;
    esac
}

main_menu