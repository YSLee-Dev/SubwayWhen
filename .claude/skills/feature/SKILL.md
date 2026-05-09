---
name: feature
description: $ARGUMENTS 기능을 spec → plan → tasks → 구현까지 단계별로 진행한다.
argument-hint: 기능명
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash(mkdir -p *)
  - Bash(xcodebuild build *)
  - Bash(xcodebuild test *)
---

# feature

$ARGUMENTS 기능의 전체 개발 흐름을 관리한다.
현재 상태를 감지하여 자동으로 다음 단계를 실행한다.

---

## 상태 감지

`.claude/specs/features/$ARGUMENTS/` 폴더를 확인하여 실행할 Step을 결정한다:

| 상태 | 실행 |
|------|------|
| `spec.md` 없음 | `reference/step1-spec.md` 를 읽고 절차를 따른다 |
| `spec.md` 있음 + `plan.md` 없음 | `reference/step2-plan.md` 를 읽고 절차를 따른다 |
| `plan.md` 있음 + `tasks.md` 없음 | `reference/step3-tasks.md` 를 읽고 절차를 따른다 |
| `tasks.md` 있음 | `reference/step4-implement.md` 를 읽고 절차를 따른다 |
