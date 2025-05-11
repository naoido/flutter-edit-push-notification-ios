//
//  NotificationService.swift
//  PushNotificationService
//
//  Created by naoto.kido on 2025/05/12.
//

import UserNotifications

class NotificationService: UNNotificationServiceExtension {

    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?

    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        self.contentHandler = contentHandler
        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)

        if let bestAttemptContent = bestAttemptContent {
            let userInfo = request.content.userInfo
            var newTitle = bestAttemptContent.title

            if let itemId = userInfo["item_id"] as? String {
                newTitle = "\(newTitle) for \(itemId)"
            } else {
                newTitle = "\(newTitle) [modified]"
            }
            bestAttemptContent.title = newTitle

            if let customValue = userInfo["my_custom_key_1"] as? String {
                bestAttemptContent.subtitle = customValue
            }
            bestAttemptContent.body = "更新済みの通知だよ❤️"
            
            contentHandler(bestAttemptContent)
        }
    }
        
    override func serviceExtensionTimeWillExpire() {
        // Called just before the extension will be terminated by the system.
        // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
        if let contentHandler = contentHandler, let bestAttemptContent =  bestAttemptContent {
            contentHandler(bestAttemptContent)
        }
    }
}
