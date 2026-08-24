# test/agents — model profile smoke

`model-smoke.sh` เปิด fresh Claude process ของ `scout`, `builder` และ `ACV-v1.0.1` แล้วตรวจ
`canonicalModel` จาก JSON result. ชุดนี้พิสูจน์ว่า agent definition ถูก discover และ default model
ถูกใช้จริง; ไม่ได้สร้าง Agent Team หรือพิสูจน์ coordination runtime.

```bash
bash test/agents/model-smoke.sh
```

ตั้ง `AGENT_SMOKE_SANDBOX` เพื่อเก็บ JSON artifacts; ไม่ตั้งจะใช้ temporary directory.
CLI ปิด tools เพราะ test นี้วัด model selection เท่านั้น และมี token cost สาม fresh sessions.
