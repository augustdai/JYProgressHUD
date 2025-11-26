//
//  JYRoundProgressView.swift
//  JYProgressHUD
//
//  Created by fuyong.dai on 2025.11.27
//  Copyright © 2025. All rights reserved.
//

import UIKit

/// 圆形进度视图，支持饼图和环形两种模式
@objc public class JYRoundProgressView: UIView {
    
    // MARK: - Properties
    
    /// 进度值 (0.0 - 1.0)
    @objc public var progress: Float = 0.0 {
        didSet {
            if progress != oldValue {
                setNeedsDisplay()
            }
        }
    }
    
    /// 进度颜色
    @objc public var progressTintColor: UIColor = .white {
        didSet {
            if progressTintColor != oldValue {
                setNeedsDisplay()
            }
        }
    }
    
    /// 背景颜色
    @objc public var backgroundTintColor: UIColor = UIColor(white: 1.0, alpha: 0.1) {
        didSet {
            if backgroundTintColor != oldValue {
                setNeedsDisplay()
            }
        }
    }
    
    /// 是否为环形模式（false 为饼图模式）
    @objc public var isAnnular: Bool = false {
        didSet {
            if isAnnular != oldValue {
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
        return CGSize(width: 50, height: 50)  // 增大尺寸：37 -> 50
    }
    
    // MARK: - Drawing
    
    public override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        if isAnnular {
            drawAnnular(in: context, rect: rect)
        } else {
            drawRound(in: context, rect: rect)
        }
    }
    
    private func drawAnnular(in context: CGContext, rect: CGRect) {
        let lineWidth: CGFloat = 2.0
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = (rect.width - lineWidth) / 2.0
        let startAngle = -CGFloat.pi / 2.0
        let endAngle = 2.0 * CGFloat.pi + startAngle
        
        // 绘制背景
        let backgroundPath = UIBezierPath()
        backgroundPath.lineWidth = lineWidth
        backgroundPath.lineCapStyle = .butt
        backgroundPath.addArc(withCenter: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
        backgroundTintColor.setStroke()
        backgroundPath.stroke()
        
        // 绘制进度
        let progressPath = UIBezierPath()
        progressPath.lineCapStyle = .square
        progressPath.lineWidth = lineWidth
        let progressEndAngle = CGFloat(progress) * 2.0 * CGFloat.pi + startAngle
        progressPath.addArc(withCenter: center, radius: radius, startAngle: startAngle, endAngle: progressEndAngle, clockwise: true)
        progressTintColor.setStroke()
        progressPath.stroke()
    }
    
    private func drawRound(in context: CGContext, rect: CGRect) {
        let lineWidth: CGFloat = 2.0
        let allRect = rect
        let circleRect = allRect.insetBy(dx: lineWidth / 2.0, dy: lineWidth / 2.0)
        let center = CGPoint(x: rect.midX, y: rect.midY)
        
        // 绘制背景
        progressTintColor.setStroke()
        backgroundTintColor.setFill()
        context.setLineWidth(lineWidth)
        context.strokeEllipse(in: circleRect)
        
        // 绘制进度
        let startAngle = -CGFloat.pi / 2.0
        let progressPath = UIBezierPath()
        progressPath.lineCapStyle = .butt
        progressPath.lineWidth = lineWidth * 2.0
        let radius = (rect.width / 2.0) - (progressPath.lineWidth / 2.0)
        let endAngle = CGFloat(progress) * 2.0 * CGFloat.pi + startAngle
        progressPath.addArc(withCenter: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
        
        context.setBlendMode(.copy)
        progressTintColor.set()
        progressPath.stroke()
    }
}

