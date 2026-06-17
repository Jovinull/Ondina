# Ondina

Plataforma de streaming e descoberta de vídeo premium.

## Stack Tecnológico

- **Frontend**: SvelteKit, TypeScript, Tailwind CSS
- **Backend**: Elixir, Phoenix (API mode)
- **Database**: PostgreSQL

## Pré-requisitos

Para rodar este projeto localmente, certifique-se de ter as seguintes ferramentas instaladas e rodando na sua máquina:

- **Node.js** (v24+ recomendado) e **NPM**
- **Elixir** (v1.14+) e **Erlang/OTP**
- **PostgreSQL** (rodando localmente na porta 5432, com o usuário padrão `postgres` e senha `postgres`)

> **Nota de Instalação do Elixir**: Se você não possui o Elixir instalado, recomendamos usar o [asdf](https://asdf-vm.com/) ou os gerenciadores de pacote do seu sistema operacional.

## Configurando e Rodando Localmente

### 1. Backend (Elixir / Phoenix)

Navegue até a pasta da API:
```bash
cd ondina_api
```

Instale as dependências e crie o banco de dados:
```bash
mix deps.get
mix ecto.setup
```

Inicie o servidor localmente (porta 4000):
```bash
mix phx.server
```

A API estará rodando em `http://localhost:4000`.

### 2. Frontend (SvelteKit)

Em um terminal separado, navegue até a pasta do frontend:
```bash
cd ondina_web
```

Instale as dependências:
```bash
npm install
```

Inicie o servidor de desenvolvimento (porta 5173):
```bash
npm run dev
```

O frontend estará rodando em `http://localhost:5173`.

## Verificando a Comunicação

Ao acessar `http://localhost:5173`, a página inicial fará uma requisição para a rota `http://localhost:4000/api/status`. Se tudo estiver configurado corretamente (incluindo o CORS no Phoenix), você verá a mensagem "Ondina API is running" renderizada na interface.
