//
//  TestChartView.swift
//  SwiftChart
//
//  Created by 에스지랩 on 7/31/24.
//

import SwiftUI
import Charts

struct GradientLine: View {
    
    @State private var selectedDate: Date?
    @State var data = WeatherData.hourlyUVIndex
    @State private var yDomain: Int = 14
    @State private var xDomain: Int = 10
    var body: some View {
        List {
            chart
            
            Button {
                yDomain -= 1
            } label: {
                Text("TestTest")
            }
            
            
            Button {
                yDomain += 1
            } label: {
                Text("TestTest")
            }
        }
        
    }
    
    private var chart: some View {
        Chart {
            RectangleMark(
                xStart: .value("hour", Calendar.current.startOfDay(for: Date())),
                xEnd: .value("hour", Calendar.current.startOfDay(for: Date()).addingTimeInterval(60*60*23))
            )
            .foregroundStyle(.linearGradient(stops: [
                Gradient.Stop(color: .green, location: 0),
                Gradient.Stop(color: .green, location: 2/14),
                Gradient.Stop(color: .yellow, location: 5/14),
                Gradient.Stop(color: .orange, location: 8/14),
                Gradient.Stop(color: .red, location: 10/14),
                Gradient.Stop(color: .purple, location: 14/14),
            ], startPoint: .bottom, endPoint: .top))
            .mask {
                if let max = WeatherData.hourlyUVIndex.max(by: { $0.uvIndex < $1.uvIndex }) {
                    ForEach(WeatherData.hourlyUVIndex, id: \.date) { hour in
                        AreaMark(
                            x: .value("hour", hour.date),
                            y: .value("uvIndex", hour.uvIndex)
                        )
                        .interpolationMethod(.cardinal)
                        .foregroundStyle(.black.opacity(0.4))

                        LineMark(
                            x: .value("hour", hour.date),
                            y: .value("uvIndex", hour.uvIndex)
                        )
                        .interpolationMethod(.cardinal)
                        .lineStyle(StrokeStyle(lineWidth: 4))
                        .symbol(Circle().strokeBorder(style: StrokeStyle(lineWidth: 0)))
                        .symbolSize(hour.date == max.date ? CGSize(width: 10, height: 10) : .zero)
                    }

                    PointMark(
                        x: .value("hour", max.date),
                        y: .value("uvIndex", max.uvIndex)
                    )
                    .symbolSize(CGSize(width: 5, height: 5))
                    .foregroundStyle(.green)
                    .annotation(spacing: 0) {
                        Text("\(max.uvIndex)")
                            .font(.caption.weight(.bold))
                            .foregroundColor(.secondary)
                    }
                }
            }

            if let selectedDate, let uvIndex = WeatherData.hourlyUVIndex.first(where: { $0.date == selectedDate })?.uvIndex {
                RuleMark(x: .value("hour", selectedDate))
                    .foregroundStyle(Color(.label))
                PointMark(
                    x: .value("hour", selectedDate),
                    y: .value("uvIndex", uvIndex)
                )
                .symbolSize(CGSize(width: 15, height: 15))
                .foregroundStyle(Color(.label))
            }
        }
        .chartYScale(domain: 0...yDomain)
        .chartYAxis {
            AxisMarks(position: .trailing, values: .automatic(desiredCount: 14)) { axisValue in
                if axisValue.index % 2 == 0 {
                    AxisValueLabel()
                }
                AxisGridLine()
            }

            AxisMarks(preset: .inset, position: .leading, values: .automatic(desiredCount: 14)) { axisValue in
                switch axisValue.index {
                case 1:
                    AxisValueLabel("Low", anchor: .topLeading)
                case 3:
                    AxisValueLabel("Moderate", anchor: .topLeading)
                case 6:
                    AxisValueLabel("High", anchor: .topLeading)
                case 8:
                    AxisValueLabel("Very high", anchor: .topLeading)
                case 11:
                    AxisValueLabel("Extreme", anchor: .topLeading)
                default:
                    AxisValueLabel()
                }
            }
        }
//        .chartXScale(domain: 0...WeatherData.hourlyUVIndex[5].uvIndex)
        .chartXAxis {
            AxisMarks(position: .bottom, values: .automatic) { _ in
                AxisValueLabel()
                AxisGridLine()
                AxisTick()
            }

            AxisMarks(position: .top, values: .automatic(desiredCount: 20)) { value in
                if value.index % 2 != 0 {
                    AxisValueLabel("\(WeatherData.hourlyUVIndex[value.index].uvIndex)", anchor: .bottom)
                }
            }
        }
        .chartOverlay { proxy in
            GeometryReader { g in
                Rectangle().fill(.clear).contentShape(Rectangle())
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { value in
                                let x = value.location.x - g[proxy.plotAreaFrame].origin.x
                                if let date: Date = proxy.value(atX: x), let roundedHour = date.nearestHour() {
                                    self.selectedDate = roundedHour
                                }
                            }
                            .onEnded { value in
                                self.selectedDate = nil
                            }
                    )
            }
        }
        .chartYAxis(.visible)
        .chartXAxis(.visible)
        .frame(height: Constants.detailChartHeight)
        .accessibilityRepresentation {
            Chart(data, id: \.date) { hour in
                Plot {
                    BarMark(
                        x: .value("hour", hour.date),
                        y: .value("uvIndex", hour.uvIndex)
                    )
                }
                .accessibilityLabel(hour.date.formatted(date: .omitted, time: .standard))
                .accessibilityValue("\(hour.uvIndex)")
            }
        }
    }
}

