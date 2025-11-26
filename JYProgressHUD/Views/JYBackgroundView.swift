//
//  JYBackgroundView.swift
//  JYProgressHUD
//
//  Created by fuyong.dai on 2025.11.27
//  Copyright © 2025. All rights reserved.
//

import UIKit

/// 背景视图，支持模糊和纯色两种样式
@objc public class JYBackgroundView: UIView {
    
    // MARK: - Properties
    
    /// 背景样式
    @objc public var style: JYProgressHUDBackgroundStyle = .blur {
        didSet {
            if style != oldValue {
                updateForBackgroundStyle()
            }
        }
    }
    
    /// 模糊效果样式（仅在 style 为 .blur 时有效）
    @objc public var blurEffectStyle: UIBlurEffect.Style = .systemMaterial {
        didSet {
            if blurEffectStyle != oldValue {
                updateForBackgroundStyle()
            }
        }
    }
    
    /// 背景颜色或模糊色调颜色
    @objc public var color: UIColor? {
        didSet {
            if color != oldValue {
                updateViewsForColor()
            }
        }
    }
    
    // MARK: - Private Properties
    
    private var effectView: UIVisualEffectView?
    
    // MARK: - Initialization
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        style = .blur
        
        // iOS 17.0+ 使用系统材质
        blurEffectStyle = .systemThickMaterial
        color = nil // iOS 17.0+ 不设置颜色效果更好
        
        clipsToBounds = true
        updateForBackgroundStyle()
    }
    
    // MARK: - Layout
    
    public override var intrinsicContentSize: CGSize {
        return .zero
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        effectView?.frame = bounds
    }
    
    // MARK: - Updates
    
    private func updateForBackgroundStyle() {
        effectView?.removeFromSuperview()
        effectView = nil
        
        if style == .blur {
            let effect = UIBlurEffect(style: blurEffectStyle)
            let newEffectView = UIVisualEffectView(effect: effect)
            insertSubview(newEffectView, at: 0)
            newEffectView.frame = bounds
            newEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            backgroundColor = color
            layer.allowsGroupOpacity = false
            effectView = newEffectView
        } else {
            backgroundColor = color
        }
    }
    
    private func updateViewsForColor() {
        if style == .blur {
            backgroundColor = color
        } else {
            backgroundColor = color
        }
    }
}

