//
//  JYProgressHUDTypes.swift
//  JYProgressHUD
//
//  Created by fuyong.dai on 2025.11.27
//  Copyright © 2025. All rights reserved.
//

import UIKit

/// 显示模式
@objc public enum JYProgressHUDMode: Int {
    /// 不确定进度（转圈）
    case indeterminate = 0
    /// 确定进度（圆形饼图）
    case determinate
    /// 水平条形进度
    case determinateHorizontalBar
    /// 环形进度
    case annularDeterminate
    /// 自定义视图
    case customView
    /// 仅文本
    case text
}

/// 动画类型
@objc public enum JYProgressHUDAnimation: Int {
    /// 淡入淡出
    case fade = 0
    /// 缩放（自动选择）
    case zoom
    /// 缩小消失
    case zoomOut
    /// 放大出现
    case zoomIn
}

/// 背景样式
@objc public enum JYProgressHUDBackgroundStyle: Int {
    /// 纯色
    case solidColor = 0
    /// 模糊
    case blur
}

/// JYProgressHUD 委托协议
@objc public protocol JYProgressHUDDelegate: AnyObject {
    /// HUD 完全隐藏后调用
    @objc optional func hudWasHidden(_ hud: JYProgressHUD)
}

/// 最大偏移量常量
public let JYProgressMaxOffset: CGFloat = 1000000.0

