////
////  Chart.swift
////  SwiftChart
////
////  Created by 에스지랩 on 7/26/24.
////
//
//import SwiftUI
//import Charts
//
//// Area Chart는 최댓값을 기준으로 그려야됨.
//// index를 기반으로 내가 가져와야 하는 데이터는, Left, Right, 그리고 최댓값.
//// Overlay도 최댓값을 기준으로 가져와야 해서 아에 새로 프로퍼티를 만드는게 더 편해보임,
//// 각 Gradient들의 중간값에 Stop을 넣어야 할듯.
//struct DummyData {
//    static let data: [(left: Float, right: Float)] = [
//        (0, 10), (5, 12), (10, 15), (15, 20), (20, 25),
//        (25, 25), (30, 30), (35, 30), (40, 35), (45, 40),
//        (50, 45), (55, 50),(65, 60), (60, 55), (55, 50), (50, 45), (45, 40),
//        (40, 35), (35, 30), (30, 25), (25, 15),
//        (30, 20), (35, 25), (40, 30), (45, 35), (50, 40),
//        (55, 45), (60, 50), (65, 55), (70, 60), (75, 65),
//        (80, 70), (75, 65), (70, 60), (65, 55), (60, 50),
//        (55, 45), (50, 40), (45, 35), (40, 30), (35, 25),
//        (30, 20), (25, 15), (20, 10), (15, 5), (10, 2),
//        (5, 1), (2, 0), (0, 0)
//    ]
//}
//
//struct GradientLine: View {
//    @State private var selectedDate: Date?
//    @State var data = PressureDatas(DummyData.data)
//    
//    var body: some View {
//        Group {
//            List {
//                Section {
//                    chart
//                }
//            }
//        }
//    }
//
//    private var chart: some View {
//        Chart {
//            RectangleMark(
//                xStart: .value("index", 0),
//                xEnd: .value("index", data.data.count)
//            )
//            .foregroundStyle(.linearGradient(stops: [
//                Gradient.Stop(color: .green, location: 0),
//                Gradient.Stop(color: .green, location: 1/10),
//                Gradient.Stop(color: .red, location: 2/10),
//                Gradient.Stop(color: .yellow, location: 3/10),
//                Gradient.Stop(color: .yellow, location: 4/10),
//                Gradient.Stop(color: .green, location: 1)
//            ], startPoint: .leading, endPoint: .trailing))
//            .mask {
//                ForEach(data.data.indices, id: \.description) { index in
//                    
//                    LineMark(
//                        x: .value("left", index),
//                        y: .value("uvIndex", data.data[index].left),
//                        series: .value("left", "a")
//                    )
//                    .interpolationMethod(.cardinal)
//                    .lineStyle(StrokeStyle(lineWidth: 1))
//                    
//                    AreaMark(
//                        x: .value("left", index),
//                        y: .value("uvIndex", data.data[index].maxValue)
//                    )
//                    .interpolationMethod(.cardinal)
//                    .foregroundStyle(.black.opacity(0.4))
//                    
//                    LineMark(
//                        x: .value("right", index),
//                        y: .value("uvIndex", data.data[index].right),
//                        series: .value("right", "b")
//                    )
//                    .interpolationMethod(.cardinal)
//                    .lineStyle(StrokeStyle(lineWidth: 1))
//                    
////                    AreaMark(
////                        x: .value("right", index),
////                        y: .value("uvIndex", data.data[index].right)
////                    )
////                    .interpolationMethod(.cardinal)
////                    .foregroundStyle(.black.opacity(0.4))
//                    
//                }
//            }
////
////            if let selectedDate, let uvIndex = WeatherData.hourlyUVIndex.first(where: { $0.date == selectedDate })?.uvIndex {
////                RuleMark(x: .value("hour", selectedDate))
////                    .foregroundStyle(Color(.label))
////                    .lineStyle(StrokeStyle(lineWidth: 1, dash: [5]))
////                
////                PointMark(
////                    x: .value("hour", selectedDate),
////                    y: .value("uvIndex", uvIndex)
////                )
////                .symbolSize(CGSize(width: 15, height: 15))
////                .foregroundStyle(Color(.label))
////                
////            }
//        }
//        .chartYScale(domain: 0...100)
//        .chartYAxis {
//            AxisMarks(position: .leading, values: .automatic(desiredCount: 100)) { axisValue in
//                if axisValue.index % 20 == 0 {
//                    AxisValueLabel(axisValue.index.description)
//                    AxisGridLine()
//                }
//            }
//            
//            AxisMarks(preset: .inset, position: .leading, values: .automatic(desiredCount: 100)) { axisValue in
//                if axisValue.index == Int(data.data.first?.left ?? 0) {
//                    AxisValueLabel("Left")
//                } else if axisValue.index == Int(data.data.first?.right ?? 0) {
//                    AxisValueLabel("Right")
//                }
//            }
//        }
//        .chartXAxis {
//            AxisMarks(preset: .inset , position: .top, values: .automatic) { axisValue in
//                AxisGridLine()
//                AxisTick()
//                AxisValueLabel("Adress")
//            }
//            
//            AxisMarks(position: .bottom, values: .automatic) { axisValue in
//                AxisValueLabel("Hello")
//            }
//            
////            AxisMarkBuilder
//        }
//        .chartOverlay { proxy in
//            GeometryReader { g in
//                Rectangle().fill(.clear).contentShape(Rectangle())
//                    .gesture(
//                        DragGesture(minimumDistance: 0)
//                            .onChanged { value in
//                                let x = value.location.x - g[proxy.plotAreaFrame].origin.x
//                                if let date: Date = proxy.value(atX: x), let roundedHour = date.nearestHour() {
//                                    self.selectedDate = roundedHour
//                                }
//                                
//                            }
//                            .onEnded { value in
//                                self.selectedDate = nil
//                            }
//                    )
//                
////                let pos1 = proxy.position(for: (x: selectedX, y: data[selectedX].1)) ?? .zero
////                let pos2 = proxy.position(for: (x: selectedX+1, y: data[selectedX+1].1)) ?? .zero
////                
////                Rectangle()
////                    .frame(width: 76, height: 40)
////                    .position()
//            }
//        }
//        .chartBackground { proxy in
//            ZStack(alignment: .topLeading) {
//                GeometryReader { geo in
////                    if showLollipop,
////                       let selectedElement {
////                        let dateInterval = Calendar.current.dateInterval(of: .day, for: selectedElement.day)!
////                        let startPositionX1 = proxy.position(forX: dateInterval.start) ?? 0
////
////                        let lineX = startPositionX1 + geo[proxy.plotAreaFrame].origin.x
////                        let lineHeight = geo[proxy.plotAreaFrame].maxY
////                        let boxWidth: CGFloat = 100
////                        let boxOffset = max(0, min(geo.size.width - boxWidth, lineX - boxWidth / 2))
////
////                        Rectangle()
////                            .fill(lollipopColor)
////                            .frame(width: 2, height: lineHeight)
////                            .position(x: lineX, y: lineHeight / 2)
////
////                        VStack(alignment: .center) {
////                            Text("\(selectedElement.day, format: .dateTime.year().month().day())")
////                                .font(.callout)
////                                .foregroundStyle(.secondary)
////                            Text("\(selectedElement.sales, format: .number)")
////                                .font(.title2.bold())
////                                .foregroundColor(.primary)
////                        }
////                        .accessibilityElement(children: .combine)
////                        .accessibilityHidden(isOverview)
////                        .frame(width: boxWidth, alignment: .leading)
////                        .background {
////                            ZStack {
////                                RoundedRectangle(cornerRadius: 8)
////                                    .fill(.background)
////                                RoundedRectangle(cornerRadius: 8)
////                                    .fill(.quaternary.opacity(0.7))
////                            }
////                            .padding(.horizontal, -8)
////                            .padding(.vertical, -4)
////                        }
////                        .offset(x: boxOffset)
////                    }
//                }
//            }
//        }
//        .chartYAxis(.visible)
//        .chartXAxis(.visible)
//        .frame(height: 300)
//
//    }
//}
//
//
//struct PressureDatas {
//    
//    // 초기에 많은 계산이 들어가더라도, 나중에 애니메이션 등의 큰 계산이 들어가기에 그때 계산을 최소화 하고자 Computed Property가 아닌 Let으로 그냥 init 박아버림. 문제 생기면 바꿔볼것.
//    init(_ value: [(left: Float, right: Float)]) {
//        var data: [ChartData] = []
//        var leftGradient: [Gradient.Stop] = []
//        var rightGradient: [Gradient.Stop] = []
//        var currentColor = Color.clear
//        var count = 0
//        
//        for (index, (left, right)) in value.enumerated() {
//            let leftColor = AnalysisColor.getColor(left)
//            let rightColor = AnalysisColor.getColor(right)
//            let location = CGFloat(index)/CGFloat((value.count-count)/2)
//            
//            data.append(ChartData(left: left, right: right, leftColor: leftColor, rightColor: rightColor))
//            
//            
//            if leftColor != currentColor {
//                leftGradient.append(
//                    Gradient.Stop(color: currentColor, location: location)
//                )
//            }
//            
//           
//        }
//        
//        self.data = data
//        self.leftGradient = leftGradient
//        self.rightGradient = rightGradient
//    }
//    
//    let data: [ChartData]
//    let leftGradient: [Gradient.Stop]
//    let rightGradient: [Gradient.Stop]
//    
//    let clubSpeed = 0
//    let handSpeed = 0
//    let tempo = 0
//    let faceAtImpact = 0
//}
//
//struct ChartData {
//    
//    init(left: Float, right: Float, leftColor: Color, rightColor: Color) {
//        self.left = left
//        self.right = right
//        self.leftColor = leftColor
//        self.rightColor = rightColor
//        self.maxValue = max(left, right)
//    }
//    
//    let left: Float
//    let right: Float
//    let leftColor: Color
//    let rightColor: Color
//    let maxValue: Float
//}
//
//enum AnalysisColor {
//    static func getColor(_ value: Float) -> Color {
//        switch value {
//        case ..<25:
//            return Color.green
//        case 25..<45:
//            return Color.yellow
//        case 45...:
//            return Color.red
//        default:
//            return Color.green
//        }
//    }
//}
//
//
//extension Date {
//    func nearestHour() -> Date? {
//        var components = NSCalendar.current.dateComponents([.minute, .second, .nanosecond], from: self)
//        let minute = components.minute ?? 0
//        let second = components.second ?? 0
//        let nanosecond = components.nanosecond ?? 0
//        components.minute = minute >= 30 ? 60 - minute : -minute
//        components.second = -second
//        components.nanosecond = -nanosecond
//        return Calendar.current.date(byAdding: components, to: self)
//    }
//}
//
//extension Date {
//    static var startOfDay: Date {
//        Calendar.current.startOfDay(for: .now)
//    }
//}
