import UIKit

class TableViewCell: UITableViewCell {
    
    @IBOutlet var foodLabel:UILabel!
    @IBOutlet var foodSp:UILabel!
    @IBOutlet var foodTime:UILabel!
    @IBOutlet weak var foodImg: UIImageView!
    
    static let cellIndentifier = "TableViewCell"

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code 
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    static func nib() -> UINib {
        return UINib(nibName: "TableViewCell", bundle: nil)
    }
    
    public func configure(with viewModel: CellViewModel){
        foodLabel.text = "Name: " + "\(viewModel.recipeName)"
        foodSp.text = "Type: " + "\(viewModel.recipeType)"
        //foodTime.text = "\(viewModel.recipeTime)" + " minutes"
        let Fdtime = viewModel.recipeTime
        var recipeHour = Decimal(0)
        var rounded = Decimal()
        if(Fdtime >= 60){
            recipeHour = Decimal(Fdtime / 60)
            NSDecimalRound(&rounded, &recipeHour, 0, .down)
            let thisHour = (rounded as NSDecimalNumber).intValue
            let thisMin = Fdtime - (thisHour * 60)
            let Minutes = (thisMin == 0) ? "\(thisHour)" + " Hour " : (thisMin >= 0) ? "\(thisHour)" + " H " + "\(thisMin)" + "min" : "\(thisMin)" + "min"
            foodTime.text = Minutes
        }else if(Fdtime < 60){
            foodTime.text = "\(viewModel.recipeTime)" + " minutes"
        }
    }
    
}
