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

    /// 底部 TabBar 外观：浅色靖蓝底、深色深灰蓝底、AMOLED 纯黑，白图标贴近安卓观感。
    static func applyTabBarAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(Theme.tabBarColor)

        let item = UITabBarItemAppearance()
        item.normal.iconColor = UIColor.white.withAlphaComponent(0.65)
        item.normal.titleTextAttributes = [.foregroundColor: UIColor.white.withAlphaComponent(0.65)]
        item.selected.iconColor = .white
        item.selected.titleTextAttributes = [.foregroundColor: UIColor.white]
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
        // 导航栏按钮/返回箭头/控件强调色跟随品牌色。
        // 底部 TabBar 的白色图标由上面的 UITabBarAppearance 显式控制，不受此影响。
        .tint(Theme.brand)
        // 主题状态（AMOLED 开关 / 系统深浅色）变化时整树重建，刷新配色与 TabBar 外观
        .id("\(theme.amoled)-\(theme.systemDark)")
        // AMOLED 强制深色；否则跟随系统深浅色自动切换
        .preferredColorScheme(theme.amoled ? .dark : nil)
        .onAppear { theme.systemDark = systemScheme == .dark }
        .onChange(of: systemScheme) { _ in
            theme.systemDark = systemScheme == .dark
            Self.applyTabBarAppearance()
        }
        .onChange(of: theme.amoled) { _ in Self.applyTabBarAppearance() }
    }
}
