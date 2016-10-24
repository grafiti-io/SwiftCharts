//
//  ChartTransform.swift
//  SwiftCharts
//
//  Created by ischuetz on 23/07/16.
//  Copyright © 2016 ivanschuetz. All rights reserved.
//

import UIKit

public class ChartTransform {
    
    public private(set) var transform = CGAffineTransformIdentity
    
    weak var chart: Chart?
    
    var scaleX: CGFloat {
        return transform.a
    }
    
    var scaleY: CGFloat {
        return transform.d
    }
    
    var transX: CGFloat {
        return transform.tx
    }
    
    var transY: CGFloat {
        return transform.ty
    }
    
    public func applyX(x: CGFloat) -> CGFloat {
        return x * scaleX + transX
    }
    
    public func applyY(y: CGFloat) -> CGFloat {
        return y * scaleY + transY
    }
    
    public func scaleWidth(width: CGFloat) -> CGFloat {
        return width * scaleX
    }
    
    public func scaleHeight(height: CGFloat) -> CGFloat {
        return height * scaleY
    }
    
    public func apply(size: CGSize) -> CGSize {
        return CGSizeApplyAffineTransform(size, transform)
    }
    
    public func apply(point: CGPoint) -> CGPoint {
        return CGPointApplyAffineTransform(point, transform)
    }
    
    public func apply(frame: CGRect) -> CGRect {
        return CGRectApplyAffineTransform(frame, transform)
    }
    
    func reset() {
        transform = CGAffineTransformIdentity
    }
    
    func zoom(deltaX deltaX: CGFloat, deltaY: CGFloat, centerX: CGFloat, centerY: CGFloat) {
        setZoom(x: transform.a * deltaX, y: transform.d * deltaY, centerX: centerX, centerY: centerY)
    }
    
    func incrementZoom(x x: CGFloat, y: CGFloat, centerX: CGFloat, centerY: CGFloat) {
        setZoom(x: transform.a + x, y: transform.d + y, centerX: centerX, centerY: centerY)
    }
    
    func setZoom(x x: CGFloat, y: CGFloat, centerX: CGFloat, centerY: CGFloat) {
//        print("trasnform before zoom: \(transform), scale: x:\(x),y:\(y)")
        transform = CGAffineTransformTranslate(transform, centerX, centerY)
        transform.a = max(x, 1)
        transform.d = max(y, 1)
        transform = CGAffineTransformTranslate(transform, -centerX, -centerY)
        
        // re-set the current translation, to validate boundaries
        setTrans(x: transform.tx, y: transform.ty)
    }

    func setTrans(x x: CGFloat, y: CGFloat) {
        
        guard let chart = chart else {return}

        // use borders of inner frame as limits
        
        let leading = chart.containerFrame.minX * transform.a - chart.containerFrame.minX
        let top = chart.containerFrame.minY * transform.d - chart.containerFrame.minY
        
        transform.tx = min(x, -leading)
        transform.ty = min(y, -top)
        
        let initTrailing = chart.view.frame.width - chart.containerFrame.maxX
        let initBottom = chart.view.frame.height - chart.containerFrame.maxY
        
        let trailing = initTrailing * transform.a - initTrailing
        let bottom = initBottom * transform.d - initBottom
        
//        print("bottom: \(bottom). initBottom: \(initBottom), chart height: \(chart.view.frame.height), container maxy: \(chart.containerFrame.maxY), trans.d: \(transform.d), chart.frame: \(chart.frame)")
        
        transform.tx = max(transform.tx, (chart.frame.width) - scaleWidth(chart.view.frame.size.width) + trailing)
        transform.ty = max(transform.ty, (chart.frame.height) - scaleHeight(chart.view.frame.height) + bottom)
    }
    
    func pan(deltaX deltaX: CGFloat, deltaY: CGFloat) {
        setTrans(x: transX + deltaX, y: transY + deltaY)
    }
}
