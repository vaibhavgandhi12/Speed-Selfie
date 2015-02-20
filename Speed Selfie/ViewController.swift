//
//  ViewController.swift
//  Speed Selfie
//
//  Created by Vaibhav Gandhi on 2/6/15.
//  Copyright (c) 2015 Vaibhav Gandhi. All rights reserved.
//

import UIKit
import CloudKit
import MobileCoreServices
import AddressBookUI
import CoreData
//@objc(Person)

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, ABPeoplePickerNavigationControllerDelegate, NSFetchedResultsControllerDelegate {

   
    @IBOutlet weak var mainView: UIView!
    
    @IBOutlet weak var btn1: UIButton! ;  @IBOutlet weak var imgView1: UIImageView!
    @IBOutlet weak var btn2: UIButton! ;  @IBOutlet weak var imgView2: UIImageView!
    @IBOutlet weak var btn3: UIButton! ;  @IBOutlet weak var imgView3: UIImageView!
    @IBOutlet weak var btn4: UIButton! ;  @IBOutlet weak var imgView4: UIImageView!
    @IBOutlet weak var btn5: UIButton! ;  @IBOutlet weak var imgView5: UIImageView!
    @IBOutlet weak var btn6: UIButton! ;  @IBOutlet weak var imgView6: UIImageView!
    @IBOutlet weak var btn7: UIButton! ;  @IBOutlet weak var imgView7: UIImageView!
    @IBOutlet weak var btn8: UIButton! ;  @IBOutlet weak var imgView8: UIImageView!
    @IBOutlet weak var btn9: UIButton! ;  @IBOutlet weak var imgView9: UIImageView!
    @IBOutlet weak var btn10: UIButton! ; @IBOutlet weak var imgView10: UIImageView!
    @IBOutlet weak var btn11: UIButton! ; @IBOutlet weak var imgView11: UIImageView!
    @IBOutlet weak var btn12: UIButton! ; @IBOutlet weak var imgView12: UIImageView!
    @IBOutlet weak var btn13: UIButton! ; @IBOutlet weak var imgView13: UIImageView!
    @IBOutlet weak var btn14: UIButton! ; @IBOutlet weak var imgView14: UIImageView!
    @IBOutlet weak var btn15: UIButton! ; @IBOutlet weak var imgView15: UIImageView!
    
    @IBOutlet weak var imgDelete1: UIImageView! ;  @IBOutlet weak var lbl1: UILabel!
    @IBOutlet weak var imgDelete2: UIImageView! ;  @IBOutlet weak var lbl2: UILabel!
    @IBOutlet weak var imgDelete3: UIImageView! ;  @IBOutlet weak var lbl3: UILabel!
    @IBOutlet weak var imgDelete4: UIImageView! ;  @IBOutlet weak var lbl4: UILabel!
    @IBOutlet weak var imgDelete5: UIImageView! ;  @IBOutlet weak var lbl5: UILabel!
    @IBOutlet weak var imgDelete6: UIImageView! ;  @IBOutlet weak var lbl6: UILabel!
    @IBOutlet weak var imgDelete7: UIImageView! ;  @IBOutlet weak var lbl7: UILabel!
    @IBOutlet weak var imgDelete8: UIImageView! ;  @IBOutlet weak var lbl8: UILabel!
    @IBOutlet weak var imgDelete9: UIImageView! ;  @IBOutlet weak var lbl9: UILabel!
    @IBOutlet weak var imgDelete10: UIImageView! ;  @IBOutlet weak var lbl10: UILabel!
    @IBOutlet weak var imgDelete11: UIImageView! ;  @IBOutlet weak var lbl11: UILabel!
    @IBOutlet weak var imgDelete12: UIImageView! ;  @IBOutlet weak var lbl12: UILabel!
    @IBOutlet weak var imgDelete13: UIImageView! ;  @IBOutlet weak var lbl13: UILabel!
    @IBOutlet weak var imgDelete14: UIImageView! ;  @IBOutlet weak var lbl14: UILabel!
    @IBOutlet weak var imgDelete15: UIImageView! ;  @IBOutlet weak var lbl15: UILabel!

    //------------------------------------------------------------------------------------
    var currentPersonID : Int = 0;
    var fetchResultController:NSFetchedResultsController!;
    var personArray:[Person] = [];
    var isEditMode : Bool = false;
    var temporaryImage: UIImage?
    
    var myNumber: String?
    var phoneNumber: String?
    var publicDatabase: CKDatabase?
//------------------------------------------------------------------------------------

    // MARK: View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        // Configuring Notifications
        
        let defaults = NSUserDefaults.standardUserDefaults()
        myNumber = defaults.stringForKey("myNumber")
        //
        
        NSTimer.scheduledTimerWithTimeInterval(10, target: self, selector: "timerFired:", userInfo: nil, repeats: true)
        
        NSLog("SenderNumber = \(myNumber!)")
        
        let predicate = NSPredicate(format: "ReceiverNumber = %@", myNumber!)
        let subscription = CKSubscription(recordType: "SpeedSelfie",
            predicate: predicate,
            options: .FiresOnRecordCreation)
        
        let notificationInfo = CKNotificationInfo()
        
        notificationInfo.alertBody = "A new Selfie is awaiting your eyes"
        notificationInfo.shouldBadge = true
        
        subscription.notificationInfo = notificationInfo
        
        publicDatabase?.saveSubscription(subscription,
            completionHandler: ({returnRecord, error in
                if let err = error {
                    NSLog("subscription failed %@",
                        err.localizedDescription)
                } else {
                    NSLog("Success" +
                        "message: Subscription set up successfully")
                }
            }))

        
        self.title = "Speed Selfie";
        [self .doInitialSetup()];
        [self .fetchFromDatabase()];
        
        navigationController?.hidesBarsOnSwipe = false
        navigationController?.hidesBarsOnTap = false
        self.navigationController?.navigationBarHidden = false;
        
        var editButton = UIBarButtonItem(title: "Edit", style: UIBarButtonItemStyle.Plain, target: self, action: Selector ("editPress:"))
        self.navigationItem.leftBarButtonItem = editButton;
        
        let path = self.getDocDirectoryPath();
        println("Doc direct: \(path)");
        // Do any additional setup after loading the view, typically from a nib.
    }
     override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true);
        navigationController?.hidesBarsOnSwipe = false
        navigationController?.hidesBarsOnTap = false
        self.navigationController?.navigationBarHidden = false;
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
  
