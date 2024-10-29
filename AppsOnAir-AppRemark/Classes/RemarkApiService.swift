import Foundation
import AppsOnAir_Core

struct RemarkApiService {
    
    /// API for get signInURL to upload image on bucket
    static func apiGetSignInURL(apiGetSignInPassData:NSDictionary=[:] , completion: @escaping(NSDictionary) -> ()) {
        // getSignIn URL from EnvironmentConfig
        let signInURL = EnvironmentConfig.getSignInURL
        let apiURL : URL = URL(string: signInURL)!
        var request = URLRequest(url: apiURL)
        
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        let parameters = apiGetSignInPassData
        let httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: [])
        request.httpBody = httpBody
        
        let apiResponse = URLSession.shared.dataTask(with: request) { data, response, error in
            do {
                Logger.logInternal("\(url) = \(apiURL)")
                
                // make sure this JSON is in the format we expect
                // convert data to json
                if(data != nil) {
                    if let json = try JSONSerialization.jsonObject(with: data!, options: []) as? [String: Any] {
                        Logger.logInternal("\(getSignInURL) \(responseJson) \(json)")
                        if let httpResponse = response as? HTTPURLResponse {
                            if httpResponse.statusCode == 200 {
                                completion(json as NSDictionary)
                            } else {
                                Logger.logInternal("\(failedGetURL) \(statusCode) \(httpResponse.statusCode)")
                                completion([:])
                            }
                        }
                    }
                } else {
                    completion([:])
                }
            } catch let error as NSError {
                Logger.logInternal("\(failedToLoad) \(error.localizedDescription)")
            }
        }
        apiResponse.resume()
    }
    
    /// API for upload image on sepcifc bucket siginURL .  (to get signIn URL use  getSignInURL())
    static func apiUploadImage(image: UIImage,signUrl:String,completion: @escaping(Bool) -> ()) {
        // Convert the UIImage to Data for Upload Image
        guard let imageData = image.getByteData() else {
            Logger.logInternal(errorImageData)
            completion(false)
            return
        }
        
        // Set up the URL
        guard let url = URL(string: signUrl) else{
            Logger.logInternal(errorURL)
            completion(false)
            return
        }
      
        // get Query params using URL
        guard let query = url.query else {
            Logger.logInternal(errorNotFoundQuery)
            completion(false)
            return
        }
        
        //get last Params from Query Params
        let queryParams = query.components(separatedBy: "&")
        guard let lastParam = queryParams.last else {
            Logger.logInternal(errorNotFoundParams)
            completion(false)
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        
        let lastQuiresKey:String = String(lastParam.split(separator: "=").first ?? "") // for getting last params key
        let lastQuiresValue:String = String(lastParam.split(separator: "=").last ?? "") // for getting last params Value
        let imageType:String = "image/\(image.getFileType() ?? "")" // 
        
        // Set appropriate headers for uploading an image
        request.setValue(lastQuiresValue, forHTTPHeaderField: lastQuiresKey)
        request.setValue(imageType, forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept") // Use "image/png" for PNG images
        
        // Set the image data as the body of the request
        request.httpBody = imageData
        
        // Perform the request using URLSession
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            // Check for errors
            if let error = error {
                Logger.logInternal("\(errorUploadImage) \(error)")
                completion(false)
            }
            
            // Optionally, check the response
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 200 {
                    Logger.logInternal(imageUploadSuccess)
                    completion(true)
                } else {
                    Logger.logInternal("\(errorUploadImage) \(statusCode) \(httpResponse.statusCode)")
                    completion(false)
                }
            }
        }
        // Start the network task
        task.resume()
    }

    /// API for add App reamrk data including upload image URLs to appsOnAir server.
    static func apiAddRemark(apiPassData:NSDictionary=[:] , completion: @escaping(NSDictionary) -> ()) {
        
        // Set up the URL
        guard let createRemarkURL = URL(string: EnvironmentConfig.serverURL) else {
            Logger.logInternal(errorURL)
            return
        }
        
        var request = URLRequest(url: createRemarkURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        let parameters = apiPassData
        let httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: [])
        request.httpBody = httpBody
        //  Use URLSession to make the POST request
        let apiResponse = URLSession.shared.dataTask(with: request) { data, response, error in
            do {
                Logger.logInternal("\(url) = \(createRemarkURL)")
                
                // make sure this JSON is in the format we expect
                // convert data to json
                if(data != nil) {
                    if let json = try JSONSerialization.jsonObject(with: data!, options: []) as? [String: Any] {
                        Logger.logInternal("\(responseJson) \(json)")
                        if let httpResponse = response as? HTTPURLResponse {
                            if httpResponse.statusCode == 200 {
                                completion(json as NSDictionary)
                            } else {
                                Logger.logInternal("\(failedToLoad) \(statusCode) \(httpResponse.statusCode)")
                                completion([:])
                            }
                        }
                    }
                } else {
                    completion([:])
                }
            } catch let error as NSError {
                Logger.logInternal("\(failedToLoad) \(error.localizedDescription)")
            }
        }
        apiResponse.resume()
    }
}

