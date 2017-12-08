//
//  CommandPViewModel.swift
//  TestLink
//
//

import UIKit

class CommandPViewModel : NSObject {
    var totalBytes = 0
    var totalBytesReceived = 0
    var myDownloadedData : NSMutableArray = NSMutableArray()
    var myFinalDataArray:NSMutableArray = NSMutableArray()
    var isFinish = false
}
