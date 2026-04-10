---
name: implement
description: $ARGUMENTS 기능을 Task 단위로 순차 구현한다.
각 Task 완료 후 반드시 인간 확인을 받은 후 다음 Task로 넘어간다.
---

# implement

$ARGUMENTS 기능을 Task 단위로 순차 구현한다.
각 Task 완료 후 반드시 인간 확인을 받은 후 다음 Task로 넘어간다.

## 실행 절차

### Step 1. 파일 확인
아래 파일이 모두 존재하는지 확인한다:
- `.claude/specs/features/$ARGUMENTS/spec.md`
- `.claude/specs/features/$ARGUMENTS/plan.md`
- `.claude/specs/features/$ARGUMENTS/tasks.md`

파일이 없으면 아래 메시지를 출력하고 중단한다:
```
❌ [없는 파일명] 이 없습니다.
먼저 /plan-feature $ARGUMENTS 를 실행하세요.
```

### Step 2. 구현 준비
세 파일을 모두 읽고 전체 구현 범위를 파악한다.
Task 목록을 출력하고 인간 확인을 요청한다:

```
📋 구현할 Task 목록:
[tasks.md의 Task 목록 출력]

구현을 시작하려면 '확인' 를 입력하세요.
```

### Step 3. Task 순차 구현
'확인' 입력 후 Task를 하나씩 순차적으로 구현한다.

각 Task마다 아래 사이클을 반복한다:

1. Task 구현
2. 빌드 확인 — 실패 시 즉시 수정
3. 관련 테스트 실행 — 실패 시 즉시 수정
4. tasks.md에서 해당 Task를 [x]로 업데이트
5. 인간 확인 요청:

```

[인간 확인 요청 - 반드시 대기]
✅ Task N 완료
📝 변경 파일: [파일 목록]
🔨 빌드: 성공
🧪 테스트: 통과

변경 내용을 확인해주세요.
계속하려면 '확인', 수정이 필요하면 내용을 알려주세요.

```

'확인' 입력 전까지 다음 Task를 절대 시작하지 않는다.

### Step 4. 전체 완료 보고
모든 Task 완료 후 Acceptance Criteria를 확인하고 보고한다:

```
🎉 전체 구현 완료

[Acceptance Criteria 체크 결과 출력]

빌드 후 직접 동작을 확인해주세요.

```
