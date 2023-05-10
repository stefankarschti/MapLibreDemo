//
//  ContentView.swift
//  MapLibreDemo
//
//  Created by Stefan Karschti on 09.05.2023.
//

import SwiftUI

struct Style {
    var name: String
    var url: String
}

let styleList: [Style]  = [
    Style(name: "Streets Style", url: "https://api.maptiler.com/maps/streets-v2/style.json?key="),
    Style(name: "Satellite Style", url: "https://api.maptiler.com/maps/hybrid/style.json?key="),
    Style(name: "Basic Style", url: "https://api.maptiler.com/maps/basic-v2/style.json?key="),
    Style(name: "Dark Style", url: "https://api.maptiler.com/maps/dataviz-dark/style.json?key="),
    Style(name: "Light Style", url: "https://api.maptiler.com/maps/dataviz-light/style.json?key="),
    Style(name: "Outdoor Style", url: "https://api.maptiler.com/maps/outdoor-v2/style.json?key="),
    Style(name: "Winter Style", url: "https://api.maptiler.com/maps/winter-v2/style.json?key="),
]

struct ContentView: View {
    let styles = styleList
    @State var currentStyleIndex = -1
    @State var styleName = "Map Style"
    @State var styleURL: String = ""
    func nextStyle() {
        currentStyleIndex = (currentStyleIndex + 1) % styles.count
        styleName = styles[currentStyleIndex].name
        styleURL = styles[currentStyleIndex].url
    }
    var body: some View {
        ZStack {
            MapView(bind_styleURL: $styleURL)
                .edgesIgnoringSafeArea(.all)
            VStack {
                Text(styleName)
                    .font(.headline)
                    .foregroundColor(.blue)
                    .padding()
//                    .background(Color.white)
                    .cornerRadius(10)
                    .onAppear {
                        nextStyle()
                    }
                    .onTapGesture {
                        nextStyle()
                    }
                Spacer()
            }
            .padding(.top)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
