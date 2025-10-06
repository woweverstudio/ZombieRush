import SwiftUI

extension GuestPopup {
    static let title = NSLocalizedString("guest_popup_title", tableName: "View", comment: "Guest popup title")
    static let message = NSLocalizedString("guest_popup_message", tableName: "View", comment: "Guest popup main message")
    static let internetRequired = NSLocalizedString("guest_popup_internet_required", tableName: "View", comment: "Internet connection required text")
    static let gameCenterRequired = NSLocalizedString("guest_popup_gamecenter_required", tableName: "View", comment: "Game Center login required text")
    static let dataNotSaved = NSLocalizedString("guest_popup_data_not_saved", tableName: "View", comment: "Game data not saved text")
    static let confirmButton = NSLocalizedString("guest_popup_confirm_button", tableName: "View", comment: "Guest popup confirm button")
    static let footerMessage = NSLocalizedString("guest_popup_footer_message", tableName: "View", comment: "Guest popup footer message")
}

// MARK: - Guest Popup View
struct GuestPopup: View {
    let onConfirm: () -> Void
    
    var message: some View {
        Text(GuestPopup.message)
            .font(.system(size: 16, design: .monospaced))
            .foregroundColor(.dsTextSecondary)
            .multilineTextAlignment(.center)
            .lineSpacing(6)
            .padding(.horizontal, 24)
    }

    var body: some View {
        VStack {
            // 헤더 영역 - 제목
            Header(title: GuestPopup.title, showBackButton: false)
            Spacer()
            message
            Spacer()
            // 내용 영역
            VStack(spacing: 16) {
                // 특징 아이콘들
                HStack(alignment: .top) {
                    VStack(spacing: 12) {
                        Image(systemName: "wifi.slash")
                            .font(.system(size: 24))
                            .foregroundColor(.red.opacity(0.7))
                            .frame(width: 24, height: 24)
                        Text(GuestPopup.internetRequired)
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
                        Text(GuestPopup.gameCenterRequired)
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
                        
                        Text(GuestPopup.dataNotSaved)
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
                    title: GuestPopup.confirmButton,
                    style: .cyan,
                    fullWidth: true
                ) {
                    onConfirm()
                }

                Text(GuestPopup.footerMessage)
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
