import ActivityKit
import SwiftUI
import WidgetKit

struct OrderTrackingActivityAttributes: ActivityAttributes {
  public struct ContentState: Codable, Hashable {
    var orderId: Int
    var productName: String
    var statusLabel: String
    var progress: Int

    var isDelivered: Bool {
      progress >= 100
    }

    var progressValue: Double {
      Double(progress) / 100.0
    }

    var headlineText: String {
      isDelivered ? "Order arrived ✅" : statusLabel
    }

    var subheadlineText: String {
      isDelivered ? "Thank you for placing the order!" : "Your order is on the way"
    }

    var actionText: String {
      isDelivered ? "Rate order" : "Track order"
    }

    var iconName: String {
      isDelivered ? "checkmark.seal.fill" : "shippingbox.fill"
    }
  }

  var orderId: Int
}

struct OrderTrackingLiveActivityWidget: Widget {
  var body: some WidgetConfiguration {
    ActivityConfiguration(for: OrderTrackingActivityAttributes.self) { context in
      LockScreenOrderCardView(context: context)
        .activityBackgroundTint(.clear)
        .activitySystemActionForegroundColor(.white)
    } dynamicIsland: { context in
      DynamicIsland {
        DynamicIslandExpandedRegion(.leading) {
          Text("Order #\(context.attributes.orderId)")
            .font(.caption.weight(.semibold))
        }

        DynamicIslandExpandedRegion(.trailing) {
          Image(systemName: context.state.iconName)
            .foregroundStyle(.green)
        }

        DynamicIslandExpandedRegion(.center) {
          Text(context.state.productName)
            .font(.caption)
            .lineLimit(1)
            .minimumScaleFactor(0.8)
        }

        DynamicIslandExpandedRegion(.bottom) {
          VStack(alignment: .leading, spacing: 8) {
            ProgressView(value: context.state.progressValue)
              .tint(.green)
            HStack {
              Text(context.state.headlineText)
                .font(.caption.weight(.semibold))
                .lineLimit(1)
              Spacer()
              Text("\(context.state.progress)%")
                .font(.caption2.weight(.bold))
                .monospacedDigit()
            }
          }
        }
      } compactLeading: {
        Image(systemName: context.state.iconName)
          .foregroundStyle(.green)
      } compactTrailing: {
        Text("\(context.state.progress)%")
          .font(.caption2.weight(.bold))
          .monospacedDigit()
      } minimal: {
        Image(systemName: context.state.iconName)
          .foregroundStyle(.green)
      }
    }
  }
}

private struct LockScreenOrderCardView: View {
  let context: ActivityViewContext<OrderTrackingActivityAttributes>

  var body: some View {
    HStack(spacing: 14) {
      VStack(alignment: .leading, spacing: 10) {
        Text("demo express")
          .font(.system(size: 20, weight: .heavy, design: .rounded))
          .foregroundStyle(.white)

        Text(context.state.subheadlineText)
          .font(.caption)
          .foregroundStyle(Color.white.opacity(0.85))
          .lineLimit(1)

        Text(context.state.headlineText)
          .font(.system(size: 28, weight: .bold, design: .rounded))
          .foregroundStyle(.white)
          .lineLimit(1)
          .minimumScaleFactor(0.75)

        ProgressView(value: context.state.progressValue)
          .tint(.green)

        HStack(spacing: 10) {
          Text(context.state.actionText)
            .font(.caption.weight(.bold))
            .foregroundStyle(.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color.green)
            .clipShape(Capsule())

          Text("\(context.state.progress)% • \(context.state.statusLabel)")
            .font(.caption2.weight(.medium))
            .foregroundStyle(Color.white.opacity(0.78))
            .lineLimit(1)
        }
      }

      Spacer(minLength: 6)

      LiveActivityStatusIllustration(
        progress: context.state.progress,
        iconName: context.state.iconName
      )
    }
    .padding(16)
    .background(
      RoundedRectangle(cornerRadius: 22, style: .continuous)
        .fill(
          LinearGradient(
            colors: [
              Color(red: 0.09, green: 0.10, blue: 0.14),
              Color(red: 0.05, green: 0.06, blue: 0.09),
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
          )
        )
    )
  }
}

private struct LiveActivityStatusIllustration: View {
  let progress: Int
  let iconName: String

  var body: some View {
    ZStack {
      RoundedRectangle(cornerRadius: 14, style: .continuous)
        .fill(Color.white.opacity(0.10))
      VStack(spacing: 8) {
        Image(systemName: iconName)
          .font(.system(size: 28, weight: .semibold))
          .foregroundStyle(.green)
        Text("\(progress)%")
          .font(.caption2.weight(.bold))
          .foregroundStyle(Color.white.opacity(0.86))
      }
      .padding(.horizontal, 8)
    }
    .frame(width: 74, height: 96)
  }
}
