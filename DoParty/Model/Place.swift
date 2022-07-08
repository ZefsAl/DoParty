//
//  Place.swift
//  DoParty
//
//  Created by Serj on 06.07.2022.
//

import SwiftUI
import MapKit

struct Place: Identifiable{
    
    var id = UUID().uuidString
    var place: CLPlacemark
    
}


