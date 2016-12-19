//
//  Chart.swift
//  SwiftCharts
//
//  Created by ischuetz on 25/04/15.
//  Copyright (c) 2015 ivanschuetz. All rights reserved.
//

import UIKit

/// ChartSettings allows configuration of the visual layout of a chart
public class ChartSettings {

    /// Empty space in points added to the leading edge of the chart
    public var leading: CGFloat = 0

    /// Empty space in points added to the top edge of the chart
    public var top: CGFloat = 0

    /// Empty space in points added to the trailing edge of the chart
    public var trailing: CGFloat = 0

    /// Empty space in points added to the bottom edge of the chart
    public var bottom: CGFloat = 0

    /// The spacing in points between axis labels when using multiple labels for each axis value. This is currently only supported with an X axis.
    public var labelsSpacing: CGFloat = 5

    /// The spacing in points between X axis labels and the X axis line
    public var labelsToAxisSpacingX: CGFloat = 5

    /// The spacing in points between Y axis labels and the Y axis line
    public var labelsToAxisSpacingY: CGFloat = 5

    public var spacingBetweenAxesX: CGFloat = 15

    public var spacingBetweenAxesY: CGFloat = 15

    /// The spacing in points between axis title labels and axis labels
    public var axisTitleLabelsToLabelsSpacing: CGFloat = 5

    /// The stroke width in points of the axis lines
    public var axisStrokeWidth: CGFloat = 1.0
    
    public var panEnabled = false
    
    public var zoomEnabled = false
    
    public init() {}
}

public protocol ChartDelegate {
    
    func onZoom(scaleX scaleX: CGFloat, scaleY: CGFloat, deltaX: CGFloat, deltaY: CGFloat, centerX: CGFloat, centerY: CGFloat, isGesture: Bool)
    
    func onPan(transX transX: CGFloat, transY: CGFloat, deltaX: CGFloat, deltaY: CGFloat, isGesture: Bool, isDeceleration: Bool)
}

/// A Chart object is the highest level access to your chart. It has the view where all of the chart layers are drawn, which you can provide (useful if you want to position it as part of a storyboard or XIB), or it can be created for you.
public class Chart {

    /// The view that the chart is drawn in
    public let view: ChartView

    public let containerView: UIView
    public let contentView: UIView
    public let drawersContentView: UIView

    /// The layers of the chart that are drawn in the view
    private let layers: [ChartLayer]

    private(set)var transform: ChartTransform

    public var delegate: ChartDelegate?

    public var transX: CGFloat {
        return contentFrame.minX
    }
    
    public var transY: CGFloat {
        return contentFrame.minY
    }

    public var scaleX: CGFloat {
        return contentFrame.width / containerFrame.width
    }
    
    public var scaleY: CGFloat {
        return contentFrame.height / containerFrame.height
    }
    
    /**
     Create a new Chart with a frame and layers. A new ChartBaseView will be created for you.

     - parameter innerFrame: Frame comprised by axes, where the chart displays content
     - parameter settings: Chart settings
     - parameter frame:  The frame used for the ChartBaseView
     - parameter layers: The layers that are drawn in the chart

     - returns: The new Chart
     */
    convenience public init(frame: CGRect, innerFrame: CGRect? = nil, settings: ChartSettings? = nil, layers: [ChartLayer]) {
        self.init(view: ChartBaseView(frame: frame), innerFrame: innerFrame, settings: settings, layers: layers)
    }

    private var anchorTranslation = CGPointZero
    
