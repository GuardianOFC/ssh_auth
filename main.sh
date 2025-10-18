#!/bin/bash
# ============================================
# SSH Auth Installer - by GuardianOFC
# Instala Python, PAM, Flask e Six, baixa ssh_auth.py e cria serviço systemd
# ============================================

set -e

SERVICE_NAME="ssh_auth"
SERVICE_FILE="/etc/systemd/system/${SERVICE_NAME}.service"
SCRIPT_PATH="/usr/local/bin/ssh_auth.py"
VENV_PATH="/opt/ssh_auth_venv"

echo ">>> Atualizando pacotes..."
apt update -y

echo ">>> Instalando dependências..."
apt install -y python3 python3-venv python3-pip curl systemd

echo ">>> Instalando módulo PAM..."
if ! apt install -y python3-pam; then
    echo ">>> Pacote python3-pam não disponível, tentando via pip..."
    pip3 install python-pam || pip3 install pam
fi

echo ">>> Baixando ssh_auth.py..."
mkdir -p /usr/local/bin
curl -L -o "$SCRIPT_PATH" "https://github.com/GuardianOFC/ssh_auth/raw/refs/heads/main/ssh_auth.py"
chmod +x "$SCRIPT_PATH"

echo ">>> Criando ambiente virtual..."
python3 -m venv "$VENV_PATH"
"$VENV_PATH/bin/pip" install --upgrade pip

echo ">>> Instalando dependências no ambiente virtual..."
"$VENV_PATH/bin/pip" install flask six python-pam || "$VENV_PATH/bin/pip" install flask six pam

echo ">>> Criando serviço systemd..."
cat > "$SERVICE_FILE" <<EOF
[Unit]
Description=SSH Auth Python Service
After=network.target

[Service]
Type=simple
ExecStart=${VENV_PATH}/bin/python ${SCRIPT_PATH}
WorkingDirectory=/usr/local/bin
Restart=on-failure
RestartSec=5
Environment=PYTHONUNBUFFERED=1

[Install]
WantedBy=multi-user.target
EOF

echo ">>> Recarregando e iniciando serviço..."
systemctl daemon-reload
systemctl enable "$SERVICE_NAME"
systemctl restart "$SERVICE_NAME"

echo ">>> Serviço criado e iniciado!"
systemctl status "$SERVICE_NAME" --no-pager