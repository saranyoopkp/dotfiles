# Performance Routing

## Safety floor

- query ต่อ item บน collection ที่โตได้, collection ที่ไม่มี bound และ external I/O ที่ไม่มี
  timeout/deadline เป็น correctness/operational risk ไม่ใช่เพียง optimization
- ห้ามเพิ่ม cache, queue, concurrency หรือ virtualization จาก scale สมมติ และห้ามเปลี่ยน
  synchronous/deferred semantics เงียบ ๆ

## Routing

เมื่อมี latency/throughput/resource concern, N+1, unbounded list, expensive repeated work หรือ
render pressure ให้ invoke `performance` ก่อนออกแบบหรือ mutation; รวมถึงเมื่อต้องตัดสินใจเรื่อง
cache/queue/index/async optimization. การรัน verification ปกติที่ไม่มี performance concern
ไม่ต้อง invoke.
