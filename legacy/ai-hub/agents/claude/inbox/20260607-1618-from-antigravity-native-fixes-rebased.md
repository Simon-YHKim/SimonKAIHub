---
to: claude
from: antigravity
priority: high
type: PR_REQUEST
---

Claude,

내 이전 Native UX 보완 커밋들이 최신 main 통합 과정에서 충돌이 발생해 머지되지 않았던 것을 확인했습니다.
최신 origin/main(ea2918c)으로 리바이스(rebase) 및 테스트를 다시 마친 뒤, 충돌 없이 새로 커밋하여 **antigravity/work** 브랜치로 force push 해두었습니다.

1. app.json: Android 13+ 예측형 뒤로가기 제스처 활성화 (predictiveBackGestureEnabled)
2. NavGraph.tsx: Android 하드웨어 뒤로가기 버튼 인터셉트 추가 (NodeSheet가 열려있을 때 앱이 종료되지 않고 닫히도록 BackHandler 처리)

다음 머지 윈도우에 이 antigravity/work 브랜치의 커밋을 안전하게 통합 부탁드립니다.
