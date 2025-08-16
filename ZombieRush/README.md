# ZombieRush

가로모드로 플레이하는 좀비 러시 게임입니다.

## 📁 프로젝트 구조

```
ZombieRush/
├── App/                    # 앱의 메인 파일
│   └── ZombieRushApp.swift
├── Views/                  # UI 화면들
│   ├── ContentView.swift   # 메인 메뉴 화면
│   ├── GameView.swift      # 게임 플레이 화면
│   └── SettingsView.swift # 설정 화면
├── Managers/               # 비즈니스 로직 관리
│   └── AudioManager.swift  # 오디오 재생 관리
├── Resources/              # 리소스 파일들
│   └── background.mp3      # 배경 음악
├── Assets.xcassets/        # 이미지 및 색상 에셋
│   ├── background.imageset # 배경 이미지
│   └── Button1.imageset    # 버튼 이미지
└── Preview Content/        # SwiftUI 프리뷰용
```

## 🎮 주요 기능

- **메인 메뉴**: 게임 시작 및 설정 접근
- **게임 화면**: 좀비 러시 게임 플레이
- **설정 화면**: 효과음, 배경음악, 진동 설정
- **백그라운드 뮤직**: 무한 반복 재생 및 설정 저장

## 🎨 UI 특징

- 가로모드 최적화
- 반응형 레이아웃
- 그림자 효과와 네온 스타일
- 사용자 친화적 인터페이스

## 🔧 기술 스택

- SwiftUI
- AVFoundation (오디오 재생)
- UserDefaults (설정 저장)
- MVVM 아키텍처

## 📱 지원 환경

- iOS 14.0+
- 가로모드 전용
- iPhone 및 iPad 지원
