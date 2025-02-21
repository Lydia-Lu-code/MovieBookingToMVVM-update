
import Foundation
import UIKit

class SheetDBService {
    /// SheetDB API 設定
    private struct Config {
        static let apiUrl = "https://sheetdb.io/api/v1/gwog7qdzdkusm"
        static let sheetName = "訂票紀錄"
    }
    
    /// 上傳到 SheetDB
    static func uploadBookingData(
        bookingData: BookingData,
        viewController: UIViewController,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {

        let totalAmount = calculateTotalAmount(
            ticketType: bookingData.ticketType,
            peopleCount: bookingData.peopleCount
        )
        
        // 1. 驗證 API URL
        guard let url = URL(string: Config.apiUrl) else {
            print("❌ SheetDB API URL 無效：\(Config.apiUrl)")
            completion(.failure(NSError(domain: "SheetDBService", code: -1, userInfo: [NSLocalizedDescriptionKey: "無效的 API URL"])))
            return
        }
        
        // 2. 準備上傳資料
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd"
        
        let uploadData: [String: Any] = [
            "訂票日期": dateFormatter.string(from: Date()),
            "電影名稱": bookingData.movieName,
            "場次日期": dateFormatter.string(from: bookingData.showDate),
            "場次時間": bookingData.showTime,
            "人數": bookingData.peopleCount,
            "票種": bookingData.ticketType,
            "座位": bookingData.notes,
            "總金額": calculateTotalAmount(
                ticketType: bookingData.ticketType,
                peopleCount: bookingData.peopleCount
            )
        ]
        
        print("📤 準備上傳資料：\(uploadData)")
        
        // 3. 建立請求
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body = ["data": [uploadData]]
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: body)
            request.httpBody = jsonData
            print("📝 請求內容：\(String(data: jsonData, encoding: .utf8) ?? "無法讀取")")
        } catch {
            print("❌ JSON 序列化失敗：\(error)")
            completion(.failure(error))
            return
        }
        
        // 4. 執行請求
        print("🚀 開始上傳到 SheetDB...")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ 網路請求失敗：\(error)")
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }
            
            // 5. 處理回應
            if let httpResponse = response as? HTTPURLResponse {
                print("📡 服務器回應狀態碼：\(httpResponse.statusCode)")
                
                if let responseData = data,
                   let responseString = String(data: responseData, encoding: .utf8) {
                    print("📥 服務器回應內容：\(responseString)")
                }
                
                if (200...299).contains(httpResponse.statusCode) {
                    print("✅ 上傳成功")
                    DispatchQueue.main.async {
                        completion(.success(()))
                    }
                } else {
                    print("❌ 服務器錯誤：\(httpResponse.statusCode)")
                    let serverError = NSError(
                        domain: "SheetDBService",
                        code: httpResponse.statusCode,
                        userInfo: [NSLocalizedDescriptionKey: "服務器回應錯誤：\(httpResponse.statusCode)"]
                    )
                    DispatchQueue.main.async {
                        completion(.failure(serverError))
                    }
                }
            } else {
                print("❌ 無效的服務器回應")
                let invalidResponseError = NSError(
                    domain: "SheetDBService",
                    code: -2,
                    userInfo: [NSLocalizedDescriptionKey: "無效的服務器回應"]
                )
                DispatchQueue.main.async {
                    completion(.failure(invalidResponseError))
                }
            }
        }.resume()
    }
    
    /// 計算總金額
    private static func calculateTotalAmount(ticketType: String, peopleCount: Int) -> Int {
        let basePrice = 280
        let packageExtra = 120
        let isPackage = ticketType == "套餐票"
        return peopleCount * (basePrice + (isPackage ? packageExtra : 0))
    }
}
