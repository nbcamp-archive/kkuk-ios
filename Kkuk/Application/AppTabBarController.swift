//
//  AppTabBarController.swift
//  Kkuk
//
//  Created by Yujin Kim on 2023-10-16.
//

import UIKit

enum AppTabBarItemType: String, CaseIterable {
    
    case home, category, search, appinfo
    
    init?(index: Int) {
        switch index {
        case 0: self = .home
        case 1: self = .category
        case 2: self = .search
        case 3: self = .appinfo
        default: return nil
        }
    }
    
    func toInt() -> Int {
        switch self {
        case .home: return 0
        case .category: return 1
        case .search: return 2
        case .appinfo: return 3
        }
    }
    
    func toTabName() -> String {
        switch self {
        case .home: return "홈"
        case .category: return "카테고리"
        case .search: return "검색"
        case .appinfo: return "앱 정보"
        }
    }
    
    func toTabSymbol() -> String {
        switch self {
        case .home: return "house.fill"
        case .category: return "folder.fill"
        case .search: return "magnifyingglass"
        case .appinfo: return "info.circle.fill"
        }
    }
    
}

class AppTabBarController: UITabBarController {
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let tabBarItemCases = AppTabBarItemType.allCases
        
        let tabBarItems = tabBarItemCases.map { makeTabBarItem(from: $0) }
        
        let homeViewController = HomeViewController()
        let categoryViewController = CategoryViewController()
        let searchContentViewController = SearchContentViewController()
        let appInfoViewController = AppInfoViewController()
        
        viewControllers = [homeViewController, categoryViewController, searchContentViewController, appInfoViewController]
            .enumerated().map { index, viewController in
                setTabBarItem(for: viewController, tabBarItem: tabBarItems[index])
            }
            .map { wrapNavigationController(from: $0) }
        
        prepareTabBarController()
    }
    
}

extension AppTabBarController {
    
    private func makeTabBarItem(from type: AppTabBarItemType) -> UITabBarItem {
        let name = type.toTabName()
        let symbol = type.toTabSymbol()
        let tag = type.toInt()
        return UITabBarItem(title: name, image: UIImage(systemName: symbol), tag: tag)
    }
    
    private func setTabBarItem(for viewController: UIViewController, tabBarItem: UITabBarItem) -> UIViewController {
        viewController.tabBarItem = tabBarItem
        return viewController
    }
    
    private func wrapNavigationController(from viewController: UIViewController) -> UINavigationController {
        let navigationController = UINavigationController(rootViewController: viewController)
        navigationController.navigationBar.isHidden = true
        
        return navigationController
    }
    
    private func prepareTabBarController() {
        setViewControllers(viewControllers, animated: false)
        selectedIndex = AppTabBarItemType.home.toInt()
        
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithOpaqueBackground()
        tabBarAppearance.backgroundColor = .white
        
        tabBar.isTranslucent = false
        tabBar.standardAppearance = tabBarAppearance
        tabBar.scrollEdgeAppearance = tabBarAppearance
        tabBar.tintColor = UIColor.black
        tabBar.tintColor = .black
        tabBar.unselectedItemTintColor = .subgray1
    }
    
}
