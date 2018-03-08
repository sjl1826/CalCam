//
//  networking.swift
//  nachenbois
//
//  Created by Mohit Bhatia on 3/4/18.
// Merge into master
import Foundation




class NLPNetworkingObject
{
    
    
    private init() {}
    
    struct CalEvent {
        var m_title: String?
        var m_date: String?
        var m_startTime: String?
        var m_endTime: String?
        var m_location: String?
        var m_notes: String?
        
    }
    
    static func getEventData(inputString: String) ->CalEvent
    {
        
        let headers = [
            "cache-control": "no-cache"
        ]
        
        let textStr: String = inputString
        
        let postData = NSData(data:textStr.data(using: String.Encoding.utf8)!)
        
        let request = NSMutableURLRequest(url: NSURL(string:"https://api.intellexer.com/recognizeNeText?apikey=bfd029d4-00c9-4dea-be4a-0f408d5ae9d9&loadNamedEntities=true&loadRelationsTree=false&loadSentences=false")! as URL, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 10.0)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = headers
        request.httpBody = postData as Data
        
        let session = URLSession.shared
        print("sync")
        let dataTask = session.dataTask(with: request as URLRequest as URLRequest, completionHandler: { (data, response, error) -> Void in
            print("async")
            if (error != nil) {
                print(error as Any)
            } else {
                let httpResponse = response as? HTTPURLResponse
                print(httpResponse!)
                
                guard let data = data,
                    let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
                    else {
                        print("Nil data received from fetchAllRooms service")
                        //completion(nil)
                        
                        return
                        //                }
                }
                print("done")
                print(json as Any)
                //print(json!.value(forKey: "text")!)
                
                
                //     if let JSONString = String(data: data, encoding: String.Encoding.utf8) {
                //                           print(JSONString)
                //        }
                //
                //
                //        do {
                //            let decoder = JSONDecoder()
                //        let product = try decoder.decode(CalEvent.self, from: data)
                //              print(product.date!)
                //        } catch let jsonErr {
                //            print("Error serializing json:", jsonErr)
                //        }
                
                //let entities = dict["entities"] as! [String:Any]
                // let title = entities["title"] as! String
                //let responseString = NSString(data: data!, encoding: )
                //print("responseString = \(responseString)")
            }
        })
        
        dataTask.resume()
        
        
        
        //Apple NLP Code
     
        let a = CalEvent()
        return a
    }
    
  
    
