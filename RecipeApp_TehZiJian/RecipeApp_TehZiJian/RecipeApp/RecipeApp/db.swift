import Foundation
import SQLite3

class DBHelper {
    var db: OpaquePointer?
    var path: String = "RecipeApp.sqlite"
    var dbData = [Recipe]()
    

    init(){
        self.db = createDB()
        self.createTable()
    }
    
    func createDB() -> OpaquePointer?{
        let filePath = try! FileManager.default.url(for: .documentDirectory,
                                                    in: .userDomainMask,
                                                    appropriateFor: nil,
                                                    create: false).appendingPathExtension(path)
        
        var db: OpaquePointer? = nil
        
        if sqlite3_open(filePath.path, &db) != SQLITE_OK{
            print("There is an error in create the db")
            return nil
        }else{
            print("database has been created with path \(path)")
            return db
        }
    }
    
    func createTable(){
        let query = "CREATE TABLE IF NOT EXISTS NRecipes(Rid INTEGER PRIMARY KEY AUTOINCREMENT, RecipeName TEXT, Ingredient TEXT, Step TEXT, RecipeType TEXT, Img TEXT, RecipeTime INTEGER);"
        
        var createTable: OpaquePointer? = nil
        
        if sqlite3_prepare_v2(self.db, query, -1, &createTable, nil) == SQLITE_OK {
            if sqlite3_step(createTable) == SQLITE_DONE{
                print("Table creation success")
            }else{
                print("Table creation failed")
            }
        }else{
            print("preparation failed")
        }
    }
    
    func insertData(recipeName: String, ingredient: String, step: String, recipeType:String, img:String, recipeTime: Int){
        let insertQuery = "INSERT INTO NRecipes (Rid, RecipeName, Ingredient, Step, RecipeType, Img, RecipeTime) VALUES(?, ?, ?, ?, ?, ?, ?)"
        
        var statement: OpaquePointer? = nil
        var isEmpty = false
        if readRecipe().isEmpty{
            isEmpty = true
        }
        
        if sqlite3_prepare_v2(db, insertQuery, -1, &statement, nil) == SQLITE_OK{
            if isEmpty{
                sqlite3_bind_int(statement, 1, 1)
            }
            sqlite3_bind_text(statement, 2, (recipeName as NSString).utf8String, -1, nil)
            sqlite3_bind_text(statement, 3, (ingredient as NSString).utf8String, -1, nil)
            sqlite3_bind_text(statement, 4, (step as NSString).utf8String, -1, nil)
            sqlite3_bind_text(statement, 5, (recipeType as NSString).utf8String, -1, nil)
            sqlite3_bind_text(statement, 6, (img as NSString).utf8String, -1, nil)
            sqlite3_bind_int(statement, 7, Int32(recipeTime))
            if sqlite3_step(statement) == SQLITE_DONE {
                print("data insert success")
            }else{
                print("data is not inserted")
            }
        }else{
            print("query is not the requirement of the table")
        }
    }
    
    func readRecipe() -> [Recipe]  {
        //var list
        var listRecipe = [Recipe]()
        let readQuery = "SELECT * FROM NRecipes;"
        var statement: OpaquePointer? = nil
        
        if sqlite3_prepare_v2(db, readQuery, -1, &statement, nil) == SQLITE_OK{
            while sqlite3_step(statement) == SQLITE_ROW {
                let id = sqlite3_column_int(statement, 0)
                let name = String(describing: String(cString: sqlite3_column_text(statement, 1)))
                let ingredient = String(describing: String(cString: sqlite3_column_text(statement, 2)))
                let step = String(describing: String(cString: sqlite3_column_text(statement, 3)))
                let recipeType = String(describing: String(cString: sqlite3_column_text(statement, 4)))
                let img = String(describing: String(cString: sqlite3_column_text(statement, 5)))
                let recipeTime = sqlite3_column_int(statement, 6)
                
                let model = Recipe(Rid: String(id), recipeName: name, ingredient: ingredient, step: step, recipeType: recipeType, imageFilePath: img, recipeTime: Int(recipeTime))
                listRecipe.append(model)
            }
        }else{
            print("query is not the requirement of the table")
        }
        return listRecipe
    }
    
