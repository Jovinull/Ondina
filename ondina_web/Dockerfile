FROM node:20-alpine

WORKDIR /app

# Copia os manifestos e instala as dependências
COPY package.json package-lock.json* ./
RUN npm install

# Copia o restante da aplicação
COPY . .

# Expõe a porta do Vite
EXPOSE 5173

# Entrypoint apontando para a rede host
CMD ["npm", "run", "dev", "--", "--host", "0.0.0.0"]
