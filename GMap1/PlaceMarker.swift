//
//  PlaceMarker.swift
//  GMap1
//
//  Created by Michael Myles on 7/19/15.
//  Copyright (c) 2015 Ron Kliffer. All rights reserved.
//

import Foundation


class PlaceMarker: GMSMarker {
    // 1
    let place: GooglePlace
    
    // 2
    init(place: GooglePlace) {
        self.place = place
        super.init()
        
        position = place.coordinate
        icon = UIImage(named: place.placeType+"_pin")
        groundAnchor = CGPoint(x: 0.5, y: 1)
        appearAnimation = kGMSMarkerAnimationPop
    }
}