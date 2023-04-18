//
//  Home.swift
//  BarGraphs
//
//  Created by Javier Rodríguez Gómez on 21/3/22.
//

import SwiftUI

struct Home: View {
    var body: some View {
        // Home view...
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 18) {
                HStack {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Weekly icons")
                            .font(.title.bold())
                        Text("reports is available")
                            .fontWeight(.semibold)
                            .foregroundColor(.gray)
                    }
                    Spacer(minLength: 10)
                    Button {
                        
                    } label: {
                        // Button with badge...
                        Image(systemName: "bell")
                            .font(.title2)
                            .foregroundColor(.gray)
                            .overlay(
                                Text("2")
                                    .font(.caption2.bold())
                                    .foregroundColor(.white)
                                    .padding(8)
                                    .background(.red)
                                    .clipShape(Circle())
                                    .offset(x: 11, y: -12),
                                alignment: .topTrailing
                            )
                            .offset(x: -2)
                            .padding(15)
                            .background(.white)
                            .clipShape(Circle())
                    }
                }
                
                // Graph view...
                BarGraph(downloads: downloads)
                
                // Users view...
                HStack(spacing: 0) {
                    // Progress view...
                    UserProgress(title: "New Users", color: Color("LightBlue"), image: "person", progress: 68)
                    UserProgress(title: "Old Users", color: Color("Pink"), image: "person", progress: 72)
                }
                .padding()
                .background(.white)
                .cornerRadius(18)
                
                // Most dowloads...
                VStack {
                    HStack {
                        Text("Most downloaded icons")
                            .font(.callout.bold())
                        Spacer()
                        Menu {
                            Button("More") {}
                            Button("Extra") {}
                        } label: {
                            Image(systemName: "line.3.horizontal")
                                .resizable()
                                .renderingMode(.template)
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 18, height: 18)
                                .foregroundColor(.primary)
                        }
                    }
                    HStack(spacing: 15) {
                        Image(systemName: "flame.fill")
                            .font(.title2)
                            .foregroundColor(.red)
                            .padding(12)
                            .background(
                                Color.gray
                                    .opacity(0.25)
                                    .clipShape(Circle())
                            )
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Fire flame")
                                .bold()
                            Text("1289 download")
                                .font(.caption2.bold())
                                .foregroundColor(.gray)
                        }
                        Spacer(minLength: 10)
                        Image(systemName: "square.and.arrow.down.on.square.fill")
                            .font(.title2)
                            .foregroundColor(.green)
                    }
                    .padding(.top, 25)
                }
                .padding()
                .background(.white)
                .cornerRadius(18)
            }
            .padding()
        }
    }
    
    @ViewBuilder
    func UserProgress(title: String, color: Color, image: String, progress: CGFloat) -> some View {
        HStack {
            Image(systemName: image)
                .font(.title2)
                .foregroundColor(color)
                .padding(10)
                .background(
                    ZStack {
                        Circle()
                            .stroke(.gray.opacity(0.3), lineWidth: 2)
                        Circle()
                            .trim(from: 0, to: progress / 100)
                            .stroke(color, lineWidth: 2)
                    }
                )
            VStack(alignment: .leading, spacing: 8) {
                Text("\(Int(progress))%")
                    .bold()
                Text(title)
                    .font(.caption2.bold())
                    .foregroundColor(.gray)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct Home_Previews: PreviewProvider {
    static var previews: some View {
        Home()
    }
}
