FROM node:18-alpine

WORKDIR /usr/src/app

# 캐시 오염을 방지하기 위해 package.json을 복사하기 전, 
# 기존에 존재할지 모르는 node_modules를 선제적으로 제거하는 명령을 넣습니다.
RUN rm -rf node_modules

# package.json만 먼저 복사하여 레이어 캐시를 최적화합니다.
COPY package.json ./

# pnpm 대신 가장 원시적이고 확실한 npm으로 '모든' 의존성을 강제 설치합니다.
# --no-package-lock 옵션으로 기존의 꼬인 락파일 영향을 완전히 배제합니다.
RUN npm install --no-package-lock

# 소스 코드를 복사합니다.
COPY server.js .

# 빌드 최종 단계에서 express의 존재를 다시 한번 검증합니다.
RUN ls node_modules/express || (echo "FATAL: express NOT FOUND" && exit 1)

EXPOSE 3000
CMD ["node", "server.js"]