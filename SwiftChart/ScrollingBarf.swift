//
//  ScrollingBarf.swift
//  SwiftChart
//
//  Created by 에스지랩 on 7/31/24.
//

import Charts
import SwiftUI
import SwiftUIDelayedGesture

enum DragState {
    case inactive
    case dragging(translation: CGSize)
}

struct ScrollingBar: View {
    @State private var scrollWidth = 450.0
    @State private var action: WineAction.InOut = .all
    @State private var yDomain: CGFloat = 40
    @State private var longPressActivated = false
    @State private var dragOffset = CGSize.zero
    @GestureState private var dragState = DragState.inactive

//    @GestureState private var dragOffset: CGSize = .zero

    private var wineData: [WineData.Grouping] {
        switch action {
        case .all:
            return WineData.allActions
        case .in:
            return WineData.wineIn
        default:
            return WineData.wineOut
        }
    }

    var body: some View {

            List {
                Section {
                    ScrollView(.horizontal) {
                        chart
                    }
                }
                customisation
            }
        
    }

    private var chart: some View {
        Chart(wineData) { grouping in
            ForEach(grouping.wines) { wine in
                Plot {
                    BarMark (
                        x: .value("Month", wine.month),
                        y: .value("Quantity",  wine.actual)
                    )
                    .foregroundStyle(wine.inOut == .in ? .purple : .green)
                }
                .accessibilityLabel("\(grouping.inOut.title)")
                .accessibilityValue("\(wine.actual)")
            }
        }
        .chartYScale(domain: 0...Float(yDomain))
        .chartYAxis {
            AxisMarks(preset: .automatic, position: .leading)
        }
        .chartXAxis {
            AxisMarks(position: .bottom, values: .automatic) { _ in
//                AxisValueLabel()
                AxisGridLine()
                AxisTick()
            }
            
            AxisMarks(preset: .automatic, position: .bottom, values: .automatic(desiredCount: 20)) { value in
                if value.index % 2 != 0 {
//                    AxisValueLabel("Test", anchor: .bottom)
                    AxisValueLabel {
                        Image("img_finish")
                            .frame(width: 50, height: 50)
                    }
                    
                }
            }
        }
        .chartOverlay { proxy in
            GeometryReader { g in
                Rectangle()
                    .foregroundStyle(.clear)
                    .contentShape(Rectangle())
                    .delayedGesture(longPressThenDragGesture(), delay: 0.1)
//                    .simultaneousGesture(longPressThenDragGesture())
                    
//                    .gesture(
//                        LongPressGesture()
//                            .onEnded({ value in
                //                                print("12e")
                //                            })
                //                    )
//                    .gesture(
//                        LongPressGesture(minimumDuration: 1.0)
//                            .onEnded { _ in
//                                self.longPressActivated = true
//                            }
//                            .simultaneously(with: DragGesture()
//                                .onChanged { value in
//                                    if self.longPressActivated {
//                                        self.dragOffset = value.translation
//                                    }
//                                }
//                                .onEnded { _ in
//                                    self.longPressActivated = false
//                                }
//                            )
//                    )
                    
                    .gesture (
                        MagnifyGesture()
                            .onChanged { value in
                                let value = value.magnification - 1
                                
                                let offset = value < 0 ? -value*5 : -value
                                
                                yDomain = min(max(10, yDomain+offset), 100)
                                scrollWidth = min(max(400, scrollWidth+offset), 550)
                                print("offset: \(offset)")
                                print("yDomain: \(yDomain)")
                                print("scrollWidth: \(scrollWidth)")
                            }
                    )
//                    .simultaneousGesture(longPressThenDragGesture())
            
//                    .gesture(
//                        DragGesture(minimumDistance: 0, coordinateSpace: .global)
//                            .onChanged { value in
//                                print(value)
//                            }
//                        LongPressGesture(minimumDuration: 0.1)
//                            .sequenced(before: DragGesture())
//                            .updating($dragState, body: { value, dstate, transaction in
//                                print(value, dstate, transaction)
//                            })
//                    )
            }
        }
        .chartYAxis(.automatic)
        .chartXAxis(.automatic)
        .padding()
        .frame(width: scrollWidth, height: Constants.detailChartHeight)
    }
    
