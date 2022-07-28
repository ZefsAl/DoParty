//
//  SheetView.swift
//  DoParty
//
//  Created by Serj on 23.07.2022.
//

import SwiftUI
import BottomSheetSwiftUI

struct SheetView: View {
    
    @ObservedObject var mapData: MapViewModel
    
    // Only for preview provider! -> @ObservedObject var mapData = MapViewModel()
    
    var header: some View {
        // Header
        HStack(spacing: 8) {
            HStack(spacing: 0) {
                Image(systemName: "magnifyingglass")
                TextField("Input here", text: $mapData.searchText)
                    .padding(10)
                    .colorScheme(.light)
                    .onTapGesture {
                        withAnimation {
                            mapData.bottomSheetPosition = .top
                        }
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
            .padding(.horizontal)
            .background(Color(UIColor.quaternaryLabel))
            .cornerRadius(9)
            
            Button {
                mapData.setUpPlacemark()
                UIApplication.shared.endEditing()
                //mapData.showResults = false
                withAnimation {
                    mapData.bottomSheetPosition = .bottom
                }
                
            } label: {
                Text("Search")
                    .fontWeight(.medium)
                    .padding(.vertical, 4)
            }
            .buttonStyle(.borderedProminent)
        }
    }
    
    
    var body: some View {
        VStack() {
            // Content
            ScrollView {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(mapData.places) { (place) in
                        VStack(alignment: .leading, spacing: 2) {
                            Text(place.place.name ?? "N/F Error")
                                .foregroundColor(.black)
                                .onTapGesture {
                                    mapData.selectPlace(place: place)
                                    //mapData.showResults = false
                                    mapData.bottomSheetPosition = .bottom
                                    UIApplication.shared.endEditing()
                                }
                            Text("\(place.place.country ?? ""), \(place.place.locality ?? ""), \(place.place.thoroughfare ?? "")")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        Divider()
                    }
                    Spacer()
                    
                }
                .padding()
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
            .gesture(DragGesture().onChanged({ _ in
                UIApplication.shared.endEditing()
            }))

        }
    }
    
    
}

//struct SheetView_Previews: PreviewProvider {
//    static var previews: some View {
//        SheetView(mapData: mapData)
//    }
//}


