//
//  TrackPathViewController.swift
//  SaveLocation
//
//  Created by differenz92 on 08/02/21.
//

import UIKit
import MapKit
import CoreLocation
import CoreData


class TrackPathViewController: UIViewController {
    
    var listLocation = [MyLocation]()
    
    @IBOutlet weak var mapView: MKMapView!
   
    override func viewDidLoad() {
        super.viewDidLoad()
        self.getLocations()
    
        if(!listLocation.isEmpty) {

        for i in 0...listLocation.count - 1 {
            
            let sourceLocation = CLLocationCoordinate2D(latitude: (listLocation[i].lat! as NSString).doubleValue, longitude: (listLocation[i].long! as NSString).doubleValue)
            
            if(listLocation.indices.contains(i+1)) {
                
            let destinationLocation = CLLocationCoordinate2D(latitude: (listLocation[i+1].lat! as NSString).doubleValue, longitude: (listLocation[i+1].long! as NSString).doubleValue)
            createPath(sourceLocation: sourceLocation, destinationLocation: destinationLocation)
                
            }
          }
        }
        self.mapView.delegate = self
    }
    
    
    @IBAction func btnBackClicked(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
   
     func getLocations(){
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        let request : NSFetchRequest<MyLocation> = MyLocation.fetchRequest()
        do {
            listLocation = try managedContext.fetch(request)
            print("List of location \(listLocation)")
    
        } catch {
            print("Failed")
        }
        
    }
 
    func createPath(sourceLocation : CLLocationCoordinate2D, destinationLocation : CLLocationCoordinate2D) {
        let sourcePlaceMark = MKPlacemark(coordinate: sourceLocation, addressDictionary: nil)
        let destinationPlaceMark = MKPlacemark(coordinate: destinationLocation, addressDictionary: nil)
        
        
        let sourceMapItem = MKMapItem(placemark: sourcePlaceMark)
        let destinationItem = MKMapItem(placemark: destinationPlaceMark)
        
        let directionRequest = MKDirections.Request()
        directionRequest.source = sourceMapItem
        directionRequest.destination = destinationItem
        directionRequest.transportType = .automobile
        
        let direction = MKDirections(request: directionRequest)
        
        direction.calculate { (response, error) in
            guard let response = response else {
                if let error = error {
                    print("ERROR FOUND : \(error.localizedDescription)")
                }
                return
            }
            
            let route = response.routes[0]
            self.mapView.addOverlay(route.polyline, level: MKOverlayLevel.aboveRoads)
            let rect = route.polyline.boundingMapRect
            self.mapView.setRegion(MKCoordinateRegion(rect), animated: true)
            
        }
    }
 
}
 
extension TrackPathViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let rendere = MKPolylineRenderer(overlay: overlay)
        rendere.lineWidth = 5
        rendere.strokeColor = .systemBlue
        
        return rendere
    }
    
}


