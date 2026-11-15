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
    @Environment(\.colorScheme) private var systemScheme

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
        // 外观模式：跟随系统传 nil；浅色/深色强制指定；AMOLED 优先强制深色
        .preferredColorScheme(theme.amoled ? .dark :
            theme.mode == .light ? .light : theme.mode == .dark ? .dark : nil)
        .onAppear { theme.systemDark = systemScheme == .dark }
        .onChange(of: systemScheme) { _ in
            theme.systemDark = systemScheme == .dark
            Self.applyTabBarAppearance()
        }
        .onChange(of: theme.amoled) { _ in Self.applyTabBarAppearance() }
        .onChange(of: theme.mode) { _ in Self.applyTabBarAppearance() }
    }
}
