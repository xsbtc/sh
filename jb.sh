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
    if [ $? -ne 0 ]; then
        echo "下载Go安装包失败，请检查网络连接"
        return 1
    fi

    tar -C /usr/local -xzf /tmp/go1.22.1.linux-amd64.tar.gz
    if [ $? -ne 0 ]; then
      echo "解压Go安装包失败"
      return 1
    fi
    
    echo "export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin" >> ~/.bashrc
    export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin
    go version
    if [ $? -ne 0 ]; then
        echo "Go安装失败或无法执行"
        return 1
    fi

    #创建~/bin目录
    mkdir -p ~/bin
    
    wget https://github.com/spectre-project/spectred/releases/download/v0.3.14/spectred-v0.3.14-linux-x86_64.zip
    if [ $? -ne 0 ]; then
        echo "下载 spectred 二进制文件失败"
        return 1
    fi
    
    unzip spectred-v0.3.14-linux-x86_64.zip
    if [ $? -ne 0 ]; then
        echo "解压 spectred 二进制文件失败"
        return 1
    fi
    
    mv spectred ~/bin/
    
    cd ~/bin
    
    
    ./spectred --utxoindex &
    SPECTRED_PID=$!
    sleep 3
    kill $SPECTRED_PID
    cd #HOME
    wget https://spectre-network.org/downloads/legacy/datadir2.zip
    if [ $? -ne 0 ]; then
        echo "下载数据目录失败"
        return 1
    fi
    
    unzip datadir2.zip -d ./.spectred/spectre-mainnet
    if [ $? -ne 0 ]; then
        echo "解压数据目录失败"
        return 1
    fi
    cd ~/bin
    screen -dmS spe bash -c './spectred --utxoindex'
    if [ $? -ne 0 ]; then
        echo "启动 spectred 失败"
        return 1
    fi


    read -p "请输入挖矿钱包地址: " wallet_addr

    read -p "请输入挖矿CPU核心数: " cpu_core

    # 检查cpu_core是否为整数
    if ! [[ "$cpu_core" =~ ^[0-9]+$ ]]; then
        echo "CPU核心数必须为整数"
        return 1
    fi


    screen -dmS spewa bash -c "./spectreminer --miningaddr='$wallet_addr' --workers='$cpu_core' --rpcserver=spr.tw-pool.com:14001"
    if [ $? -ne 0 ]; then
      echo "启动挖矿程序失败"
      return 1
    fi

    echo "====================== 安装完成 请使用screen -r spe 查看运行情况 ==========================="

}

function miner() {
    cd ~/bin

    read -p "请输入挖矿钱包地址: " wallet_addr
    read -p "请输入挖矿CPU核心数: " cpu_core

    # 检查cpu_core是否为整数
    if ! [[ "$cpu_core" =~ ^[0-9]+$ ]]; then
        echo "CPU核心数必须为整数"
        return 1
    fi
    
    screen -dmS spewa bash -c "./spectreminer --miningaddr='$wallet_addr' --workers='$cpu_core' --rpcserver=spr.tw-pool.com:14001"
    if [ $? -ne 0 ]; then
      echo "启动挖矿程序失败"
      return 1
    fi
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
