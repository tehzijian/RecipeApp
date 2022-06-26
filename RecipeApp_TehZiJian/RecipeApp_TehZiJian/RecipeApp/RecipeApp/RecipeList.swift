import UIKit

class RecipeListViewController: UIViewController {
   
    let db = DBHelper()
    
    var listViewData = [Recipe]()
    
    @IBOutlet weak var btnSelectRecipeType: UIButton!
    @IBOutlet var listTableView: UITableView!
    let transparentView = UIView()
    let ddlTableView = UITableView()
    var selectedbutton = UIButton()
    var dataSource = [String] ()
//    let db = Firestore.firestore()
    
    var documentsUrl: URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        listViewData = db.readRecipe()
        listTableView.register(TableViewCell.nib(), forCellReuseIdentifier: TableViewCell.cellIndentifier)
        listTableView.delegate = self
        listTableView.dataSource = self
        ddlTableView.delegate = self
        ddlTableView.dataSource = self
        ddlTableView.register(DdlTableViewCell.self, forCellReuseIdentifier: "ddlCell")
    }
    

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        btnSelectRecipeType.setTitle("Select Recipe Type", for: .normal)
        listViewData = db.readRecipe()
        self.listTableView.reloadData()
        
    }
    
    func addTransparentView(frames: CGRect) {
        let window  = UIApplication.shared.keyWindow
        transparentView.frame = window?.frame ?? self.view.frame
        self.view.addSubview(transparentView)
        
        ddlTableView.frame = CGRect(x: frames.origin.x, y: frames.origin.y + frames.height, width: frames.width, height: 0)
        
        self.view.addSubview(ddlTableView)
        ddlTableView.layer.cornerRadius = 4
        
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
    
    
    @IBAction func onCLickAddNewRecipe(_ sender: Any) {
        let vc = storyboard?.instantiateViewController(identifier: "AddRecipeViewController") as? AddRecipeViewController
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    
    @IBAction func onClickSelectType(_ sender: Any) {
        var newSelect:[String] = ["Select Recipe Type"]
        newSelect.append(contentsOf: getXmlData())
        dataSource = newSelect
        selectedbutton = btnSelectRecipeType
        addTransparentView(frames: btnSelectRecipeType.frame)
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
}

class DdlTableViewCell:TableViewCell{
    
}
        
extension RecipeListViewController: UITableViewDataSource, UITableViewDelegate{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
     
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var size:CGFloat = 10.0
        switch tableView {
        case listTableView:
            size  = 120.0
        case ddlTableView:
            size = 50.0
        default:
            print("something wrong here")
        }
        
        return size
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var numberOfRow = 1
        switch tableView {
        case listTableView:
            numberOfRow = listViewData.count
        case ddlTableView:
            numberOfRow = dataSource.count
        default:
            print("something wrong here")
        }
        return numberOfRow
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = TableViewCell()
        
        switch tableView {
        case listTableView:
            cell = tableView.dequeueReusableCell(withIdentifier: TableViewCell.cellIndentifier, for: indexPath) as! TableViewCell
            
            let model = listViewData[indexPath.row]
            cell.configure(with: CellViewModel(recipeName: model.recipeName ,recipeType: model.recipeType, recipeTime: Int(model.recipeTime)))
            //TODO: change to proper image url
            cell.foodImg.image = load(fileName: listViewData[indexPath.row].imageFilePath)
        case ddlTableView:
            cell = tableView.dequeueReusableCell(withIdentifier: "ddlCell", for: indexPath) as! TableViewCell
            cell.textLabel?.text = dataSource[indexPath.row]
        default:
            print("something wrong here")
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch tableView {
        case listTableView:
            let vc = storyboard?.instantiateViewController(identifier: "RecipeDetailViewController") as? RecipeDetailViewController
            tableView.deselectRow(at: indexPath, animated: true)
            
            if let imageExist = UIImage(named: listViewData[indexPath.row].recipeName){
                vc?.image = imageExist
            }
            vc?.singleRecipe = listViewData[indexPath.row]
            vc?.imageFilePath = listViewData[indexPath.row].imageFilePath
            vc?.name = listViewData[indexPath.row].recipeName
            vc?.recipeID = listViewData[indexPath.row].Rid
            self.navigationController?.pushViewController(vc!, animated: true)
        case ddlTableView:
            //TODO: selected type filter
            selectedbutton.setTitle(dataSource[indexPath.row], for: .normal)
            removeTransparentView()
            if dataSource[indexPath.row] == "Select Recipe Type"{
                listViewData = db.readRecipe()
            }else{
                listViewData = db.filterRecipe(recipeType: dataSource[indexPath.row])
            }
            self.listTableView.reloadData()
            
        default:
            print("something wrong here")
        }
        
        
    }
}
extension UIViewController{

    func showToast(messages : String, seconds: Double){
        let alert = UIAlertController(title: nil, message: messages, preferredStyle: .alert)
        alert.view.backgroundColor = .black
        alert.view.alpha = 0.5
        alert.view.layer.cornerRadius = 15
        self.present(alert, animated: true)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + seconds) {
            alert.dismiss(animated: true)
        }
    }
 }
