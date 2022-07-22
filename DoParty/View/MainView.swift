//
//  MainView.swift
//  DoParty
//
//  Created by Serj on 02.07.2022.
//

import SwiftUI
import CoreLocation

struct MainView: View {
    @StateObject var mapData = MapViewModel()
    // Location manager
    @State var locationManager = CLLocationManager()
    
    //@Environment(\.dismiss) var dismiss
    
    var body: some View {
        
        ZStack {
            MapView()
                .environmentObject(mapData)
                .ignoresSafeArea()
                .colorScheme(.light)
                .gesture(DragGesture().onChanged({ _ in
                    UIApplication.shared.endEditing()
                    
                    withAnimation(.linear, {
                        mapData.showResults = false
                    })
                    
                }))
            
            VStack {
                VStack(spacing: 8) {
                    HStack {
                        // TextField
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .font(.headline)
                                .foregroundColor(.black)
                                
                            TextField("Search", text: $mapData.searchText)
                                .colorScheme(.light)
                                .onChange(of: mapData.searchText) { _ in
                                    mapData.showResults = true
                                }


                            if !mapData.searchText.isEmpty {
                                Button {
                                    mapData.searchText = ""
                                    
                                } label: {
                                    Image(systemName: "xmark")
                                        .foregroundColor(.black)
                                }
                            }
                        }
                        .padding()
                        .background(.white)
                        .cornerRadius(12)
                        
                        Button {
                            mapData.setUpPlacemark()
                            UIApplication.shared.endEditing()
                            mapData.showResults = false
                        } label: {
                            Text("Search")
                                .fontWeight(.medium)
                                .padding(.vertical, 10)
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    
                    if mapData.showResults && mapData.searchText != "" {
                            ZStack {
                                List {
                                    ForEach(mapData.places) { (place) in
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(place.place.name ?? "N/F Error")
                                                .foregroundColor(.black)
                                                .onTapGesture {
                                                    mapData.selectPlace(place: place)
                                                    mapData.showResults = false
                                                }
                                            Text("\(place.place.country ?? ""), \(place.place.locality ?? ""), \(place.place.thoroughfare ?? "")")
                                                .font(.caption)
                                                .foregroundColor(.gray)
                                        }
                                    }
                                }
                                .colorScheme(.light)
                                .listStyle(PlainListStyle())
                            }
                            .background(Color.white)
                            .cornerRadius(12)

                    }
                    
                    // Displayng results
//                    if !mapData.places.isEmpty && mapData.searchText != "" {
//                        ZStack {
//                            List {
//                                ForEach(mapData.places) { (place) in
//                                    VStack(alignment: .leading, spacing: 2) {
//                                        Text(place.place.name ?? "N/F Error")
//                                            .foregroundColor(.black)
//                                            .onTapGesture {
//                                                mapData.selectPlace(place: place)
//                                        }
//                                        Text("\(place.place.country ?? ""), \(place.place.locality ?? ""), \(place.place.thoroughfare ?? "")")
//                                            .font(.caption)
//                                            .foregroundColor(.gray)
//
//
//                                    }
//
//                                }
//                            }
//                            .colorScheme(.light)
//                            .listStyle(PlainListStyle())
//
//
//                        }
//                        .background(Color.white)
//                        .cornerRadius(12)
//
//
//
//                    }
                    
//                    if !mapData.places.isEmpty && mapData.searchText != "" {
//                        ScrollView(.vertical, showsIndicators: true) {
//                            VStack {
//                                ForEach(mapData.places) { (place) in
//                                    Text(place.place.name ?? "")
//                                        .foregroundColor(.black)
//                                        .frame(maxWidth: .infinity, alignment: .leading)
//                                        .padding(.horizontal)
//                                        .padding(.top, 10)
//                                        .padding(.bottom, 8)
//                                        .onTapGesture {
//                                            mapData.selectPlace(place: place)
//                                        }
//                                    Divider()
//                                }
//                            }
//                        }
//                        .background(Color.white)
//                        .cornerRadius(12)
//                    }
                    
                }
                .padding()
                
                
                Spacer()
                
                // Start Button - Vstack
                VStack {
                    
                    Button {
                        mapData.focusLocation()
                    } label: {
                        Image(systemName: "location.fill")
                    }
                    .font(.title)
                    .padding(14)
                    .background(.white)
                    .clipShape(Circle())
                    
                    Button {
                        mapData.updateMapType()
                    } label: {
                        Image(systemName: mapData.mapType == .standard ? "network" : "map")
                    }
                    .font(.title)
                    .padding(14)
                    .background(.white)
                    .clipShape(Circle())
                } // End Button - Vstack
                .frame(maxWidth: .infinity, alignment: .trailing)
                .padding()
            }
            
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
        .onChange(of: mapData.searchText) { value in
            // Searching places
            
            // Own delay time to avoid Continous search request
            let delay = 0.3
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                if value == mapData.searchText {
                    // Search
                    self.mapData.searchQuery()
                }
            }
        }
    }
    
}


struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
