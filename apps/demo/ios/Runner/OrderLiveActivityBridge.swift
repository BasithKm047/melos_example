import ActivityKit
import Flutter
import Foundation

@available(iOS 16.1, *)
struct OrderTrackingActivityAttributes: ActivityAttributes {
  public struct ContentState: Codable, Hashable {
    var orderId: Int
    var productName: String
    var statusLabel: String
    var progress: Int
  }

  var orderId: Int
}

@available(iOS 16.1, *)
final class OrderLiveActivityBridge {
  private let methodChannel: FlutterMethodChannel
  private var activitiesByOrderId: [Int: Activity<OrderTrackingActivityAttributes>] = [:]

  init(binaryMessenger: FlutterBinaryMessenger) {
    methodChannel = FlutterMethodChannel(
      name: "order_live_activity",
      binaryMessenger: binaryMessenger
    )

    methodChannel.setMethodCallHandler { [weak self] call, result in
      self?.handleMethodCall(call, result: result)
    }
  }

  private func handleMethodCall(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard let args = call.arguments as? [String: Any],
      let payload = LiveActivityPayload(dictionary: args)
    else {
      result(
        FlutterError(
          code: "invalid_args",
          message: "Expected orderId, productName, statusLabel, and progress",
          details: nil
        )
      )
      return
    }

    switch call.method {
    case "startLiveActivity":
      start(payload: payload, result: result)
    case "updateLiveActivity":
      update(payload: payload, result: result)
    case "endLiveActivity":
      end(payload: payload, result: result)
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  private func start(payload: LiveActivityPayload, result: @escaping FlutterResult) {
    if activitiesByOrderId[payload.orderId] != nil {
      update(payload: payload, result: result)
      return
    }

    let attributes = OrderTrackingActivityAttributes(orderId: payload.orderId)
    let state = OrderTrackingActivityAttributes.ContentState(
      orderId: payload.orderId,
      productName: payload.productName,
      statusLabel: payload.statusLabel,
      progress: payload.progress
    )

    do {
      let activity: Activity<OrderTrackingActivityAttributes>
      if #available(iOS 16.2, *) {
        let content = ActivityContent(state: state, staleDate: nil)
        activity = try Activity.request(attributes: attributes, content: content, pushType: nil)
      } else {
        activity = try Activity.request(
          attributes: attributes,
          contentState: state,
          pushType: nil
        )
      }

      activitiesByOrderId[payload.orderId] = activity
      result(activity.id)
    } catch {
      result(
        FlutterError(
          code: "start_failed",
          message: "Failed to start live activity",
          details: error.localizedDescription
        )
      )
    }
  }

  private func update(payload: LiveActivityPayload, result: @escaping FlutterResult) {
    guard let activity = activitiesByOrderId[payload.orderId] else {
      result(nil)
      return
    }

    let state = OrderTrackingActivityAttributes.ContentState(
      orderId: payload.orderId,
      productName: payload.productName,
      statusLabel: payload.statusLabel,
      progress: payload.progress
    )

    Task {
      if #available(iOS 16.2, *) {
        let content = ActivityContent(state: state, staleDate: nil)
        await activity.update(content)
      } else {
        await activity.update(using: state)
      }

      DispatchQueue.main.async {
        result(nil)
      }
    }
  }

  private func end(payload: LiveActivityPayload, result: @escaping FlutterResult) {
    guard let activity = activitiesByOrderId[payload.orderId] else {
      result(nil)
      return
    }

    let state = OrderTrackingActivityAttributes.ContentState(
      orderId: payload.orderId,
      productName: payload.productName,
      statusLabel: payload.statusLabel,
      progress: payload.progress
    )

    Task {
      if #available(iOS 16.2, *) {
        let content = ActivityContent(state: state, staleDate: nil)
        await activity.end(content, dismissalPolicy: .immediate)
      } else {
        await activity.end(using: state, dismissalPolicy: .immediate)
      }

      activitiesByOrderId.removeValue(forKey: payload.orderId)
      DispatchQueue.main.async {
        result(nil)
      }
    }
  }
}

private struct LiveActivityPayload {
  let orderId: Int
  let productName: String
  let statusLabel: String
  let progress: Int

  init?(dictionary: [String: Any]) {
    guard let orderId = dictionary["orderId"] as? Int,
      let productName = dictionary["productName"] as? String,
      let statusLabel = dictionary["statusLabel"] as? String,
      let rawProgress = dictionary["progress"] as? Int
    else {
      return nil
    }

    self.orderId = orderId
    self.productName = productName
    self.statusLabel = statusLabel
    self.progress = min(max(rawProgress, 0), 100)
  }
}
