# Testing Strategy Routing

## Safety floor

- verification ต้องพิสูจน์ claim และ failure mode ที่เกี่ยว; build/typecheck หรือ test ที่ผ่าน
  ไม่พิสูจน์ runtime flow ที่ไม่ได้รัน
- test ที่จำเป็นพังห้าม skip/comment เพื่อทำให้ suite เขียว และ high-risk logic เรื่องเงิน,
  authorization, tenant, data loss หรือ irreversible side effect ต้องมีหลักฐานตรงความเสี่ยง

## Routing

เมื่อจะเลือก test level/matrix/fixture, แก้ regression, เปลี่ยน logic หรือ boundary ที่มีความเสี่ยง,
suite ผ่านแต่ flow ยังพัง หรือ coverage gap ยังไม่ชัด ให้ invoke `testing-strategy` ก่อนวาง test.
การรันคำสั่ง verification ที่ repo และ criterion กำหนดชัดแล้วไม่ต้อง invoke.
