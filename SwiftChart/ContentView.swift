//
//  ContentView.swift
//  SwiftChart
//
//  Created by 에스지랩 on 7/24/24.
//

import SwiftUI
import Charts

struct ContentView: View {
    var data: [ToyShape] = [
        .init(type: "Cube", count: 5),
        .init(type: "Sphere", count: 4),
        .init(type: "Pyramid", count: 4)
    ]
    
    let stops = [
      Gradient.Stop(color: .red, location: 0.0),
      Gradient.Stop(color: .red, location: 0.5),
      Gradient.Stop(color: .green, location: 0.50001),
      Gradient.Stop(color: .green, location: 1.0)
    ]
    
    var body: some View {
        VStack {
            Chart {
                LineMark(
                       x: .value("Shape Type", data[0].type),
                       y: .value("Total Count", data[0].count)
                   )
//                .lineStyle(<#T##style: StrokeStyle##StrokeStyle#>)
//                .foregroundStyle(.red.gradient)   
                .foregroundStyle(.linearGradient(Gradient(stops: stops),
            startPoint: .bottom,
            endPoint: .top))
                .interpolationMethod(.catmullRom)

                LineMark(
                        x: .value("Shape Type", data[1].type),
                        y: .value("Total Count", data[1].count)
                   )
                .foregroundStyle(.yellow.gradient)
                .interpolationMethod(.catmullRom)

                LineMark(
                        x: .value("Shape Type", data[2].type),
                        y: .value("Total Count", data[2].count)
                )
                .foregroundStyle(.blue.gradient)
                .interpolationMethod(.catmullRom)
//                .tapgest
            }
//            .Gest
        }
        .padding()
    }
}

#Preview {
    ContentView()
}

struct ToyShape: Identifiable {
    var type: String
    var count: Double
    var id = UUID()
}