    /**
     Create a new Chart with a view and layers.

     
     - parameter innerFrame: Frame comprised by axes, where the chart displays content
     - parameter settings: Chart settings
     - parameter view:   The view that the chart will be drawn in
     - parameter layers: The layers that are drawn in the chart

     - returns: The new Chart
     */
    public init(view: ChartView, innerFrame: CGRect? = nil, settings: ChartSettings? = nil, layers: [ChartLayer]) {
        
        self.layers = layers
        
        self.view = view
        
        transform = ChartTransform()
        
        let containerView = UIView(frame: innerFrame ?? view.bounds)
        containerView.backgroundColor = UIColor.yellowColor().colorWithAlphaComponent(0.3)

        let drawersContentView = ChartContentView(frame: containerView.bounds)
        drawersContentView.backgroundColor = UIColor.clearColor()
        containerView.addSubview(drawersContentView)
        
        let contentView = ChartContentView(frame: containerView.bounds)
        contentView.backgroundColor = UIColor.blueColor().colorWithAlphaComponent(0.3)
        containerView.addSubview(contentView)
        
        
        containerView.clipsToBounds = false
        view.addSubview(containerView)

        self.contentView = contentView
        self.drawersContentView = drawersContentView
        self.containerView = containerView
        
        transform.chart = self
        
        contentView.chart = self
        drawersContentView.chart = self

        
        print("CHART INIT - will update anchor")
        
        updateContentAnchor()
        
        
        if let settings = settings {
            self.view.configure(settings)
        }
        
        self.view.chart = self
        
        print("CHART INIT - calling layers chartInitialized")

        
        for layer in self.layers {
            layer.chartInitialized(chart: self)
        }

        self.view.setNeedsDisplay()
        

    }
    
    
    func updateContentAnchor() {
        print("update anchor")
        
        func changeAnchor(view: UIView, newAnchor: CGPoint) {

            
            let oldAnchor = view.layer.anchorPoint
//            let offsetAnchor = CGPoint(x: newAnchor.x - view.layer.anchorPoint.x, y: newAnchor.y - view.layer.anchorPoint.y)
            let offsetAnchor = CGPoint(x: newAnchor.x - view.layer.anchorPoint.x, y: newAnchor.y - view.layer.anchorPoint.y)
            let offset = CGPoint(x: view.frame.width * offsetAnchor.x, y: view.frame.height * offsetAnchor.y)
//            let offset = CGPoint(x: view.frame.width * view.transform.a * offsetAnchor.x, y: view.frame.height * view.transform.d * offsetAnchor.y)
            view.layer.anchorPoint = newAnchor
            
            view.transform = CGAffineTransformTranslate(view.transform, offset.x, offset.y) // TODO remove this?
            
            anchorTranslation = CGPointMake(anchorTranslation.x + offset.x, anchorTranslation.y + offset.y)
 
            
            
            print("changeAnchor() newAnchor: \(newAnchor), offsetAnchor: \(offsetAnchor), offset: \(offset), content view transform is now: \(contentView.transform), contentView frame: \(contentView.frame), containerView frame: \(containerView.frame)-- oldAnchor: x: \(oldAnchor.x), y: \(oldAnchor.y)")
        }
        
     
        
        
//        let origin = CGPointZero
//        let p1x = origin.x - containerView.frame.origin.x
//            - contentView.frame.origin.x
//        let p1y = origin.y - containerView.frame.origin.y
//            - contentView.frame.origin.y
//        let originInContentViewCoords = CGPointMake(p1x, p1y)
////        let originInContentViewCoords = CGPointMake(p1x / contentView.transform.a, p1y / contentView.transform.d)
//        

////        let originInContentViewCoords = CGPointMake(p.x * contentView.transform.a, p.y * contentView.transform.d)
////        let newAnchor = CGPoint(x: originInContentViewCoords.x / containerView.frame.width, y: originInContentViewCoords.y / containerView.frame.height)
////        let newAnchor = CGPoint(x: originInContentViewCoords.x / (contentView.frame.width / contentView.transform.a), y: originInContentViewCoords.y / (contentView.frame.height / contentView.transform.d))
//        
//        var newAnchor = CGPoint(x: originInContentViewCoords.x / contentView.frame.width, y: originInContentViewCoords.y / contentView.frame.height)

        
        
        
        
        
        
        let origin = CGPointZero
        let p1x = origin.x - containerView.frame.origin.x
        let p1y = origin.y - containerView.frame.origin.y
        
        let originInContentViewCoords = CGPointMake(p1x, p1y)
        
        let newAnchor = CGPoint(x: originInContentViewCoords.x / containerView.frame.width, y: originInContentViewCoords.y / containerView.frame.height)
        
        
        
        
        
        
        print("calculated new anchor: \(newAnchor), originIncontentCoords: \(originInContentViewCoords), contentView size: \(contentView.frame.size)")

        
        changeAnchor(contentView, newAnchor: newAnchor)
     

        
    }
    
    
    public required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /**
     Adds a subview to the chart's content view

     - parameter view: The subview to add to the chart's content view
     */
    public func addSubview(view: UIView) {
        self.contentView.addSubview(view)
    }

