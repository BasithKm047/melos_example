import ActivityKit
import SwiftUI
import WidgetKit

struct OrderTrackingActivityWidgetAttributes: ActivityAttributes {
  public struct ContentState: Codable, Hashable {
    var orderId: Int
    var productName: String
    var statusLabel: String
    var progress: Int
  }

  var orderId: Int
}

struct OrderTrackingLiveActivityWidget: Widget {
  var body: some WidgetConfiguration {
    ActivityConfiguration(for: OrderTrackingActivityWidgetAttributes.self) { context in
      VStack(alignment: .leading, spacing: 10) {
        Text("Order #\(context.attributes.orderId)")
          .font(.headline)

        Text(context.state.productName)
          .font(.subheadline)
          .lineLimit(1)

        ProgressView(value: Double(context.state.progress), total: 100)
          .tint(.blue)

        Text("\(context.state.statusLabel) - \(context.state.progress)%")
          .font(.footnote)
          .foregroundStyle(.secondary)
      }
      .padding()
    } dynamicIsland: { context in
      DynamicIsland {
        DynamicIslandExpandedRegion(.leading) {
          Text("Order #\(context.attributes.orderId)")
            .font(.caption)
        }

        DynamicIslandExpandedRegion(.trailing) {
          Text("\(context.state.progress)%")
            .font(.caption2)
        }

        DynamicIslandExpandedRegion(.bottom) {
          VStack(alignment: .leading, spacing: 6) {
            ProgressView(value: Double(context.state.progress), total: 100)
            Text(context.state.statusLabel)
              .font(.footnote)
          }
        }
      } compactLeading: {
        Text("\(context.state.progress)%")
      } compactTrailing: {
        Image(systemName: "shippingbox.fill")
      } minimal: {
        Text("\(context.state.progress)%")
      }
    }
  }
}
