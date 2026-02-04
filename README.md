'''
# SSH Auth

**SSH Auth** é um projeto que oferece uma solução de autenticação SSH baseada em uma API RESTful. Ele integra-se com o sistema de autenticação PAM (Pluggable Authentication Modules) do Linux para validar credenciais de usuário de forma segura e centralizada. O projeto é composto por um script de instalação em Shell e uma aplicação em Python que utiliza o framework Flask.

## Visão Geral

O principal objetivo deste projeto é fornecer um mecanismo de autenticação externo para sistemas que necessitam validar usuários do sistema operacional via SSH, mas que não podem ou não desejam interagir diretamente com os mecanismos de autenticação tradicionais. A solução expõe um endpoint HTTP que recebe um nome de usuário e uma senha, retornando um status de sucesso ou falha na autenticação.

## Funcionalidades

- **Autenticação baseada em API**: Permite que aplicações externas validem credenciais de usuários do sistema via uma simples chamada de API.
- **Integração com PAM**: Utiliza o sistema PAM para autenticação, garantindo que as políticas de segurança do sistema operacional sejam respeitadas.
- **Instalação Automatizada**: Um script de instalação (`main.sh`) automatiza todo o processo de configuração, desde a instalação de dependências até a criação de um serviço `systemd`.
- **Serviço Systemd**: O `ssh_auth` é executado como um serviço do sistema, garantindo que ele seja iniciado automaticamente com o sistema e reiniciado em caso de falhas.
- **Ambiente Isolado**: As dependências Python são instaladas em um ambiente virtual, evitando conflitos com outros pacotes do sistema.

## Arquitetura

O projeto é dividido em dois componentes principais:

| Componente | Tecnologia | Descrição |
| :--- | :--- | :--- |
| **Instalador** | Shell Script | Responsável por preparar o ambiente, instalar dependências como Python e o módulo PAM, baixar o código da aplicação e configurar o serviço `systemd`. |
| **API de Autenticação** | Python (Flask) | Uma aplicação web leve que expõe o endpoint `/auth` para receber requisições de autenticação via método POST. |

## Instalação

Para instalar e configurar o **SSH Auth**, execute o script `main.sh` com permissões de superusuário:

```bash
sudo ./main.sh
```

O script realizará as seguintes ações:

1.  Atualizará a lista de pacotes do sistema.
2.  Instalará o `python3`, `python3-venv`, `python3-pip`, `curl` e `systemd`.
3.  Instalará o módulo `python3-pam`.
4.  Fará o download do script `ssh_auth.py` para `/usr/local/bin`.
5.  Criará um ambiente virtual para o Python em `/opt/ssh_auth_venv`.
6.  Instalará as bibliotecas `Flask`, `six` e `python-pam` no ambiente virtual.
7.  Criará e habilitará um serviço `systemd` chamado `ssh_auth`.

## Uso

Após a instalação, a API estará disponível na porta `5001`. Para autenticar um usuário, envie uma requisição POST para o endpoint `/auth` com um corpo JSON contendo o nome de usuário e a senha:

```bash
curl -X POST -H "Content-Type: application/json" \
     -d '{"username": "seu_usuario", "password": "sua_senha"}' \
     http://localhost:5001/auth
```

### Respostas da API

- **Sucesso na Autenticação**:

  ```json
  {
    "success": true,
    "message": "Authentication successful"
  }
  ```

- **Falha na Autenticação**:

  ```json
  {
    "success": false,
    "message": "Invalid credentials"
  }
  ```

'''
