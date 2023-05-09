//
//  ContentView.swift
//  MapLibreDemo
//
//  Created by Stefan Karschti on 09.05.2023.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        MapView()
            .edgesIgnoringSafeArea(.all)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
