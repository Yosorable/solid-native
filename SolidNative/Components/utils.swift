//
//  utils.swift
//  SolidNative
//
//  Created by LZY on 2024/5/13.
//

import Foundation
import UIKit

func GetKeyWindowUIViewController() -> UIViewController? {
    let kw = UIApplication
        .shared
        .connectedScenes
        .flatMap { ($0 as? UIWindowScene)?.windows ?? [] }
        .last { $0.isKeyWindow }
    return kw?.rootViewController
}

func GetTopViewController(controller: UIViewController? = GetKeyWindowUIViewController()) -> UIViewController? {
    if let navigationController = controller as? UINavigationController {
        return GetTopViewController(controller: navigationController.visibleViewController)
    }
    if let tabController = controller as? UITabBarController {
        if let selected = tabController.selectedViewController {
            return GetTopViewController(controller: selected)
        }
    }
    if let presented = controller?.presentedViewController {
        return GetTopViewController(controller: presented)
    }
    return controller
}