// MARK: - Accessibility

extension GradientLine: AXChartDescriptorRepresentable {
    func makeChartDescriptor() -> AXChartDescriptor {
        let min = data.map(\.uvIndex).min() ?? 0
        let max = data.map(\.uvIndex).max() ?? 0

        // A closure that takes a date and converts it to a label for axes
        let dateTupleStringConverter: (((date: Date, uvIndex: Int)) -> (String)) = { dataPoint in
            dataPoint.date.formatted(date: .omitted, time: .standard)
        }
        
        let xAxis = AXCategoricalDataAxisDescriptor(
            title: "Time of day",
            categoryOrder: data.map { dateTupleStringConverter($0) }
        )

        let yAxis = AXNumericDataAxisDescriptor(
            title: "UV Index value",
            range: Double(min)...Double(max),
            gridlinePositions: []
        ) { value in "\(Int(value))" }

        let series = AXDataSeriesDescriptor(
            name: "UV Index",
            isContinuous: true,
            dataPoints: data.map {
                .init(x: dateTupleStringConverter($0), y: Double($0.uvIndex))
            }
        )

        return AXChartDescriptor(
            title: "UV Index",
            summary: nil,
            xAxis: xAxis,
            yAxis: yAxis,
            additionalAxes: [],
            series: [series]
        )
    }
}

enum WeatherData {
    static let hourlyUVIndex: [(date: Date, uvIndex: Int)] = [
        (.startOfDay.addingTimeInterval(3600*0), 0),
        (.startOfDay.addingTimeInterval(3600*1), 0),
        (.startOfDay.addingTimeInterval(3600*2), 0),
        (.startOfDay.addingTimeInterval(3600*3), 0),
        (.startOfDay.addingTimeInterval(3600*4), 0),
        (.startOfDay.addingTimeInterval(3600*5), 0),
        (.startOfDay.addingTimeInterval(3600*6), 0),
        (.startOfDay.addingTimeInterval(3600*7), 1),
        (.startOfDay.addingTimeInterval(3600*8), 4),
        (.startOfDay.addingTimeInterval(3600*9), 6),
        (.startOfDay.addingTimeInterval(3600*10), 9),
        (.startOfDay.addingTimeInterval(3600*11), 12),
        (.startOfDay.addingTimeInterval(3600*12), 12),
        (.startOfDay.addingTimeInterval(3600*13), 11),
        (.startOfDay.addingTimeInterval(3600*14), 9),
        (.startOfDay.addingTimeInterval(3600*15), 6),
        (.startOfDay.addingTimeInterval(3600*16), 3),
        (.startOfDay.addingTimeInterval(3600*17), 1),
        (.startOfDay.addingTimeInterval(3600*18), 0),
        (.startOfDay.addingTimeInterval(3600*19), 0),
        (.startOfDay.addingTimeInterval(3600*20), 0),
        (.startOfDay.addingTimeInterval(3600*21), 0),
        (.startOfDay.addingTimeInterval(3600*22), 0),
        (.startOfDay.addingTimeInterval(3600*23), 0)
    ]
}

extension Date {
    static var startOfDay: Date {
        Calendar.current.startOfDay(for: .now)
    }
}

extension Date {
    func nearestHour() -> Date? {
        var components = NSCalendar.current.dateComponents([.minute, .second, .nanosecond], from: self)
        let minute = components.minute ?? 0
        let second = components.second ?? 0
        let nanosecond = components.nanosecond ?? 0
        components.minute = minute >= 30 ? 60 - minute : -minute
        components.second = -second
        components.nanosecond = -nanosecond
        return Calendar.current.date(byAdding: components, to: self)
    }
}

extension Array {
    func appending(contentsOf: [Element]) -> Array {
        var a = Array(self)
        a.append(contentsOf: contentsOf)
        return a
    }
}

enum Constants {
    static let previewChartHeight: CGFloat = 100
    static let detailChartHeight: CGFloat = 300
}
