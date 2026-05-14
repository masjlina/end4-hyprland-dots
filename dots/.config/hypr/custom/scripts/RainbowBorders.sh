#!/usr/bin/env bash
set -euo pipefail

random_hex() {
  # 0xffRRGGBB
  printf "0xff%s" "$(openssl rand -hex 3)"
}

# Сколько цветов в градиенте
N=10
COLORS=()
for ((i=0; i<N; i++)); do
  COLORS+=("$(random_hex)")
done

# Угол градиента
ANGLE="270deg"

# Собираем ЕДИНУЮ строку значения
ACTIVE_VALUE="${COLORS[*]} ${ANGLE}"

# Применяем: значение обязательно в кавычках!
hyprctl keyword general:col.active_border "$ACTIVE_VALUE"

# --- при желании можно включить и для неактивных окон ---
# hyprctl keyword general:col.inactive_border "$ACTIVE_VALUE"