    func readParticularRecipe(id: String) -> Recipe  {
        //var list
        var listRecipe = Recipe(Rid: "", recipeName: "", ingredient: "", step: "", recipeType: "", imageFilePath: "", recipeTime: 0)
        let readQuery = "SELECT * FROM NRecipes where Rid = \(id) ;"
        var statement: OpaquePointer? = nil
        
        if sqlite3_prepare_v2(db, readQuery, -1, &statement, nil) == SQLITE_OK{
            while sqlite3_step(statement) == SQLITE_ROW {
                let id = String(describing: String(cString: sqlite3_column_text(statement, 0)))
                let name = String(describing: String(cString: sqlite3_column_text(statement, 1)))
                let ingredient = String(describing: String(cString: sqlite3_column_text(statement, 2)))
                let step = String(describing: String(cString: sqlite3_column_text(statement, 3)))
                let recipeType = String(describing: String(cString: sqlite3_column_text(statement, 4)))
                let img = String(describing: String(cString: sqlite3_column_text(statement, 5)))
                let recipeTime = sqlite3_column_int(statement, 6)
                
                let model = Recipe(Rid: String(id), recipeName: name, ingredient: ingredient, step: step, recipeType: recipeType, imageFilePath: img, recipeTime: Int(recipeTime))
                listRecipe = model
            }
        }else{
            print("query is not the requirement of the table")
        }
        return listRecipe
    }
    
    func updateRecipe(id: String,recipeName: String, ingredient: String, step: String, recipeType:String, img:String, recipeTime: Int){
        let updateQuery = "UPDATE NRecipes SET RecipeName = '\(recipeName)', Ingredient = '\(ingredient)', Step = '\(step)', RecipeType = '\(recipeType)', Img = '\(img)', RecipeTime = '\(recipeTime)' WHERE Rid = \(id);"
        
        var statement: OpaquePointer? = nil
        
        if sqlite3_prepare_v2(db, updateQuery, -1, &statement, nil) == SQLITE_OK{
            if sqlite3_step(statement) == SQLITE_DONE {
                print("data successfully updated")
            }else{
                print("data is not updated")
            }
        }

    }
    
    func deleteRecipe(id: String){
        let deleteQuery = "DELETE FROM NRecipes WHERE Rid = \(id);"
        
        var statement: OpaquePointer? = nil
        
        if sqlite3_prepare_v2(db, deleteQuery, -1, &statement, nil) == SQLITE_OK{
            if sqlite3_step(statement) == SQLITE_DONE {
                print("data successfully deleted")
            }else{
                print("data is not deleted")
            }
        }
    }
    
    func filterRecipe(recipeType: String) -> [Recipe]  {
        //var list
        var listRecipe = [Recipe]()
        let readQuery = "SELECT * FROM NRecipes WHERE RecipeType = '\(recipeType.lowercased())';"
        var statement: OpaquePointer? = nil
        
        if sqlite3_prepare_v2(db, readQuery, -1, &statement, nil) == SQLITE_OK{
            while sqlite3_step(statement) == SQLITE_ROW {
                let id = String(describing: String(cString: sqlite3_column_text(statement, 0)))
                let name = String(describing: String(cString: sqlite3_column_text(statement, 1)))
                let ingredient = String(describing: String(cString: sqlite3_column_text(statement, 2)))
                let step = String(describing: String(cString: sqlite3_column_text(statement, 3)))
                let recipeType = String(describing: String(cString: sqlite3_column_text(statement, 4)))
                let img = String(describing: String(cString: sqlite3_column_text(statement, 5)))
                let recipeTime = sqlite3_column_int(statement, 6)
                
                let model = Recipe(Rid: String(id), recipeName: name, ingredient: ingredient, step: step, recipeType: recipeType, imageFilePath: img, recipeTime: Int(recipeTime))
                listRecipe.append(model)
            }
        }else{
            print("query is not the requirement of the table")
        }
        return listRecipe
    }
    
    
}
