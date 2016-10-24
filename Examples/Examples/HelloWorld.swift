//
//  HelloWorld.swift
//  SwiftCharts
//
//  Created by ischuetz on 05/05/15.
//  Copyright (c) 2015 ivanschuetz. All rights reserved.
//

import UIKit
import SwiftCharts

class HelloWorld: UIViewController {

    private var chart: Chart? // arc

    override func viewDidLoad() {
        super.viewDidLoad()

        // map model data to chart points
        let chartPoints: [ChartPoint] = [(2, 2), (4, 4), (6, 6), (8, 8), (8, 10), (15, 15)].map{ChartPoint(x: ChartAxisValueInt($0.0), y: ChartAxisValueInt($0.1))}
        
        let labelSettings = ChartLabelSettings(font: ExamplesDefaults.labelFont)
        
        let generator = ChartAxisGeneratorMultiplier(2)
        let labelsGenerator = ChartAxisLabelsGeneratorFunc {scalar in
//            return ChartAxisLabel(text: "", settings: labelSettings)
//            let str = scalar >= 10 ? "very long number!!!!" : "\(scalar)"
//            return ChartAxisLabel(text: "very long number!!!!!!!!!!!!!!!!!!!", settings: labelSettings)
            return ChartAxisLabel(text: scalar >= 10 ? "very long number!!!!!!!!!!!!!!!!!!!" : "\(scalar)", settings: labelSettings)
        }
        
        let xLabelsGenerator = ChartAxisLabelsGeneratorFunc {scalar in
            //            return ChartAxisLabel(text: "", settings: labelSettings)
            return ChartAxisLabel(text: "", settings: labelSettings)
        }
        
        let xGenerator = ChartAxisGeneratorMultiplier(2)
        
        let xModel = ChartAxisModel(firstModelValue: 0, lastModelValue: 16, axisTitleLabels: [ChartAxisLabel(text: "Axis title", settings: labelSettings)], axisValuesGenerator: xGenerator, labelsGenerator: xLabelsGenerator)
        
        let yModel = ChartAxisModel(firstModelValue: 0, lastModelValue: 16, axisTitleLabels: [ChartAxisLabel(text: "Axis title", settings: labelSettings.defaultVertical())], axisValuesGenerator: generator, labelsGenerator: labelsGenerator)
        
        let chartFrame = ExamplesDefaults.chartFrame(self.view.bounds)
        
        let chartSettings = ExamplesDefaults.chartSettingsWithPanZoom
        
        // generate axes layers and calculate chart inner frame, based on the axis models
        let coordsSpace = ChartCoordsSpaceLeftBottomSingleAxis(chartSettings: chartSettings, chartFrame: chartFrame, xModel: xModel, yModel: yModel)
        let (xAxisLayer, yAxisLayer, innerFrame) = (coordsSpace.xAxisLayer, coordsSpace.yAxisLayer, coordsSpace.chartInnerFrame)
        
        // create layer with guidelines
        let guidelinesLayerSettings = ChartGuideLinesDottedLayerSettings(linesColor: UIColor.blackColor(), linesWidth: ExamplesDefaults.guidelinesWidth)
        let guidelinesLayer = ChartGuideLinesDottedLayer(xAxisLayer: xAxisLayer, yAxisLayer: yAxisLayer, settings: guidelinesLayerSettings)
        
        // view generator - this is a function that creates a view for each chartpoint
        let viewGenerator = {(chartPointModel: ChartPointLayerModel, layer: ChartPointsViewsLayer, chart: Chart, isTransform: Bool) -> UIView? in
            let viewSize: CGFloat = Env.iPad ? 30 : 20
            let center = chartPointModel.screenLoc
            let view = UIView(frame: CGRectMake(center.x - viewSize / 2, center.y - viewSize / 2, viewSize, viewSize))
            
            view.backgroundColor = chartPointModel.index == 0 ? UIColor.greenColor() : chartPointModel.index == 3 ? UIColor.redColor() : UIColor.cyanColor()
            let dot = UIView(frame: CGRectMake(view.bounds.midX - 1, view.bounds.midY - 1, 2, 2))
            dot.backgroundColor = UIColor.blueColor()
            view.addSubview(dot)
            return view
        }
        
        // create layer that uses viewGenerator to display chartpoints
        let chartPointsLayer = ChartPointsViewsLayer(xAxis: xAxisLayer.axis, yAxis: yAxisLayer.axis, chartPoints: chartPoints, viewGenerator: viewGenerator)
        
        // create chart instance with frame and layers
        let chart = Chart(
            frame: chartFrame,
            innerFrame: innerFrame,
            settings: chartSettings,
            layers: [
                xAxisLayer,
                yAxisLayer,
                guidelinesLayer,
                chartPointsLayer
            ]
        )
        
        self.view.addSubview(chart.view)
        self.chart = chart
        
        let line = UIView(frame: CGRectMake(20, 0, 1, 1000))
        line.backgroundColor = UIColor.redColor()
        view.addSubview(line)

        let line2 = UIView(frame: CGRectMake(40, 0, 1, 1000))
        line2.backgroundColor = UIColor.redColor()
        view.addSubview(line2)
        
        
        let line3 = UIView(frame: CGRectMake(60, 0, 1, 1000))
        line3.backgroundColor = UIColor.redColor()
        view.addSubview(line3)
        
//        chart.zoom(deltaX: 0, deltaY: 2, centerX: 0, centerY: chart.view.frame.height)
//
//        let x = xAxisLayer.axis.screenLocForScalar(2)
//        let y = yAxisLayer.axis.screenLocForScalar(2)
//        
//        
//        let dx: CGFloat = 2
//        let dy: CGFloat = 2
//        
//        let x2a = xAxisLayer.axis.screenLocForScalar(8)
//        let y2a = yAxisLayer.axis.screenLocForScalar(8)
//        print("x2a: \(x2a), y2a: \(y2a)")
//        
////        chart.zoom(deltaX: dx * dx, deltaY: dy * dy, centerX: x, centerY: y)
//        chart.zoom(deltaX: dx, deltaY: dy, centerX: x, centerY: y)
//        
//        
//        let x2 = xAxisLayer.axis.screenLocForScalar(8)
//        let y2 = yAxisLayer.axis.screenLocForScalar(8)
//        print("x2: \(x2), y2: \(y2)")
//        chart.zoom(deltaX: 1, deltaY: 1.4, centerX: x2, centerY: y2)
//        
//        chart.zoom(deltaX: dx, deltaY: dy, centerX: x, centerY: y)
//        chart.zoom(deltaX: dx, deltaY: dy, centerX: x, centerY: y)
//        chart.zoom(deltaX: dx, deltaY: dy, centerX: x, centerY: y)
    }
}
