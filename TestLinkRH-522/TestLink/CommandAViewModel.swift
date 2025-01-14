//
//  SummaryViewModel.swift
//  TestLink
//
//

import UIKit

class CommandAViewModel: NSObject {
    
    var imgbettery = ""
    var peripheralName = ""
    
    //6nd BYTE:
    //  0->K type
    //  1->J type
    //  2->E type
    //  3->T type
    //  4->N type
    //  5->R type
    //  6->S type
    
    var DeviceType = ""
    
    var isCels = ""
    var isFeh = ""
    var isKel = ""
    
    var cOrFOrK = ""
    
    //var cOrF = ""
    
    var deviceMaxValueRange:Float = 2500
    var deviceMinValueRange:Float = -200
    
    var isRHConnected:Bool = true
    var isT1Connected:Bool = true
    var isT2Connected:Bool = true
    
    var isChangeTemp : Bool = false
    
    var isWetBulb:Bool = false
    var isDewPoint:Bool = false
    var isNormal:Bool = false
    
    private var _RHtemperature : String = "--"
    var RHtemperature : String{
        set {
            let i = Double(newValue)
            if i == nil
            {
                self._RHtemperature = "--"
            }
            else
            {
                
                if !self.isRHConnected {
                    self._RHtemperature = "--"
                }
                else if i! > Double(MaxTempValue) {
                    self._RHtemperature = "OL"
                }
                else if i! < Double(MinTempValue) {
                    self._RHtemperature = "-OL"
                }
                else {
                    self._RHtemperature = newValue
                }
            }
        }
        get
        {
            return self._RHtemperature
        }
    }
    
    private var _temperatureT1 : String = "--"
    var temperatureT1 : String{
        set {
            
            var newT1 = newValue
            if cOrFOrK == "F" {
                newT1 = String(format: "%.1f",(Float(newValue)! * 1.8) + 32)
            }else if cOrFOrK == "K" {
                newT1 = String(format: "%.1f",(Float(newValue)! + 273.15))
            }
            
            var i = Double(newT1)
            if i == nil
            {
                self._temperatureT1 = "--"
            }
            else
            {
                
//                if !self.isT1Connected {
//                    self._temperatureT1 = "--"
//                }
//                else if i! > Double(MaxTempValue) {
//                    self._temperatureT1 = "OL"
//                }
//                else if i! < Double(MinTempValue) {
//                    self._temperatureT1 = "-OL"
//                }
//                else {
//                    self._temperatureT1 = newValue
//                }
                
                if !self.isT1Connected {
                    self._temperatureT1 = "--"
                }
                else if i! > Double(MainCenteralManager.sharedInstance().getMaxValue(temperatureType: cOrFOrK, deviceType: DeviceType)) {
                    self._temperatureT1 = "OL"
                }
                else if i! > Double(MainCenteralManager.sharedInstance().getMaxValue(temperatureType: cOrFOrK, deviceType: DeviceType)) {
                    self._temperatureT1 = "-OL"
                }
                else {
                    self._temperatureT1 = newValue
                }
            }
        }
        get
        {
            return self._temperatureT1
        }
    }
    
    private var _temperatureT2 : String = "--"
    var temperatureT2 : String{
        set {
            
            var newT2 = newValue
            if cOrFOrK == "C" {
                newT2 = String(format: "%.1f", (Float(newValue)! - 32) / 1.8)
            }else if cOrFOrK == "K" {
                newT2 = String(format:"%.1f",(Float(newValue)! + 459.67) * (5/9))
            }

            let i = Double(newT2)
            if i == nil
            {
                self._temperatureT2 = "--"
            }
            else
            {
                
//                if !self.isT2Connected {
//                    self._temperatureT2 = "--"
//                }
//                else if i! > Double(MaxTempValue) {
//                    self._temperatureT2 = "OL"
//                }
//                else if i! < Double(MinTempValue) {
//                    self._temperatureT2 = "-OL"
//                }
//                else {
//                    self._temperatureT2 = newValue
//                }
                
                if !self.isT2Connected {
                    self._temperatureT2 = "--"
                }
                else if i! > Double(MainCenteralManager.sharedInstance().getMaxValue(temperatureType: cOrFOrK, deviceType: DeviceType)) {
                    self._temperatureT2 = "OL"
                }
                else if i! > Double(MainCenteralManager.sharedInstance().getMaxValue(temperatureType: cOrFOrK, deviceType: DeviceType)) {
                    self._temperatureT2 = "-OL"
                }
                else {
                    self._temperatureT2 = newValue
                }
            }
        }
        get
        {
            return self._temperatureT2
        }
    }
}

