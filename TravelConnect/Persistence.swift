//
//  Persistence.swift
//  TravelConnect
//
//  Created by Yangru Guo on 28/10/2023.
//

import CoreData
import SwiftUI

struct PersistenceController {
    
    static let shared = PersistenceController()

    let container: NSPersistentCloudKitContainer

    init(inMemory: Bool = false) {
        container = NSPersistentCloudKitContainer(name: "TranvelConnectDB")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }
    
    //MARK: - Create Record
    func addTrip(trip:Trip,context: NSManagedObjectContext) {
        buildTripRecordItem(trip: trip, context: context)
        do {
            try context.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
    
    //MARK: - Construct Record
    func buildTripRecordItem(trip:Trip,context:NSManagedObjectContext){
        let tripRecordItem = TripRecord(context: context)
        tripRecordItem.id = trip.id 
        tripRecordItem.type = trip.type
        tripRecordItem.date = trip.date
        tripRecordItem.tripInfo = trip.tripInfo
        for place in trip.placesOfInterest {
            let placeRecord = PlaceOfInterestRecord(context: context)
            placeRecord.time = place.time
            placeRecord.type = place.type
            placeRecord.name = place.name
            placeRecord.placeDescription = place.description
            let mapRecord = MapItemRecord(context: context)
            let coordinateRecord = CoordinateRecord(context: context)
            coordinateRecord.latitude = place.mapItem.coordinates.latitude
            coordinateRecord.longitude = place.mapItem.coordinates.longitude
            mapRecord.coordinate = coordinateRecord
            placeRecord.mapItem = mapRecord
            tripRecordItem.addToPlaceOfInterest(placeRecord)
        }
        tripRecordItem.topImage = trip.topImage
    }
    
    //MARK: - Retrieve All Records
    func fetchAllRouteRecords(context:NSManagedObjectContext) -> [TripRecord] {
        
        let fetchRequest:NSFetchRequest<TripRecord> = TripRecord.fetchRequest()
        
        do{
            let tripRecordItems = try context.fetch(fetchRequest)
            return tripRecordItems
        }catch{
            print(error)
        }
        return []
    }
    
    //MARK: - Delete Records
    func deleteTripRecord(trip:Trip,context:NSManagedObjectContext) {
        if let tripRecord = fetchTripRecord(trip: trip, context: context){
            do {
                context.delete(tripRecord)
                try context.save()
            } catch {
                print("Error deleting trip record: \(error)")
            }
        }
    }
    
    //MARK: - Retrive Individual Record
    func fetchTripRecord(trip:Trip,context:NSManagedObjectContext) -> TripRecord? {
        let fetchRequest: NSFetchRequest<TripRecord> = TripRecord.fetchRequest()
        let date = trip.date
        let description = trip.tripInfo
        fetchRequest.predicate = NSPredicate(format: "date == %@ AND tripInfo == %@", date as NSDate, description)
        do{
            let matchingObject = try context.fetch(fetchRequest).first
            return matchingObject
        } catch{
            print("Error fetching objects: \(error)")
            return nil
        }
    }
    
    //MARK: - Update Record
    func updateTripRecord(oldTrip: Trip, newTrip:Trip,context:NSManagedObjectContext) {
        deleteTripRecord(trip: oldTrip, context: context)
        addTrip(trip: newTrip, context: context)
        do {
            try context.save()
        } catch {
            print("Error updating specific record: \(error)")
        }
    }
}