//------------------------------------------------------------------------------------
    //MARK: Segue Method
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        
        if (segue.identifier == "cameraSegue") {
            //let myRow = tableView.indexPathForSelectedRow().row+1
            let vc = segue.destinationViewController as CameraViewController
            vc.myNumber = myNumber
            //vc.SelectedBundesland.text = "Test"
            // Send contact number from here.
        }
    }
    
    //------------------------------------------------------------------------------------
    func doInitialSetup(){
        println("Success");
        
        for view in self.mainView.subviews as [UIView]{
            
            if let currentButton = view as? UIButton {
                currentButton.layer.cornerRadius = currentButton.bounds.size.width/2.0;
                currentButton.layer.masksToBounds = true;
                currentButton.layer.borderWidth = 1.0;
                currentButton.layer.borderColor = UIColor .darkGrayColor().CGColor;
            }
        }
        
        for view in self.mainView.subviews as [UIView]{
            if view.tag > 400 && view.tag < 450{
                continue;
            }
            
            if let currentImageView = view as? UIImageView{
                currentImageView.layer.cornerRadius = currentImageView.bounds.size.width/2.0;
                currentImageView.layer.borderWidth = 1.0;
                currentImageView.layer.masksToBounds = true;
                currentImageView.layer.borderColor = UIColor .darkGrayColor().CGColor;
                //currentImageView.image = UIImage(named: "r.jpg");
            }
        }
        
    }
    //------------------------------------------------------------------------------------
    
    func loadData(personObject: Person){
        let pid = personObject.personID;
        println("Person ID: \(pid)");
        //let image1 = UIImage(data: personObject.image);
        let image1 = UIImage(data: personObject.image);
        if image1 == nil{
            println("Image is nil");
        }
        switch pid{
          
        case 0:
            if isEditMode{
                self.imgDelete1.hidden=false;
            }
            else{
                self.imgView1.image = image1;
                self.imgView1.layer.cornerRadius = self.imgView1.bounds.size.width/2.0;
                self.imgView1.layer.borderWidth = 1.0;
                self.imgView1.layer.borderColor = UIColor.darkGrayColor().CGColor;
                self.lbl1.text = personObject.name;
                self.imgDelete1.hidden = true;
                
            }
        
        case 1:
            if isEditMode{
                self.imgDelete2.hidden=false;
            }
            else{
                self.imgView2.image = image1;
                self.imgView2.layer.cornerRadius = self.imgView2.bounds.size.width/2.0;
                self.imgView2.layer.borderWidth = 1.0;
                self.imgView2.layer.borderColor = UIColor.darkGrayColor().CGColor;
                self.lbl2.text = personObject.name;
                self.imgDelete2.hidden = true;
                
            }
        
        case 2:
            if isEditMode{
                self.imgDelete3.hidden=false;
            }
            else{
                self.imgView3.image = image1;
                self.imgView3.layer.cornerRadius = self.imgView3.bounds.size.width/2.0;
                self.imgView3.layer.borderWidth = 1.0;
                self.imgView3.layer.borderColor = UIColor .darkGrayColor().CGColor;
                self.lbl3.text = personObject.name;
                self.imgDelete3.hidden = true;
                
            }
        case 3:
            if isEditMode{
                self.imgDelete4.hidden=false;
            }
            else{
                self.imgView4.image = image1;
                self.imgView4.layer.cornerRadius = self.imgView3.bounds.size.width/2.0;
                self.imgView4.layer.borderWidth = 1.0;
                self.imgView4.layer.borderColor = UIColor .darkGrayColor().CGColor;
                self.lbl4.text = personObject.name;
                self.imgDelete4.hidden = true;
            }
            
        case 4:
            if isEditMode{
                self.imgDelete5.hidden=false;
            }
            else{
                self.imgView5.image = image1;
                self.imgView5.layer.cornerRadius = self.imgView5.bounds.size.width/2.0;
                self.imgView5.layer.borderWidth = 1.0;
                self.imgView5.layer.borderColor = UIColor.darkGrayColor().CGColor;
                self.lbl5.text = personObject.name;
                self.imgDelete5.hidden = true;
                
            }
            
        case 5:
            if isEditMode{
                self.imgDelete6.hidden=false;
            }
            else{
                self.imgView6.image = image1;
                self.imgView6.layer.cornerRadius = self.imgView6.bounds.size.width/2.0;
                self.imgView6.layer.borderWidth = 1.0;
                self.imgView6.layer.borderColor = UIColor .darkGrayColor().CGColor;
                self.lbl6.text = personObject.name;
                self.imgDelete6.hidden = true;
                
            }
            
        case 6:
            if isEditMode{
                self.imgDelete7.hidden=false;
            }
            else{
                self.imgView7.image = image1;
                self.imgView7.layer.cornerRadius = self.imgView7.bounds.size.width/2.0;
                self.imgView7.layer.borderWidth = 1.0;
                self.imgView7.layer.borderColor = UIColor.darkGrayColor().CGColor;
                self.lbl7.text = personObject.name;
                self.imgDelete7.hidden = true;
            }
            
        case 7:
            if isEditMode{
                self.imgDelete8.hidden=false;
            }
            else{
                self.imgView8.image = image1;
                self.imgView8.layer.cornerRadius = self.imgView8.bounds.size.width/2.0;
                self.imgView8.layer.borderWidth = 1.0;
                self.imgView8.layer.borderColor = UIColor .darkGrayColor().CGColor;
                self.lbl8.text = personObject.name;
                self.imgDelete8.hidden = true;
                
            }
            
        case 8:
            if isEditMode{
                self.imgDelete9.hidden=false;
            }
            else{
                self.imgView9.image = image1;
                self.imgView9.layer.cornerRadius = self.imgView9.bounds.size.width/2.0;
                self.imgView9.layer.borderWidth = 1.0;
                self.imgView9.layer.borderColor = UIColor.darkGrayColor().CGColor;
                self.lbl9.text = personObject.name;
                self.imgDelete9.hidden = true;
                
            }
            
        case 9:
            if isEditMode{
                self.imgDelete10.hidden=false;
            }
            else{
                self.imgView10.image = image1;
                self.imgView10.layer.cornerRadius = self.imgView10.bounds.size.width/2.0;
                self.imgView10.layer.borderWidth = 1.0;
                self.imgView10.layer.borderColor = UIColor.darkGrayColor().CGColor;
                self.lbl10.text = personObject.name;
                self.imgDelete10.hidden = true;
                
            }
            
        case 10:
            if isEditMode{
                self.imgDelete11.hidden=false;
            }
            else{
                self.imgView11.image = image1;
                self.imgView11.layer.cornerRadius = self.imgView11.bounds.size.width/2.0;
                self.imgView11.layer.borderWidth = 1.0;
                self.imgView11.layer.borderColor = UIColor.darkGrayColor().CGColor;
                self.lbl11.text = personObject.name;
                self.imgDelete11.hidden = true;
                
            }
        case 11:
            if isEditMode{
                self.imgDelete12.hidden=false;
            }
            else{
                self.imgView12.image = image1;
                self.imgView12.layer.cornerRadius = self.imgView12.bounds.size.width/2.0;
                self.imgView12.layer.borderWidth = 1.0;
                self.imgView12.layer.borderColor = UIColor.darkGrayColor().CGColor;
                self.lbl12.text = personObject.name;
                self.imgDelete12.hidden = true;
                
            }
        case 12:
            if isEditMode{
                self.imgDelete13.hidden=false;
            }
            else{
                self.imgView13.image = image1;
                self.imgView13.layer.cornerRadius = self.imgView13.bounds.size.width/2.0;
                self.imgView13.layer.borderWidth = 1.0;
                self.imgView13.layer.borderColor = UIColor.darkGrayColor().CGColor;
                self.lbl13.text = personObject.name;
                self.imgDelete13.hidden = true;
                
            }
        case 13:
            if isEditMode{
                self.imgDelete14.hidden=false;
            }
            else{
                self.imgView14.image = image1;
                self.imgView14.layer.cornerRadius = self.imgView14.bounds.size.width/2.0;
                self.imgView14.layer.borderWidth = 1.0;
                self.imgView14.layer.borderColor = UIColor.darkGrayColor().CGColor;
                self.lbl14.text = personObject.name;
                self.imgDelete14.hidden = true;
                
            }
        case 14:
            if isEditMode{
                self.imgDelete15.hidden=false;
            }
            else{
                self.imgView15.image = image1;
                self.imgView15.layer.cornerRadius = self.imgView15.bounds.size.width/2.0;
                self.imgView15.layer.borderWidth = 1.0;
                self.imgView15.layer.borderColor = UIColor.darkGrayColor().CGColor;
                self.lbl15.text = personObject.name;
                self.imgDelete15.hidden = true;
                
            }
        
        default:
            println("Default!");
        }
    }
    //------------------------------------------------------------------------------------
    
    func clearData(pid: NSNumber){

        switch pid{

        case 0:
            self.imgView1.image=nil;
            //imgVw2.layer.borderWidth=0;
            self.lbl1.text="";
            self.imgDelete1.hidden=true;
            break;
            
        case 1:
            self.imgView2.image=nil;
            //imgVw2.layer.borderWidth=0;
            self.lbl2.text="";
            self.imgDelete2.hidden=true;
            break;
            
        case 2:
            self.imgView3.image=nil;
            //imgVw3.layer.borderWidth=0;
            self.lbl3.text="";
            self.imgDelete3.hidden=true;
            break;

        case 3:
            self.imgView4.image=nil;
            //imgVw2.layer.borderWidth=0;
            self.lbl4.text="";
            self.imgDelete4.hidden=true;
            break;
   
        case 4:
            self.imgView5.image=nil;
            //imgVw2.layer.borderWidth=0;
            self.lbl5.text="";
            self.imgDelete5.hidden=true;
            break;

        case 5:
            self.imgView6.image=nil;
            //imgVw2.layer.borderWidth=0;
            self.lbl6.text="";
            self.imgDelete6.hidden=true;
            break;

        case 6:
            self.imgView7.image=nil;
            //imgVw2.layer.borderWidth=0;
            self.lbl7.text="";
            self.imgDelete7.hidden=true;
            break;

        case 7:
            self.imgView8.image=nil;
            //imgVw2.layer.borderWidth=0;
            self.lbl8.text="";
            self.imgDelete8.hidden=true;
            break;

        case 8:
            self.imgView9.image=nil;
            //imgVw2.layer.borderWidth=0;
            self.lbl9.text="";
            self.imgDelete9.hidden=true;
            break;

        case 9:
            self.imgView10.image=nil;
            //imgVw2.layer.borderWidth=0;
            self.lbl10.text="";
            self.imgDelete10.hidden=true;
            break;

        case 10:
            self.imgView11.image=nil;
            //imgVw2.layer.borderWidth=0;
            self.lbl11.text="";
            self.imgDelete11.hidden=true;
            break;

        case 11:
            self.imgView12.image=nil;
            //imgVw2.layer.borderWidth=0;
            self.lbl12.text="";
            self.imgDelete12.hidden=true;
            break;

        case 12:
            self.imgView13.image=nil;
            //imgVw2.layer.borderWidth=0;
            self.lbl13.text="";
            self.imgDelete13.hidden=true;
            break;

        case 13:
            self.imgView14.image=nil;
            //imgVw2.layer.borderWidth=0;
            self.lbl14.text="";
            self.imgDelete14.hidden=true;
            break;

        case 14:
            self.imgView15.image=nil;
            //imgVw2.layer.borderWidth=0;
            self.lbl15.text="";
            self.imgDelete15.hidden=true;
            break;
        default:
            println("Default!");

        }
        
    }
