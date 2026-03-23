const express = require('express');
const os = require('os');
const fs = require('fs');
const app = express();
const port = 3000;

// 파드 내부가 아닌, 마운트될 외부 볼륨의 경로입니다.
const dataFile = '/data/visitor.log';

app.get('/', (req, res) => {
  const logMsg = `Hit by ${os.hostname()} at ${new Date().toISOString()}\n`;
  
  // 외부 디스크(볼륨)에 로그를 누적해서 기록합니다.
  try {
    fs.appendFileSync(dataFile, logMsg);
    const logs = fs.readFileSync(dataFile, 'utf8');
    res.send(`K8s Test [v4.2 PV/PVC] - Unbreakable Data\n\n[ Persisted Logs ]\n${logs}`);
  } catch (err) {
    res.status(500).send("Volume Mount Failed.");
  }
});

app.get('/health', (req, res) => res.status(200).send('OK'));
app.listen(port, () => console.log(`Server is running on port ${port}`));