import Foundation

class GetRecipeTypes: CustomDebugStringConvertible {
    
    var recipeType = ""
    
    var debugDescription: String {
        return "\(recipeType.self)"
    }
}

class TypeParser:NSObject {
    var xmlParser: XMLParser?
    var recipeTypes: [GetRecipeTypes] = []
    var xmlTest = ""
    var currentType: GetRecipeTypes?
    
    init(withXML xml:String) {
        if let data = xml.data(using: String.Encoding.utf8){
            xmlParser = XMLParser(data: data)
        }
    }
    
    func parse() -> [GetRecipeTypes] {
        xmlParser?.delegate = self
        xmlParser?.parse()
        return recipeTypes
    }
}

extension TypeParser: XMLParserDelegate{
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        xmlTest = ""
        
        if elementName == "Recipe" {
            currentType = GetRecipeTypes()
        }
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if elementName == "recipetypes" {
            currentType?.recipeType = xmlTest.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines)
        }
        if elementName == "Recipe" {
            if let type = currentType {
                recipeTypes.append(type)
            }
        }
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        xmlTest += string
    }
}

func getXmlData() -> [String]{
    var data:[String] = []
    do {
        if let xmlUrl = Bundle.main.path(forResource: "recipetypes", ofType: "xml"){
            
            let xml = try String(contentsOfFile: xmlUrl)
            let typeParser = TypeParser(withXML: xml)
            let types = typeParser.parse()
            for type in types{
                data.append(type.recipeType)
            }
        }
    }catch{
        print(error)
    }
    return data
}