    static func coreNLP(ocrText: String)->CalEvent
    {
        var outEvent = CalEvent()

//        var gvText = "BRUIN ENTREPRENEURS PRESENTS STARTUP LABS INFO SESSION 10/2 AT 6 - 7 PM AT Los Angeles Museum"
        var gvText = ocrText
        var baseDateStr: String?
        //Enumerate
        var eventTitle: String = ""
        var titleOngoing:Bool = true
        var isPM: Bool = false
        var endTimeRange: Bool = false
        var timeExStr = ""
        var startTime = ""
        var endTime = ""
        var dateOver: Bool = false
        var timeSearchRange: Bool = false
        let eventText = gvText
        let tagger = NSLinguisticTagger(tagSchemes: [.lexicalClass], options: 0)
        tagger.string = eventText
        let range = NSRange(location: 0, length: eventText.utf16.count)
        let options: NSLinguisticTagger.Options = [/*.omitPunctuation,*/ .omitWhitespace]
        tagger.enumerateTags(in: range, unit: .word, scheme: .lexicalClass, options: options) { tag, tokenRange, _ in
            if let tag = tag {
                let word = (eventText as NSString).substring(with: tokenRange)
                if(tag.rawValue == "Noun" && titleOngoing){
                print("Noun!")
                eventTitle.append(word + " ")
                }
                
                else if(tag.rawValue != "Noun")
                {
                    titleOngoing = false
                }
                
                if(word == "AM" || word == "am")
                {
                    isPM = false
                }
                
                if(word == "PM" || word == "pm")
                {
                    isPM = true
                }
                
                if(tag.rawValue == "Punctuation")
                {
                    dateOver = true
                    timeExStr.append(word + " ")
                }
                
                if(dateOver && tag.rawValue == "Noun")
                {
                    timeSearchRange = true
                }
                
                if(dateOver == true && timeSearchRange == true && tag.rawValue == "Number")
                {
                    startTime.append(word)
                    timeSearchRange = false
                    
                    
                }
                
                if(tag.rawValue == "Dash")
                {
                    endTimeRange = true
                }
                
                if(startTime != "" && tag.rawValue == "Number" && endTimeRange == true)
                {
                    endTime.append(word)
                }
               
            
                print("\(word): \(tag)")
            }
        }
        
        outEvent.m_title = eventTitle
        print("Event Title: \(eventTitle)")
        

        print("Start Time: \(startTime)")
        print("End Time: \(endTime)")
        var testString : NSString = gvText as NSString
        
        let types : NSTextCheckingResult.CheckingType = [.address , .date, .phoneNumber, .link ]
        let dataDetector = try? NSDataDetector(types: types.rawValue)
        
        dataDetector?.enumerateMatches(in: testString as String, options: [], range: NSMakeRange(0,testString.length), using: { (match, flags, _) in
            
            let matchString = testString.substring(with: (match?.range)!)
            
            if match?.resultType == .date {
                var da = match?.date
                var dur = match?.duration
                print("Date is: \(da)")
                print("Duration is: \(dur)")
                print("date: \(matchString)")
                
               // dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssz"
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy/MM/dd"
                baseDateStr = dateFormatter.string(from: da!)
                print("Date str: \(baseDateStr)")
                
                dateFormatter.dateFormat="yyyy-MM-dd'T'HH:mm:ss"
                let defaultStartTime = dateFormatter.string(from: da!)
                
                if(isPM == true)
                {
                    let strTime = Int(startTime)
                    if(strTime != 0)
                    {
                        startTime = String((12 + strTime!))
                    }
                    
                    else
                    {
                        dateFormatter.dateFormat="HH:mm:ss"

                        startTime = dateFormatter.string(from: da!)
                    }
                    
                    let eTime = Int(endTime)
                    if(eTime != 0)
                    {
                        endTime = String((12 + eTime!))
                    }
                        
                    else
                    {
                        dateFormatter.dateFormat="HH:mm:ss"
                        
                        endTime = dateFormatter.string(from: da!)
                    }
                    
                
                }
                
                startTime = baseDateStr! + " " + startTime + ":00"
                endTime = baseDateStr! + " " + endTime + ":00"
                
                print("Final Start \(startTime)")
                print("Final End \(endTime)")
//                dateFormatter.dateFormat = "yyyy/MM/dd HH:mm"
//                outEvent.m_startTime = dateFormatter.date(from: startTime)
//                outEvent.m_endTime = dateFormatter.date(from: endTime)
//                print(outEvent.m_startTime)
//                print(outEvent.m_endTime)
                
                outEvent.m_startTime = startTime
                outEvent.m_endTime = endTime
                outEvent.m_date = baseDateStr
                

            
                
            }else if match?.resultType == .phoneNumber {
                outEvent.m_notes?.append("Phone No: \(matchString)\n")
                print("phoneNumber: \(matchString)")
                
                
            }else if match?.resultType == .address {
                
                outEvent.m_location = matchString
                print("address: \(matchString)")
                
                
            }else if match?.resultType == .link {
                outEvent.m_notes?.append("URL: \(matchString)\n")
                print("link: \(matchString)")
                
                
            }else{
                outEvent.m_notes?.append("Other: \(matchString)\n")
                print("else \(matchString)")
            }
            
        })
        
                return outEvent
    }
    
    
}



//        typealias TaggedToken = (String, String?)
//
//        let options: NSLinguisticTagger.Options = [.omitWhitespace, .omitPunctuation, .omitOther]
//        let tagger = NSLinguisticTagger(tagSchemes: NSLinguisticTagger.availableTagSchemes(forLanguage: "en"), options: Int(options.rawValue))
//        tagger.string = gvText
//
//
//        var tokens: [TaggedToken] = []
//        tagger.enumerateTags(in: NSMakeRange(0, text.characters.count), scheme:scheme, options: options) { tag, tokenRange, _, _ in
//            let token = (text as NSString).substring(with: tokenRange)
//            tokens.append((token, tag))
//        }

//        let tagger = NSLinguisticTagger(tagSchemes: [.tokenType], options: 0)
//        tagger.string = gvText
//        let range = NSRange(location: 0, length: gvText.utf16.count)
//        let options: NSLinguisticTagger.Options = [.omitPunctuation, .omitWhitespace]
//        tagger.enumerateTags(in: range, unit: .word, scheme: .tokenType, options: options) { _, tokenRange, _ in
//            let word = (gvText as NSString).substring(with: tokenRange)
//            print(word)
//        }

//        let options = NSLinguisticTagger.Options.omitWhitespace.rawValue | NSLinguisticTagger.Options.joinNames.rawValue
//        let tagger = NSLinguisticTagger(tagSchemes: NSLinguisticTagger.availableTagSchemes(forLanguage: "en"), options: Int(options))
//
//        let inputString = gvText
//        tagger.string = inputString
//
//        let range = NSRange(location: 0, length: inputString.utf16.count)
//        tagger.enumerateTags(in: range, scheme: .nameTypeOrLexicalClass, options: NSLinguisticTagger.Options(rawValue: options)) { tag, tokenRange, sentenceRange, stop in
//            guard let range = Range(tokenRange, in: inputString) else { return }
//            let token = inputString[range]
//
//            print("\(tag): \(token)")
//        }
//


