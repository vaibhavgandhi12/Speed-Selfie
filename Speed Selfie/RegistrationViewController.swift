//
//  RegistrationViewController.swift
//  Speed Selfie
//
//  Created by Vaibhav Gandhi on 2/8/15.
//  Copyright (c) 2015 Vaibhav Gandhi. All rights reserved.
//

import UIKit

class RegistrationViewController: UIViewController {

    @IBOutlet weak var myNumber: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func enterPressed(sender: AnyObject) {
        NSLog("Enter: " + myNumber.text)
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject(myNumber.text, forKey: "myNumber")
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        var mainController = mainStoryboard.instantiateViewControllerWithIdentifier("normal_vc") as ViewController
        self.navigationController?.pushViewController(mainController, animated: true)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
