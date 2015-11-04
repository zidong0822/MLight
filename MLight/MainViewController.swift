//
//  MainViewController.swift
//  mlight
//
//  Created by Microduino on 10/23/15.
//  Copyright © 2015 Microduino. All rights reserved.
//

import UIKit
import AVFoundation
class MainViewController: UIViewController,ISColorWheelDelegate{

    var navgationView:UIView?
    var tableView : UITableView?
    var colorWheel :ISColorWheel?
    var selectedColor:UIColor?;
    let colorWheelSize = CGFloat(250)
    var brightnessSlider:UISlider?
    var wellView:UIView?
    var audioRecorder:AVAudioRecorder!
    var audioPlayer:AVAudioPlayer!
    
    ////定义音频的编码参数，这部分比较重要，决定录制音频文件的格式、音质、容量大小等，建议采用AAC的编码方式
    let recordSettings = [AVSampleRateKey : NSNumber(float: Float(11025.0)),//声音采样率
        AVFormatIDKey : NSNumber(int: Int32(kAudioFormatMPEG4AAC)),//编码格式
        AVNumberOfChannelsKey : NSNumber(int: 2),//采集音轨
        AVEncoderAudioQualityKey : NSNumber(int: Int32(AVAudioQuality.Medium.rawValue))]//音频质量
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        

        
        
        self.view.backgroundColor = UIColor.whiteColor();
        self.selectedColor = UIColor.redColor();
     
        initNavgationView1();
        
        let  size = self.view.bounds.size;
        
        let wheelSize = CGSizeMake(size.width * 0.6, size.width * 0.6);

        
        
        colorWheel = ISColorWheel(frame: CGRectMake(size.width / 2 - wheelSize.width / 2,
            size.height * 0.1,
            wheelSize.width,
            wheelSize.height));
        colorWheel!.delegate = self;
        colorWheel!.continuous = true;
        self.view.addSubview(colorWheel!);
        
        brightnessSlider = UISlider(frame:CGRectMake(size.width*0.4,
            size.height*0.8,
            size.width*0.5,
            size.height*0.1))
        brightnessSlider!.minimumValue = 0.0;
        brightnessSlider!.maximumValue = 1.0;
        brightnessSlider!.value = 1.0;
        brightnessSlider!.continuous = true;
        brightnessSlider!.addTarget(self, action: "changeBrightness:", forControlEvents:UIControlEvents.ValueChanged)
         self.view.addSubview(brightnessSlider!);
       
        wellView =  UIView(frame: CGRectMake(size.width*0.1,
            size.height*0.8,
            size.width*0.2,
            size.height*0.1));
         self.view.addSubview(wellView!);
        
        
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
            try audioRecorder = AVAudioRecorder(URL: self.directoryURL()!,
                settings: recordSettings)//初始化实例
            audioRecorder.prepareToRecord()//准备录音
            
            
        } catch {
            
            
        }
      
        
    }
    func directoryURL() -> NSURL? {
        //定义并构建一个url来保存音频，音频文件名为ddMMyyyyHHmmss.caf
        //根据时间来设置存储文件名
        let currentDateTime = NSDate()
        let formatter = NSDateFormatter()
        formatter.dateFormat = "ddMMyyyyHHmmss"
        let recordingName = formatter.stringFromDate(currentDateTime)+".caf"
        print(recordingName)
        
        let fileManager = NSFileManager.defaultManager()
        let urls = fileManager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        let documentDirectory = urls[0] as NSURL
        let soundURL = documentDirectory.URLByAppendingPathComponent(recordingName)
        return soundURL
    }
    
    func startRecord() {
        //开始录音
        if !audioRecorder.recording {
            let audioSession = AVAudioSession.sharedInstance()
            do {
                try audioSession.setActive(true)
                audioRecorder.record()
                doTimer()
            } catch {
            }
        }
    }

    
    func changeBrightness(sender:UISlider){
   
        colorWheel?.brightness = brightnessSlider!.value;
        wellView?.backgroundColor = colorWheel!.currentColor();
        
        startRecord();
    }
    
    func colorWheelDidChangeColor(colorWheel: ISColorWheel!) {
          wellView?.backgroundColor = colorWheel!.currentColor();
    }
    
    
    func initNavgationView1(){
        
        self.navgationView=UIView(frame: CGRectMake(0,20, self.view.frame.width,44))
        self.navgationView!.backgroundColor=UIColor(red: 50/255, green: 167/255, blue: 152/255, alpha: 1.0)
        self.navgationView!.layer.shadowColor = UIColor.blackColor().CGColor
        self.navgationView!.layer.shadowOffset = CGSizeMake(4,4);//shadowOffset阴影偏移,x向右偏移4，y向下偏移4，默认(0, -3),这个跟shadowRadius配合使用
        self.navgationView!.layer.shadowOpacity = 0.8;//阴影透明度，默认0
        self.navgationView!.layer.shadowRadius = 4;//阴影半径，默认3
        self.view.addSubview(self.navgationView!)
        
        let navgationLabel=UILabel(frame: CGRectMake(80,20, self.view.frame.width-100,44))
        navgationLabel.text = "BLE Device Scan";
        self.view.addSubview(navgationLabel);
        
        let goBackButton=UIButton(frame: CGRectMake(0,25,30,30))
        goBackButton.setImage(UIImage(named:"back"),forState:UIControlState.Normal)
        goBackButton.addTarget(self, action:"goBack:", forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(goBackButton);
        
        let navgationButton=UIButton(frame: CGRectMake(35,25,30,30))
        navgationButton.setImage(UIImage(named:"icon_white"),forState:UIControlState.Normal)
        self.view.addSubview(navgationButton);
        
        
    
        
        
    }
   
    
    func doTimer(){
        let timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: "timerFireMethod:", userInfo: nil, repeats:true);
        timer.fire()
    }
    func timerFireMethod(timer: NSTimer) {
   
        audioRecorder.updateMeters();
        
        var  avg = audioRecorder.averagePowerForChannel(0) as Float ;
        
        let minValue = -60 as Float;
        let range = 60 as Float;
        let outRange = 100 as Float;
        if (avg < minValue) {
            avg = minValue;
        }
        let  decibels = (avg + range) / range * outRange;
        
        print(decibels);
        
    }
    

    
    func  goBack(sender:UIButton){
    
        self.navigationController?.popViewControllerAnimated(true)
    
    }

    
    
    

}