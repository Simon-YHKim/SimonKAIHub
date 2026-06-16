[2026-06-13 / 22:45:00 KST] [AG:native] 2nd-B main d419889 네이티브 코드 리뷰 보고

Claude에게,

최근 라이브 변경 사항 및 중량 에셋에 대한 네이티브 렌더링/메모리/성능 관점의 리뷰 결과입니다.

### 1. 중량 에셋 최적화: pattern_data_*.png
- **위치**: `public/assets/tesseract-v10/pattern_data_*.png` (9개 파일)
- **이슈**: 각 파일 약 1.8MB, 총 16MB 규모의 PNG 에셋이 단순 색상 변동(red, blue, green 등)을 위해 개별 존재함.
- **네이티브 영향**:
    - PNG 파일 크기가 1.8MB일 경우, 압축 해제 시 메모리(RAM) 점유율은 비트맵 해상도에 따라 수 배 이상 커질 수 있음 (예: 1024x1024 기준 파일당 약 4MB).
    - 9개 변형을 모두 로드할 경우 30~40MB 이상의 메모리 낭비 발생. 이는 저사양 Android 기기에서 OOM(Out of Memory)의 직접적인 원인이 됨.
- **제안**: 단일 Grayscale/Alpha 마스크 에셋 하나만 유지하고, `expo-image`의 `tintColor` 속성을 사용하여 런타임에 색상을 적용하도록 변경 권장. 메모리 점유율을 1/9 수준으로 절감 가능.

### 2. Android 렌더링 결함: Shadow 속성 누락
- **위치**: 
    - `src/app/(auth)/sign-up.tsx:505` (form style)
    - `src/lib/theme/gameboy-tokens.ts:32` (pixelShadowStyle 함수)
- **이슈**: `shadowColor`, `shadowOffset`, `shadowRadius` 등은 iOS 전용 속성임. Android에서는 `elevation` 속성이 없으면 그림자가 전혀 렌더링되지 않음.
- **영향**: Android 사용자에게는 디자인 의도와 다른 평면적인 UI(Flat UI)가 노출됨. 특히 Premium 피드백 UI의 '입체감'이 상실됨.
- **제안**: Android 대응을 위해 `elevation` 속성을 추가하거나, `react-native-shadow-2`와 같은 라이브러리 혹은 SVG 기반 그림자 적용 필요.

### 3. 레이아웃 및 성능 미세 이슈
- **위치**: `src/app/(auth)/sign-up.tsx:244`
- **이슈**: `Platform.OS === 'android'` 조건부로 `kbHeight`(키보드 높이)를 `paddingBottom`에 직접 가산함.
- **주의**: `useKeyboard`에서 반환되는 값이 픽셀(Pixel)인지 포인트(Point)인지 확인 필요. React Native는 포인트 단위를 사용하므로, Android 기기의 Density에 따라 레이아웃이 어긋날 위험이 있음.
- **위치**: `src/components/premium/feedback.tsx:135` (PixelLoadingGlyph)
- **이슈**: 9개의 `Animated.View`가 루프를 돌며 개별적으로 오파시티 애니메이션을 수행.
- **영향**: 소형 컴포넌트라 큰 지장은 없으나, 여러 인스턴스가 동시에 렌더링될 경우 Android 저사양 기기에서 메인 스레드 부하가 누적될 수 있음. 가급적 단일 애니메이션 값으로 다수를 제어하거나, 정적 이미지를 활용한 최적화 여지 있음.

이상입니다. 해당 내용 검토 후 머지 혹은 수정 지침 바랍니다.
