//
//  VibeWriteViewController.swift
//  CleverVibes
//
//  Created by Josh Safran on 4/19/17.
//  Copyright © 2017 Josh Safran. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import AlamofireImage

class VibeWriteViewController:UIViewController,UICollectionViewDelegate,UITextViewDelegate{
    @IBOutlet weak var artImageView: UIImageView!
    
//    @IBOutlet weak var vibeTextField: UITextField!
    @IBOutlet weak var doneButton: UIButton!
    
    @IBOutlet weak var artChooseButton: UIButton!
    
    var galleryName = ""
    
    var chosenArtObject:ArtObject?
    
    var artGridVC : VibeWriteArtSelectionViewController?
    
    var artDataSource: ArtCollectionDataSource?
    
    @IBOutlet weak var textView: UITextView!
    var hasTouchedTextView = false
    
    let characterLimit = 38;
    
    func setupWithArtDataSource(source:ArtCollectionDataSource){
        artDataSource = source
    }
    
    override func viewDidLoad() {
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        
        //Uncomment the line below if you want the tap not not interfere and cancel other interactions.
        tap.cancelsTouchesInView = false
        
        navigationController?.navigationBar.backItem
        
        view.addGestureRecognizer(tap)
        var button = UIBarButtonItem(title: "Back", style: UIBarButtonItemStyle.plain, target: self, action: "goBack")
        self.navigationItem.backBarButtonItem = button
        
    }
    
    func goBack()
    {
        self.navigationController?.popViewController(animated: true)
    }
    
    
    @IBAction func didTapChooseArtButton(_ sender: Any) {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "WriteVibeArtSelectionScene") as? VibeWriteArtSelectionViewController{
//            vc.setupWithGalleryName(galleryName: galleryName)
//            
//            vc.collectionView?.delegate = self
            
            artGridVC = vc
            vc.dataSource = artDataSource
            vc.delegate = self
            
            
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @IBAction func didTapSubmit(_ sender: Any) {
        if(!isDoneButtonAvailable()){
            var alert = UIAlertController(title: "Required Info", message: "Both a chosen art piece and Vibe clue are necessary to submit.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil);
            return;
        }
        
        if(ProfanityController.doesStringContainProfanity(str: textView.text)){
            var alert = UIAlertController(title: "Profanity", message: "This app is friendly for all, try to keep your language the same!", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
            textView.text = "";
            self.present(alert, animated: true, completion: nil);
            return;
        }
        
        
        
        var newVibe = VibeObject()
        //        newVibe.clue = vibeTextField.text!
        newVibe.clue = textView.text;
        newVibe.answerObjectNumber = chosenArtObject!.objectNumber
        newVibe.galleryName = galleryName
        
        if let vc = storyboard?.instantiateViewController(withIdentifier: "UploadVibeScreen") as? UploadVibeViewController{
            vc.navController = navigationController
            
            vc.setupWithVibeObject(obj: newVibe)
            
            navigationController?.present(vc, animated: true, completion:nil );
        }
    }
    
    
    
    func setupWithGalleryName(name:String){
        galleryName = name
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        chosenArtObject = artDataSource?.artObjectSet[indexPath.row]
        loadImageForArtObject(obj: chosenArtObject!)
        navigationController?.popViewController(animated: true)
        
        

    }
    
    func loadImageForArtObject(obj:ArtObject){
        let url = obj.fullURL
        Alamofire.request(url).responseImage { response in
            if let image = response.result.value {
                
                if(self.artImageView != nil){
                    self.artImageView.image = image;
                }else{
                    print("Missing full reference");
                }
                
            }
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n"){
            dismissKeyboard();
            return false;
        }
        
        var isRemovingText = text.characters.count == 0 && range.length >= 1;
        
        if(!isRemovingText && textView.text.characters.count >= characterLimit){
            return false;
        }
        
        
        
        return true;
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if(!hasTouchedTextView){
            textView.text = "";
            textView.textColor = UIColor.black;
            hasTouchedTextView = true;
        }
    }
    
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        dismissKeyboard()
        return true
    }
    

    func dismissKeyboard(){
        view.endEditing(true)
        
    }
    
    func isDoneButtonAvailable()->Bool{
        let available = chosenArtObject != nil &&
                        textView.text != nil &&
                        textView.text.characters.count != 0 &&
                        hasTouchedTextView
        return available
    }
}
