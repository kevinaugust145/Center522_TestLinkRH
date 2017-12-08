//
//  BTServiceInfo.swift
//  BtSample
//
//  Created by Yu chengJhuo on 1/11/17.
//  Copyright © 2017 Yu-cheng Jhuo. All rights reserved.
//

import CoreBluetooth

class BTServiceInfo {

    var service: CBService!
    var characteristics: [CBCharacteristic]
    init(service: CBService, characteristics: [CBCharacteristic]) {
        self.service = service
        self.characteristics = characteristics
    }
}
