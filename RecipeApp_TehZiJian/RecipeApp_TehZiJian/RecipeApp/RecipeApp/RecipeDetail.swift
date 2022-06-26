import UIKit

class RecipeDetailViewController: UIViewController {

    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var recipeImg: UIImageView!
    @IBOutlet weak var ingredientLabel: UILabel!
    @IBOutlet weak var stepLabel: UITextView!
    @IBOutlet weak var recipeTypeLabel: UILabel!
    @IBOutlet weak var recipeTime: UILabel!
    
    var db = DBHelper()
    
    var image = UIImage()
    var name = ""
    var recipeID: String=""
    var singleRecipe = Recipe(Rid: "", recipeName: "", ingredient: "", step: "", recipeType: "", imageFilePath: "", recipeTime: 0)
    var documentsUrl: URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    }
    var imageFilePath: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        stepLabel.isEditable = false
        label.text = "Name: " + "\(name)"
        ingredientLabel.text = "Ingredient: " + "\(singleRecipe.ingredient)"
        stepLabel.text = "Step: \n" + "\(singleRecipe.step)"
        recipeTypeLabel.text = "Recipe Type: " + "\(singleRecipe.recipeType)"
        //rename the image between image and image view
        recipeImg.image = load(fileName: imageFilePath)
        
        let Fdtime = singleRecipe.recipeTime
        var recipeHour = Decimal(0)
        var rounded = Decimal()
        if(Fdtime >= 60){
            recipeHour = Decimal(Fdtime / 60)
            NSDecimalRound(&rounded, &recipeHour, 0, .down)
            let thisHour = (rounded as NSDecimalNumber).intValue
            let thisMin = Fdtime - (thisHour * 60)
            let Minutes = (thisMin == 0) ? "\(thisHour)" + " Hour " : (thisMin >= 0) ? "\(thisHour)" + " Hour " + "\(thisMin)" + "min" : "\(thisMin)" + "min"
            recipeTime.text = "Recipe Time: " + Minutes
        }else if(Fdtime < 60){
            recipeTime.text = "Recipe Time: " + "\(singleRecipe.recipeTime)" + " minutes"
        }
    }
    

    @IBAction func OnclickEdit(_ sender: Any) {
        let vc = storyboard?.instantiateViewController(identifier: "ModifyRecipeViewController") as? ModifyRecipeViewController
        
        vc?.modifyRecipe = self.singleRecipe
        self.navigationController?.pushViewController(vc!, animated: true)
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
    
    @IBAction func OnClickDelete(_ sender: Any) {
        let alert = UIAlertController(title: "Delete Confirmation", message: "Would you like to delete selected recipes?", preferredStyle: UIAlertController.Style.alert)

        // add the actions (buttons)
        alert.addAction(UIAlertAction(title: "Delete", style: UIAlertAction.Style.default,handler: {_ in
            _ = self.navigationController?.popViewController(animated: true)
            
            self.db.deleteRecipe(id: self.recipeID)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))

        // show the alert
        self.present(alert, animated: true, completion: nil)
        
    }
    

}
