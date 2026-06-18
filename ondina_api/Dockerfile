FROM elixir:1.14-alpine

# Instala dependências nativas e essenciais
RUN apk add --no-cache build-base npm git inotify-tools postgresql-client ffmpeg

WORKDIR /app

# Instalação do Hex e Rebar
RUN mix local.hex --force && \
    mix local.rebar --force

# Copiar os arquivos de lock e mix para cache
COPY mix.exs mix.lock ./
RUN mix deps.get

COPY . .

# Expõe a porta que o Phoenix rodará
EXPOSE 4000

# Comando default em ambiente de dev rodará com live reload
CMD ["sh", "-c", "mix deps.get && mix ecto.setup && mix phx.server"]
