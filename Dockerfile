# Node.js 18 버전의 Alpine 이미지를 기반으로 사용합니다.
FROM node:18-alpine

# 컨테이너 내부 작업 디렉토리 설정
WORKDIR /usr/src/app

# pnpm 전역 설치
RUN npm install -g pnpm

# 의존성 관련 파일을 먼저 복사합니다.
COPY package.json pnpm-lock.yaml ./

# pnpm 설정을 강제로 평면 구조(Hoisted)로 고정하고 의존성을 설치합니다.
# 이 명령은 pnpm 특유의 심볼릭 링크 구조를 완전히 무시하고 모든 패키지를 실제 파일로 node_modules에 박아넣습니다.
RUN pnpm config set node-linker hoisted && \
    pnpm install --no-frozen-lockfile

# 소스 코드를 복사합니다.
COPY server.js .

# 빌드가 완료된 시점에 node_modules에 express가 진짜 있는지 강제로 검사합니다.
# 만약 여기서 express가 없으면 빌드 자체가 실패하도록 설계하여 불량 이미지가 생성되는 것을 원천 차단합니다.
RUN ls node_modules/express || (echo "ERROR: express not found in node_modules" && exit 1)

# 포트 개방 및 실행
EXPOSE 3000
CMD ["node", "server.js"]