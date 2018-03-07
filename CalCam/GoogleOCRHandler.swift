//
//  GoogleOCRHandler.swift
//  nachenbois
//
//  Created by Alex Zhao on 3/6/18.
//  Copyright © 2018 Samuel J. Lee. All rights reserved.
//

import Alamofire

class GoogleOCRHandler {
    
    static func postToGoogle(imageData: String, callback: @escaping (String) -> ()) {
        let parameters: [String: Any] = [
            "requests": [
                "image": [
                    "content": imageData
                ],
                "features": [
                    "type": "TEXT_DETECTION"
                ]
            ]
        ]
        
        Alamofire.request(
            "https://vision.googleapis.com/v1/images:annotate?key=AIzaSyDONsOyKqqDT-_ZZqh7dIAUHUFgcLrVuXs",
            method: .post,
            parameters: parameters,
            encoding: JSONEncoding.default
        ).validate().responseJSON { response in
            if let json = response.result.value as? [String: Any] {
                if let resp = json["responses"] as? NSArray {
                    if let data = resp[0] as? [String: Any] {
                        if let fullTextAnno = data["fullTextAnnotation"] as? [String: Any] {
                            if let fullText = fullTextAnno["text"] as? String {
                                callback(fullText)
                            }
                        }
                    }
                }
            }
        }
        callback("")
    }
    
}

