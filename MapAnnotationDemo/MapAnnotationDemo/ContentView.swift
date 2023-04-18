//
//  ContentView.swift
//  MapAnnotationDemo
//
//  Created by Javier Rodríguez Gómez on 22/3/23.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationStack {
            SearchView()
                .navigationBarBackButtonHidden(true)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
