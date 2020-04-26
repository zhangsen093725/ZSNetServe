//
//  ZSNetWorkingTool.swift
//  Base
//
//  Created by 张森 on 2019/7/15.
//  Copyright © 2019 张森. All rights reserved.
//

import Foundation
import Alamofire

@objcMembers public class ZSNetWorkingTool: NSObject {
    
    public static let `default`: Session = Alamofire.Session.default
    
    /// 网络请求的httpHeader
    open class var zs_httpHeaders: [String : String] {
        return [:]
    }
    
    /// 网络请求的contentType， defult：["application/json", "text/json", "text/javascript", "text/html", "text/plain", "application/atom+xml", "application/xml", "text/xml", "image/png", "image/jpeg", "multipart/form-data"]
    open class var zs_contentType: Set<String> {
        return []
    }
    
    /// 网络请求超时时长，默认为 30 s
    open class var zs_timeOut: TimeInterval {
        return 30
    }
    
    /// 网络请求编码方式，默认为URLDefult
    open class var zs_requestEncoding: RequestEncoding {
        return .URLDefult
    }
    
    /// 网络请求响应编码方式，默认为JSON
    open class var zs_responseEncoding: ResponseEncoding {
        return .JSON
    }
}




public extension ZSNetWorkingTool {
    /// 网络请求
    /// - Parameters:
    ///   - base: 请求的基础url，比如 https://www.baidu.com/
    ///   - path: 请求的url path，比如 search/page
    ///   - parameters: 请求的参数
    ///   - timeOut: 请求超时 默认为 30 秒
    ///   - encoding: 请求编码，默认为 URLDefult
    ///   - response: 响应编码，默认为 JSON
    ///   - headers: 请求httpHeader
    ///   - completion: 网络请求回调
    class func zs_request<ResultType>(_ base: String,
                                      path: String,
                                      parameters: Parameters? = nil,
                                      timeOut: TimeInterval = 30,
                                      method: HTTPMethod = .get,
                                      encoding: RequestEncoding = .URLDefult,
                                      response: ResponseEncoding = .JSON,
                                      headers: [String: String]? = nil,
                                      contentType: Set<String>? = nil,
                                      completion: (ZSCompletion<ResultType>)? = nil) {
        
        var httpHeaders = zs_defaultHTTPHeaders
        
        headers?.forEach { httpHeaders.add(name: $0.key, value: $0.value) }
        
        var _contentType_ = zs_defultContentType
        
        if let tempContentType = contentType {
            _contentType_  = _contentType_.union(tempContentType)
        }
        
        self.default.session.configuration.timeoutIntervalForRequest = timeOut
        
        let url = base + path
        
        let request: DataRequest = self.default.request(
            url,
            method: method,
            parameters: parameters,
            encoding: zs_parameterEncoding(encoding: encoding),
            headers: httpHeaders)
            .validate(contentType: _contentType_)
        
        switch response {
        case .JSON:
            request.responseJSON { (responseObject) in
                
                switch responseObject.result {
                case .success(let value) where completion != nil:
                    completion!(value as? ResultType, true, nil)
                case .failure(let error) where completion != nil:
                    completion!(nil, false, error as NSError)
                    print(error)
                default : break
                }
            }
        case .Data:
            request.response { (responseObject) in
                
                if completion != nil {
                    completion!(responseObject.data as? ResultType, true, nil)
                }
            }
        }
    }
    
    /// 提供Objective-C请求使用
    @objc class func zs_objcRequest(_ base: String,
                                    path: String,
                                    parameters: [String : Any]? = nil,
                                    timeOut: TimeInterval = 30,
                                    method: ZSHTTPMethod = .get,
                                    encoding: RequestEncoding = .URLDefult,
                                    response: ResponseEncoding = .JSON,
                                    headers: [String : String]? = nil,
                                    contentType: Set<String>? = nil,
                                    completion: (ZSCompletion<Any>)? = nil) {
        
        zs_request(base,
                   path: path,
                   parameters: parameters,
                   timeOut: timeOut,
                   method: zs_method(method),
                   encoding: encoding,
                   response: response,
                   headers: headers,
                   contentType: contentType,
                   completion: completion)
    }
    
    /// 提供Objective-C请求使用
    @objc class func zs_objcUpload(_ file: Any,
                                   to path: String,
                                   fileKey: String? = nil,
                                   mimeType: String,
                                   parameters: [String: String]? = nil,
                                   method: ZSHTTPMethod = .put,
                                   headers: [String : String]? = nil,
                                   progress: ((Double) -> Void)? = nil,
                                   completion: (ZSCompletion<Any>)? = nil) {
        
        let _headers_ = headers == nil ? nil : HTTPHeaders(headers!)
        
        Upload(file,
               to: path,
               fileKey: fileKey,
               mimeType: mimeType,
               parameters: parameters,
               method: zs_method(method),
               headers: _headers_,
               progress: progress,
               completion: completion)
        
    }
    
    /// 提供Objective-C请求使用
    @objc class func zs_objcUpload(files: [Any],
                                   to path: String,
                                   fileKey: String,
                                   parameters: [String: String]? = nil,
                                   method: ZSHTTPMethod = .put,
                                   headers: [String : String]? = nil,
                                   progress: ((Double) -> Void)? = nil,
                                   completion: (ZSCompletion<Any>)? = nil) {
        
        let _headers_ = headers == nil ? nil : HTTPHeaders(headers!)
        
        Upload(files: files,
               to: path,
               fileKey: fileKey,
               parameters: parameters,
               method: zs_method(method),
               headers: _headers_,
               progress: progress,
               completion: completion)
    }
    
    /// 提供Objective-C请求使用
    @objc class func zs_objcDownload(_ path: String,
                                     to url: URL,
                                     progress: ((Double) -> Void)? = nil,
                                     completion: (ZSCompletion<Any>)? = nil) {
        
        Download(path, to: url, progress: progress, completion: completion)
    }
}
