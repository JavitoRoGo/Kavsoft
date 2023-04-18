//
//  ContentView.swift
//  RollingNumbers
//
//  Created by Javier Rodríguez Gómez on 23/1/23.
//

import SwiftUI

struct ContentView: View {
    @State var value: Int = 0
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 25) {
                RollingText(font: .system(size: 55), weight: .black, value: $value)
                
                Button("Change value") {
                    value = .random(in: 100...9999)
                }
            }
            .padding()
            .navigationTitle("Rolling Counter")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
