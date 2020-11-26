//
//  AdvertisingService.swift
//  BLE test
//
//  Created by Lampa on 25.11.2020.
//

import UIKit
import CoreBluetooth


class AdvertisingService: NSObject {
    var deviceId = UIDevice.current.identifierForVendor!.uuidString
    
    let serviceId = CBUUID(string: "28B282ED-AAAA-4582-9224-9E0E93174079")
    let fakeServiceId = CBUUID(string: "11111111-1111-2222-2222-333333333333")
    let charId = CBUUID(string: "B1428E10-BBBB-4D5E-BB39-9136E124CA10")
    
    let properties: CBCharacteristicProperties = [.read, .notify, .writeWithoutResponse, .write]
    let permissions: CBAttributePermissions = [.readable, .writeable]
    
    var characteristic: CBMutableCharacteristic!
    var peripheralManager: CBPeripheralManager!
    var service: CBMutableService!
    
    static var canAdvertise = true
    var didUpdateStateCalled = false
    weak var delegate: ViewControllerProtocol?
    
    
    override init() {
        super.init()
        
        self.characteristic = CBMutableCharacteristic(type: charId, properties: self.properties, value: nil, permissions: self.permissions)
        
        peripheralManager = CBPeripheralManager(delegate: self, queue: .none, options: nil)
        service = CBMutableService(type: AdvertisingService.canAdvertise ? serviceId : fakeServiceId, primary: true)
//        service.characteristics = [self.characteristic]
    }
    
    deinit {
        
        if AdvertisingService.canAdvertise == false {
            if peripheralManager.isAdvertising {
                peripheralManager.stopAdvertising()
                delegate?.addItem(item: "stopAdvertising")
            }
            peripheralManager.removeAllServices()
            delegate?.addItem(item: "removeAllServices")
        }
    }
    
    private func advertise(advertisingData: [String: Any]) {
        print(advertisingData)
        delegate?.addItem(item: "\(advertisingData)")
        
        peripheralManager.stopAdvertising()
        delegate?.addItem(item: "stopAdvertising")
        self.peripheralManager?.startAdvertising(advertisingData)
        delegate?.addItem(item: "startAdvertising(advertisingData)")
        
        if AdvertisingService.canAdvertise == false {
            delegate?.removeAdvertisingAfter()
        }
    }
    
    func stopAdvertise() {
        guard didUpdateStateCalled else { return }
        
        service = CBMutableService(type: AdvertisingService.canAdvertise ? serviceId : fakeServiceId, primary: true)
//        service.characteristics = [self.characteristic]
        
        if let service: CBMutableService = self.service {
            
            self.peripheralManager?.removeAllServices()
            delegate?.addItem(item: "removeAllServices)")
            self.peripheralManager?.add(service)
            delegate?.addItem(item: "add(service)")
            
        }
    }
}

extension AdvertisingService: CBPeripheralManagerDelegate {
    
    func peripheralManagerDidStartAdvertising(_ peripheral: CBPeripheralManager, error: Error?) {
        
        delegate?.addItem(item: "peripheralManagerDidStartAdvertising")
        
        if let error = error {
            delegate?.addItem(item: "\(error.localizedDescription)")
            print("Advertising ERROR: \(error.localizedDescription)")
        }
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, didAdd service: CBService, error: Error?) {
        
        print("\ndidAdd service")
        
        let advertisingData: [String: Any] = [
            CBAdvertisementDataServiceUUIDsKey: [self.service?.uuid],
            CBAdvertisementDataLocalNameKey: AdvertisingService.canAdvertise ? "BLE Vlad" : "iPhone"
        ]
        
        self.advertise(advertisingData: advertisingData)
        
    }
    
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        
        switch peripheral.state {
            
        case .poweredOn:
            delegate?.addItem(item: "poweredOn")
            didUpdateStateCalled = true
            
            if let service: CBMutableService = self.service {
                
                self.peripheralManager?.removeAllServices()
                delegate?.addItem(item: "removeAllServices")
                self.peripheralManager?.add(service)
                delegate?.addItem(item: "add(service)")
            }
         break
            
        default: break
        }
    }
}
