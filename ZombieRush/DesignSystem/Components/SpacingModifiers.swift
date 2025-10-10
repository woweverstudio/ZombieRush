import SwiftUI

// MARK: - Spacing Modifiers
extension View {
    func pagePadding() -> some View {
        self.padding(.horizontal, UIConstants.pageHorizontal)
    }

    func sectionSpacing(_ spacing: CGFloat = UIConstants.Spacing.x16) -> some View {
        self.padding(.vertical, spacing)
    }

    func ctaButtonSpacing() -> some View {
        self
            .padding(.top, UIConstants.ctaButtonTopSpacing)
            .padding(.bottom, UIConstants.ctaButtonBottomSpacing)
    }
}


