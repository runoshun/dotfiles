#!/bin/bash

# プラットフォームの判定
OS=$(uname)

get_cpu_bar() {
    local cpu_usage=$1
    local bar_count=$((cpu_usage / 10)) # 10段階で表示
    local bar=""

    # CPU使用率に応じて色を選択
    local color
    if [ $cpu_usage -le 30 ]; then
        color="white"
    elif [ $cpu_usage -le 70 ]; then
        color="yellow"
    else
        color="red"
    fi

    # 使用率部分（色付きスペース）
    bar="#[bg=$color]"
    for ((i = 0; i < bar_count; i++)); do
        bar="${bar} "
    done

    # 未使用部分（暗い背景のスペース）
    bar="${bar}#[bg=colour236]"
    for ((i = bar_count; i < 10; i++)); do
        bar="${bar} "
    done

    echo "#[default] ${bar}#[default]"
}

get_cpu_usage() {
    if [ "$OS" = "Darwin" ]; then
        # macOS: top コマンドを使用して小数点1位まで表示
        top -l 1 -n 0 | grep "CPU usage" | awk '{printf "%.1f", $3}' | tr -d '%'
    else
        # Linux: /proc/stat を使用して小数点1位まで表示
        CPU_IDLE=$(top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/")
        echo "scale=1; 100 - $CPU_IDLE" | bc
    fi
}

get_memory_usage() {
    if [ "$OS" = "Darwin" ]; then
        # トータルメモリをGB単位で取得
        TOTAL_MEM=$(sysctl -n hw.memsize)
        TOTAL_MEM=$(echo "scale=1; $TOTAL_MEM / 1024 / 1024 / 1024" | bc)

        # memory_pressure から空きメモリの割合を取得し、使用率を計算
        FREE_PERCENT=$(memory_pressure | grep "System-wide memory free percentage:" | awk '{print $5}' | tr -d '%')
        USED_PERCENT=$((100 - FREE_PERCENT))

        # 使用メモリをGBに変換
        USED_MEM=$(echo "scale=1; $TOTAL_MEM * $USED_PERCENT / 100" | bc)

        echo "${USED_MEM}/${TOTAL_MEM}GB"
    else
        # Linux: free コマンドを使用
        free -g | awk '/Mem:/ {printf "%.1f/%.1fGB", $3, $2}'
    fi
}

# メイン処理
main() {
    local cpu_raw=$(get_cpu_usage)
    CPU_USAGE=$(printf "%4.1f" $cpu_raw | sed 's/100.0/100./')
    CPU_BAR=$(get_cpu_bar ${CPU_USAGE%.*}) # 小数点以下を切り捨ててバー表示用に使用
    MEM_USAGE=$(get_memory_usage)
    # 出力時に幅を指定して右寄せ
    echo "#[fg=black,bg=blue,bold] CPU ${CPU_BAR} #[default]${CPU_USAGE}%  #[fg=black,bg=green,bold] MEM #[default] ${MEM_USAGE}"
}

# エラーハンドリング
if ! main; then
    echo "Error: Failed to get system stats"
    exit 1
fi
