//
//  IvViewController.swift
//  Speed Selfie
//
//  Created by Vaibhav Gandhi on 2/8/15.
//  Copyright (c) 2015 Vaibhav Gandhi. All rights reserved.
//

import UIKit

class IvViewController: UIViewController {

    var image: UIImage?

    @IBOutlet weak var imageView: UIImageView!
    
    override func viewWillAppear(animated: Bool) {
        imageView.image = image
    }

}
