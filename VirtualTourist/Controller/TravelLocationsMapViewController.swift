//
//  TravelLocationsMapViewController.swift
//  VirtualTourist
//
//  Created by Khaled Shuwaish on 24/02/2019.
//  Copyright © 2019 Khaled Shuwaish. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class TravelLocationsMapViewController: UIViewController , MKMapViewDelegate   {
    @IBOutlet weak var mapView: MKMapView!
    var dataController : DataController!
    var annotations = [MKAnnotation]()
    var fetchedResultsController:NSFetchedResultsController<Pin>!
    var pinSelected: Pin!

    

    override func viewDidLoad() {
        super.viewDidLoad()
        let longGesture = UILongPressGestureRecognizer(target: self, action:
            #selector(LongPress(_:)))
        mapView.addGestureRecognizer(longGesture)

//        UIImageWriteToSavedPhotosAlbum(UIImage, nil, nil, nil)

        
        
        fetchAllPins()
        DisplayPinsOnTheMap()
        mapView.delegate = self
        showPinsOnMapWhenAppStart()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if (!CheckInternet.Connection()){
            self.Alert(Message: "Your Device is not connected with internet")
        }
        
    }
    
    func Alert (Message: String){
        
        let alert = UIAlertController(title: "Alert", message: Message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "ok", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    
    
    func showPinsOnMapWhenAppStart(){
        if let lastPin = fetchedResultsController.fetchedObjects?.first {
            let coredinate:CLLocationCoordinate2D = CLLocationCoordinate2DMake(lastPin.coordinate.latitude, lastPin.coordinate.longitude)
            let span = MKCoordinateSpan(latitudeDelta: 3.0, longitudeDelta: 3.0)
            let region = MKCoordinateRegion(center: coredinate, span: span)
            self.mapView.setRegion(region, animated: true)
            
            for location in fetchedResultsController.fetchedObjects! {
                
                let latitude = location.latitude
                let longitude = location.longitude
                
                let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                
                let annotation = MKPointAnnotation()
                annotation.coordinate = coordinate
                
                self.annotations.append(annotation)
                
            }
            DispatchQueue.main.async {
                self.mapView.addAnnotations(self.annotations)
            }
        }
    }
    fileprivate func fetchAllPins() {
        let fetchRequest :NSFetchRequest<Pin> = Pin.fetchRequest()
        let sortDescriptor =  NSSortDescriptor(key: "creationDate", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: "PinData")
        fetchedResultsController.delegate = self
        
        do{
            try fetchedResultsController.performFetch()
        }catch{
            fatalError("The fetch could not be performed : \(error.localizedDescription)")
        }
        print(fetchedResultsController.fetchedObjects)
    }
    

    func DisplayPinsOnTheMap() {
        let allPins = fetchedResultsController.fetchedObjects!
        for pin in allPins{
            let coordinate = CLLocationCoordinate2D(latitude: pin.latitude, longitude: pin.longitude)
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            self.annotations.append(annotation)
        }
        addAnnotation()
    }
    func addAnnotation() {
        DispatchQueue.main.async {
            self.mapView.addAnnotations(self.annotations)
        }
    }

    @objc func LongPress(_ sender: UIGestureRecognizer){
        if (sender.state == UIGestureRecognizer.State.began) {
            let pin = Pin(context: dataController.viewContext)
            let location = sender.location(in: mapView)
            let coordinate = mapView.convert(location, toCoordinateFrom: mapView)
            pin.latitude = coordinate.latitude
            pin.longitude = coordinate.longitude
            
            do {
                try dataController.viewContext.save()
            } catch {
                print("error")
            }            
            let annotation = MKPointAnnotation()
            annotation.coordinate.latitude = pin.latitude
            annotation.coordinate.longitude = pin.longitude
            mapView.addAnnotation(annotation)

        }
        

    }

    func addPinToCoreData(longitude : Double , latitude : Double){
        let date = Date()
        let CoreDataPin = Pin(context: dataController.viewContext)
        CoreDataPin.longitude = longitude
        CoreDataPin.latitude = latitude
        CoreDataPin.creationDate = date
        do {
            try dataController.viewContext.save()
        } catch  {
            print(error)
        }

}
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinColor = .red
            pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        else {
            pinView!.annotation = annotation
        }
        return pinView
    }
   
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        let annotation = view.annotation
        let annotationLong = annotation?.coordinate.longitude
        let annotationLat = annotation?.coordinate.latitude
        if let fetchedResults = fetchedResultsController.fetchedObjects {
            for pin in fetchedResults {
                if pin.latitude == annotationLat && pin.longitude == annotationLong {
                    pinSelected = pin
                    performSegue(withIdentifier: "PhotoVC", sender: self)
                    break
                }
            }
        }
    
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
                if (segue.identifier == "PhotoVC" ) {
                    if let PhotoVC = segue.destination as? PhotoAlbumViewController {
                        PhotoVC.dataController = dataController
                        PhotoVC.pinSelected = pinSelected
            }
        }
    }
    
    
}
extension TravelLocationsMapViewController : NSFetchedResultsControllerDelegate {
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        
        guard let pin = anObject as? Pin else {
            preconditionFailure("All changes observed in the map view controller should be for Point instances")
        }
    }
}


extension Pin: MKAnnotation {
    public var coordinate: CLLocationCoordinate2D {
        let latDegrees = CLLocationDegrees(latitude)
        let longDegrees = CLLocationDegrees(longitude)
        return CLLocationCoordinate2D(latitude: latDegrees, longitude: longDegrees)
    }
    
}





