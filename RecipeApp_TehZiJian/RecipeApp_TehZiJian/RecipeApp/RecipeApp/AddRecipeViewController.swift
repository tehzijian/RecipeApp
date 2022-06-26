import Foundation
import UIKit

class AddRecipeViewController: UIViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var RecipeName: UITextField!
    @IBOutlet weak var Ingredient: UITextField!
    @IBOutlet weak var Step: UITextField!
    @IBOutlet weak var RecipeTypesBtn: UIButton!
    @IBOutlet weak var RecipeImageView: UIImageView!
    @IBOutlet weak var RecipeTime: UITextField!
    @IBOutlet weak var UploadImageButton: UIButton!
    @IBOutlet weak var AddRecipeButton: UIButton!
    var uploadImage = UIImagePickerController()
    let transparentView = UIView()
    let ddlTableView = UITableView()
//    let db = Firestore.firestore()
    let db = DBHelper()
    var selectedbutton = UIButton()
    var dataSource = [String] ()
    var photoUrl: String = ""
    var documentsUrl: URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        RecipeTime.delegate = self
        ddlTableView.delegate = self
        ddlTableView.dataSource = self
        ddlTableView.register(DdlTableViewCell.self, forCellReuseIdentifier: "ddlCell")
        self.uploadImage.delegate = self
        // Do any additional setup after loading the view.
    }
    
    @IBAction func selectType(_ sender: Any) {
        var newSelect:[String] = ["Select Recipe Type"]
        newSelect.append(contentsOf: getXmlData())
        dataSource = newSelect
        selectedbutton = RecipeTypesBtn
        addTransparentView(frames: RecipeTypesBtn.frame)
    }
    
    @IBAction func saveRecipe(_ sender: Any) {
        let tfName = RecipeName.text ?? ""
        let tfIngredient = Ingredient.text ?? ""
        let tfStep = Step.text ?? ""
        let savedUrl = save(image: self.RecipeImageView.image!)
        let tfTime = Int(RecipeTime.text!) ?? 0
        if (!validate()){
            let alert = UIAlertController(title: "Add New Recipe Confirmation", message: "Would you like to add new recipes?", preferredStyle: UIAlertController.Style.alert)

            // add the actions (buttons)
            alert.addAction(UIAlertAction(title: "Add", style: UIAlertAction.Style.default,handler: { [self]_ in
                
                db.insertData(recipeName: tfName, ingredient: tfIngredient, step: tfStep, recipeType: (RecipeTypesBtn.titleLabel?.text?.lowercased())!, img: savedUrl!, recipeTime: tfTime)
                self.navigationController?.popToRootViewController(animated: true)
                self.tabBarController?.selectedIndex = 0
                RecipeName.text = ""
                Ingredient.text = ""
                Step.text = ""
                RecipeImageView.image = UIImage(named:  "placeholder")
                RecipeTime.text = ""
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))

            // show the alert
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    
    
    @IBAction func UploadImage(_ sender: Any) {
        self.uploadImage.allowsEditing = false
        self.uploadImage.sourceType = .savedPhotosAlbum

        self.present(uploadImage, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let selectedImage = info[.originalImage] as? UIImage else {
            fatalError("Expected a dictionary containing an image, but was provided the following: \(info)")
        }
        self.RecipeImageView.contentMode = .scaleAspectFit
        self.RecipeImageView.image = selectedImage
        dismiss(animated: true, completion: nil)
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

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.uploadImage = UIImagePickerController()
        dismiss(animated: true, completion: nil)
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
        if RecipeName.text!.isEmpty {
            errors = true
            message += "Please Fill in Recipe Name"
            alertWithTitle(title: title, message: message, ViewController: self, toFocus:self.RecipeName)
        }
        if Ingredient.text!.isEmpty {
            errors = true
            message += "Please Fill in Ingredients"
            alertWithTitle(title: title, message: message, ViewController: self, toFocus:self.Ingredient)
        }
        if Step.text!.isEmpty {
            errors = true
            message += "Please Fill in Steps"
            alertWithTitle(title: title, message: message, ViewController: self, toFocus:self.Step)
        }
        if RecipeTime.text!.isEmpty {
            errors = true
            message += "Please Fill in Recipe Time"
            alertWithTitle(title: title, message: message, ViewController: self, toFocus:self.Step)
        }
        if RecipeTypesBtn.titleLabel?.text == "Select Recipe Types" {
            errors = true
            message += "Please select one of the types"
            alertWithTitle(title: title, message: message, ViewController: self, toFocus:self.RecipeName)
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
}

extension AddRecipeViewController: UITableViewDataSource, UITableViewDelegate{
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

extension UIViewController{

func showToast(message : String, seconds: Double){
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.view.backgroundColor = .black
        alert.view.alpha = 0.5
        alert.view.layer.cornerRadius = 15
        self.present(alert, animated: true)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + seconds) {
            alert.dismiss(animated: true)
        }
    }
 }
