//
//  URLSessionDelegate.swift
//  FairyTales
//
//  Created by Siarhei Samoshyn on 08/08/2025.
//

import Foundation
import Network

class CustomURLSessionDelegate: NSObject, URLSessionDelegate {
    
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        
        // Разрешаем все соединения для localhost и разработки
        let host = challenge.protectionSpace.host
        
        if host == "localhost" || host == "127.0.0.1" || host == "0.0.0.0" {
            // Для разработки разрешаем все сертификаты
            if let serverTrust = challenge.protectionSpace.serverTrust {
                let credential = URLCredential(trust: serverTrust)
                completionHandler(.useCredential, credential)
            } else {
                completionHandler(.performDefaultHandling, nil)
            }
        } else {
            // Для других хостов используем стандартную проверку
            completionHandler(.performDefaultHandling, nil)
        }
    }
}
