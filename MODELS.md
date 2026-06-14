# MODELS.md — 허브 AI 모델·effort 정본 (always-best)

> **목적**: 4-AI 허브의 모든 AI가 **항상 가장 높은 벤치마크 모델 + 최대 reasoning effort**를 쓰도록 강제한다.
> **기계 판독 정본 = `tools/models.json`** (hub-daemon.ps1이 읽어 spawn 플래그를 만든다). 이 문서는 사람용 요약.
> **갱신**: `model-benchmark-refresh` 일일 cloud schedule이 제공사별 최신 최고모델을 재조사해 둘 다 갱신한다(§ 갱신 절차).
> **마지막 점검**: 2026-06-14 (hub-upgrade-research workflow — 제공사별 병렬 웹검색 + 적대적 교차검증).

---

## 정본 표 (2026-06-14)

| AI | CLI | 최고모델 | effort 최대 | 선택/플래그 |
|---|---|---|---|---|
| **Claude** | `claude` | `claude-fable-5` | `max` | `/model fable` → `/effort max` (영속: env `CLAUDE_CODE_EFFORT_LEVEL=max`) |
| **Codex** | `codex` | `gpt-5.5` | `xhigh` | `-m gpt-5.5 -c model_reasoning_effort="xhigh"` |
| **Grok** | `grok` | `grok-4.3` | `high` | env `GROK_MODEL=grok-4.3` `GROK_REASONING_EFFORT=high` (+ `-m grok-4.3`) |
| **Antigravity** | `agy`/`gemini` | `gemini-3.1-pro-preview` | `high`(=max) | `-m gemini-3.1-pro-preview` / agy `"Gemini 3.1 Pro (High)"` |

---

## AI별 근거·주의 (검증됨)

### Claude — `claude-fable-5` @ max
- Fable 5(2026-06-09)는 Anthropic 최강 공개 모델. Opus 4.8를 코딩·장기 에이전트에서 상회. effort 척도 `low|medium|high|xhigh|max`, **max = 토큰 상한 없음**.
- **주의**: Fable 5 안전 분류기가 보안/생물 콘텐츠에서 Opus 4.8로 자동 폴백. `max`의 세션 간 영속은 env `CLAUDE_CODE_EFFORT_LEVEL=max`로만 가능. 인터랙티브 Claude Code는 정액(토큰 미과금).
- **폴백**: `claude-opus-4-8` @ `xhigh`.

### Codex — `gpt-5.5` @ xhigh
- GPT-5.5(2026-04-23) = OpenAI 최신 프런티어, Codex CLI 기본. **`gpt-5.5-codex` 변종 없음 → `-m gpt-5.5`**. `xhigh`가 최대 reasoning.
- **주의**: 검증자 교정 — GPT-5.5 SWE-bench Verified ~82.6%(Claude Opus 4.8 88.6%보다 낮음). 그러나 *Codex 레인에서 쓸 수 있는 최고 OpenAI 모델*. gpt-5.6 루머(공식 id 미정) 주시.

### Grok — `grok-4.3` @ high
- Grok 4.3(2026-04-30) = Grok 라인 최상위, Artificial Analysis Intelligence Index 53(high). **reasoning_effort 기본 low → high 명시 필수**.
- **주의**: 점(`.`) 모델 id(`grok-4.3`, `grok-4-3` 아님). reasoning_effort CLI 노출은 빌드마다 다름 → env(`GROK_MODEL`/`GROK_REASONING_EFFORT`)로 설정(superagent 빌드). 레거시 `grok-4`/`grok-4-0709`는 reasoning_effort 거부.

### Antigravity — `gemini-3.1-pro-preview` @ high(=max)
- Gemini 3.1 Pro(2026-02-19) = Google 종합 1위(SWE-bench Verified 80.6%, ARC-AGI-2 77.1%, 16개 중 13개 벤치 선두). **thinkingLevel HIGH가 최대이자 3.1 Pro 기본값**.
- **주의**: Gemini CLI는 **2026-06-18 폐기 → agy(Antigravity CLI)로 이관**. agy 모델 라벨 `"Gemini 3.1 Pro (High)"`의 `(High)`가 최대 thinking(agy 기본은 `Gemini 3.5 Flash (High)`이라 override 필요). Gemini 3.5 Flash가 일부 에이전트-코딩 벤치에서 3.1 Pro를 더 낮은 비용에 상회(방어가능한 대안).

---

## 갱신 절차 (일일 cloud schedule)

- 스케줄명 `model-benchmark-refresh` — 매일 ~09:00 KST cloud agent가 실행.
- 동작: 제공사별(Anthropic/OpenAI/xAI/Google) 최신 최고모델·effort 플래그를 웹 재조사(병렬+적대적 검증) → 변동 시 `tools/models.json` + 이 표 갱신 → `commit.ps1 -As claude` → 변경 있으면 Simon에게 1줄 알림.
- 수동 재조사: hub-upgrade-research workflow 재실행(`Workflow` 또는 저장된 스크립트).
- **불변 원칙**: 항상 *그 CLI에서 실제 호출 가능한* 최고 벤치마크 모델 + 최대 effort. 비용 게이트(§11-5)는 인터랙티브 정액이라 해당 없음(헤드리스 `claude -p`만 과금).
