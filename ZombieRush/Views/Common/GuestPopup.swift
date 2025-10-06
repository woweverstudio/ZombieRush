import SwiftUI

// MARK: - Guest Popup View
struct GuestPopup: View {
    let onConfirm: () -> Void
    
    var message: some View {
        Text("인터넷 연결 또는 게임센터 로그인이 필요합니다. 게스트모드는 기존 게임 데이터를 사용하지 않고 임시 데이터를 사용합니다.")
            .font(.system(size: 16, design: .monospaced))
            .foregroundColor(.dsTextSecondary)
            .multilineTextAlignment(.center)
            .lineSpacing(6)
            .padding(.horizontal, 24)
    }

    var body: some View {
        VStack {
            // 헤더 영역 - 제목
            Header(title: "게스트 모드", showBackButton: false)
            Spacer()
            message
            Spacer()
            // 내용 영역
            VStack(spacing: 16) {
                // 특징 아이콘들
                HStack {
                    VStack(spacing: 12) {
                        Image(systemName: "wifi.slash")
                            .font(.system(size: 24))
                            .foregroundColor(.red.opacity(0.7))
                            .frame(width: 24, height: 24)
                        Text("인터넷\n연결 필요")
                            .font(.system(size: 11, design: .monospaced))
                            .foregroundColor(.dsTextSecondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    
                    VStack(spacing: 12) {
                        Image(systemName: "gamecontroller.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.orange.opacity(0.7))
                            .frame(width: 24, height: 24)
                        Text("Game Center\n로그인 필요")
                            .font(.system(size: 11, design: .monospaced))
                            .foregroundColor(.dsTextSecondary)
                            .multilineTextAlignment(.center)
                            .lineSpacing(2)
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    
                    VStack(spacing: 12) {
                        Image(systemName: "cloud.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.cyan.opacity(0.7))
                            .frame(width: 24, height: 24)
                        
                        Text("게임 내용\n저장되지 않음")
                            .font(.system(size: 11, design: .monospaced))
                            .foregroundColor(.dsTextSecondary)
                            .multilineTextAlignment(.center)
                            .lineSpacing(2)
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                }
            }

            Spacer()

            // 버튼 영역
            VStack(spacing: 12) {
                PrimaryButton(
                    title: "일단 플레이하기",
                    style: .cyan,
                    fullWidth: true
                ) {
                    onConfirm()
                }

                Text("나중에 로그인할 수 있습니다")
                    .font(.system(size: 12, design: .monospaced))
                    .foregroundColor(.dsTextDisabled)
            }
            
        }
        .padding(20)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.gray.opacity(0.05))
        .presentationDetents([.medium]) // Sheet 크기 설정
        .presentationDragIndicator(.visible) // 드래그 인디케이터 표시
    }
}

// MARK: - Preview
#Preview {
    GuestPopup(
        onConfirm: {
            print("Confirm tapped")
        }
    )
}
