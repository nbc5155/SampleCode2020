//
//  Location.swift
//  Around Town
//
//  Created by jjh9 on 9/28/20.
//

import Foundation
import MapKit

struct Place :Identifiable {
    var category : String
    var placemark : MKPlacemark
    var id = UUID()
    
    var highlighted : Bool = false
    
    var name : String {placemark.name ?? "No Name"}
    var streetNumber : String {placemark.subThoroughfare ?? ""}
    var streetName : String {placemark.thoroughfare ?? ""}
    var address : String {streetNumber + streetName}
    
    var coordinate : CLLocationCoordinate2D {placemark.location!.coordinate}
    
    mutating func highlightToggle() {
        highlighted.toggle()
    }
}

class LocationsManager : ObservableObject {
    
    
    //MARK: Published values
    @Published var region = MKCoordinateRegion(center: TownData.initialCoordinate, span: MKCoordinateSpan(latitudeDelta: TownData.span, longitudeDelta: TownData.span))
    
    // Map will annotate these items
    @Published var mappedPlaces = [Place]()
    

    
    //MARK: Local Search
    var searchCategoryIndex : Int = 0 {
        didSet {performSearch(on: TownData.categories[searchCategoryIndex])}
    }
    
    func clearSearch() {
        mappedPlaces.removeAll()
    }
    
    func performSearch(on category:String) {
        
        //make a local search request and start it
        let request = MKLocalSearch.Request()
        request.region = region
        request.naturalLanguageQuery = category
        let search = MKLocalSearch(request: request)
        
        search.start { (response, error) in
            guard error == nil else {print(error!.localizedDescription); return}
            
            let mapItems = response!.mapItems
            for item in mapItems {
                let place = Place(category: category, placemark: item.placemark)
                self.mappedPlaces.append(place)
            }
        }
    }
}