//------------------------------------------------------------------------------------
 // MARK: Datbase Methods
    func fetchFromDatabase(){
        
        // Retrieve content from persistent store
        var fetchRequest = NSFetchRequest(entityName: "Person")
        let sortDescriptor = NSSortDescriptor(key: "personID", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        if let managedObjectContext = (UIApplication.sharedApplication().delegate as AppDelegate).managedObjectContext {
            fetchResultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
            fetchResultController.delegate = self
            
            var e: NSError?
            var result = fetchResultController.performFetch(&e)
            personArray = fetchResultController.fetchedObjects as [Person]
            
            println("--->\(personArray.count)");
            
            var i:Int
            for i=0; i < personArray.count ; i++ {
                let personObj = personArray[i];
                println("Person Array Name=> \(personObj.name)");
                self.loadData(personObj);
            }
    
            if result != true {
                println(e?.localizedDescription)
            }
        }

    }
    //------------------------------------------------------------------------------------
    
    func savePersonToDatabase(person :ABRecord!){
        
        var personObject: Person!
        var firstName = ABRecordCopyValue(person, kABPersonFirstNameProperty).takeUnretainedValue() as String;
        var lastName = ABRecordCopyValue(person, kABPersonFirstNameProperty).takeUnretainedValue() as String;
        var companyName = ABRecordCopyValue(person, kABPersonFirstNameProperty).takeUnretainedValue() as String;
        
        if let managedObjectContext = (UIApplication.sharedApplication().delegate as AppDelegate).managedObjectContext{
            personObject = NSEntityDescription.insertNewObjectForEntityForName("Person", inManagedObjectContext: managedObjectContext) as Person
        }
        if countElements(firstName) == 0{
            
            if countElements(lastName) == 0{
            
                if countElements(companyName) == 0{
                    //[self displayErrorAlert:"Contact name or Company Name not found!"];
                }
                else{
                    personObject.name = companyName;
                }
            }
            else{
                    personObject.name = lastName;
                }
        }
        else{
                    personObject.name = firstName;
            }
    
        println("Saved name is --> \(personObject.name)")
        
        //#pragma- save imagepath to Document Directory
        
        //let documentDirectoryPath = self.getDocDirectoryPath();
        if let imageData = ABPersonCopyImageDataWithFormat(person, kABPersonImageFormatThumbnail) {
            personObject.image = imageData.takeRetainedValue()
            /*if let imageToResize = UIImage(data: imageData) {
                personObject.image = UIImage.resizeImage(imageToResize)
            }*/
            
        }
        else{
            let imageString = String(currentPersonID)
            
            if let path = NSBundle.mainBundle().pathForResource(imageString, ofType:"jpg") {
                if let imageData = NSData(contentsOfFile: path) {
                    if let imageToResize = UIImage(data: imageData) {
                        personObject.image = UIImage.resizeImage(imageToResize)
                    }
                    
                }
            }
            
        }
        
        if let managedObjectContext = (UIApplication.sharedApplication().delegate as AppDelegate).managedObjectContext{
            //personObject = NSEntityDescription.insertNewObjectForEntityForName("Person", inManagedObjectContext: managedObjectContext) as Person
            
            personObject.name = firstName;
            personObject.personID = currentPersonID;
            println("===> \(currentPersonID)");
            var e: NSError?
            if managedObjectContext.save(&e) != true {
                println("insert error: \(e!.localizedDescription)")
                return
            }
            
        }
        self.loadData(personObject);
    }

    //------------------------------------------------------------------------------------

    func deleteContact(personToDelete: Person){
        
        let pid = personToDelete.personID;
        self.clearData(pid);
        if let managedObjectContext = (UIApplication.sharedApplication().delegate as AppDelegate).managedObjectContext{
            managedObjectContext.deleteObject(personToDelete);
            // Commit the change.
            var e: NSError?
            if managedObjectContext.save(&e) != true {
                println("Delete error: \(e!.localizedDescription)")
                return
            }
        }
        
    }
    
//------------------------------------------------------------------------------------
    
// MARK: IBActions
    @IBAction func btnPress(sender: AnyObject) {
        
        if (UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)){
            let imagePicker = UIImagePickerController();
            imagePicker.delegate = self;
            imagePicker.sourceType = UIImagePickerControllerSourceType.Camera;
            imagePicker.mediaTypes = [kUTTypeImage as NSString];
            imagePicker.allowsEditing = false;
            imagePicker.cameraDevice = UIImagePickerControllerCameraDevice.Front;
            self.presentViewController(imagePicker, animated: true, completion: nil);
        }
        else{
            let alert = UIAlertController (title: "Error", message: "No camera found!", preferredStyle: UIAlertControllerStyle.Alert);
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler:nil));
            self.presentViewController(alert, animated: true, completion: nil);
        }
    }
