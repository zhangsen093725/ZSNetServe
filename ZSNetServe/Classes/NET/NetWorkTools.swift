//
//  NetWorkTool.swift
//  Base
//
//  Created by 张森 on 2019/7/15.
//  Copyright © 2019 张森. All rights reserved.
//

import Foundation
import Alamofire

@objc public enum ResponseEncoding: Int {
    case JSON = 1, Data
}

@objc public enum RequestEncoding: Int {
    case JSONString = 1, URLDefult = 2, URLQueryString = 3, HTTPBody = 4
}

@objc public enum JDHTTPMethod: Int {
    case post = 1, get = 2, put = 3, delete = 4
}

@objcMembers public class NetWorkingTool: NSObject {
    
    public private(set) var responseObject: DataResponse<Any>? = nil
    public private(set) var responseData: DefaultDataResponse? = nil
    
    private var complete: ((_ responseData: Any?) -> Void)? = nil
    private var success: ((_ responseObject: Any?) -> Void)? = nil
    private var fail: ((_ error: NSError?) -> Void)? = nil
    
    private static let `default`: SessionManager = Alamofire.SessionManager.default
    
    /// defaultHTTPHeaders
    private static let defaultHTTPHeaders: HTTPHeaders = {
        // Accept-Encoding HTTP Header; see https://tools.ietf.org/html/rfc7230#section-4.2.3
        let acceptEncoding: String = "gzip;q=1.0, compress;q=0.5"
        
        // Accept-Language HTTP Header; see https://tools.ietf.org/html/rfc7231#section-5.3.5
        let acceptLanguage = Locale.preferredLanguages.prefix(6).enumerated().map { index, languageCode in
            let quality = 1.0 - (Double(index) * 0.1)
            return "\(languageCode);q=\(quality)"
        }.joined(separator: ", ")
        
        // User-Agent Header; see https://tools.ietf.org/html/rfc7231#section-5.5.3
        // Example: `iOS Example/1.0 (org.alamofire.iOS-Example; build:1; iOS 10.0.0) Alamofire/4.0.0`
        let userAgent: String = {
            if let info = Bundle.main.infoDictionary {
                let executable = info[kCFBundleExecutableKey as String] as? String ?? "Unknown"
                let bundle = info[kCFBundleIdentifierKey as String] as? String ?? "Unknown"
                let appVersion = info["CFBundleShortVersionString"] as? String ?? "Unknown"
                let appBuild = info[kCFBundleVersionKey as String] as? String ?? "Unknown"
                
                let osName: String = {
                    #if os(iOS)
                    return "iOS"
                    #elseif os(watchOS)
                    return "watchOS"
                    #elseif os(tvOS)
                    return "tvOS"
                    #elseif os(macOS)
                    return "OS X"
                    #elseif os(Linux)
                    return "Linux"
                    #else
                    return "Unknown"
                    #endif
                }()
                
                let osNameVersion: String = {
                    let version = ProcessInfo.processInfo.operatingSystemVersion
                    let versionString = "\(version.majorVersion).\(version.minorVersion).\(version.patchVersion)"
                    return "\(osName) \(versionString)"
                }()
                
                let alamofireVersion: String = {
                    guard
                        let afInfo = Bundle(for: SessionManager.self).infoDictionary,
                        let build = afInfo["CFBundleShortVersionString"]
                        else { return "Unknown" }
                    
                    return "Alamofire/\(build)"
                }()
                
                return "\(executable)/\(appVersion) (\(bundle); build:\(appBuild); \(osName); \(osNameVersion)) \(alamofireVersion)"
            }
            
            return "Alamofire"
        }()
        
        return [
            "Accept-Encoding": acceptEncoding,
            "Accept-Language": acceptLanguage,
            "User-Agent"     : userAgent
        ]
    }()
    
    
    /// contentType
    private static let contentType: Set<String> = {
        
        return ["application/json",
                "text/json",
                "text/javascript",
                "text/html",
                "text/plain",
                "application/atom+xml",
                "application/xml",
                "text/xml",
                "image/png",
                "image/jpeg",
                "multipart/form-data"]
    }()
    
    
    public class func parameterEncoding(encoding: RequestEncoding) -> ParameterEncoding {
        switch encoding {
        case .URLDefult:
            return URLEncoding.default
        case .URLQueryString:
            return URLEncoding.queryString
        case .HTTPBody:
            return URLEncoding.httpBody
        case .JSONString:
            return JSONEncoding.default
        }
    }
    