    /// The frame of the chart's view
    public var frame: CGRect {
        return self.view.frame
    }

    public var containerFrame: CGRect {
        return containerView.frame
    }
    
    public var contentFrame: CGRect {
        return contentView.frame
    }
    
    /// The bounds of the chart's view
    public var bounds: CGRect {
        return self.view.bounds
    }

    /**
     Removes the chart's view from its superview
     */
    public func clearView() {
        self.view.removeFromSuperview()
    }

    public func update() {
        for layer in self.layers {
            layer.update()
        }
        self.view.setNeedsDisplay()
    }
 
    func notifyAxisInnerFrameChange(xLow xLow: ChartAxisLayerWithFrameDelta? = nil, yLow: ChartAxisLayerWithFrameDelta? = nil, xHigh: ChartAxisLayerWithFrameDelta? = nil, yHigh: ChartAxisLayerWithFrameDelta? = nil) {
        for layer in layers {
            layer.handleAxisInnerFrameChange(xLow, yLow: yLow, xHigh: xHigh, yHigh: yHigh)
        }

        handleAxisInnerFrameChange(xLow, yLow: yLow, xHigh: xHigh, yHigh: yHigh)
    }
    
    var frameChangeScalingFactor: CGPoint?
    var xLowDelta: CGFloat? = nil
    var yLowDelta: CGFloat? = nil
    
    private func handleAxisInnerFrameChange(xLow: ChartAxisLayerWithFrameDelta?, yLow: ChartAxisLayerWithFrameDelta?, xHigh: ChartAxisLayerWithFrameDelta?, yHigh: ChartAxisLayerWithFrameDelta?) {
        let previousContentFrame = contentView.frame
        
        print("inner change")
        
        
        xLowDelta = yLow?.delta
        yLowDelta = yLow?.delta
        
//        print("handleAxisInnerFrameChange(), xLow delta: \(xLow?.delta), yLow delta: \(yLow?.delta), current container view frame: \(containerView.frame)")
        
        // Resize container view
        containerView.frame = ChartUtils.insetBy(containerView.frame, dx: yLow.deltaDefault0, dy: xHigh.deltaDefault0, dw: yHigh.deltaDefault0, dh: xLow.deltaDefault0)
        // Change dimensions of content view by total delta of container view
        contentView.frame = CGRectMake(contentView.frame.origin.x, contentView.frame.origin.y, contentView.frame.width - (yLow.deltaDefault0 + yHigh.deltaDefault0), contentView.frame.height - (xLow.deltaDefault0 + xHigh.deltaDefault0))

        print("container view frame after resize: \(containerView.frame)")
        
        
        // Scale contents of content view
        let widthChangeFactor = contentView.frame.width / previousContentFrame.width
        let heightChangeFactor = contentView.frame.height / previousContentFrame.height
        frameChangeScalingFactor = CGPointMake((frameChangeScalingFactor?.x ?? 1) * widthChangeFactor, (frameChangeScalingFactor?.y ?? 1) * heightChangeFactor)
        
        let frameBeforeScale = contentView.frame
//        print("start init")
        applyTransformToContentView(transform)
//        print("end init")
//        contentView.transform = CGAffineTransformMakeScale(contentView.transform.a * widthChangeFactor, contentView.transform.d * heightChangeFactor)
        contentView.frame = frameBeforeScale
        
        
        
        // Since resizing the container view changes its position (and thus also the position of the content view) relative to the chart view's origin, and we use the chart view's origin as anchor point, we have to update the anchor point.
        updateContentAnchor()

        
        
        
        applyTransformToContentView(transform)
        
    }

    
    public func zoom(deltaX deltaX: CGFloat, deltaY: CGFloat, centerX: CGFloat, centerY: CGFloat) {
        print("zoom")
        
        
        let centerTest = CGPointApplyAffineTransform(CGPointMake(centerX, centerY), CGAffineTransformInvert(transform.transform))
        
        transform.zoom(deltaX: deltaX, deltaY: deltaY, centerX: centerTest.x, centerY: centerTest.y)
        
        print("ZOOM content view, current anchor: \(contentView.layer.anchorPoint), contentView frame: \(contentView.frame), container frame: \(containerView.frame), transform: \(transform.transform)")
        
        updateTransforms()
        
        print("ZOOM content view after update transforms, current anchor: \(contentView.layer.anchorPoint), contentView frame: \(contentView.frame), container frame: \(containerView.frame), transform: \(transform.transform)")

    }
    
