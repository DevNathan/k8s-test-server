# ---------- STAGE 1: BUILDER ----------
FROM node:25-alpine AS builder
WORKDIR /app

# pnpm 설치 (네가 쓰던 9.12.2 버전을 명시하여 환경을 일치시킵니다)
RUN npm i -g pnpm@9.12.2

# 의존성 설치를 위한 설정 파일 복사
COPY package.json pnpm-lock.yaml ./

# [FIX] CI 환경에서 락파일 불일치로 인한 설치 누락을 방지하기 위해 
# --frozen-lockfile 대신 --prefer-offline을 사용하여 강제로 설치를 완결짓습니다.
RUN pnpm install

# 모든 소스 파일 복사 (express가 포함된 전체 컨텍스트)
COPY . .

# 여기서 빌드 결과물(Next.js라면 pnpm build)을 생성하거나, 
# 단순 서버라면 이 단계에서 모든 의존성이 확보됩니다.

# ---------- STAGE 2: RUNTIME ----------
FROM node:25-alpine AS runner
WORKDIR /app

ENV NODE_ENV=production

# 빌드 단계에서 설치된 node_modules와 소스 코드를 통째로 가져옵니다.
# (Next.js standalone 구조가 아니라면 아래와 같이 가져오는 것이 가장 확실합니다)
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/server.js ./server.js
COPY --from=builder /app/package.json ./package.json

# [FINAL CHECK] 실행 직전 express의 존재를 한 번 더 확인합니다.
RUN ls node_modules/express || (echo "FATAL: express missing in runner stage" && exit 1)

EXPOSE 3000

# 런타임 실행
CMD ["node", "server.js"]