    /// 公共的请求方法
    class public func request(_ base: String,
                              url: String,
                              parameters: Parameters? = nil,
                              timeOut: TimeInterval = 10,
                              method: HTTPMethod = .get,
                              encoding: RequestEncoding = .URLDefult,
                              response: ResponseEncoding = .JSON,
                              headers: HTTPHeaders? = nil,
                              complete: ((Any?, Data?, NSError?) -> Void)? = nil) {
        
        var httpHeaders = defaultHTTPHeaders
        
        if let tempHeaders = headers {
            for (key, value) in tempHeaders {
                httpHeaders[key] = value
            }
        }
        
        self.default.session.configuration.timeoutIntervalForRequest = timeOut
        
        let path = base + url
        
        let request: DataRequest = self.default.request(path,
                                                        method: method,
                                                        parameters: parameters,
                                                        encoding: parameterEncoding(encoding: encoding),
                                                        headers: httpHeaders)
            .validate(contentType: contentType)
        
        switch response {
        case .JSON:
            request.responseJSON { (responseObject) in
                
                switch responseObject.result {
                case .success(let value) where complete != nil:
                    complete!(value, nil, nil)
                case .failure(let error) where complete != nil:
                    complete!(nil, nil, error as NSError)
                    print(error)
                default : break
                }
            }
        case .Data:
            request.response { (responseObject) in
                
                if complete != nil {
                    complete!(nil, responseObject.data, nil)
                }
            }
        }
    }
    
    
    class public func POST(_ base: String,
                           url: String,
                           parameters: Parameters?,
                           contentId: Any? = nil,
                           timeOut: TimeInterval = 10,
                           encoding: RequestEncoding = .URLDefult,
                           response: ResponseEncoding = .JSON,
                           headers: HTTPHeaders? = nil,
                           complete: ((Any?, Data?, NSError?) -> Void)?) {
        
        request(base,
                url: url,
                parameters: parameters,
                timeOut: timeOut,
                method: .post,
                encoding: encoding,
                response: response,
                headers: headers,
                complete: complete)
        
    }
    
    
    public class func GET(_ base: String,
                          url: String,
                          parameters: Parameters?,
                          contentId: Any? = nil,
                          timeOut: TimeInterval = 10,
                          encoding: RequestEncoding = .URLDefult,
                          response: ResponseEncoding = .JSON,
                          headers: HTTPHeaders? = nil,
                          complete: ((Any?, Data?, NSError?) -> Void)?) {
        
        request(base,
                url: url,
                parameters: parameters,
                timeOut: timeOut,
                method: .get,
                encoding: encoding,
                response: response,
                headers: headers,
                complete: complete)
    }
    
    
    public class func PUT(_ base: String,
                          url: String,
                          parameters: Parameters?,
                          contentId: Any? = nil,
                          timeOut: TimeInterval = 10,
                          encoding: RequestEncoding = .URLDefult,
                          response: ResponseEncoding = .JSON,
                          headers: HTTPHeaders? = nil,
                          complete: ((Any?, Data?, NSError?) -> Void)?) {
        
        request(base,
                url: url,
                parameters: parameters,
                timeOut: timeOut,
                method: .put,
                encoding: encoding,
                response: response,
                headers: headers,
                complete: complete)
    }
    
    
    public class func DELETE(_ base: String,
                             url: String,
                             parameters: Parameters?,
                             timeOut: TimeInterval = 10,
                             contentId: Any? = nil,
                             encoding: RequestEncoding = .URLDefult,
                             response: ResponseEncoding = .JSON,
                             headers: HTTPHeaders? = nil,
                             complete: ((Any?, Data?, NSError?) -> Void)?) {
        
        request(base,
                url: url,
                parameters: parameters,
                timeOut: timeOut,
                method: .delete,
                encoding: encoding,
                response: response,
                headers: headers,
                complete: complete)
    }
    
    
    /// 公共的下载方法
    class public func download(_ path: String,
                               to destination: DownloadRequest.DownloadFileDestination? = nil,
                               progress: ((Double) -> Void)? = nil,
                               complete: ((String?, NSError?) -> Void)? = nil) {
        
        guard let requestUrl: URL = URL.init(string: path) else { return }
        
        let _destination_: DownloadRequest.DownloadFileDestination = { _, response in
            
            let cachesURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
            
            let ext = response.mimeType?.split(separator: "/").last ?? ""
            
            let filename = response.suggestedFilename?.replacingOccurrences(of: ".\(ext)", with: "")
            
            let fileURL = cachesURL.appendingPathComponent((filename ?? "\(Date())") + ".\(ext)")
            
            return (fileURL, [.removePreviousFile, .createIntermediateDirectories])
        }
        
        self.default.download(URLRequest.init(url: (requestUrl)), to: (destination == nil ? _destination_ : destination))
            .downloadProgress(queue: DispatchQueue.main, closure: { (progressObject) in
                if progress != nil {
                    progress!(progressObject.fractionCompleted)
                }
            })
            .responseData { (response) in
                
                guard complete != nil else { return }
                
                complete!(response.destinationURL?.path, response.error as NSError?)
        }
    }
    