    public func pan(deltaX deltaX: CGFloat, deltaY: CGFloat, isGesture: Bool, isDeceleration: Bool) {
        transform.pan(deltaX: deltaX, deltaY: deltaY)
        updateTransforms()
    }

    private func incrementZoom(x x: CGFloat, y: CGFloat, centerX: CGFloat, centerY: CGFloat) {
        transform.incrementZoom(x: x, y: y, centerX: centerX, centerY: centerY)
        updateTransforms()
    }
    
    
    var debugLastAnchor: CGPoint?
    
    private func updateTransforms() {
        print("update transforms")
      
        applyTransformToContentView(transform)
        
        for layer in layers {
            layer.onTransformUpdate(transform)
        }
        
        let origin = CGPointZero
        let p1x = origin.x - containerView.frame.origin.x - contentView.frame.origin.x
        let p1y = origin.y - containerView.frame.origin.y - contentView.frame.origin.y
//        let p = CGPointMake(p1x, p1y)

        
        
//        print("after update trans, contentview frame: \(contentView.frame), container frame: \(containerView.frame), zero: \(p)")
        
    }
    
    
    
    
    private func applyTransformToContentView(transform: ChartTransform) {
        print("apply transform to content")

//        let oldTransform = contentView.transform // for logging
        
        let m = CGAffineTransformMake(1, 0, 0, 1, anchorTranslation.x, anchorTranslation.y)

        contentView.transform = CGAffineTransformConcat(transform.transform, m)
        contentView.transform = CGAffineTransformScale(contentView.transform, frameChangeScalingFactor?.x ?? 1, frameChangeScalingFactor?.y ?? 1)
        
//        print("applyTransformToContentView(): content transform before: \(oldTransform), after: \(contentView.transform), global transform: \(transform.transform), frameChangeScalingFactor: \(frameChangeScalingFactor)")

    }

    /**
     Draws the chart's layers in the chart view

     - parameter rect: The rect that needs to be drawn
     */
    private func drawRect(rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        for layer in self.layers {
            layer.chartViewDrawing(context: context!, chart: self)
        }
    }
    
    private func drawContentViewRect(rect: CGRect, sender: ChartContentView) {
        let context = UIGraphicsGetCurrentContext()
        if sender == drawersContentView {
            for layer in layers {
                layer.chartDrawersContentViewDrawing(context: context!, chart: self, view: sender)
            }
        } else if sender == contentView {
            for layer in layers {
                layer.chartContentViewDrawing(context: context!, chart: self)
            }
            self.drawersContentView.setNeedsDisplay()
        }
    }
}


public class ChartContentView: UIView {
    
    weak var chart: Chart?
    
    override public func drawRect(rect: CGRect) {
        self.chart?.drawContentViewRect(rect, sender: self)
    }
}

