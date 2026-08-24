---
name: ops
description: Router operations/infrastructure/reliability สำหรับ IaC, cloud/network/IAM/secret, incident, observability, health และ SLI/SLO. เลือก incident-response, infra-change หรือ observability ตามงานก่อนวิเคราะห์หรือเปลี่ยนแปลง
---

# Operations

Rules ด้าน production readiness, compatibility/rollout และ operations/observability เป็น safety floor เสมอ; skills นี้เพิ่ม workflow เฉพาะงาน ไม่ลด requirement หรือให้สิทธิ์เปลี่ยน external state เอง

| ลักษณะงาน | ต้องอ่าน |
|---|---|
| IaC, cloud resource, network, IAM, secret, state, drift หรือ provisioning | `ops:infra-change` |
| outage, incident, degraded production, mitigation หรือ post-incident evidence | `ops:incident-response` |
| health check, logs, metrics, traces, alert, dashboard, SLI/SLO หรือ silent failure | `ops:observability` |

ก่อน mutation ภายนอกเสมอ: ระบุ environment, target, blast radius, rollback/mitigation และ authorization ที่ชัดเจน. การอ่านสถานะและรวบรวมหลักฐานทำได้ก่อน แต่ plan ไม่ใช่ approval และ incident ไม่ใช่สิทธิ์ให้ restart/rollback/deploy เอง.
