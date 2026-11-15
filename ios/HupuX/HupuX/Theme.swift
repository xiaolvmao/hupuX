//
//  Theme.swift
//  HupuX
//
//  主色由虎扑红改为靛蓝。
//  深色模式跟随系统自动切换，AMOLED 省电黑在设置中可强制开启（纯黑防烧屏）。
//

import SwiftUI
import Combine

extension Color {
    init(hex: UInt32) {
        self.init(
            .sRGB,
            red:   Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue:  Double(hex & 0xFF) / 255,
            opacity: 1
        )
    }
}

/// 全局主题设置，持久化在 UserDefaults。
/// systemDark 由 RootView 从环境 colorScheme 同步而来，不持久化、随系统实时变化；
/// 任一主题状态变化时由 RootView 通过 `.id` 触发整树重建，使下面 Theme 的计算属性重新取值。
final class ThemeSettings: ObservableObject {
    static let shared = ThemeSettings()

    private static let key = "amoled_theme"

    /// 系统当前是否处于深色模式（由 RootView 同步，自动跟随系统）
    @Published var systemDark = false

    /// 强制纯黑省电模式（设置中的 AMOLED 开关）
    @Published var amoled: Bool {
        didSet { UserDefaults.standard.set(amoled, forKey: Self.key) }
    }

    private init() {
        amoled = UserDefaults.standard.bool(forKey: Self.key)
    }

    func toggle() { amoled.toggle() }
}

enum Theme {
    private static var amoled: Bool { ThemeSettings.shared.amoled }

    /// 深色配色开关：跟随系统深浅色，AMOLED 打开时强制深色
    private static var dark: Bool { amoled || ThemeSettings.shared.systemDark }

    // 品牌强调色（靛蓝，小面积强调）
    static let brand          = Color(hex: 0x4A5FE0)
    static let brandDark      = Color(hex: 0x3A4BC2)
    static let pillBrand      = Color(hex: 0x5B6CE8)
    static let pillBrandDark  = Color(hex: 0x3846BC)

    // 随主题变化的表面/文字色
    static var appBg:         Color {
        amoled ? Color(hex: 0x000000) : dark ? Color(hex: 0x0F1016) : Color(hex: 0xF0F2FA)
    }
    static var cardBg:        Color {
        amoled ? Color(hex: 0x000000) : dark ? Color(hex: 0x1A1D27) : Color(hex: 0xFFFFFF)
    }
    static var textPrimary:   Color { dark ? Color(hex: 0xE4E8F2) : Color(hex: 0x1A1C2E) }
    static var textSecondary: Color { dark ? Color(hex: 0x8A90A0) : Color(hex: 0x6B7080) }
    static var textTertiary:  Color { dark ? Color(hex: 0x5F6578) : Color(hex: 0xABB0BF) }
    static var placeholder:   Color {
        amoled ? Color(hex: 0x121212) : dark ? Color(hex: 0x1E222E) : Color(hex: 0xF4F5FA)
    }
    /// 热度 / 高分（语义色保持红橙系；深色下提亮，保证对比度）
    static var hot:           Color { dark ? Color(hex: 0xFF6B5E) : Color(hex: 0xF04438) }

    /// 顶栏品牌渐变色（浅色：靛蓝渐变；深色：低调深蓝渐变；AMOLED：纯黑，防大块色块烧屏）
    static var headerColors: [Color] {
        amoled ? [.black, .black]
            : dark ? [Color(hex: 0x232A50), Color(hex: 0x1A2044)]
            : [brand, brandDark]
    }
    /// 底部 TabBar 背景（浅色靛蓝；深色沉稳深灰蓝；AMOLED 纯黑）
    static var tabBarColor: Color {
        amoled ? .black : dark ? Color(hex: 0x161926) : brand
    }

    /// 分段 pill：选中态（白塑料，两主题一致，黑底醒目）
    static var pillSelectedColors: [Color] { [.white, Color(hex: 0xD8D8D8)] }
    /// 分段 pill：未选中态
    static var pillUnselectedColors: [Color] {
        amoled ? [Color(hex: 0x2A2D3A), Color(hex: 0x1D2028)]
            : dark ? [Color(hex: 0x2E3448), Color(hex: 0x222738)]
            : [pillBrand, pillBrandDark]
    }
    /// 帖子正文 HTML 文字色（深色下浅色，否则深色）
    static var bodyTextHex: String { dark ? "#EBEBF0" : "#1A1C2E" }
}