//------------------------------------------------------------------------------------
    
    @IBAction func btnClicked(sender: AnyObject) {
        
        let btnTag = sender.tag;
        var personObject: Person!
        var fetchResultArray:[Person] = [];
        
        var fetchRequest = NSFetchRequest(entityName: "Person")
        let sortDescriptor = NSSortDescriptor(key: "personID", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        let fetchPredicate = NSPredicate(format: "personID==%d",btnTag);
        fetchRequest.predicate = fetchPredicate;
        
        
        
        if let managedObjectContext = (UIApplication.sharedApplication().delegate as AppDelegate).managedObjectContext {
            fetchResultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
            fetchResultController.delegate = self
            
            var e: NSError?
            var result = fetchResultController.performFetch(&e)
            fetchResultArray = fetchResultController.fetchedObjects as [Person]
        }
        if fetchResultArray.count == 0{
            let picker = ABPeoplePickerNavigationController();
            currentPersonID = sender.tag;
            println("\(currentPersonID)");
            picker.peoplePickerDelegate = self;
            self.presentViewController(picker, animated: true, completion: nil);
        }
        else{
            personObject = fetchResultArray.last;
            println("Which person tapped? -> \(personObject.name)");
            if(isEditMode){        //edit mode so delete contact.
                self.deleteContact(personObject);
                return;
            }
            //Code for camera goes here
            self.performSegueWithIdentifier("cameraSegue", sender: self)
            
        }
    }
    
    
    //------------------------------------------------------------------------------------
    @IBAction func editPress(sender: AnyObject) {
        isEditMode=true;
        var doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.Plain, target: self, action: Selector ("donePress:"))
        self.navigationItem.leftBarButtonItem = doneButton;
        self.navigationItem.leftBarButtonItem?.tintColor = UIColor.redColor();
        self.fetchFromDatabase();
    }

    //------------------------------------------------------------------------------------
    @IBAction func donePress(sender: AnyObject) {
        isEditMode=false;
        var editButton = UIBarButtonItem(title: "Edit", style: UIBarButtonItemStyle.Plain, target: self, action: Selector ("editPress:"))
        self.navigationItem.leftBarButtonItem=nil;
        self.navigationItem.leftBarButtonItem = editButton;
        self.fetchFromDatabase();
    }
