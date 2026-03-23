FROM node:18-alpine

WORKDIR /usr/src/app

RUN npm install -g pnpm && pnpm config set node-linker hoisted

COPY package.json pnpm-lock.yaml ./

RUN pnpm install

COPY server.js .

EXPOSE 3000
CMD ["node", "server.js"]
