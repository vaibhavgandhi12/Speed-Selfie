//
//  CameraViewController.swift
//  Speed Selfie
//
//  Created by Vaibhav Gandhi on 2/7/15.
//  Copyright (c) 2015 Vaibhav Gandhi. All rights reserved.
//

//import Foundation
import UIKit
import CoreVideo
import CoreMedia
import AVFoundation
import MobileCoreServices
import MessageUI
import CloudKit

class CameraViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, AVCaptureVideoDataOutputSampleBufferDelegate, MFMessageComposeViewControllerDelegate {

    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var btnRetake: UIButton!
    @IBOutlet weak var btnSend: UIButton!
    @IBOutlet weak var btnCamera: UIButton!
    @IBOutlet weak var pappa: UIView!
    @IBOutlet weak var imgVw2: UIImageView!
    
    //var phoneNumber : String?;
    var phoneNumber: String = "585520"
    var myNumber: String?
    
    var effectCounter = 0
    var image: UIImage?
    
    var device: AVCaptureDevice?
    var captureSession: AVCaptureSession?
    var previewLayer: AVCaptureVideoPreviewLayer?
    var annotationsField: UITextField
    var startPoint: CGPoint?
    var globalImage : UIImage?
//------------------------------------------------------------------------------------
    required init(coder aDecoder: NSCoder) {
        
        annotationsField = UITextField()
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.hidden = true
        btnRetake.hidden = true
        btnSend.hidden = true
        btnCamera.layer.cornerRadius = btnCamera.bounds.size.width/2.0;
        //navigationController?.hidesBarsOnSwipe = true
        //navigationController?.hidesBarsOnTap = true
        
        //        var gestureRecognizer = UISwipeGestureRecognizer(target: self, action: "handleGesture:")
        //        gestureRecognizer.direction = .Left | .Right
        //        imageView.addGestureRecognizer(gestureRecognizer)
        setupCamera()
        
        // Text annotation code goes here.
        
        // Done button toolbar
        let keyboardDoneButtonView = UIToolbar()
        keyboardDoneButtonView.sizeToFit()
        
        // Initialize the button
        let item = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.Bordered, target: self, action: Selector("endEditing") )
        var toolbarButtons = [item]
        
        //Put the buttons into the ToolBar and display the tool bar
        keyboardDoneButtonView.setItems(toolbarButtons, animated: false)
        self.annotationsField.inputAccessoryView = keyboardDoneButtonView
        self.annotationsField.placeholder = "Tap to enter"
        
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true);
        //navigationController?.hidesBarsOnSwipe = true
        //navigationController?.hidesBarsOnTap = true
        self.navigationController?.navigationBarHidden = true;
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

//------------------------------------------------------------------------------------
    //MARK: Filters
    
    func curvePress(sender: AnyObject) {
        if let tempImage = image {
            imageView.image = tempImage.curveFilter()
        }
    }
    
    func vignettePress(sender: AnyObject) {
        if let tempImage = image {
            imageView.image = tempImage.vignetteWithRadius(0, andIntensity: 18)
        }
    }
    
    func bwPress(sender: AnyObject) {
        if let tempImage = image {
            imageView.image = tempImage.saturateImage(0, withContrast: 1.05)
        }
    }
    
    func saturationPress(sender: AnyObject) {
        if let tempImage = image {
            imageView.image = tempImage.saturateImage(1.7, withContrast: 1)
        }
    }
    
