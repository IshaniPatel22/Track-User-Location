//
//  ViewController.swift
//  SaveLocation
//
//  Created by differenz157 on 06/02/21.
//

import UIKit
import CoreLocation
import CoreData


class ViewController: UIViewController , CLLocationManagerDelegate {
    
    
    var locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func btnStartClicked(_ sender: Any) {
        
        deleteCoreData()
        self.startLocationTracking()
    }
    
    @IBAction func btnStopClicked(_ sender: Any) {
        
        let vc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TrackPathViewController") as? TrackPathViewController
        self.navigationController?.pushViewController(vc!, animated: true)
        
    }
    
    func startLocationTracking() {
        switch CLLocationManager.authorizationStatus() {
        case .authorizedAlways, .authorizedWhenInUse, .notDetermined:
            
            locationManager = CLLocationManager()
            locationManager.pausesLocationUpdatesAutomatically = false
            locationManager.requestWhenInUseAuthorization()
            locationManager.distanceFilter = 50
            locationManager.requestAlwaysAuthorization()
            locationManager.delegate = self
            locationManager.startUpdatingLocation()
            
        case .denied:
            let alert = UIAlertController(title: "Alert", message: "somthing wrong", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Click", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        case .restricted:
            break
        @unknown default:
            fatalError()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedAlways {
            // you're good to go!
        }
    }
   
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
            guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
            if let location = locations.last {
            createData(location.coordinate)
       }
}
    
// MARK: - Save Data
    func createData(_ location: CLLocationCoordinate2D){
        
        let lat = String(location.latitude)
        let long = String(location.longitude)
        let lId = UUID().uuidString
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        let userEntity = NSEntityDescription.entity(forEntityName: "MyLocation", in: managedContext)!
        
        let user = NSManagedObject(entity: userEntity, insertInto: managedContext)
        user.setValue(lId, forKeyPath: "id")
        user.setValue(lat, forKey: "lat")
        user.setValue(long, forKey: "long")
        do {
            try managedContext.save()
            
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
       }
// MARK: - Retrive Core data
    func retrieveData() {
            
            //As we know that container is set up in the AppDelegates so we need to refer that container.
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
            
            //We need to create a context from this container
            let managedContext = appDelegate.persistentContainer.viewContext
            
            //Prepare the request of type NSFetchRequest  for the entity
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "MyLocation")
            do {
                let result = try managedContext.fetch(fetchRequest)
                for data in result as! [NSManagedObject] {
                    print(data.value(forKey: "id") as! String)
                    print(data.value(forKey: "lat") as! String)
                    print(data.value(forKey: "long") as! String)
                }
                
            } catch {
                
                print("Failed")
            }
        }
    
}

// MARK: - Delete Core data

func deleteCoreData(){

    //As we know that container is set up in the AppDelegates so we need to refer that container.
    guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
    
    //We need to create a context from this container
    let managedContext = appDelegate.persistentContainer.viewContext
    
    //Prepare the request of type NSFetchRequest  for the entity
    let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "MyLocation")
    do {
        let results = try managedContext.fetch(fetchRequest)
                for managedObject in results
                {
                    let managedObjectData:NSManagedObject = managedObject as! NSManagedObject
                    managedContext.delete(managedObjectData)
                   // try managedContext.save()
                }
            } catch let error as NSError{
                
               print("Could not Delete. \(error), \(error.userInfo)")
       }
    
}
