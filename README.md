# Ondina - Plataforma de Vídeos e Streaming 🎬🌊

Ondina é uma plataforma completa de streaming e engajamento em tempo real, construída para escalar usando Elixir e oferecer uma interface absurdamente rápida e bela usando SvelteKit.

## Stack Tecnológica 🚀
- **Backend**: Elixir (1.14), Phoenix, Ecto
- **Streaming**: FFmpeg para fragmentação assíncrona (HLS Adaptativo)
- **Mensageria/PubSub**: WebSockets do Phoenix Channels
- **Frontend**: SvelteKit 5 (Runes), TailwindCSS
- **Banco de Dados**: PostgreSQL 15

## Como Rodar Localmente via Docker (Recomendado) 🐳
A arquitetura foi inteiramente conteinerizada para o seu conforto. O banco de dados, o backend e o frontend subirão unificados. O servidor possui "Live Reload" (Volumes espelhados) ativados para dev!

### 1. Inicie a Arquitetura Completa
Na raiz do projeto (`/Ondina`), simplesmente execute:
```bash
docker compose up --build -d
```
*Isto irá baixar as imagens, baixar o FFmpeg interno, instalar as dependências hex/npm e subir os três containers (`db`, `api` e `web`).*

### 2. Acesso aos Serviços
- **Frontend (SvelteKit)**: [http://localhost:5173](http://localhost:5173)
- **Backend API**: [http://localhost:4000/api](http://localhost:4000/api)
- **PostgreSQL**: `localhost:5433`

### 3. Migrações e Seeds do Banco
Uma vez que o docker compose subir o projeto, execute o script de migração no container da API:
```bash
docker exec -it ondina_api mix ecto.setup
```

E pronto! Faça o login, mande seus uploads e veja a mágica do HLS fragmentando seus vídeos em tempo real.
