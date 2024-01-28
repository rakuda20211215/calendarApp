//
//  MapView.swift
//  calendarApp
//
//  Created by 蒔苗純平 on 2024/01/24.
//

import SwiftUI
import MapKit

struct MapView: View {
    let address: String
    @Binding var showInfo: Bool
    var body: some View {
        if #available(iOS 17, *) {
            MapSheet17A(address: address, showInfo: $showInfo)
        } else {
            MapSheet17B(address: address, showInfo: $showInfo)
        }
    }
    
    @available(iOS 17.0, *)
    struct MapSheet17A: View {
        @EnvironmentObject private var customColor: CustomColor
        let address: String
        @State private var cameraPosition: MapCameraPosition = MapCameraPosition.region(MKCoordinateRegion())
        @State private var coordinate: CLLocationCoordinate2D?
        @Binding var showInfo: Bool
        
        let span: Double = 0.02
        let coordinateSpan: MKCoordinateSpan
        
        init(address: String, showInfo: Binding<Bool>) {
            self.address = address
            self._showInfo = showInfo
            self.coordinateSpan = MKCoordinateSpan(latitudeDelta: span, longitudeDelta: span)
        }
        
        var body: some View {
            VStack {
                Map(position: $cameraPosition) {
                    if let coordinate = self.coordinate {
                        Marker(address, coordinate: coordinate)
                            .tint(.orange)
                    }
                }
                .mapControls {
                    MapPitchToggle()
                }
                .task {
                    setCoordinate(address) { location in
                        self.cameraPosition = MapCameraPosition.region(MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: location[0], longitude: location[1]), span: coordinateSpan))
                        self.coordinate = CLLocationCoordinate2D(latitude: location[0], longitude: location[1])
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        showInfo.toggle()
                    } label: {
                        Image(systemName: "multiply")
                            .foregroundStyle(customColor.foreGround)
                    }
                }
                ToolbarItem(placement: .principal) {
                    Text(address)
                        .foregroundStyle(customColor.foreGround)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
        }
        
        private func setCoordinate(_ address: String, _ set:@escaping ([CLLocationDegrees]) -> Void) {
            CLGeocoder().geocodeAddressString(address) { placemarks, error in
                guard error == nil,
                      let latitude = placemarks?.first?.location?.coordinate.latitude,
                      let longitude = placemarks?.first?.location?.coordinate.longitude else { return }
                set([latitude, longitude])
            }
        }
    }
    
    struct MapSheet17B: View {
        @EnvironmentObject private var customColor: CustomColor
        let address: String
        @State private var coordinate: CLLocationCoordinate2D?
        @State private var region: MKCoordinateRegion = MKCoordinateRegion()
        @Binding var showInfo: Bool
        
        let span: Double = 0.02
        let coordinateSpan: MKCoordinateSpan
        
        init(address: String, showInfo: Binding<Bool>) {
            self.address = address
            self._showInfo = showInfo
            self.coordinateSpan = MKCoordinateSpan(latitudeDelta: span, longitudeDelta: span)
        }
        
        var body: some View {
            VStack {
                Map(coordinateRegion: $region)
                .task {
                    setRegion()
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        showInfo.toggle()
                    } label: {
                        Image(systemName: "multiply")
                            .foregroundStyle(customColor.foreGround)
                    }
                }
                ToolbarItem(placement: .principal) {
                    Text(address)
                        .foregroundStyle(customColor.foreGround)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
        }
        
        private func setRegion() {
            setCoordinate { coordinate in
                self.coordinate = coordinate
                self.region = MKCoordinateRegion(center: coordinate, span: coordinateSpan)
            }
        }
        
        private func setCoordinate(_ set:@escaping ((CLLocationCoordinate2D) -> Void)){
            CLGeocoder().geocodeAddressString(address) { placemarks, error in
                guard error == nil,
                      let latitude = placemarks?.first?.location?.coordinate.latitude,
                      let longitude = placemarks?.first?.location?.coordinate.longitude else { return }
                set(CLLocationCoordinate2D(latitude: latitude, longitude: longitude))
            }
        }
    }
}
