//
//  DetailsVC.swift
//  Sanat Kitabim
//
//  Created by Serhat  Şimşek  on 5.06.2023.
//

import UIKit
import CoreData

class DetailsVC: UIViewController,UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var artistLabel: UITextField!
    @IBOutlet weak var nameLabel: UITextField!
    @IBOutlet weak var yearLabel: UITextField!
    
    @IBOutlet weak var saveButtonOutlet: UIButton!
    
    var chosenPainting = ""
    var chosenPaintingId : UUID?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if chosenPainting != ""{
            
            saveButtonOutlet.isHidden = true
            
            // core data
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            
            let fetcRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Eserler")
            let idString = chosenPaintingId?.uuidString
            
            fetcRequest.predicate = NSPredicate(format: "id = %@", idString!)
            fetcRequest.returnsObjectsAsFaults = false
            
            do{
                let results =  try context.fetch(fetcRequest)
                if results.count > 0 {
                    
                    for result in results as! [NSManagedObject]{
                        if let name = result.value(forKey: "name") as? String{
                            nameLabel.text = name
                        }
                        if let artist = result.value(forKey: "artist") as? String{
                            artistLabel.text = artist
                        }
                        if let year = result.value(forKey: "year") as? Int{
                            yearLabel.text = String(year)
                        }
                        if let imageData = result.value(forKey: "image") as? Data{
                            let image = UIImage(data: imageData)
                            imageView.image = image
                        }
                    }
                    
                }
            }catch {
            print("Details sınıfındaki veriler çekilemedi")
            }
        } else{
            saveButtonOutlet.isEnabled = false
        }
        
        
        // recognizer
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(gestureRecognizer)
        
        imageView.isUserInteractionEnabled = true
        let imageTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(selectImage))
        imageView.addGestureRecognizer(imageTapRecognizer)
    }
    
    @objc func selectImage(){
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        present(picker, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imageView.image = info[.editedImage] as? UIImage
        saveButtonOutlet.isEnabled = true
        self.dismiss(animated: true)
    }
    
    @objc func hideKeyboard(){
        view.endEditing(true)
    }
    
    @IBAction func saveButton(_ sender: Any) {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let newPainting = NSEntityDescription.insertNewObject(forEntityName: "Eserler", into: context)
        
        newPainting.setValue(artistLabel.text, forKey: "artist")
        newPainting.setValue(nameLabel.text, forKey: "name")
        newPainting.setValue(UUID(), forKey: "id")
        
        if let year = Int(yearLabel.text!) {
            newPainting.setValue(year, forKey: "year")
        }
        
        let data = imageView.image?.jpegData(compressionQuality: 0.5)
        newPainting.setValue(data, forKey: "image")
        
        do{
            try context.save()
            print("kayıt başarılı")
        } catch {
            print("kayıt hatası")
        }
        
        NotificationCenter.default.post(name: NSNotification.Name("newData"), object: nil)
        
        self.navigationController?.popViewController(animated: true)
        
        
    }
}