/// A UIView subclass for drawing charts
public class ChartBaseView: ChartView {
    
    override public func drawRect(rect: CGRect) {
        self.chart?.drawRect(rect)
    }
}

public class ChartView: UIView, UIGestureRecognizerDelegate {
    
    /// The chart that will be drawn in this view
    weak var chart: Chart?
    
    private var lastPanTranslation: CGPoint?
    
    private var pinchRecognizer: UIPinchGestureRecognizer?
    private var panRecognizer: UIPanGestureRecognizer?
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        self.sharedInit()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.sharedInit()
    }
   
    func configure(settings: ChartSettings) {
        if settings.zoomEnabled {
            let pinchRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(ChartView.onPinch(_:)))
            pinchRecognizer.delegate = self
            addGestureRecognizer(pinchRecognizer)
            self.pinchRecognizer = pinchRecognizer
        }
        
        if settings.panEnabled {
            let panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(ChartView.onPan(_:)))
            panRecognizer.delegate = self
            addGestureRecognizer(panRecognizer)
            self.panRecognizer = panRecognizer
        }
    }
    
    /**
     Initialization code shared between all initializers
     */
    func sharedInit() {
        self.backgroundColor = UIColor.clearColor()
    }
    
    private var currentPinchCenter: CGPoint? // testing fixed pinch center (during gesture)

    
    @objc func onPinch(sender: UIPinchGestureRecognizer) {
        
        guard sender.numberOfTouches() > 1 else {return}
        guard let chart = chart else {return}
        
        
        
        switch sender.state {
        case .Began:
            let center = sender.locationInView(self)
            currentPinchCenter = center
        default: break
        }
        
        let center = currentPinchCenter ?? sender.locationInView(self)
        
        let x = abs(sender.locationInView(self).x - sender.locationOfTouch(1, inView: self).x)
        let y = abs(sender.locationInView(self).y - sender.locationOfTouch(1, inView: self).y)
        
        // calculate scale x and scale y
        let (absMax, absMin) = x > y ? (abs(x), abs(y)) : (abs(y), abs(x))
        let minScale = (absMin * (sender.scale - 1) / absMax) + 1
        let (deltaX, deltaY) = x > y ? (sender.scale, minScale) : (minScale, sender.scale)
        
        chart.zoom(deltaX: deltaX, deltaY: deltaY, centerX: center.x, centerY: center.y)

        sender.scale = 1.0
    }
    
    @objc func onPan(sender: UIPanGestureRecognizer) {
        
        switch sender.state {
            
        case .Began:
            lastPanTranslation = nil
            
        case .Changed:
            
            let trans = sender.translationInView(self)
            
            let deltaX = lastPanTranslation.map{trans.x - $0.x} ?? trans.x
            let deltaY = lastPanTranslation.map{trans.y - $0.y} ?? trans.y
            
            lastPanTranslation = trans
            
            chart?.pan(deltaX: deltaX, deltaY: deltaY, isGesture: true, isDeceleration: false)
            
        case .Ended:
//            break
            guard let view = sender.view else {print("Recogniser has no view"); return}
            
            let velocityX = sender.velocityInView(sender.view).x
            let velocityY = sender.velocityInView(sender.view).y
            
            func next(index: Int, velocityX: CGFloat, velocityY: CGFloat) {
                dispatch_async(dispatch_get_main_queue()) {
                    
                    self.chart?.pan(deltaX: velocityX, deltaY: velocityY, isGesture: true, isDeceleration: true)
                    
                    if abs(velocityX) > 0.1 || abs(velocityY) > 0.1 {
                        let friction: CGFloat = 0.9
                        next(index + 1, velocityX: velocityX * friction, velocityY: velocityY * friction)
                    }
                }
            }
            let initFriction: CGFloat = 50
            next(0, velocityX: velocityX / initFriction, velocityY: velocityY / initFriction)
            
        case .Cancelled: break;
        case .Failed: break;
        case .Possible: break;
        }
    }
}
