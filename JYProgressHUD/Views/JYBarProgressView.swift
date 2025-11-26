//
//  JYBarProgressView.swift
//  JYProgressHUD
//
//  Created by fuyong.dai on 2025.11.27
//  Copyright © 2025. All rights reserved.
//

import UIKit

/// 水平条形进度视图
@objc public class JYBarProgressView: UIView {
    
    // MARK: - Properties
    
    /// 进度值 (0.0 - 1.0)
    @objc public var progress: Float = 0.0 {
        didSet {
            if progress != oldValue {
                setNeedsDisplay()
            }
        }
    }
    
    /// 边框颜色
    @objc public var lineColor: UIColor = .white {
        didSet {
            if lineColor != oldValue {
                setNeedsDisplay()
            }
        }
    }
    
    /// 剩余部分颜色
    @objc public var progressRemainingColor: UIColor = .clear {
        didSet {
            if progressRemainingColor != oldValue {
                setNeedsDisplay()
            }
        }
    }
    
    /// 进度颜色
    @objc public var progressColor: UIColor = .white {
        didSet {
            if progressColor != oldValue {
                setNeedsDisplay()
            }
        }
    }
    
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
        backgroundColor = .clear
        isOpaque = false
    }
    
    // MARK: - Layout
    
    public override var intrinsicContentSize: CGSize {
        return CGSize(width: 150, height: 12)  // 增大尺寸：120x10 -> 150x12
    }
    
    // MARK: - Drawing
    
    public override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        let radius = (rect.height / 2.0) - 2.0
        let amount = CGFloat(progress) * rect.width
        
        // 绘制背景和边框
        context.setLineWidth(2.0)
        context.setStrokeColor(lineColor.cgColor)
        context.setFillColor(progressRemainingColor.cgColor)
        
        // 绘制圆角矩形背景
        let backgroundPath = UIBezierPath(roundedRect: rect.insetBy(dx: 2, dy: 2), cornerRadius: radius)
        context.addPath(backgroundPath.cgPath)
        context.drawPath(using: .fillStroke)
        
        // 绘制进度
        context.setFillColor(progressColor.cgColor)
        
        if amount >= radius + 4 && amount <= rect.width - radius - 4 {
            // 中间区域
            let progressRect = CGRect(x: 4, y: 4, width: amount - 4, height: rect.height - 8)
            let progressPath = UIBezierPath(roundedRect: progressRect, cornerRadius: radius - 2)
            context.addPath(progressPath.cgPath)
            context.fillPath()
        } else if amount > radius + 4 {
            // 右侧圆角区域
            let x = amount - (rect.width - radius - 4)
            let progressPath = UIBezierPath()
            progressPath.move(to: CGPoint(x: 4, y: rect.height / 2))
            progressPath.addArc(withCenter: CGPoint(x: rect.width - radius - 4, y: rect.height / 2),
                               radius: radius - 2,
                               startAngle: .pi,
                               endAngle: -acos(x / (radius - 2)),
                               clockwise: false)
            progressPath.addLine(to: CGPoint(x: amount, y: rect.height / 2))
            progressPath.addLine(to: CGPoint(x: amount, y: 4))
            progressPath.addArc(withCenter: CGPoint(x: rect.width - radius - 4, y: rect.height / 2),
                               radius: radius - 2,
                               startAngle: -.pi,
                               endAngle: acos(x / (radius - 2)),
                               clockwise: true)
            progressPath.addLine(to: CGPoint(x: amount, y: rect.height / 2))
            context.addPath(progressPath.cgPath)
            context.fillPath()
        } else if amount < radius + 4 && amount > 0 {
            // 左侧圆角区域
            let progressPath = UIBezierPath()
            progressPath.move(to: CGPoint(x: 4, y: rect.height / 2))
            progressPath.addArc(withCenter: CGPoint(x: radius + 4, y: rect.height / 2),
                               radius: radius - 2,
                               startAngle: .pi,
                               endAngle: 0,
                               clockwise: false)
            progressPath.addLine(to: CGPoint(x: radius + 4, y: rect.height / 2))
            context.addPath(progressPath.cgPath)
            context.fillPath()
        }
    }
}

