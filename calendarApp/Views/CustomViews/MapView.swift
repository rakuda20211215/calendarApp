//
//  MapView.swift
//  calendarApp
//
//  Created by 蒔苗純平 on 2024/01/24.
//

import SwiftUI
import MapKit

struct MapView: View {
    var body: some View {
        if #available(iOS 17.0, *) {
            Map {
                Marker("test", systemImage: "location_on", coordinate: CLLocationCoordinate2D(latitude: 34.7345036, longitude: 136.5101973))
                    .tint(.orange)
            }
        } else {
            // Fallback on earlier versions
        }
    }
}

#Preview {
    MapView()
}
