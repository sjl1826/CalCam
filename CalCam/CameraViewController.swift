//
//  viewController2.swift
//  nachenbois
//
//  Created by Samuel J. Lee on 3/6/18.
//  Copyright © 2018 Samuel J. Lee. All rights reserved.
//

import UIKit
import EventKit

class CameraViewController : UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    let imagePicker = UIImagePickerController()
    
    func cameraop() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            imagePicker.sourceType = .camera;
            imagePicker.allowsEditing = false
            imagePicker.delegate = self
            self.present(imagePicker, animated: true, completion: nil)
        }
        else
        {
            let alert  = UIAlertController(title: "Warning", message: "You don't have camera", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func openCamera(_ sender: UIButton) {
        cameraop()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // loads
    }
    
    @IBOutlet weak var myImg: UIImageView!
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            myImg.contentMode = .scaleToFill
            myImg.image = pickedImage
            // Convert image to base 64
            let b64Str: String = imgToB64(img: pickedImage)
            // Pass to Google OCR
            GoogleOCRHandler.postToGoogle(imageData: b64Str, callback: handleOCR)
        }
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func reTake(_ sender: Any) {
        cameraop()
    }
    
    
    @IBAction func addtoCalendar(_ sender: Any) {
        
        let eventStore:EKEventStore = EKEventStore()
        eventStore.requestAccess(to: .event) {(granted, error) in
            
            if(granted) && (error == nil){
                print("granted\(granted)")
                let event:EKEvent = EKEvent(eventStore: eventStore)
                event.title = "Winter Showcase 2018"
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy/MM/dd HH:mm"
                let startTime = formatter.date(from: "2018/03/12 18:00")
                event.startDate = startTime
                let endTime = formatter.date(from: "2018/03/12 20:00")
                event.endDate = endTime
                event.notes = "Theoria Foundations Choreography"
                event.location = "UCLA Ackerman Grand Ballroom"
                event.calendar = eventStore.defaultCalendarForNewEvents
                do{
                    try eventStore.save(event, span: .thisEvent)
                    print("saved event")
                }catch let error as NSError{
                    print("error")
                }
                
            }
            else{
                print("error : \(error)")
            }
        }
    }
    
    func imgToB64(img: UIImage) -> String {
        let imgData: Data = UIImagePNGRepresentation(img)!
        return imgData.base64EncodedString()
    }
    
    func handleOCR(text: String) {
        print(text)
    }
    
}

