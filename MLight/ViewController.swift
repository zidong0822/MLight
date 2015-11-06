//
//  ViewController.swift
//  MLight
//
//  Created by Microduino on 11/4/15.
//  Copyright © 2015 Microduino. All rights reserved.
//

import UIKit
import CoreBluetooth
class ViewController: UIViewController,UITableViewDataSource,UITableViewDelegate,CBCentralManagerDelegate,CBPeripheralDelegate{

    var navgationView:UIView?
    var tableView : UITableView?
    var isScan:Bool = true
    var manager: CBCentralManager!
    var peripheral: CBPeripheral!
    var writeCharacteristic: CBCharacteristic!
    //保存收到的蓝牙设备
    var deviceList:NSMutableArray = NSMutableArray()
    var peripheralList:NSMutableArray = NSMutableArray()
    //服务和特征的UUID
    let kServiceUUID = [CBUUID(string:"FFF0")]
    let kCharacteristicUUID = [CBUUID(string:"FFF6")]
    

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.blackColor()
        self.manager = CBCentralManager(delegate: self, queue: nil)
        initNavgationView();
        initTableView();
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "colorChange:", name: "colorchange", object: nil)
    }

    
    func initNavgationView(){
        
        self.navgationView=UIView(frame: CGRectMake(0,20, self.view.frame.width,44))
        self.navgationView!.backgroundColor=UIColor(red: 50/255, green: 167/255, blue: 152/255, alpha: 1.0)
        self.navgationView!.layer.shadowColor = UIColor.blackColor().CGColor
        self.navgationView!.layer.shadowOffset = CGSizeMake(4,4);//shadowOffset阴影偏移,x向右偏移4，y向下偏移4，默认(0, -3),这个跟shadowRadius配合使用
        self.navgationView!.layer.shadowOpacity = 0.8;//阴影透明度，默认0
        self.navgationView!.layer.shadowRadius = 4;//阴影半径，默认3
        self.view.addSubview(self.navgationView!)
        
        let navgationLabel=UILabel(frame: CGRectMake(55,20, self.view.frame.width-100,44))
        navgationLabel.text = "BLE Device Scan";
        self.view.addSubview(navgationLabel);
        
        let navgationButton=UIButton(frame: CGRectMake(10,25,30,30))
        navgationButton.setImage(UIImage(named:"icon_white"),forState:UIControlState.Normal)
        self.view.addSubview(navgationButton);
        
        
        let scanButton=RNLoadingButton(frame: CGRectMake(self.view.frame.width-90,20,100,44))
        scanButton .setTitle(" stop", forState: UIControlState.Normal)
        scanButton.loading = true
        //scanButton.hideTextWhenLoading = false
        //scanButton.hideImageWhenLoading = true
        scanButton.setActivityIndicatorAlignment(RNLoadingButtonAlignmentLeft);
        scanButton.addTarget(self, action:"scanBlueTooth:", forControlEvents: UIControlEvents.TouchUpInside)
        scanButton.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
        self.view.addSubview(scanButton);
        
        
    }

    //初始化tableview
    func initTableView(){
        // 初始化tableView的数据
        self.tableView=UITableView(frame:CGRectMake(0, 64,self.view.frame.width, self.view.frame.height),style:UITableViewStyle.Plain)
        // 设置tableView的数据源
        self.tableView?.dataSource = self
        // 设置tableView的委托
        self.tableView!.delegate = self
        self.tableView?.tableFooterView = UIView();
        self.tableView!.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        self.view.addSubview(self.tableView!)
    }
    //总行数
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        
        return self.deviceList.count;
    }
    //加载数据
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        
        let cell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "newsCell")
                let  cp = self.deviceList.objectAtIndex(indexPath.row) as!CBPeripheral
        
                let nameLabel = UILabel(frame: CGRectMake(10, 10, 300, 40));
                let  textFont = UIFont(name:"Arial", size: 18)
                nameLabel.font = textFont
                if(cp.name == nil){
                    nameLabel.text = "Unknown Device";
                }
                else{
                    nameLabel.text = cp.name;
                }
                let uuidLabel = UILabel(frame: CGRectMake(10, 50, self.view.frame.width, 30));
                uuidLabel.font = UIFont(name:"Arial", size: 13)
                uuidLabel.text = cp.identifier.UUIDString
        
                let detailbutton = UIButton(frame:CGRectMake(self.view.frame.width-60,20, 60, 40))
                detailbutton.setImage(UIImage(named:"go"),forState:UIControlState.Normal)
        
                cell.contentView.addSubview(nameLabel);
                cell.contentView.addSubview(uuidLabel);
                cell.contentView.addSubview(detailbutton);
                cell.imageView!.image = UIImage(named:"green.png")
        return cell;
        
    }
    
    //选择一行
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true);
                let  peripheral = self.deviceList.objectAtIndex(indexPath.row) as!CBPeripheral
        
                if(self.peripheralList.containsObject(self.deviceList.objectAtIndex(indexPath.row))){
                    self.peripheralList.removeObject(self.deviceList.objectAtIndex(indexPath.row))
                    self.manager.cancelPeripheralConnection(peripheral);
                    print("蓝牙已断开！")
                }else{
                    self.peripheralList.addObject(self.deviceList.objectAtIndex(indexPath.row))
                    self.manager.connectPeripheral(peripheral, options: nil);
                    print("蓝牙已连接！ \(self.peripheralList.count)")
                }
                self.navigationController?.pushViewController(MainViewController(), animated: true);
        
    }
    //行高度
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 80;
    }
    func scanBlueTooth(sender:RNLoadingButton!){
        
        
        sender.loading = !sender.loading
        sender.hideImageWhenLoading = true
        if(isScan){
            
            sender.setTitle("scan", forState: UIControlState.Normal)
            self.navgationView!.backgroundColor=UIColor(red: 33/255, green: 122/255, blue: 183/255, alpha: 1.0)
            isScan = false
        }else{
            self.navgationView!.backgroundColor=UIColor(red: 50/255, green: 167/255, blue: 152/255, alpha: 1.0)
            sender.setTitle("   stop", forState: UIControlState.Normal)
            isScan = true
        }
    }

    
    //2.检查运行这个App的设备是不是支持BLE。代理方法
    func centralManagerDidUpdateState(central: CBCentralManager) {
        switch central.state {
        case CBCentralManagerState.PoweredOn:
            self.manager.scanForPeripheralsWithServices(nil, options:[CBCentralManagerScanOptionAllowDuplicatesKey: false])
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
        print(peripheral)
        if(!self.deviceList.containsObject(peripheral)){
            self.deviceList.addObject(peripheral)
            self.tableView?.reloadData();
            
        }
        
    }
    //连接外设失败
    func centralManager(central: CBCentralManager, didFailToConnectPeripheral peripheral: CBPeripheral, error: NSError?) {
        
    }
    //4.连接外设成功，开始发现服务
    func centralManager(central: CBCentralManager, didConnectPeripheral peripheral: CBPeripheral) {
        
        print("连接到设备: \(peripheral)")
        //停止扫描外设
        self.manager.stopScan()
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
            i++
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
    func colorChange(title:NSNotification)
    {
        let color = title.object as! UIColor;
        let components = CGColorGetComponents(color.CGColor);
        print(components[0],components[1],components[2]);
        
        let string = "C:\(Int(components[0]*255)),\(Int(components[0]*255)),\(Int(components[0]*255)),\(-1)\n"
        let data = string.dataUsingEncoding(NSUTF8StringEncoding)
        print(data);
        peripheral.writeValue(data!, forCharacteristic: self.writeCharacteristic,type: CBCharacteristicWriteType.WithoutResponse)
  

    }

    
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.navigationBar.hidden = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    

}

