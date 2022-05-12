import UIKit
import CoreData

final class CoreDataManager {
    static let instance = CoreDataManager()
    
    func saveLink(_ link: LinkModel) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return}
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let entity = NSEntityDescription.entity(forEntityName: "LinkEntity", in: managedContext)!
        
        let qrcodeLink = NSManagedObject(entity: entity, insertInto: managedContext)
        
        qrcodeLink.setValue(link.linkString, forKey: "linkString")
        
        do {
            try managedContext.save()
            print("Saved")
        } catch let error as NSError {
            print("Error - \(error)")
        }
    }
    
    func getLink() -> [LinkModel]? {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return nil}
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "LinkEntity")
        
        do {
            let objects = try managedContext.fetch(fetchRequest)
            var links = [LinkModel]()
            for object in objects {
                guard let linkString = object.value(forKey: "linkString") as? String else { return nil}
                let link = LinkModel(linkString: linkString)
                links.append(link)
            }
            return links
        } catch let error as NSError {
            print("Error - \(error)")
        }
        return nil
    }
    
    private init() { }
}
