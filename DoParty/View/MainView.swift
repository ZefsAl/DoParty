//
//  MainView.swift
//  DoParty
//
//  Created by Serj on 02.07.2022.
//

import SwiftUI
import CoreLocation
import BottomSheetSwiftUI


struct MainView: View {
    
    @StateObject var mapData = MapViewModel()
    // Location manager
    @State private var locationManager = CLLocationManager()
    
    
    
    
    var body: some View {
        
        ZStack {
            
            ZStack {
                LinearGradient(colors: [.orange, .purple], startPoint: .top, endPoint: .bottom)
                MapView().opacity(0.7)
                    .environmentObject(mapData)
                    .ignoresSafeArea()
                    .bottomSheet(bottomSheetPosition: $mapData.bottomSheetPosition, options: []) {
                        SheetView(mapData: mapData).header
                    } mainContent: {
                        SheetView(mapData: mapData).body
                        .gesture(DragGesture().onChanged({ _ in
                            UIApplication.shared.endEditing()
                        }))
                    }
                    
            }
            .ignoresSafeArea()
            .preferredColorScheme(.light)
            .zIndex(0)
            
            // [.backgroundBlur(effect: .dark)]
            
//            .bottomSheet(bottomSheetPosition: $mapData.bottomSheetPosition, options: []) {
//                SheetView(mapData: mapData).header
//            } mainContent: {
//                SheetView(mapData: mapData).body
//                .gesture(DragGesture().onChanged({ _ in
//                    UIApplication.shared.endEditing()
//                }))
//            }
//            .ignoresSafeArea()
//            .preferredColorScheme(.light)
            
            
            
            
            
            
            
            VStack {
                
                //Spacer()
                //Color(UIColor.white.withAlphaComponent(0.5))
                
                    
                // Start Button - Vstack
                VStack {
                    
                    Button {
                        mapData.focusLocation()
                    } label: {
                        Image(systemName: "location.fill")
                    }
                    .font(.title)
                    .padding(14)
                    .background(.thinMaterial)
                    .clipShape(Circle())
                    
                    Button {
                        mapData.updateMapType()
                    } label: {
                        Image(systemName: mapData.mapType == .standard ? "network" : "map")
                    }
                    .font(.title)
                    .padding(14)
                    .background(.thinMaterial)
                    .clipShape(Circle())
                } // End Button - Vstack
                .frame(maxWidth: .infinity, alignment: .trailing)
                .padding()
            }
            .zIndex(1)
            
        }
        .onAppear {
            // Setting Delegate
            locationManager.delegate = mapData
            locationManager.requestWhenInUseAuthorization()
            locationManager.requestLocation()
        }
        .alert(Text("Permission denied"), isPresented: $mapData.permissionDenied) {
            Button("Go to settings") {
                UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Please enaple permission in app settings")
        }
    }
    
}


struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
