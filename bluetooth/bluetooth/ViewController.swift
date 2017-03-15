//
//  ViewController.swift
//  bluetooth
//
//  Created by 张江东 on 17/3/15.
//  Copyright © 2017年 58kuaipai. All rights reserved.

//注意:  如果你不知道外设UUID 用 lightBlue 这个app查看

import UIKit
import CoreBluetooth

//服务
let service1  = "00A9B803-EF34-4311-8EFE-F3D25901878E"

//let service2  = "6E400001-B5A3-F393-E0A9-E50E24DCCA9E"
//读
let service3  = "6E400002-B5A3-F393-E0A9-E50E24DCCA9E"
//写
let service4  = "6E400003-B5A3-F393-E0A9-E50E24DCCA9E"

class ViewController: UIViewController,CBCentralManagerDelegate,CBPeripheralDelegate {
    
    //中心设备
    lazy var magager: CBCentralManager = CBCentralManager()
    //外设列表
    var connectPeripheral : CBPeripheral?
//    lazy var  peripherals : NSMutableArray = NSMutableArray()

    override func viewDidLoad() {
        super.viewDidLoad()
        magager.delegate = self
    }


    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        
        if (central.state == .poweredOn){
            print("打开蓝牙了")
            //必须状态ok后才可以扫描 要不不执行代理方法
            magager.scanForPeripherals(withServices: nil, options: nil)
        }
    }
    
    //外设更新名字
    func peripheralDidUpdateName(_ peripheral: CBPeripheral) {
        
    }
    
    //扫码到设备后回调方法
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber)
    {
        print("发现外设")
        print("名字 \(peripheral.name)")
        print("Rssi: \(RSSI)")
        print("外设UUID-->",peripheral.identifier.uuidString,"service-->",peripheral.services)
        
        if  (peripheral.name?.contains("QNix"))! != false
        {
            self.magager.stopScan()
            connectPeripheral = peripheral
            self.magager.connect(peripheral, options: nil)
        }

    }
    
    //外设链接成功
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        connectPeripheral?.delegate = self
        
        var array : [CBUUID]?
        let uuid3 = CBUUID(string: service3)
        let uuid4 = CBUUID(string: service4)
        array?.append(uuid3)
        array?.append(uuid4)
        //发现设备服务
        connectPeripheral?.discoverServices(array)
    }
    
    //连接外设失败
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("连接外设失败")
    }
    
    //发现服务
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        
        print("发现服务UUID-->",peripheral.identifier.uuidString)

        //连接服务
        for service in peripheral.services! {
            connectPeripheral?.discoverCharacteristics(nil, for: service)
        }
    }
    
    //发现特征
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        //弹框
        
        for characteristic in service.characteristics! {
            print("发现特征UUID---> ",String(describing:characteristic.uuid))
            //接受通知
            if characteristic.uuid.uuidString ==  service4 {
                self.connectPeripheral?.setNotifyValue(true, for: characteristic)
            }
        }
        
    }
    
    //接受数据
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        
        let backToString = String(data: characteristic.value!, encoding: String.Encoding.utf8) as String!
        print("backToString",backToString ?? "",characteristic.uuid)
    }
    
    //写数据
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        
    }

}