//------------------------------------------------------------------------------------

    // MARK: Addressbook Delegate
    
     func peoplePickerNavigationController(peoplePicker: ABPeoplePickerNavigationController!, didSelectPerson person: ABRecord!) {
        self.savePersonToDatabase(person);
    }

     func peoplePickerNavigationControllerDidCancel(peoplePicker: ABPeoplePickerNavigationController!) {
        self .dismissViewControllerAnimated(true, completion: nil);
    }
    
    func peoplePickerNavigationController(peoplePicker: ABPeoplePickerNavigationController!, shouldContinueAfterSelectingPerson person: ABRecord!, property: ABPropertyID, identifier: ABMultiValueIdentifier) -> Bool {

        //self.peoplePickerNavigation(peoplePicker, didSelectPerson: person, property: property, identifier: identifier);
        return true;
    }
    
    func peoplePickerNavigationController(peoplePicker: ABPeoplePickerNavigationController!,  didSelectPerson person: ABRecord!, property: ABPropertyID, identifier: ABMultiValueIdentifier){
        var firstName = ABRecordCopyValue(person, kABPersonFirstNameProperty);
        println("\(firstName)");
    }
    
//------------------------------------------------------------------------------------
    
    
    // MARK: Document Directory
    
    func getDocDirectoryPath() -> String{
        let documentsPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as NSString
        return documentsPath;
    }
    
