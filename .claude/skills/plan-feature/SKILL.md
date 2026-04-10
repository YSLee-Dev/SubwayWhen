---
name: plan-feature
description: $ARGUMENTS 기능의 plan.md 와 tasks.md 를 생성한다.
disable-model-invocation: true
---

# plan-feature

$ARGUMENTS 기능의 plan.md 와 tasks.md 를 생성한다.

## 실행 절차

### Step 1. spec 확인
`.claude/specs/features/$ARGUMENTS/spec.md` 를 읽는다.
파일이 없으면 아래 메시지를 출력하고 중단한다:
```
❌ spec.md 가 없습니다.
먼저 /new-feature $ARGUMENTS 를 실행하세요.
```

### Step 2. plan.md 생성
- 기존 관련 파일을 읽고 현재 상태를 파악한다
- `.claude/templates/plan.template.md` 를 참고하여 plan.md 를 작성한다
- 코드는 작성하지 않는다
- `.claude/specs/features/$ARGUMENTS/plan.md` 로 저장한다

### Step 3. 인간 확인 요청
plan.md 작성 완료 후 아래 메시지를 출력하고 반드시 대기한다:

```
✅ plan.md 생성 완료
📁 위치: .claude/specs/features/$ARGUMENTS/plan.md

plan.md 를 검토해주세요.
계속하려면 '확인' 를 입력하세요.
수정이 필요하면 수정 내용을 알려주세요.
```

### Step 4. tasks.md 생성
'확인' 입력 후에만 진행한다.
- spec.md 와 plan.md 를 참고하여 tasks.md 를 작성한다
- 코드는 작성하지 않는다
- `.claude/specs/features/$ARGUMENTS/tasks.md` 로 저장한다

### Step 5. 완료 보고
```
✅ tasks.md 생성 완료
📁 위치: .claude/specs/features/$ARGUMENTS/tasks.md

tasks.md 를 검토 후 /implement $ARGUMENTS 를 실행하세요.
```
