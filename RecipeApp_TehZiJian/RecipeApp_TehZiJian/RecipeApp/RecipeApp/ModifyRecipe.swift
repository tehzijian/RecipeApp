import Foundation
import UIKit

class ModifyRecipeViewController:UIViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate, UITextFieldDelegate{
    
    @IBOutlet weak var recipeNameTextField: UITextField!
    @IBOutlet weak var ingredientTextField: UITextField!
    @IBOutlet weak var stepTextField: UITextField!
    @IBOutlet weak var recipeTypeButton: UIButton!
    @IBOutlet weak var RecipeImageView: UIImageView!
    @IBOutlet weak var recipeTimeField: UITextField!
    @IBOutlet weak var selectNewImageButton: UIButton!
    @IBOutlet weak var updateButton: UIButton!
    
    var modifyRecipe = Recipe(Rid: "", recipeName: "", ingredient: "", step: "", recipeType: "", imageFilePath: "", recipeTime: 0)
//    var db = Firestore.firestore()
    var documentsUrl: URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    }
    
    var db = DBHelper()
    var imagePicker = UIImagePickerController()
    var selectedbutton = UIButton()
    var dataSource = [String] ()
    let transparentView = UIView()
    let ddlTableView = UITableView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        recipeTimeField.delegate = self
        ddlTableView.delegate = self
        ddlTableView.dataSource = self
        self.imagePicker.delegate = self
        ddlTableView.register(DdlTableViewCell.self, forCellReuseIdentifier: "ddlCell")
        recipeNameTextField.text = modifyRecipe.recipeName
        ingredientTextField.text = modifyRecipe.ingredient
        stepTextField.text = modifyRecipe.step
        recipeTimeField.text = String(modifyRecipe.recipeTime)
        recipeTypeButton.setTitle("\(modifyRecipe.recipeType)", for: .normal)
        RecipeImageView.image = load(fileName: modifyRecipe.imageFilePath)
    }
    
    @IBAction func updateRecipe(_ sender: Any) {
        let savedUrl = save(image: self.RecipeImageView.image!)
        if (!validate()){
            let alert = UIAlertController(title: "Update Recipe Confirmation", message: "Would you like to update recipes information?", preferredStyle: UIAlertController.Style.alert)

            // add the actions (buttons)
            alert.addAction(UIAlertAction(title: "Update", style: UIAlertAction.Style.default,handler: { [self]_ in
                
                self.db.updateRecipe(id: self.modifyRecipe.Rid, recipeName: recipeNameTextField.text!, ingredient: ingredientTextField.text!, step: stepTextField.text!, recipeType: (recipeTypeButton.titleLabel?.text?.lowercased())!, img: savedUrl!, recipeTime: Int(recipeTimeField.text ?? "")!)
                self.navigationController?.popToRootViewController(animated: true)
                

            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))

            // show the alert
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func selectRecipeType(_ sender: Any) {
        dataSource = getXmlData()
        selectedbutton = recipeTypeButton
        addTransparentView(frames: recipeTypeButton.frame)
    }
    
    @IBAction func selectNewImage(_ sender: Any) {
        
        self.imagePicker.allowsEditing = false
        self.imagePicker.sourceType = .savedPhotosAlbum

        self.present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let selectedImage = info[.originalImage] as? UIImage else {
            fatalError("Expected a dictionary containing an image, but was provided the following: \(info)")
        }
        self.RecipeImageView.contentMode = .scaleAspectFit
        self.RecipeImageView.image = selectedImage
        
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.imagePicker = UIImagePickerController()
        dismiss(animated: true, completion: nil)
    }
    
    func addTransparentView(frames: CGRect) {
        let window  = UIApplication.shared.keyWindow
        transparentView.frame = window?.frame ?? self.view.frame
        self.view.addSubview(transparentView)
        
        ddlTableView.frame = CGRect(x: frames.origin.x, y: frames.origin.y + frames.height, width: frames.width, height: 0)
        
        self.view.addSubview(ddlTableView)
        ddlTableView.layer.cornerRadius = 5
        
        transparentView.backgroundColor = UIColor.black.withAlphaComponent(0.9)
        ddlTableView.reloadData()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(removeTransparentView))
        transparentView.addGestureRecognizer(tapGesture)
        transparentView.alpha = 0
        UIView.animate(withDuration: 0.4, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: .curveEaseOut,
                       animations: {
                        self.transparentView.alpha = 0.5
                        self.ddlTableView.frame = CGRect(x: frames.origin.x, y: frames.origin.y + frames.height, width: frames.width, height: 200)
                       }, completion: nil)
        
    }
    
    @objc func removeTransparentView(){
        let frames = selectedbutton.frame
        UIView.animate(withDuration: 0.4, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: .curveEaseOut,
                       animations: {
                        self.transparentView.alpha = 0
                        self.ddlTableView.frame = CGRect(x: frames.origin.x, y: frames.origin.y + frames.height, width: frames.width, height: 0)
                       }, completion: nil)
    }
    
    
    private func save(image: UIImage) -> String? {
        
        let fileName = String(arc4random())
        let fileURL = documentsUrl.appendingPathComponent(fileName)
        if let imageData = image.jpegData(compressionQuality: 1.0) {
           try? imageData.write(to: fileURL, options: .atomic)
           return fileName // ----> Save fileName
        }
        print("Error saving image")
        return nil
    }
    
    private func load(fileName: String) -> UIImage? {
        let fileURL = documentsUrl.appendingPathComponent(fileName)
        do {
            let imageData = try Data(contentsOf: fileURL)
            return UIImage(data: imageData)
        } catch {
            print("Error loading image : \(error)")
        }
        return nil
    }
    
    func textField(_ recipeTimeField: UITextField,
      shouldChangeCharactersIn range: NSRange,
      replacementString string: String) -> Bool {
      let invalidCharacters =
        CharacterSet(charactersIn: "0123456789").inverted
      return (string.rangeOfCharacter(from: invalidCharacters) == nil)
    }
        
    
    func validate() -> Bool {
        var errors = false
        let title = "Error"
        var message = ""
        if recipeNameTextField.text!.isEmpty {
            errors = true
            message += "Please Fill in Recipe Name"
            alertWithTitle(title: title, message: message, ViewController: self, toFocus:self.recipeNameTextField)
        }
        if ingredientTextField.text!.isEmpty {
            errors = true
            message += "Please Fill in Ingredients"
            alertWithTitle(title: title, message: message, ViewController: self, toFocus:self.ingredientTextField)
        }
        if stepTextField.text!.isEmpty {
            errors = true
            message += "Please Fill in Steps"
            alertWithTitle(title: title, message: message, ViewController: self, toFocus:self.stepTextField)
        }
        if recipeTimeField.text!.isEmpty {
            errors = true
            message += "Please Fill in Recipe Time"
            alertWithTitle(title: title, message: message, ViewController: self, toFocus:self.recipeTimeField)
        }
        if recipeTypeButton.titleLabel?.text == "Select Recipe Type" {
            errors = true
            message += "Please select one of the types"
            alertWithTitle(title: title, message: message, ViewController: self, toFocus:self.stepTextField)
        }
        return errors
    }
    
    func alertWithTitle(title: String!, message: String, ViewController: UIViewController, toFocus:UITextField) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: UIAlertAction.Style.cancel,handler: {_ in
                toFocus.becomeFirstResponder()
            });
            alert.addAction(action)
        ViewController.present(alert, animated: true, completion:nil)
    }
    
}


extension ModifyRecipeViewController: UITableViewDataSource, UITableViewDelegate{
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = TableViewCell()
        
        cell = tableView.dequeueReusableCell(withIdentifier: "ddlCell", for: indexPath) as! TableViewCell
                    cell.textLabel?.text = dataSource[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //TODO: selected type filter
                    selectedbutton.setTitle(dataSource[indexPath.row], for: .normal)
                    removeTransparentView()
        
    }
}