//------------------------------------------------------------------------------------
    
    // MARK: Fetch Records
    
    func timerFired(timer: NSTimer) {
        NSLog("Fired")
        let record: CKRecordID = CKRecordID(recordName: myNumber)
        self.fetchRecord(record);
    }
    
    func fetchRecord(recordID: CKRecordID) -> Void {
        publicDatabase = CKContainer.defaultContainer().publicCloudDatabase
        
        var tempRecord: CKRecord?
        var error: NSError?
        publicDatabase?.fetchRecordWithID(recordID) { tempRecord, error in
            if (error != nil) {
                NSLog("Error: " + error.description)
            } else {
                let receiver = tempRecord.objectForKey("ReceiverNumber") as String
                let sender = tempRecord.objectForKey("SenderNumber") as String
                let asset = tempRecord.objectForKey("Image") as CKAsset
                let data = NSData(contentsOfURL: asset.fileURL)
                let image =  UIImage(data: data!)
                let iv = UIImageView(image: image)
//                 dispatch_async(dispatch_get_main_queue()) {
                NSOperationQueue.mainQueue().addOperationWithBlock {
                    let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                    var mainController = mainStoryboard.instantiateViewControllerWithIdentifier("imageView") as IvViewController
                    mainController.image = image
                    self.navigationController?.pushViewController(mainController, animated: true)
                }
                let modifyOperation = CKModifyRecordsOperation(recordsToSave: nil, recordIDsToDelete: [tempRecord.recordID])
                modifyOperation?.modifyRecordsCompletionBlock = { savedRecords, deletedRecords, error in
                    if error == nil {
                        NSLog("Record deletion completed successfully.")
                    } else {
                        NSLog("Error deleting records: %@", error.localizedDescription)
                    }
                }
                self.publicDatabase?.addOperation(modifyOperation)
                NSLog("Receiver: " + receiver + " Sender: " + sender)
                
            }
        }
    }
 
    
    
}