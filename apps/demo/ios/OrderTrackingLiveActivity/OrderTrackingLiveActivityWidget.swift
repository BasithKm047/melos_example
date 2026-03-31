import ActivityKit
import SwiftUI
import WidgetKit

private enum LiveActivityConfig {
  static let appGroupId = "group.com.example.demo.liveactivities"
  static let brandKey = "brand"
  static let subtitleKey = "subtitle"
  static let titleKey = "title"
  static let productNameKey = "productName"
  static let statusLabelKey = "statusLabel"
  static let actionLabelKey = "actionLabel"
  static let progressKey = "progress"
}

private let sharedDefaults = UserDefaults(suiteName: LiveActivityConfig.appGroupId)

struct LiveActivitiesAppAttributes: ActivityAttributes, Identifiable {
  public typealias LiveDeliveryData = ContentState

  public struct ContentState: Codable, Hashable {
    var appGroupId: String
  }

  var id = UUID()
}

extension LiveActivitiesAppAttributes {
  func prefixedKey(_ key: String) -> String {
    "\(id)_\(key)"
  }
}

private struct OrderLiveActivityPayload {
  let brand: String
  let subtitle: String
  let title: String
  let productName: String
  let statusLabel: String
  let actionLabel: String
  let progress: Int

  var progressValue: Double {
    Double(progress) / 100.0
  }

  var isDelivered: Bool {
    progress >= 100
  }

  var iconName: String {
    isDelivered ? "checkmark.seal.fill" : "shippingbox.fill"
  }

  static func from(_ context: ActivityViewContext<LiveActivitiesAppAttributes>) -> OrderLiveActivityPayload {
    func readString(_ key: String, fallback: String) -> String {
      guard let defaults = sharedDefaults else {
        return fallback
      }
      let value = defaults.string(forKey: context.attributes.prefixedKey(key))
      if let value, !value.isEmpty {
        return value
      }
      return fallback
    }

    func readInt(_ key: String, fallback: Int) -> Int {
      guard let defaults = sharedDefaults else {
        return fallback
      }
      let fullKey = context.attributes.prefixedKey(key)
      if let number = defaults.object(forKey: fullKey) as? NSNumber {
        return min(max(number.intValue, 0), 100)
      }
      return min(max(defaults.integer(forKey: fullKey), 0), 100)
    }

    let progress = readInt(LiveActivityConfig.progressKey, fallback: 0)
    let statusLabel = readString(LiveActivityConfig.statusLabelKey, fallback: "Order placed")

    return OrderLiveActivityPayload(
      brand: readString(LiveActivityConfig.brandKey, fallback: "demo express"),
      subtitle: readString(
        LiveActivityConfig.subtitleKey,
        fallback: progress >= 100 ? "Thank you for placing the order!" : "Your order is on the way"
      ),
      title: readString(
        LiveActivityConfig.titleKey,
        fallback: progress >= 100 ? "Order arrived" : statusLabel
      ),
      productName: readString(LiveActivityConfig.productNameKey, fallback: "Order"),
      statusLabel: statusLabel,
      actionLabel: readString(
        LiveActivityConfig.actionLabelKey,
        fallback: progress >= 100 ? "Rate order" : "Track order"
      ),
      progress: progress
    )
  }
}

struct OrderTrackingLiveActivityWidget: Widget {
  var body: some WidgetConfiguration {
    ActivityConfiguration(for: LiveActivitiesAppAttributes.self) { context in
      let payload = OrderLiveActivityPayload.from(context)
      LockScreenOrderCardView(payload: payload)
        .activityBackgroundTint(.clear)
        .activitySystemActionForegroundColor(.white)
    } dynamicIsland: { context in
      let payload = OrderLiveActivityPayload.from(context)
      DynamicIsland {
        DynamicIslandExpandedRegion(.leading) {
          Text(payload.brand)
            .font(.caption.weight(.semibold))
            .lineLimit(1)
        }

        DynamicIslandExpandedRegion(.trailing) {
          Image(systemName: payload.iconName)
            .foregroundStyle(.green)
        }

        DynamicIslandExpandedRegion(.center) {
          Text(payload.productName)
            .font(.caption)
            .lineLimit(1)
            .minimumScaleFactor(0.8)
        }

        DynamicIslandExpandedRegion(.bottom) {
          VStack(alignment: .leading, spacing: 8) {
            ProgressView(value: payload.progressValue)
              .tint(.green)
            HStack {
              Text(payload.title)
                .font(.caption.weight(.semibold))
                .lineLimit(1)
              Spacer()
              Text("\(payload.progress)%")
                .font(.caption2.weight(.bold))
                .monospacedDigit()
            }
          }
        }
      } compactLeading: {
        Image(systemName: payload.iconName)
          .foregroundStyle(.green)
      } compactTrailing: {
        Text("\(payload.progress)%")
          .font(.caption2.weight(.bold))
          .monospacedDigit()
      } minimal: {
        Image(systemName: payload.iconName)
          .foregroundStyle(.green)
      }
    }
  }
}

private struct LockScreenOrderCardView: View {
  let payload: OrderLiveActivityPayload

  var body: some View {
    HStack(spacing: 14) {
      VStack(alignment: .leading, spacing: 10) {
        Text(payload.brand)
          .font(.system(size: 20, weight: .heavy, design: .rounded))
          .foregroundStyle(.white)

        Text(payload.subtitle)
          .font(.caption)
          .foregroundStyle(Color.white.opacity(0.85))
          .lineLimit(1)

        Text(payload.title)
          .font(.system(size: 28, weight: .bold, design: .rounded))
          .foregroundStyle(.white)
          .lineLimit(1)
          .minimumScaleFactor(0.75)

        ProgressView(value: payload.progressValue)
          .tint(.green)

        HStack(spacing: 10) {
          Text(payload.actionLabel)
            .font(.caption.weight(.bold))
            .foregroundStyle(.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color.green)
            .clipShape(Capsule())

          Text("\(payload.progress)% - \(payload.statusLabel)")
            .font(.caption2.weight(.medium))
            .foregroundStyle(Color.white.opacity(0.78))
            .lineLimit(1)
        }
      }

      Spacer(minLength: 6)

      LiveActivityStatusIllustration(
        progress: payload.progress,
        iconName: payload.iconName
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
