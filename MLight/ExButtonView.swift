//
//  ExButtonView.swift
//  ExButton
//
//  Created by 汪鑫源 on 15/8/3.
//  Copyright © 2015年 汪鑫源. All rights reserved.
//

import UIKit

class ExButtonView: UIView {
  
  var buttons = [ExButton]()
  var didTapClosure: ((tag: Int) -> (Void))?
  
  let buttonDistance = CGFloat(66)
  let labelToButtonDistance = CGFloat(20)
  
  init(button: UIButton, forExButton buttons: [ExButton], handler: ((tag: Int) -> (Void))?) {
    super.init(frame: UIScreen.mainScreen().bounds)
    self.buttons = buttons
    self.didTapClosure = handler
    
    backgroundColor = UIColor.clearColor()
    alpha = 0
    
    addGestureRecognizer(UITapGestureRecognizer(target: self, action: "dismiss"))
    
    let dismissButton = UIButton(frame: button.frame)
    dismissButton.setImage(button.imageView?.image, forState: UIControlState.Normal)
    dismissButton.addTarget(self, action: "dismiss", forControlEvents: UIControlEvents.TouchUpInside)
    addSubview(dismissButton)
    
    var i = 0
    for exButton in buttons {
      let btn = UIButton(frame: button.frame)
      btn.setImage(exButton.image, forState: UIControlState.Normal)
      btn.backgroundColor = exButton.color;
      btn.layer.cornerRadius = 20;
      btn.layer.shadowColor = UIColor.blackColor().CGColor;//shadowColor阴影颜色
      btn.layer.shadowOffset = CGSizeMake(4,4);//shadowOffset阴影偏移,x向右偏移4，y向下偏移4，默认(0, -3),这个跟shadowRadius配合使用
      btn.layer.shadowOpacity = 0.8;//阴影透明度，默认0
      btn.layer.shadowRadius = 4;//阴影半径，默认3

      btn.addTarget(self, action: "didTapButton:", forControlEvents: UIControlEvents.TouchUpInside)
      btn.alpha = 0
      btn.tag = ++i
      addSubview(btn)
      
      let label = UILabel()
      label.text = exButton.title
      label.font = UIFont(name: "helvetica", size: 12)
      label.sizeToFit()
      label.center.y = btn.center.y
      label.frame.origin.x = btn.frame.origin.x - label.frame.size.width - labelToButtonDistance
      label.alpha = 0
      label.tag = i+100
      addSubview(label)
    }
  }

  required init?(coder aDecoder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
  }
  
  func didTapButton(button: UIButton) {
    if let closure = didTapClosure {
      closure(tag: button.tag)
    }
    dismiss()
  }
  
  func show() {
    UIApplication.sharedApplication().keyWindow?.addSubview(self)
    UIView.animateWithDuration(0.25) {
      self.alpha = 0.85
      for i in 1...self.buttons.count {
        let btn = self.viewWithTag(i) as! UIButton
        btn.center.x += CGFloat(i) * self.buttonDistance
        btn.alpha = 1
        let label = self.viewWithTag(i+100) as! UILabel
        label.center.x = btn.center.x
        label.alpha = 1
      }
    }
  }

  func dismiss() {
    UIView.animateWithDuration(0.25, animations: { () -> Void in
      self.alpha = 0
      for i in 1...self.buttons.count {
        let btn = self.viewWithTag(i) as! UIButton
        btn.center.x -= CGFloat(i) * self.buttonDistance
        btn.alpha = 0
        let label = self.viewWithTag(i+100) as! UILabel
        label.center.x = btn.center.x
        label.alpha = 0
      }
      }) { _ in self.removeFromSuperview() }
  }
  
}

class ExButton {
  var image: UIImage
  var title: String
  var color:UIColor
  
  init() {
    image = UIImage()
    title = ""
    color = UIColor()
    
  }
  
    init(image: UIImage, title: String,color:UIColor) {
    self.image = image
    self.title = title
    self.color = color
  }
}