//------------------------------------------------------------------------------------
    //MARK: IBActions
    
    @IBAction func goBack(sender: AnyObject) {
        
        self.navigationController?.popToRootViewControllerAnimated(true)
    }
    @IBAction func btnPress(sender: AnyObject) {
        imageView.image = image
        imageView.hidden = false
        btnRetake.hidden = false
        btnSend.hidden = false
        btnCamera.hidden = true
        captureSession?.stopRunning()
    }
    
    @IBAction func retakePress(sender: AnyObject) {
        effectCounter = 0
        imageView.hidden = true
        btnCamera.hidden = false
        btnRetake.hidden = true
        btnSend.hidden = true
        captureSession?.startRunning()
        annotationsField.removeFromSuperview()
    }
    
    @IBAction func Send(sender: AnyObject) {
        //self.sendImage();
        if let tempImage = image {
            UIGraphicsBeginImageContext(tempImage.size);
            tempImage.drawInRect(CGRect(x: 0, y: 0, width: tempImage.size.width, height: tempImage.size.height))
            let data = UIImageJPEGRepresentation(UIGraphicsGetImageFromCurrentImageContext(), 0.75)
            UIGraphicsEndImageContext()
            
            let cachesDirectory: NSURL = NSFileManager.defaultManager().URLForDirectory(NSSearchPathDirectory.CachesDirectory, inDomain: NSSearchPathDomainMask.UserDomainMask, appropriateForURL: nil, create: true, error: nil)!
            let temporaryName = NSUUID().UUIDString.stringByAppendingPathExtension("jpeg")!
            let localURL = cachesDirectory.URLByAppendingPathComponent(temporaryName)
            let asset = CKAsset(fileURL: localURL)
            data.writeToURL(localURL, atomically: true)
            
            let recordID = CKRecordID(recordName: phoneNumber)
            let record = CKRecord(recordType: "SpeedSelfie", recordID: recordID)
            record.setObject(phoneNumber, forKey: "ReceiverNumber")
            record.setObject(myNumber, forKey: "SenderNumber")
            record.setObject(asset, forKey: "Image")
            
            let myContainer: CKContainer = CKContainer.defaultContainer()
            let publicDatabase: CKDatabase = myContainer.publicCloudDatabase
            var tempRecord: CKRecord?
            var error: NSError?
            publicDatabase.saveRecord(record) { tempRecord, error in
                if (error != nil) {
                    // Insert successfully saved record code
                    NSLog("Description Not Sent: " + recordID.description + " more: " + error.description)
                    var alert = UIAlertController(title: "Speed Selfie", message: "Not Sent" + error.description, preferredStyle: UIAlertControllerStyle.Alert)
                    var action = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default) { act in
                        self.dismissViewControllerAnimated(true, completion: nil)
                    }
                    alert.addAction(action)
                    self.presentViewController(alert, animated: true, completion: nil)
                }
                else {
                    NSLog("Sent " + tempRecord.recordChangeTag)
                    var alert = UIAlertController(title: "Speed Selfie", message: "Sent", preferredStyle: UIAlertControllerStyle.Alert)
                    
                    var action = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default) { act in
                        self.dismissViewControllerAnimated(true, completion: nil)
                    }
                    alert.addAction(action)
                    self.presentViewController(alert, animated: true, completion: nil)
                }
            }
        }

    }
   
    //MARK: Swipe Gesture handling
    
    @IBAction func handleSwipeGesture(sender: UISwipeGestureRecognizer) {
        if sender.direction != .Left {
            return
        }
        
        //let location = sender.locationInView(imageView)
        let location = sender.locationInView(pappa)
        
        if (location.y < 0) && (location.y > imageView.bounds.height) {
            return
        }
        
        effectCounter++
        if effectCounter % 4 == 0 {
            curvePress(imageView)
        } else if effectCounter % 4 == 1 {
            vignettePress(imageView)
        } else if effectCounter % 4 == 2 {
            bwPress(imageView)
        } else if effectCounter % 4 == 3 {
            saturationPress(imageView)
        }
    }
//------------------------------------------------------------------------------------
    //MARK: Camera capture and setup
    
    func setupCamera() {
        var devices: Array = AVCaptureDevice.devicesWithMediaType(AVMediaTypeVideo)
        for tempDevice in devices {
            if (tempDevice.position == AVCaptureDevicePosition.Front) {
                device = (tempDevice as AVCaptureDevice)
            }
        }
        
        var input = AVCaptureDeviceInput.deviceInputWithDevice(device, error: nil) as AVCaptureDeviceInput
        var output = AVCaptureVideoDataOutput()
        output.alwaysDiscardsLateVideoFrames = true
        
        let queue: dispatch_queue_t  = dispatch_queue_create("cameraQueue", nil)
        output.setSampleBufferDelegate(self, queue: queue)
        
        var formatKey: String = kCVPixelBufferPixelFormatTypeKey
        var formatValue = kCVPixelFormatType_32BGRA
        var videoSettings = [formatKey: formatValue]
        output.videoSettings = videoSettings
        
        captureSession = AVCaptureSession()
        captureSession?.addInput(input)
        captureSession?.addOutput(output)
        captureSession?.sessionPreset = AVCaptureSessionPresetPhoto
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
        
        previewLayer?.frame = imageView.frame
        
        view.layer.insertSublayer(previewLayer, atIndex: 0)
        
        captureSession?.startRunning()
    }
    
    func captureOutput(captureOutput: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, fromConnection connection: AVCaptureConnection!) {
        var imageBuffer: CVImageBufferRef = CMSampleBufferGetImageBuffer(sampleBuffer)
        CVPixelBufferLockBaseAddress(imageBuffer, 0)
        var baseAddress = CVPixelBufferGetBaseAddress(imageBuffer)
        var bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer)
        var width = CVPixelBufferGetWidth(imageBuffer)
        var height = CVPixelBufferGetHeight(imageBuffer)
        
        var colorSpace = CGColorSpaceCreateDeviceRGB()
        var bitmapInfoMask = CGBitmapInfo.ByteOrder32Little.rawValue | CGImageAlphaInfo.PremultipliedFirst.rawValue
        var bitmapInfo = CGBitmapInfo(rawValue: bitmapInfoMask)
        
        var newContext = CGBitmapContextCreate(baseAddress, width, height, 8, bytesPerRow, colorSpace, bitmapInfo)
        var newImage = CGBitmapContextCreateImage(newContext)
        
        image = UIImage(CGImage: newImage, scale: 1.0, orientation: UIImageOrientation.LeftMirrored)
        //globalImage = image;
        CVPixelBufferUnlockBaseAddress(imageBuffer, 0)
    }

