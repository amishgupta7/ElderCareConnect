//
//  Global.swift
//  ElderCareConnect
//
//  Created by Amish Gupta on 6/14/24.
//

import Foundation
import UIKit
import Charts
import SwiftUI

extension UIColor {
    convenience init(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        
        var rgb: UInt64 = 0
        Scanner(string: hexSanitized).scanHexInt64(&rgb)
        
        let red = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
        let blue = CGFloat(rgb & 0x0000FF) / 255.0
        
        self.init(red: red, green: green, blue: blue, alpha: 1.0)
    }
}

struct Global {
    static var signinType = ""
    static var navcustomColor = UIColor(hex: "#340000")
    static var appYellow = UIColor(hex: "#F29E12")
    //static var appYellow = UIColor(hex: "#B26F0D")
    static var tabelviewheadercolor = UIColor(hex: "#FCD490")
}

// Function to make the heading part bold
func createBoldLabelText(boldText: String, normalText: String) -> NSAttributedString {
    let boldAttributes: [NSAttributedString.Key: Any] = [
        .font: UIFont.boldSystemFont(ofSize: 15)
    ]
    let normalAttributes: [NSAttributedString.Key: Any] = [
        .font: UIFont.systemFont(ofSize: 15)
    ]
    
    // Create attributed strings for the bold and normal parts
    let boldString = NSMutableAttributedString(string: boldText, attributes: boldAttributes)
    let normalString = NSAttributedString(string: normalText, attributes: normalAttributes)
    
    // Append the normal text after the bold part
    boldString.append(normalString)
    
    return boldString
}

struct PieChartView: View {
    var statusCounts: [String: Int]
    var onSelectStatus: (String) -> Void
    var initialHighlight: String?  // New parameter for initial highlighted status

    @State private var selectedStatus: String? = nil

    // The offset to correct the starting angle of the pie chart
    let angleOffset: Double = -.pi / 2  // Starts the pie chart from the top (12 o'clock position)

    init(statusCounts: [String: Int], onSelectStatus: @escaping (String) -> Void, initialHighlight: String? = nil) {
        self.statusCounts = statusCounts
        self.onSelectStatus = onSelectStatus
        self.initialHighlight = initialHighlight
        _selectedStatus = State(initialValue: initialHighlight)  // Set initial highlighted status
    }

    var body: some View {
        if statusCounts.values.reduce(0, +) > 0 {  // Ensure we have data before rendering
            VStack(spacing: 8) {  // Reduced spacing between the pie chart and the legend
                ZStack {
                    // Pie Chart
                    Chart {
                        ForEach(statusCounts.keys.sorted(), id: \.self) { status in
                            if let count = statusCounts[status], count > 0 {
                                SectorMark(
                                    angle: .value("Count", count),
                                    innerRadius: .ratio(0.5),
                                    outerRadius: .ratio(1)
                                )
                                .foregroundStyle(colorForStatus(status))  // Use custom color based on status
                                .opacity(selectedStatus == nil || selectedStatus == status ? 1.0 : 0.3)
                            }
                        }
                    }
                    .frame(width: 200, height: 200)  // Reduced size by 20%

                    // Center Text for "Requests"
                    Text("Requests")
                        .font(.system(size: 16))  // Adjust the size here
                        .foregroundColor(Color(red: 52/255, green: 0/255, blue: 0/255))  // Adjust color as needed
                        .bold()

                    // Overlay to capture tap gesture for precise location
                    GeometryReader { geo in
                        Color.clear
                            .contentShape(Rectangle())  // Makes the entire area tappable
                            .gesture(
                                DragGesture(minimumDistance: 0)
                                    .onEnded { value in
                                        let tapLocation = value.location
                                        if let tappedStatus = determineTappedStatus(at: tapLocation, in: geo.size) {
                                            selectedStatus = tappedStatus
                                            onSelectStatus(tappedStatus)  // Callback to filter requests
                                        }
                                    }
                            )
                    }
                }

                // Custom Legend
                HStack(spacing: 12) {  // Adjusted spacing between legend items
                    ForEach(statusCounts.keys.sorted(), id: \.self) { status in
                        if let count = statusCounts[status], count > 0 {
                            HStack {
                                Circle()
                                    .fill(colorForStatus(status))
                                    .frame(width: 12, height: 12)  // Reduced the size of the legend circles
                                Text("\(status): \(count)")
                                    .font(.caption)  // Reduced font size to make the legends smaller
                            }
                        }
                    }
                }
                .padding(.top, 5)  // Reduced padding between the chart and the legend
            }
        } else {
            Text("No data available")
                .frame(height: 200)  // Adjusted the frame to match the new size
        }
    }





    // Function to return color based on status
    func colorForStatus(_ status: String) -> Color {
        switch status {
        case "Pending":
            return .yellow
        case "Accepted":
            return .cyan
        case "Completed":
            return .green
        case "Cancelled":
            return .red
        default:
            return .gray
        }
    }

    // Function to determine which sector was tapped based on location
    func determineTappedStatus(at location: CGPoint, in size: CGSize) -> String? {
        let sortedStatuses = statusCounts.keys.sorted()
        let totalCount = statusCounts.values.reduce(0, +)
        let centerX = size.width / 2
        let centerY = size.height / 2
        let dx = location.x - centerX
        let dy = location.y - centerY
        let distance = sqrt(dx * dx + dy * dy)
        let radius = min(size.width, size.height) / 2
        
        if distance > radius || distance < radius * 0.5 {
            return nil
        }

        var angle = atan2(dy, dx)
        if angle < 0 {
            angle += 2 * .pi
        }
        
        angle -= angleOffset
        if angle < 0 {
            angle += 2 * .pi
        }

        // Adjust the cumulative angle calculation
        var cumulativeAngle: Double = 0
        for status in sortedStatuses {
            guard let count = statusCounts[status], count > 0 else { continue }
            let sectorFraction = Double(count) / Double(totalCount)
            let sectorAngle = sectorFraction * 2 * .pi
            if angle >= cumulativeAngle && angle < cumulativeAngle + sectorAngle {
                return status
            }
            cumulativeAngle += sectorAngle
        }

        return nil
    }
}
