//
//  ViewController.swift
//  MLight
//
//  Created by Microduino on 11/4/15.
//  Copyright © 2015 Microduino. All rights reserved.
//

import UIKit
import CoreBluetooth
class ViewController: UIViewController,UITableViewDataSource,UITableViewDelegate,BLECentralDelegate{

    var navgationView:UIView?
    var tableView : UITableView?
    var isScan:Bool = true
    var bleMingle: BLEMingle!
    //保存收到的蓝牙设备
    var deviceList:NSMutableArray = NSMutableArray()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.blackColor()
        initNavgationView();
        initTableView();
        
        bleMingle = BLEMingle()
        bleMingle.delegate = self;
        // 创建目标队列
        let workingQueue = dispatch_queue_create("my_queue", nil)
        
        // 派发到刚创建的队列中，GCD 会负责进行线程调度
        dispatch_async(workingQueue) {
            NSThread.sleepForTimeInterval(2)  // 模拟两秒的执行时间
            dispatch_async(dispatch_get_main_queue()) {
                self.bleMingle.startScan()
            }
        }

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
        scanButton.addTarget(self, action:#selector(scanBlueTooth), forControlEvents: UIControlEvents.TouchUpInside)
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
        let mainViewController = MainViewController()
        mainViewController.bleMingle = bleMingle;
        bleMingle.connectPeripheral(peripheral);
        self.navigationController?.pushViewController(mainViewController, animated: true);
        
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
    func didDiscoverPeripheral(peripheral: CBPeripheral!){
       
        if(!self.deviceList.containsObject(peripheral)){
            self.deviceList.addObject(peripheral)
            self.tableView?.reloadData();
            
        }

    }

    
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.navigationBar.hidden = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
       
    }

    

}