    private func longPressThenDragGesture() -> some Gesture {
        
        let longPress = LongPressGesture()
            .onChanged({ value in
                self.longPressActivated = value
            })
        
        let drag = longPressActivated ? DragGesture()
            .onChanged { value in
                self.dragOffset = value.translation
            }
            .onEnded { _ in
                self.longPressActivated = false
            } : nil
        
        print(dragOffset, longPressActivated)
        
        return longPress.sequenced(before: drag).simultaneously(with: longPressActivated ? drag : nil)
    }
    
    private var customisation: some View {
        Section {
            Picker("Type", selection: $action.animation(.easeInOut)) {
                ForEach(WineAction.InOut.allCases) { inOut in
                    Text(inOut.title).tag(inOut)
                }
            }
            .pickerStyle(.segmented)
            .padding(.vertical)
            VStack(alignment: .leading) {
                Text("ScrollView Width: \(scrollWidth, specifier: "%.0f")")
                Slider(value: $scrollWidth, in: 450...1600) {
                    Text("ScrollView Width")
                } minimumValueLabel: {
                    Text("450")
                } maximumValueLabel: {
                    Text("1600")
                }
            }
        }
    }
}

struct WineAction: Identifiable {
    enum InOut: Int, CaseIterable, Identifiable {
        case all, `in`, out
        var title: String {
            switch self {
            case .all:
                return "All Wines"
            case .in:
                return "Wine In "
            case .out:
                return "Wine Out"
            }
        }
        var id: Int {
            self.rawValue
        }
    }
    let month: String
    let inOut: InOut
    let qty: Int
    var id = UUID()
    var actual: Int {
        inOut == .out ? -qty : qty
    }
    
    static var allActions: [WineAction] {
        [
            .init(month: "Jan", inOut: .in, qty: 15),
            .init(month: "Jan", inOut: .out, qty: 20),
            .init(month: "Feb", inOut: .in, qty: 22),
            .init(month: "Feb", inOut: .out, qty: 18),
            .init(month: "Mar", inOut: .in, qty: 12),
            .init(month: "Mar", inOut: .out, qty: 26),
            .init(month: "Apr", inOut: .in, qty: 3),
            .init(month: "Apr", inOut: .out, qty: 18),
            .init(month: "May", inOut: .in, qty: 6),
            .init(month: "May", inOut: .out, qty: 20),
            .init(month: "Jun", inOut: .in, qty: 18),
            .init(month: "Jun", inOut: .out, qty: 15),
            .init(month: "Jul", inOut: .in, qty: 24),
            .init(month: "Jul", inOut: .out, qty: 18),
            .init(month: "Aug", inOut: .in, qty: 6),
            .init(month: "Aug", inOut: .out, qty: 22),
            .init(month: "Sep", inOut: .in, qty: 28),
            .init(month: "Sep", inOut: .out, qty: 12),
            .init(month: "Oct", inOut: .in, qty: 12),
            .init(month: "Oct", inOut: .out, qty: 27),
            .init(month: "Nov", inOut: .in, qty: 20),
            .init(month: "Nov", inOut: .out, qty: 19),
            .init(month: "Dec", inOut: .in, qty: 7),
            .init(month: "Dec", inOut: .out, qty: 21)
        ]
    }
    static var winesIn: [WineAction] {
        allActions.filter { $0.inOut == .in }
    }
    
    static var winesOut: [WineAction] {
        allActions.filter { $0.inOut == .out }
    }
}

enum WineData {
    struct Grouping: Identifiable {
        let inOut: WineAction.InOut
        let wines: [WineAction]
        var id: Int {
            inOut.rawValue
        }
    }
    static let allActions: [Grouping] = [
        .init(inOut: .in, wines: WineAction.winesIn),
        .init(inOut: .out, wines: WineAction.winesOut)
    ]
    static let wineIn: [Grouping] = [
        .init(inOut: .in, wines: WineAction.winesIn)
    ]
    static let wineOut: [Grouping] = [
        .init(inOut: .in, wines: WineAction.winesOut)
    ]
}

