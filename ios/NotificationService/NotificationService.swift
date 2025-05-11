//
//  NotificationService.swift
//  NotificationServce
//
//  Created by naoto.kido on 2025/05/12.
//
// !IMPORTANT
// ここでタスクキルされた状態でもプッシュ通知受信時に前処理をする。

import UserNotifications

class NotificationService: UNNotificationServiceExtension {

    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?

    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        self.contentHandler = contentHandler
        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
        
        if let bestAttemptContent = bestAttemptContent {
            let userInfo = request.content.userInfo
             print("NotificationService: Received userInfo: \(userInfo)")

             if let data = userInfo["data"] as? [String: Any] {
                 if let title = data["actual_title"] as? String {
                     bestAttemptContent.title = title
                 }
                 if let body = data["actual_body"] as? String {
                     bestAttemptContent.body = body
                 }
                 if let category = data["category"] as? String {
                     bestAttemptContent.categoryIdentifier = category
                 }
             } else {
                 // データがなかった場合
             }
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
