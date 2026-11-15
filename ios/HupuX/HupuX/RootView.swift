//
//  RootView.swift
//  HupuX
//
//  底部 Tab 框架：首页/发现/评分/搜索/我的。本地收藏已移除，帖子收藏走虎扑账号（在「我的」里）。
//  目前仅首页有内容，其余为占位，后续逐屏补。
//

import SwiftUI

struct RootView: View {
    @StateObject private var theme = ThemeSettings.shared
    @Environment(\.colorScheme) private var envScheme
    @Environment(\.scenePhase) private var scenePhase

    init() {
        Self.applyTabBarAppearance()
    }

    /// 底部 TabBar 外观：跟随页面背景色，图标用主题文字色，极简风。
    static func applyTabBarAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(Theme.tabBarColor)

        let item = UITabBarItemAppearance()
        item.normal.iconColor = UIColor(Theme.textSecondary)
        item.normal.titleTextAttributes = [.foregroundColor: UIColor(Theme.textSecondary)]
        item.selected.iconColor = UIColor(Theme.textPrimary)
        item.selected.titleTextAttributes = [.foregroundColor: UIColor(Theme.textPrimary)]
        appearance.stackedLayoutAppearance = item
        appearance.inlineLayoutAppearance = item
        appearance.compactInlineLayoutAppearance = item

        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }

    /// 窗口级深浅色 override。
    /// 不用 SwiftUI 的 .preferredColorScheme：iOS 16/17 上从「浅色/深色」切回「跟随系统」时
    /// 传 nil 可能清不掉旧 override，导致跟随系统失效（App 被钉死在旧外观）。
    /// 这里直接设置 UIWindow.overrideUserInterfaceStyle，清除是确定性的：
    /// 跟随系统 = .unspecified，浅色/深色 = 显式指定，AMOLED 强制深色。
    static func applyWindowAppearance() {
        let t = ThemeSettings.shared
        let style: UIUserInterfaceStyle = {
            if t.amoled { return .dark }
            switch t.mode {
            case .dark:   return .dark
            case .light:  return .light
            case .system: return .unspecified
            }
        }()
        for scene in UIApplication.shared.connectedScenes {
            guard let ws = scene as? UIWindowScene else { continue }
            for window in ws.windows where window.overrideUserInterfaceStyle != style {
                window.overrideUserInterfaceStyle = style
            }
        }
    }

    var body: some View {
        TabView {
            HomeView()
                .tabItem { Label("首页", systemImage: "house.fill") }
            ZoneListView()
                .tabItem { Label("发现", systemImage: "square.grid.2x2.fill") }
            ScoreView()
                .tabItem { Label("评分", systemImage: "star.fill") }
            SearchView()
                .tabItem { Label("搜索", systemImage: "magnifyingglass") }
            ProfileView()
                .tabItem { Label("我的", systemImage: "person.fill") }
        }
        // 导航栏按钮/返回箭头/控件强调色跟随主题。
        // 底部 TabBar 的图标颜色由上面的 UITabBarAppearance 显式控制，不受此影响。
        .tint(Theme.brand)
        // 主题状态（外观模式 / AMOLED 开关 / 系统深浅色）变化时整树重建，刷新配色与 TabBar 外观
        .id("\(theme.mode)-\(theme.amoled)-\(theme.systemDark)")
        .onAppear {
            syncSystemDark()
            Self.applyWindowAppearance()
            Self.applyTabBarAppearance()
        }
        // 系统深浅色实时变化（跟随系统模式的核心通道：无 override 时环境值是真实系统值）
        .onChange(of: envScheme) { _ in
            syncSystemDark()
            Self.applyWindowAppearance()
            Self.applyTabBarAppearance()
        }
        // 回前台时兜底：系统在后台切换过外观、或环境值被历史 override 污染时，从 UIScreen 追平
        .onChange(of: scenePhase) { phase in
            if phase == .active {
                syncSystemDark()
                Self.applyWindowAppearance()
                Self.applyTabBarAppearance()
            }
        }
        .onChange(of: theme.mode) { _ in
            Self.applyWindowAppearance()
            Self.applyTabBarAppearance()
        }
        .onChange(of: theme.amoled) { _ in
            Self.applyWindowAppearance()
            Self.applyTabBarAppearance()
        }
    }

    /// 同步真实系统深浅色到 ThemeSettings.systemDark。
    /// UIScreen 在窗口层级之上，其 trait 不受 window.overrideUserInterfaceStyle 污染，
    /// 是系统外观的可靠来源；取不到时回退到环境值。
    private func syncSystemDark() {
        var dark = envScheme == .dark
        if let screen = UIApplication.shared.connectedScenes
            .compactMap({ ($0 as? UIWindowScene)?.screens.first })
            .first,
           screen.traitCollection.userInterfaceStyle != .unspecified {
            dark = (screen.traitCollection.userInterfaceStyle == .dark)
        }
        if theme.systemDark != dark {
            theme.systemDark = dark
        }
    }
}
