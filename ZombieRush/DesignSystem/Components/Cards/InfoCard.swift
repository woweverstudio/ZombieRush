import SwiftUI

// MARK: - Info Card Component
struct InfoCard: View {
    let title: String
    let subtitle: String?
    let iconName: String?
    let iconColor: Color
    let value: String?
    let style: CardStyle

    init(
        title: String,
        subtitle: String? = nil,
        iconName: String? = nil,
        iconColor: Color = .cyan,
        value: String? = nil,
        style: CardStyle = .default
    ) {
        self.title = title
        self.subtitle = subtitle
        self.iconName = iconName
        self.iconColor = iconColor
        self.value = value
        self.style = style
    }

    var body: some View {
        Card(style: style) {
            VStack(spacing: 8) {
                // 아이콘 (있는 경우)
                if let iconName = iconName {
                    Image(systemName: iconName)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(iconColor)
                        .frame(width: 50, height: 50)
                }

                // 타이틀
                Text(title)
                    .font(.system(size: 12, weight: .medium, design: .monospaced))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)

                // 값 표시 (있는 경우)
                if let value = value {
                    Text(value)
                        .font(.system(size: 14, weight: .bold, design: .monospaced))
                        .foregroundColor(iconColor)
                }
            }
        }
    }
}

// MARK: - Selection Info Card Component
struct SelectionInfoCard: View {
    let title: String
    let subtitle: String?
    let iconName: String?
    let iconColor: Color
    let value: String?
    let isSelected: Bool
    let action: () -> Void

    init(
        title: String,
        subtitle: String? = nil,
        iconName: String? = nil,
        iconColor: Color = .cyan,
        value: String? = nil,
        isSelected: Bool = false,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.subtitle = subtitle
        self.iconName = iconName
        self.iconColor = iconColor
        self.value = value
        self.isSelected = isSelected
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            InfoCard(
                title: title,
                subtitle: subtitle,
                iconName: iconName,
                iconColor: iconColor,
                value: value,
                style: isSelected ? .selected : .default
            )
        }
    }
}

// MARK: - Preview
#Preview {
    VStack(spacing: 16) {
        InfoCard(
            title: "Fire Element",
            iconName: "flame.fill",
            iconColor: .red,
            value: "5"
        )

        SelectionInfoCard(
            title: "Ice Element",
            iconName: "snowflake",
            iconColor: .blue,
            value: "3",
            isSelected: true
        ) {
            print("Ice Element selected")
        }

        SelectionInfoCard(
            title: "Lightning Element",
            iconName: "bolt.fill",
            iconColor: .yellow,
            value: "2",
            isSelected: false
        ) {
            print("Lightning Element selected")
        }
    }
    .padding()
    .background(Color.black)
}
