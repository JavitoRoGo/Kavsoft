//
//  ChartView.swift
//  AnotherLineChart
//
//  Created by Javier Rodríguez Gómez on 20/4/22.
//

import SwiftUI

struct ChartView: View {
    let data: [Double]
    var maxY: Double {
        data.max() ?? 0
    }
    var minY: Double {
        data.min() ?? 0
    }
    var lineColor: Color {
        let priceChange = (data.last ?? 0) - (data.first ?? 0)
        return priceChange > 0 ? Color.green : Color.red
    }
    @State private var percentage: CGFloat = 0
    
    var body: some View {
        VStack {
            chartView
                .frame(height: 300)
                .scaleEffect(x: 0.98)
                .background(chartBackground)
                .overlay(chartYAxis.padding(.horizontal, 4), alignment: .leading)
            chartXLabels
                .padding(.horizontal, 4)
        }
        .font(.caption)
        .foregroundColor(.secondary)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                withAnimation(.linear(duration: 2.0)) {
                    percentage = 1.0
                }
            }
        }
    }
}

struct ChartView_Previews: PreviewProvider {
    static var previews: some View {
        ChartView(data: data)
    }
}


extension ChartView {
    private var chartView: some View {
        GeometryReader { geometry in
            Path { path in
                for index in data.indices {
                    let xPosition = geometry.size.width / CGFloat(data.count) * CGFloat(index + 1)
                    let yAxis = maxY - minY
                    let yPosition = (1 - CGFloat((data[index] - minY) / yAxis)) * geometry.size.height
                    
                    if index == 0 {
                        path.move(to: CGPoint(x: xPosition, y: yPosition))
                    }
                    path.addLine(to: CGPoint(x: xPosition, y: yPosition))
                }
            }
            .trim(from: 0, to: percentage)
            .stroke(lineColor, style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
            .shadow(color: lineColor, radius: 10, x: 0, y: 10)
            .shadow(color: lineColor.opacity(0.5), radius: 10, x: 0, y: 20)
            .shadow(color: lineColor.opacity(0.2), radius: 10, x: 0, y: 30)
            .shadow(color: lineColor.opacity(0.1), radius: 10, x: 0, y: 40)
        }
    }
    
    private var chartBackground: some View {
        VStack {
            Divider()
            Spacer()
            Divider()
            Spacer()
            Divider()
        }
    }
    
    private var chartYAxis: some View {
        VStack {
            Text(maxY, format: .number.precision(.fractionLength(1)))
            Spacer()
            Text((maxY + minY) / 2, format: .number.precision(.fractionLength(1)))
            Spacer()
            Text(minY, format: .number.precision(.fractionLength(1)))
        }
    }
    
    private var chartXLabels: some View {
        HStack {
            Text("Lo")
            Spacer()
            Text("Hi")
        }
    }
}
