//
//  PhotoAlbumViewController.swift
//  VirtualTourist
//
//  Created by Khaled Shuwaish on 25/02/2019.
//  Copyright © 2019 Khaled Shuwaish. All rights reserved.
//

import UIKit
import CoreData
import MapKit


class PhotoAlbumViewController: UIViewController , UICollectionViewDelegate , UICollectionViewDataSource , NSFetchedResultsControllerDelegate{


    @IBOutlet weak var shareBu: UIButton!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    var ArrayPhotoSelected = [IndexPath]()
    @IBOutlet weak var newCollectionBu: UIButton!
    @IBOutlet weak var CollcetionFlow: UICollectionViewFlowLayout!
    var dataController : DataController!

    var pinSelected: Pin!
    var fetchedResultsController:NSFetchedResultsController<Photo>!

    var ArrayOfPhotos = [URL]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self
        FetchedResultsController()
        FlowLayout()

    }
    override func viewWillAppear(_ animated: Bool) {
        if (!CheckInternet.Connection()){
            self.Alert(Message: "Your Device is not connected with internet")
        }
        ZoomPin()
    }

    func Alert (Message: String){
        let alert = UIAlertController(title: "Alert", message: Message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "ok", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    
    func newColl(){
        if let fetchR = self.fetchedResultsController.fetchedObjects {
            for newPhoto in fetchR {
                dataController.viewContext.delete(newPhoto)
                try? dataController.viewContext.save()
            }
            FlickrAPI.shared.getPhotoFromAPI(pin: pinSelected) { (imageURLStrings) in
                guard imageURLStrings != nil else {
                    return
                }
                for imageURLString in imageURLStrings! {
                    let photo = Photo(context: self.dataController.viewContext)
                    photo.imageUrl = imageURLString
                    photo.pin = self.pinSelected
                }
                try? self.dataController.viewContext.save()
            }
        }
    }
    
    @IBAction func PressNewcollectionBJ(_ sender: UIButton) {
        if (!CheckInternet.Connection()){
            self.Alert(Message: "Your Device is not connected with internet")
            return
        }
        let newCollection = "New Collection"
        let Delete = "Delete"
        
        if sender.currentTitle == newCollection{
            if let fetchR = self.fetchedResultsController.fetchedObjects {
                for newPhoto in fetchR {
                    dataController.viewContext.delete(newPhoto)
                    try? dataController.viewContext.save()
                }
                FlickrAPI.shared.getPhotoFromAPI(pin: pinSelected) { (imageURLStrings) in
                    guard imageURLStrings != nil else {
                        return
                    }
                    for imageURLString in imageURLStrings! {
                        let photo = Photo(context: self.dataController.viewContext)
                        photo.imageUrl = imageURLString
                        photo.pin = self.pinSelected
                    }
                    try? self.dataController.viewContext.save()
                }
            }
            return
            
        } else  if sender.currentTitle == Delete {
            newCollectionBu.setTitle("New Collection", for: .normal)
            deletePhotos()
            shareBu.isEnabled = false

        }
    }
    
    func deletePhotos() {
        var DeletePhotoArray: [Photo] = [Photo]()
        for i in ArrayPhotoSelected {
            DeletePhotoArray.append(fetchedResultsController.object(at: i))
        }
        
        for i in DeletePhotoArray {
            dataController.viewContext.delete(i)
            try? dataController.viewContext.save()
        }
        ArrayPhotoSelected.removeAll()
    }
    
  
    func ZoomPin() {
        let annotation = MKPointAnnotation()
        annotation.coordinate = CLLocationCoordinate2DMake(pinSelected.latitude, pinSelected.longitude)
        self.mapView.addAnnotation(annotation)
        let coredinate:CLLocationCoordinate2D = CLLocationCoordinate2DMake(pinSelected.latitude, pinSelected.longitude)
        let span = MKCoordinateSpan(latitudeDelta: 0.07, longitudeDelta: 0.07)
        let region = MKCoordinateRegion(center: coredinate, span: span)
        self.mapView.setRegion(region, animated: true)
    }
    
    
    private func FetchedResultsController() {
        let fetchRequest: NSFetchRequest<Photo> = Photo.fetchRequest()
        let predicate = NSPredicate(format: "pin == %@", self.pinSelected)
        fetchRequest.predicate = predicate
        let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        
        fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
            
        } catch {
            fatalError("The fetch couldn't be performed: \(error.localizedDescription)")
        }
    }
    
    func SavePhotosInCoreData(data : Data) {
        let CoreDataPhoto = Photo(context: dataController.viewContext)
        CoreDataPhoto.imageData = data
        CoreDataPhoto.creationDate  = Date()
        CoreDataPhoto.pin = pinSelected
        do {
            try dataController.viewContext.save()
        }catch{
            print("Error")
        }
    }
    func FlowLayout(){
        let space:CGFloat = 3.0
        let dimension = (view.frame.size.width - (2 * space)) / 3.0
        CollcetionFlow.minimumInteritemSpacing = space
        CollcetionFlow.minimumLineSpacing = space
        CollcetionFlow.itemSize = CGSize(width: dimension, height: dimension)
    }
    
   
    @IBAction func ShareActionBu(_ sender: Any) {
        let cell = collectionView.cellForItem(at: ArrayPhotoSelected.first!) as! CollectionViewCell
        
        let ImageView = cell.image.image
        let ViewControler = UIActivityViewController(activityItems: [ImageView], applicationActivities: nil)
        self.present(ViewControler, animated: true, completion: nil)
        
        ViewControler.completionWithItemsHandler = {
            (activityType: UIActivity.ActivityType?, completed: Bool, returnedItems: [Any]?, error: Error?) in
            if !completed  {
                return
            }
            ViewControler.dismiss(animated: true, completion: nil)
//            self.navigationController?.popToRootViewController(animated: true)
//            self.dismiss(animated: true, completion: nil)
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let sectionInfo = self.fetchedResultsController.sections?[section] {
            return sectionInfo.numberOfObjects
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! CollectionViewCell
        cell.viewPhotoSelected.isHidden = true

        guard fetchedResultsController.object(at: indexPath).imageData != nil else {
            cell.ActivityInd.startAnimating()
            let photo = fetchedResultsController.object(at: indexPath)
            URLSession.shared.dataTask(with: URL(string: photo.imageUrl!)!) { result, response, error in
                if error == nil {
                    if let data = result {
                        photo.imageData = data
                        DispatchQueue.main.async {
                            cell.image.image = UIImage(data: data)
                        }
                    }
                } else {
                    print(error!)
                }
                
                DispatchQueue.main.async {
                    cell.ActivityInd.stopAnimating()
                }
                }.resume()
            return cell
        }
        
        let dataObject = self.fetchedResultsController.object(at: indexPath)
        cell.image.image = UIImage(data: dataObject.imageData!)
        newCollectionBu.isEnabled = true
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let cell = collectionView.cellForItem(at: indexPath) as! CollectionViewCell

        shareBu.isEnabled = true
        cell.viewPhotoSelected.isHidden = false
        newCollectionBu.setTitle("Delete", for: .normal)
        ArrayPhotoSelected.append(indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        
        let cell = collectionView.cellForItem(at: indexPath) as! CollectionViewCell
        
        cell.viewPhotoSelected.isHidden = true
        
        ArrayPhotoSelected.remove(at: indexPath.startIndex)
        
        if ArrayPhotoSelected.count == 0 {
            newCollectionBu.setTitle("New Collection", for: .normal)
        }
    }
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        collectionView.reloadData()
    }
    
    
}


    
    

