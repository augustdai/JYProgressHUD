//
//  UIView+JYProgressHUD.swift
//  JYProgressHUD
//
//  Created by fuyong.dai on 2025.11.27
//  Copyright © 2025. All rights reserved.
//

import UIKit

public extension UIView {
    /// 显示 HUD
    /// - Parameter animated: 是否使用动画，默认为 true
    /// - Returns: 创建的 HUD 实例
    @objc @discardableResult
    func showProgressHUD(animated: Bool = true) -> JYProgressHUD {
        return JYProgressHUD.showHUDAdded(to: self, animated: animated)
    }
    
    /// 隐藏 HUD
    /// - Parameter animated: 是否使用动画，默认为 true
    @objc func hideProgressHUD(animated: Bool = true) {
        _ = JYProgressHUD.hideHUD(for: self, animated: animated)
    }
    
    /// 获取当前 HUD
    /// - Returns: 找到的 HUD 实例，如果没有则返回 nil
    @objc func progressHUD() -> JYProgressHUD? {
        return JYProgressHUD.HUD(for: self)
    }
}

public extension JYProgressHUD {
    /// Swift 风格的显示方法
    /// - Parameters:
    ///   - view: 要添加到的视图
    ///   - animated: 是否使用动画，默认为 true
    /// - Returns: 创建的 HUD 实例
    static func show(on view: UIView, animated: Bool = true) -> JYProgressHUD {
        return showHUDAdded(to: view, animated: animated)
    }
    
    /// Swift 风格的隐藏方法
    /// - Parameters:
    ///   - view: 要查找的视图
    ///   - animated: 是否使用动画，默认为 true
    static func hide(from view: UIView, animated: Bool = true) {
        _ = hideHUD(for: view, animated: animated)
    }
    
    /// 配置方法（链式调用）- 设置模式
    /// - Parameter mode: 显示模式
    /// - Returns: HUD 实例，用于链式调用
    @discardableResult
    func withMode(_ mode: JYProgressHUDMode) -> JYProgressHUD {
        self.mode = mode
        return self
    }
    
    /// 配置方法（链式调用）- 设置主标签
    /// - Parameter text: 标签文本
    /// - Returns: HUD 实例，用于链式调用
    @discardableResult
    func withLabel(_ text: String) -> JYProgressHUD {
        label.text = text
        return self
    }
    
    /// 配置方法（链式调用）- 设置详情标签
    /// - Parameter text: 详情文本
    /// - Returns: HUD 实例，用于链式调用
    @discardableResult
    func withDetailsLabel(_ text: String) -> JYProgressHUD {
        detailsLabel.text = text
        return self
    }
    
    /// 配置方法（链式调用）- 设置进度
    /// - Parameter progress: 进度值 (0.0 - 1.0)
    /// - Returns: HUD 实例，用于链式调用
    @discardableResult
    func withProgress(_ progress: Float) -> JYProgressHUD {
        self.progress = progress
        return self
    }
    
    /// 配置方法（链式调用）- 设置动画类型
    /// - Parameter animation: 动画类型
    /// - Returns: HUD 实例，用于链式调用
    @discardableResult
    func withAnimation(_ animation: JYProgressHUDAnimation) -> JYProgressHUD {
        animationType = animation
        return self
    }
}

