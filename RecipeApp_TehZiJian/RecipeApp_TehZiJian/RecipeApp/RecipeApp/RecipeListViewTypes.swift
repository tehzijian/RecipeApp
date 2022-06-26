import Foundation


struct Recipe {
    let Rid: String
    let recipeName: String
    let ingredient: String
    let step: String
    let recipeType:String
    let imageFilePath: String
    let recipeTime: Int
}
struct CellViewModel{
    let recipeName: String
    let recipeType:String
    let recipeTime: Int
}
