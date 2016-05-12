//
//  BLEHelper.swift
//  BLEHelper
//
//  Created by Microduino on 11/4/15.
//  Copyright © 2015 Microduino. All rights reserved.
//

import Foundation
import CoreBluetooth
class BLEMingle: NSObject, CBPeripheralManagerDelegate, CBCentralManagerDelegate, CBPeripheralDelegate {


    var peripheralManager: CBPeripheralManager!
    var centralManager: CBCentralManager!
    var peripheral: CBPeripheral!
    var writeCharacteristic: CBCharacteristic!
    var delegate: BLECentralDelegate?
    var dataToSend: NSData!
    //服务和特征的UUID
    let kServiceUUID = [CBUUID(string:"FFF0")]
    let kCharacteristicUUID = [CBUUID(string:"FFF6")]

    override init() {
        super.init()
        peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
        centralManager = CBCentralManager(delegate: self, queue: nil)
        print("初始化蓝牙成功")
    }


    func startScan() {
        centralManager.scanForPeripheralsWithServices(nil, options:[CBCentralManagerScanOptionAllowDuplicatesKey: false])
        print("开始搜索蓝牙设备")
    }
    
    func didDiscoverPeripheral(peripheral: CBPeripheral!) -> CBPeripheral! {
      
        return nil
    }
    func stopScan() {
        centralManager.stopScan()
        print("停止搜索")
    }
     //2.检查运行这个App的设备是不是支持BLE。代理方法
    func centralManagerDidUpdateState(central: CBCentralManager) {
        switch central.state {
        case CBCentralManagerState.PoweredOn:
            print("蓝牙已打开,请扫描外设")
        case CBCentralManagerState.Unauthorized:
            print("这个应用程序是无权使用蓝牙低功耗")
        case CBCentralManagerState.PoweredOff:
            print("蓝牙目前已关闭")
        default:
            print("中央管理器没有改变状态")
        }

    }
    //3.查到外设后，停止扫描，连接设备
    //广播、扫描的响应数据保存在advertisementData 中，可以通过CBAdvertisementData 来访问它。
    func centralManager(central: CBCentralManager, didDiscoverPeripheral peripheral: CBPeripheral, advertisementData: [String : AnyObject], RSSI: NSNumber){
       
        delegate?.didDiscoverPeripheral(peripheral)

    }
     //连接外设失败
    func centralManager(central: CBCentralManager, didFailToConnectPeripheral peripheral: CBPeripheral, error: NSError?) {
        
    }
      //4.连接外设成功，开始发现服务
    func centralManager(central: CBCentralManager, didConnectPeripheral peripheral: CBPeripheral) {
        print("连接到设备: \(peripheral)")
        //停止扫描外设
        self.centralManager.stopScan()
        self.peripheral = peripheral
        self.peripheral.delegate = self
        self.peripheral.discoverServices(nil)
     
    }
    //5.请求周边去寻找它的服务所列出的特征
    func peripheral(peripheral: CBPeripheral, didDiscoverServices error: NSError?){
        if error != nil {
            print("错误的服务特征:\(error!.localizedDescription)")
            return
        }
        var i: Int = 0
        for service in peripheral.services! {
            print("服务的UUID:\(service.UUID)")
            i += 1
            //发现给定格式的服务的特性
            if (service.UUID == CBUUID(string:"FFF0")) {
                peripheral.discoverCharacteristics(kCharacteristicUUID, forService: service as CBService)
            }
            peripheral.discoverCharacteristics(nil, forService: service as CBService)
        }
    }
    //6.已搜索到Characteristics
    func peripheral(peripheral: CBPeripheral, didDiscoverCharacteristicsForService service: CBService, error: NSError?) {
        print("发现特征的服务:\(service.UUID.data)   ==  服务UUID:\(service.UUID)")
        if (error != nil){
            print("发现错误的特征：\(error!.localizedDescription)")
            return
        }
        
        for  characteristic in service.characteristics!  {
            //罗列出所有特性，看哪些是notify方式的，哪些是read方式的，哪些是可写入的。
            print("服务UUID:\(service.UUID)         特征UUID:\(characteristic.UUID)")
            //特征的值被更新，用setNotifyValue:forCharacteristic
            switch characteristic.UUID.description {
            case "FFF6":
                self.peripheral.readValueForCharacteristic(characteristic as CBCharacteristic)
                self.writeCharacteristic = characteristic 
                
            default:
                break
            }
        }

        print("didDiscoverCharacteristicsForService: \(service)")

    }
    
    func peripheral(peripheral: CBPeripheral, didUpdateValueForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
        if error != nil {
            return
        }

    }
    
    func peripheral(peripheral: CBPeripheral, didUpdateNotificationStateForCharacteristic characteristic: CBCharacteristic, error: NSError?) {

    }
    
    func centralManager(central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: NSError?) {

    }
    
    func peripheralManagerDidUpdateState(peripheral: CBPeripheralManager) {
        
        
    }
    
    func peripheralManager(peripheral: CBPeripheralManager, central: CBCentral, didSubscribeToCharacteristic characteristic: CBCharacteristic) {
        
        print("Central subscribed to characteristic: \(characteristic)")
    }
    
    func peripheralManager(peripheral: CBPeripheralManager, central: CBCentral, didUnsubscribeFromCharacteristic characteristic: CBCharacteristic) {
        
        print("Central unsubscribed from characteristic")
    }
    
    class var sharedInstance: BLEMingle {
        struct Static {
            static let instance: BLEMingle = BLEMingle()
        }
        return Static.instance
    }
    
    func writeValue(data: NSData!){
        peripheral.writeValue(data, forCharacteristic: self.writeCharacteristic,type: CBCharacteristicWriteType.WithoutResponse)
           print("手机向蓝牙发送的数据为:\(data)")
        
    }
    
    func connectPeripheral(peripheral: CBPeripheral){
    
        centralManager.connectPeripheral(peripheral, options: nil);
        
    }


}