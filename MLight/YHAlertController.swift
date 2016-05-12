//
//  YHAlertController.swift
//  BLEHelper
//
//  Created by HeHongwe on 15/11/6.
//  Copyright © 2015年 Microduino. All rights reserved.
//

import Foundation
import UIKit

extension UIAlertController {
    class func showAlert(
        presentController: UIViewController!,
        title: String!,
        message: String!,
        cancelButtonTitle: String? = "cancel",
        okButtonTitle: String? = "ok") {
            let alert = UIAlertController(title: title!, message: message!, preferredStyle: UIAlertControllerStyle.Alert)
            if (cancelButtonTitle != nil) {
                alert.addAction(UIAlertAction(title: cancelButtonTitle!, style: UIAlertActionStyle.Default, handler: nil))// do not handle cancel, just dismiss
            }
            if (okButtonTitle != nil) {
                alert.addAction(UIAlertAction(title: okButtonTitle!, style: UIAlertActionStyle.Default, handler: nil))// do not handle cancel, just dismiss
            }
            
            presentController!.presentViewController(alert, animated: true, completion: nil)
    }
    
    class func showAlert(
        presentController: UIViewController!,
        title: String!,
        message: String!,
        cancelButtonTitle: String? = "cancel",
        okButtonTitle: String? = "ok",
        okHandler: ((UIAlertAction!) -> Void)!) {
            let alert = UIAlertController(title: title!, message: message!, preferredStyle: UIAlertControllerStyle.Alert)
            if (cancelButtonTitle != nil) {
                alert.addAction(UIAlertAction(title: cancelButtonTitle!, style: UIAlertActionStyle.Default, handler: nil))// do not handle cancel, just dismiss
            }
            if (okButtonTitle != nil) {
                alert.addAction(UIAlertAction(title: okButtonTitle!, style: UIAlertActionStyle.Default, handler: okHandler))// do not handle cancel, just dismiss
            }
            
            presentController!.presentViewController(alert, animated: true, completion: nil)
    }  
}