    /// 公共的上传方法
    class private func upload(_ request: UploadRequest,
                              progress: ((Double) -> Void)? = nil,
                              complete: ((Any?, NSError?) -> Void)? = nil) {
        
        request.validate(contentType: contentType).uploadProgress(queue: DispatchQueue.main, closure: { (progressObject) in
            
            if progress != nil {
                progress!(progressObject.fractionCompleted)
            }
            
        }).responseJSON { (responseObject) in
            
            guard complete != nil else { return }
            
            switch responseObject.result {
            case .success(let value) where complete != nil:
                complete!(value, nil)
            case .failure(let error) where complete != nil:
                complete!( nil, error as NSError)
                print(error)
            default : break
            }
        }
    }
    
    class private func multipartFormData(_ fileData: Any,
                                         fileKey: String? = nil,
                                         mimeType: String,
                                         parameters: [String: String]? = nil) -> (MultipartFormData) -> Void {
        
        let block: (MultipartFormData) -> Void = { multableData in
            
            for (key, value) in parameters! {
                
                guard let valueData: Data = value.data(using: .utf8) else { continue }
                
                multableData.append(valueData, withName: key)
            }
            
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd hh:mm:ss:SSS"
            let fileName = formatter.string(from: Date())
            
            if let data = fileData as? Data {
                multableData.append(data, withName: fileKey!, fileName: fileName, mimeType: mimeType)
                return
            }
            
            if let fileUrl = fileData as? URL {
                multableData.append(fileUrl, withName: fileKey!, fileName: fileName, mimeType: mimeType)
                return
            }
            
            if let filePath = fileData as? String {
                guard let fileUrl: URL = URL.init(string: filePath) else { return }
                multableData.append(fileUrl, withName: fileKey!, fileName: fileName, mimeType: mimeType)
                return
            }
        }
        return block
    }
    
    class private func encodingCompletion(_ progress: ((Double) -> Void)? = nil,
                                          complete: ((Any?, NSError?) -> Void)? = nil) -> (SessionManager.MultipartFormDataEncodingResult) -> Void {
        
        return { (encodingResult) in
            
            switch encodingResult {
            case .success(request: let uploadRequest, streamingFromDisk: _, streamFileURL: _):
                
                upload(uploadRequest, progress: progress, complete: complete)
                break
                
            case .failure(let error):
                
                if complete != nil {
                    complete!(nil, error as NSError)
                }
                break
            }
        }
    }
    