//------------------------------------------------------------------------------------
    //MARK: Add text to Image and capture
    
     func addText() {
        
        annotationsField.frame = CGRect(x: 0, y: startPoint!.y , width: self.view.frame.width, height:44)
        annotationsField.backgroundColor = UIColor.redColor();
        annotationsField.textColor = UIColor.darkGrayColor()
        annotationsField.alpha = 0.5
        annotationsField.textAlignment = NSTextAlignment.Center
        
        var rotationGesture = UIRotationGestureRecognizer()
        var panGesture = UIPanGestureRecognizer()
        panGesture.maximumNumberOfTouches = 1
        panGesture.minimumNumberOfTouches = 1
        rotationGesture.addTarget(self, action: Selector("handleRotationGestureRecognizer:"))
        panGesture.addTarget(self, action: Selector("handlePanGestureRecognizer:"))
        
        //annotationsField.addGestureRecognizer( rotationGesture )
        //annotationsField.addGestureRecognizer( panGesture )
        //self.view.addSubview(annotationsField)
        self.pappa.addSubview(annotationsField)
    }
    
    @IBAction func removeText() {
        annotationsField.removeFromSuperview()
    }
    
    @IBAction func captureImage() {
        
        annotationsField.backgroundColor = UIColor.clearColor()
        annotationsField.textColor = UIColor.whiteColor()
        //var finalPath = self.getPicturePath()
        //UIGraphicsBeginImageContext(CGSize(width: self.view.frame.width, height: (self.view.frame.height - 300 - 10)))
        
        let contextWidth = pappa.frame.width
        let contextHeight = pappa.frame.height
        
        let contextSize = CGSize(width: contextWidth, height: contextHeight)
        
        UIGraphicsBeginImageContext(contextSize)
        
        let currentContext = UIGraphicsGetCurrentContext()
        
        self.pappa.layer.renderInContext(currentContext)
        let renderedImage = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        // globalImage = UIGraphicsGetImageFromCurrentImageContext()
        //    if globalImage == nil{
        //        println("its nil")
        //    }
        //    else
        //    {
        //        self.imgVw2.image = renderedImage
        //    }
        
        self.imgVw2.image = renderedImage
        //var imageData = UIImagePNGRepresentation(renderedImage)
        //imageData.writeToFile(finalPath, atomically:true)
        
        // send to a person
        
        
        
        // delete from folder
        //NSFileManager.defaultManager().removeItemAtPath(finalPath, error: nil)
        annotationsField.backgroundColor = UIColor.grayColor();
        annotationsField.textColor = UIColor.whiteColor()
        annotationsField.alpha = 0.5
        
        //self.performSegueWithIdentifier("cameraSegue", sender: self);
        
    }
    
//------------------------------------------------------------------------------------
    //MARK:  Send Image

    func sendImage(){
        if (MFMessageComposeViewController.canSendText()) {
            let controller = MFMessageComposeViewController();
            controller.body = "Sent from Speed Selfie!";
            controller.recipients = ["+12023744955"]
            //let sendImageData = UIImageJPEGRepresentation(globalImage, 1.0)
            //let sendImageData = UIImagePNGRepresentation(self.imageView.image)
            let sendImageData = UIImageJPEGRepresentation(self.imageView.image, 1.0)
            if controller.addAttachmentData(sendImageData, typeIdentifier: kUTTypeJPEG, filename: "img.jpeg"){
                println("Success!")
            }
            controller.messageComposeDelegate = self;
            self.presentViewController(controller, animated: true, completion: nil);
        }
    }
    
    func messageComposeViewController(controller: MFMessageComposeViewController!, didFinishWithResult result: MessageComposeResult) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
//------------------------------------------------------------------------------------
    //MARK:  Pan Gesture handling
    
    func handlePanGestureRecognizer (sender: UIPanGestureRecognizer){
        
        // get the point where it is tapped
        var point = sender.translationInView(self.view!)
        
        // move textField by that much
        // but check for boundries first
        sender.view!.center = CGPointMake(sender.view!.center.x, sender.view!.center.y + point.y)
        sender.setTranslation(CGPointZero, inView: self.view!)
        
    }
    
    func handleRotationGestureRecognizer (sender: UIRotationGestureRecognizer){
        
        var transform = sender.view!.transform
        var rotation = sender.rotation
        sender.view?.transform = CGAffineTransformRotate( transform , rotation )
        sender.rotation = 0;
    }


    override func touchesBegan(touches: NSSet, withEvent event: UIEvent){
        let theTouch = touches.anyObject() as UITouch
        startPoint = theTouch.locationInView(self.view)
        
        println("Y==> \(startPoint!.y)");
        if startPoint!.y > 55 && startPoint!.y < 450{
            self.addText();
        }
        
    }
    
    func endEditing(){
        self.annotationsField.resignFirstResponder()
    }
}