//
//  Theme.swift
//  HupuX
//
//  极简中性配色：强调色为中性灰，顶栏/TabBar 跟随页面背景。
//  深色模式支持三档：跟随系统 / 浅色 / 深色（设置中切换），
//  AMOLED 省电黑在深色基础上可强制开启（纯黑防烧屏）。
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

    private static let modeKey = "appearance_mode"
    private static let amoledKey = "amoled_theme"

    /// 外观模式
    enum AppearanceMode: String, CaseIterable {
        case system, light, dark
        var label: String {
            switch self {
            case .system: return "跟随系统"
            case .light:  return "浅色"
            case .dark:   return "深色"
            }
        }
    }

    /// 系统当前是否处于深色模式（由 RootView 同步，自动跟随系统）
    @Published var systemDark = false

    /// 外观模式（持久化）
    @Published var mode: AppearanceMode {
        didSet { UserDefaults.standard.set(mode.rawValue, forKey: Self.modeKey) }
    }

    /// 强制纯黑省电模式（设置中的 AMOLED 开关）
    @Published var amoled: Bool {
        didSet { UserDefaults.standard.set(amoled, forKey: Self.amoledKey) }
    }

    private init() {
        mode = AppearanceMode(rawValue: UserDefaults.standard.string(forKey: Self.modeKey) ?? "") ?? .system
        amoled = UserDefaults.standard.bool(forKey: Self.amoledKey)
    }

    /// 当前实际是否深色：外观模式优先，AMOLED 强制深色
    var resolvedDark: Bool {
        if amoled { return true }
        switch mode {
        case .dark:   return true
        case .light:  return false
        case .system: return systemDark
        }
    }
}

enum Theme {
    private static var settings: ThemeSettings { ThemeSettings.shared }

    /// 深色配色开关：由外观模式决定，AMOLED 打开时强制深色
    private static var dark: Bool { settings.resolvedDark }

    /// 强调色（中性灰，极简风；深色下提亮为浅灰）
    static var brand:   Color { dark ? Color(hex: 0xB9BFCB) : Color(hex: 0x565D6A) }
    /// 灰色强调底上的文字/图标色（深色下用深字，浅色下用白字）
    static var onBrand: Color { dark ? Color(hex: 0x16181F) : .white }

    // 随主题变化的表面/文字色
    static var appBg:         Color {
        dark ? (settings.amoled ? Color(hex: 0x000000) : Color(hex: 0x0F1016)) : Color(hex: 0xF0F2FA)
    }
    static var cardBg:        Color {
        dark ? (settings.amoled ? Color(hex: 0x000000) : Color(hex: 0x1A1D27)) : Color(hex: 0xFFFFFF)
    }
    static var textPrimary:   Color { dark ? Color(hex: 0xE4E8F2) : Color(hex: 0x1A1C2E) }
    static var textSecondary: Color { dark ? Color(hex: 0x8A90A0) : Color(hex: 0x6B7080) }
    static var textTertiary:  Color { dark ? Color(hex: 0x5F6578) : Color(hex: 0xABB0BF) }
    static var placeholder:   Color {
        dark ? (settings.amoled ? Color(hex: 0x121212) : Color(hex: 0x1E222E)) : Color(hex: 0xF4F5FA)
    }
    /// 热度 / 高分（语义色保持红橙系；深色下提亮，保证对比度）
    static var hot:           Color { dark ? Color(hex: 0xFF6B5E) : Color(hex: 0xF04438) }

    /// 顶栏背景色（跟随页面背景，极简无色块）
    static var headerColors: [Color] { [appBg, appBg] }
    /// 底部 TabBar 背景（跟随页面背景）
    static var tabBarColor: Color { appBg }

    /// 分段 pill：选中态（浅色：深灰底白字；深色/AMOLED：白底深字）
    static var pillSelectedColors: [Color] {
        dark ? [.white, Color(hex: 0xD8D8D8)] : [Color(hex: 0x565D6A), Color(hex: 0x454C58)]
    }
    /// 分段 pill：未选中态
    static var pillUnselectedColors: [Color] {
        dark ? [Color(hex: 0x2A2D3A), Color(hex: 0x1D2028)] : [Color(hex: 0xE6E8EF), Color(hex: 0xD9DCE5)]
    }
    /// 帖子正文 HTML 文字色（深色下浅色，否则深色）
    static var bodyTextHex: String { dark ? "#EBEBF0" : "#1A1C2E" }
}
