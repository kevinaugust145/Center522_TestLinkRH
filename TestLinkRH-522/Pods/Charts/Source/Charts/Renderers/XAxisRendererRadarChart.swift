//
//  XAxisRendererRadarChart.swift
//  Charts
//
//  Copyright 2015 Daniel Cohen Gindi & Philipp Jahoda
//  A port of MPAndroidChart for iOS
//  Licensed under Apache License 2.0
//
//  https://github.com/danielgindi/Charts
//

import Foundation
import CoreGraphics

#if !os(OSX)
    import UIKit
#endif

open class XAxisRendererRadarChart: XAxisRenderer
{
    open weak var chart: RadarChartView?
    
    public init(viewPortHandler: ViewPortHandler?, xAxis: XAxis?, chart: RadarChartView?)
    {
        super.init(viewPortHandler: viewPortHandler, xAxis: xAxis, transformer: nil)
        
        self.chart = chart
    }
    
    open override func renderAxisLabels(context: CGContext)
    {
        guard let
            xAxis = axis as? XAxis,
            let chart = chart
            else { return }
        
        if !xAxis.isEnabled || !xAxis.isDrawLabelsEnabled
        {
            return
        }
        
        let labelFont = xAxis.labelFont
        let labelTextColor = xAxis.labelTextColor
        let labelRotationAngleRadians = xAxis.labelRotationAngle * ChartUtils.Math.FDEG2RAD
        let drawLabelAnchor = CGPoint(x: 0.5, y: 0.25)
        
        let sliceangle = chart.sliceAngle
        
        // calculate the factor that is needed for transforming the value to pixels
        let factor = chart.factor
        
        let center = chart.centerOffsets
        
        for i in stride(from: 0, to: chart.data?.maxEntryCountSet?.entryCount ?? 0, by: 1)
        {
            
            let label = xAxis.valueFormatter?.stringForValue(Double(i), axis: xAxis) ?? ""
            
            let angle = (sliceangle * CGFloat(i) + chart.rotationAngle).truncatingRemainder(dividingBy: 360.0)
            
            let p = ChartUtils.getPosition(center: center, dist: CGFloat(chart.yRange) * factor + xAxis.labelRotatedWidth / 2.0, angle: angle)
            
            drawLabel(context: context,
                      formattedLabel: label,
                      x: p.x,
                      y: p.y - xAxis.labelRotatedHeight / 2.0,
                      attributes: [NSAttributedStringKey.font: labelFont, NSAttributedStringKey.foregroundColor: labelTextColor],
                      anchor: drawLabelAnchor,
                      angleRadians: labelRotationAngleRadians)
        }
    }
    
    open func drawLabel(
        context: CGContext,
        formattedLabel: String,
        x: CGFloat,
        y: CGFloat,
        attributes: [NSAttributedStringKey: Any],
        anchor: CGPoint,
        angleRadians: CGFloat)
    {
        ChartUtils.drawText(
            context: context,
            text: formattedLabel,
            point: CGPoint(x: x, y: y),
            attributes: attributes,
            anchor: anchor,
            angleRadians: angleRadians)
    }
    
    open override func renderLimitLines(context: CGContext)
    {
        /// XAxis LimitLines on RadarChart not yet supported.
    }
}