    class public func upload(_ data: Data,
                             fileKey: String? = nil,
                             mimeType: String,
                             to path: String,
                             parameters: [String: String]? = nil,
                             method: HTTPMethod = .put,
                             headers: HTTPHeaders? = nil,
                             progress: ((Double) -> Void)? = nil,
                             complete: ((Any?, NSError?) -> Void)? = nil) {
        
        guard let requestUrl: URL = URL.init(string: path) else { return }
        
        if parameters == nil && fileKey == nil {
            upload(self.default.upload(data,
                                       to: requestUrl,
                                       method: method,
                                       headers:headers),
                   progress: progress,
                   complete: complete)
            return
        }
        
        self.default.upload(multipartFormData: multipartFormData(data,
                                                                 fileKey: fileKey,
                                                                 mimeType: mimeType,
                                                                 parameters: parameters),
                            to: requestUrl,
                            method: method,
                            headers: headers,
                            encodingCompletion: encodingCompletion(progress,
                                                                   complete: complete))
    }
    
    class public func upload(_ filePath: String,
                             fileKey: String? = nil,
                             mimeType: String,
                             to path: String,
                             parameters: [String: String]? = nil,
                             method: HTTPMethod = .put,
                             headers: HTTPHeaders? = nil,
                             progress: ((Double) -> Void)? = nil,
                             complete: ((Any?, NSError?) -> Void)? = nil) {
        
        guard let fileUrl: URL = URL.init(string: filePath) else { return }
        guard let requestUrl: URL = URL.init(string: path) else { return }
        
        if parameters == nil && fileKey == nil {
            upload(self.default.upload(fileUrl,
                                       to: requestUrl,
                                       method: method,
                                       headers:headers),
                   progress: progress,
                   complete: complete)
            return
        }
        
        self.default.upload(multipartFormData: multipartFormData(fileUrl,
                                                                 fileKey: fileKey,
                                                                 mimeType: mimeType,
                                                                 parameters: parameters),
                            to: requestUrl,
                            method: method,
                            headers: headers,
                            encodingCompletion: encodingCompletion(progress,
                                                                   complete: complete))
    }
    
    class public func upload(_ inputStream: InputStream,
                             to path: String,
                             method: HTTPMethod = .put,
                             headers: HTTPHeaders? = nil,
                             progress: ((Double) -> Void)? = nil,
                             complete: ((Any?, NSError?) -> Void)? = nil) {
        
        guard let requestUrl: URL = URL.init(string: path) else { return }
        
        upload(self.default.upload(inputStream,
                                   to: requestUrl,
                                   method: method,
                                   headers:headers),
               progress: progress,
               complete: complete)
    }
    
    @objc class public func Upload(_ file: Any,
                                   to path: String,
                                   fileKey: String? = nil,
                                   mimeType: String,
                                   parameters: [String: String]? = nil,
                                   method: JDHTTPMethod = .put,
                                   headers: HTTPHeaders? = nil,
                                   progress: ((Double) -> Void)? = nil,
                                   complete: ((Any?, NSError?) -> Void)? = nil) {
        
        var _method_: HTTPMethod = .put
        
        switch method {
        case .post:
            _method_ = .post
        case .get:
            _method_ = .get
        case .put:
            _method_ = .put
        case .delete:
            _method_ = .delete
        }
        
        if let image = file as? UIImage {
            guard let data: Data = image.jpegData(compressionQuality: 0.5) else {
                if complete != nil {
                    let userInfo = [ NSLocalizedDescriptionKey : "图片格式不正确"]
                    let error: NSError = NSError(domain: NSURLErrorDomain, code: 404, userInfo: userInfo)
                    complete!(nil, error)
                }
                return
            }
            upload(data,
                   fileKey: fileKey,
                   mimeType: "image/jpeg",
                   to: path,
                   parameters: parameters,
                   method: _method_,
                   headers: headers,
                   progress: progress,
                   complete: complete)
            return
        }
        
        if let url = file as? URL {
            
            upload(url.absoluteString,
                   mimeType: mimeType,
                   to: path,
                   parameters: parameters,
                   method: _method_,
                   headers: headers,
                   progress: progress,
                   complete: complete)
            return
            
        }
        
        if let string = file as? String {
            
            upload(string,
                   mimeType: mimeType,
                   to: path,
                   parameters: parameters,
                   method: _method_,
                   headers: headers,
                   progress: progress,
                   complete: complete)
            return
        }
    }
}
