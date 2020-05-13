//
//  ZSNetworkRequest.swift
//  Alamofire
//
//  Created by 张森 on 2020/5/13.
//

import UIKit
import Alamofire

open class ZSNetworkRequest: NSObject {
    
    public static let `default`: Session = Alamofire.Session.default
    
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
    class func zs_request<ResultType>(
        _ base: String,
        path: String,
        parameters: Parameters? = nil,
        timeOut: TimeInterval? = nil,
        method: HTTPMethod = .get,
        encoding: RequestEncoding? = nil,
        response: ResponseEncoding? = nil,
        headers: [String: String]? = nil,
        contentType: Set<String>? = nil,
        completion: (ZSNetworkConfigure.ZSCompletion<ResultType>)? = nil) {
        
        
        let _contentType = contentType == nil ? ZSNetworkConfigure.zs_contentType : contentType!
        
        var httpContentType = ZSNetworkConfigure.zs_defultContentType
        httpContentType  = httpContentType.union(_contentType)
        
        let _response = response == nil ? ZSNetworkConfigure.zs_responseEncoding : response!
        
        let _timeOut = timeOut == nil ? ZSNetworkConfigure.zs_timeOut : timeOut!
        
        let requestEncoding = encoding == nil ? ZSNetworkConfigure.zs_requestEncoding : encoding!
        let _encoding = ZSNetworkConfigure.zs_parameterEncoding(encoding: requestEncoding)
        
        var httpHeaders = ZSNetworkConfigure.zs_defaultHTTPHeaders
        
        let _header = headers == nil ? ZSNetworkConfigure.zs_httpHeaders : headers!
        _header.forEach { httpHeaders.add(name: $0.key, value: $0.value) }
        
        
        
        self.default.session.configuration.timeoutIntervalForRequest = _timeOut
        
        let url = base + path
        
        let request: DataRequest = self.default.request(
            url,
            method: method,
            parameters: parameters,
            encoding: _encoding,
            headers: httpHeaders)
            .validate(contentType: httpContentType)
        
        switch _response {
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
    @objc class func zs_objcRequest(
        _ base: String,
        path: String,
        parameters: [String : Any]? = nil,
        timeOut: TimeInterval = 30,
        method: ZSHTTPMethod = .get,
        encoding: RequestEncoding = .URLDefult,
        response: ResponseEncoding = .JSON,
        headers: [String : String]? = nil,
        contentType: Set<String>? = nil,
        completion: (ZSNetworkConfigure.ZSCompletion<Any>)? = nil) {
        
        zs_request(base,
                   path: path,
                   parameters: parameters,
                   timeOut: timeOut,
                   method: ZSNetworkConfigure.zs_method(method),
                   encoding: encoding,
                   response: response,
                   headers: headers,
                   contentType: contentType,
                   completion: completion)
    }
    
    /// 提供Objective-C请求使用
    @objc class func zs_objcUpload(
        _ file: Any,
        to path: String,
        fileKey: String? = nil,
        mimeType: String,
        parameters: [String: String]? = nil,
        method: ZSHTTPMethod = .put,
        headers: [String : String]? = nil,
        progress: ((Double) -> Void)? = nil,
        completion: (ZSNetworkConfigure.ZSCompletion<Any>)? = nil) {
        
        let _headers_ = headers == nil ? nil : HTTPHeaders(headers!)
        
        Upload(file,
               to: path,
               fileKey: fileKey,
               mimeType: mimeType,
               parameters: parameters,
               method: ZSNetworkConfigure.zs_method(method),
               headers: _headers_,
               progress: progress,
               completion: completion)
        
    }
    
    /// 提供Objective-C请求使用
    @objc class func zs_objcUpload(
        files: [Any],
        to path: String,
        fileKey: String,
        parameters: [String: String]? = nil,
        method: ZSHTTPMethod = .put,
        headers: [String : String]? = nil,
        progress: ((Double) -> Void)? = nil,
        completion: (ZSNetworkConfigure.ZSCompletion<Any>)? = nil) {
        
        let _headers_ = headers == nil ? nil : HTTPHeaders(headers!)
        
        Upload(files: files,
               to: path,
               fileKey: fileKey,
               parameters: parameters,
               method: ZSNetworkConfigure.zs_method(method),
               headers: _headers_,
               progress: progress,
               completion: completion)
    }
    
    /// 提供Objective-C请求使用
    @objc class func zs_objcDownload(
        _ path: String,
        to url: URL,
        progress: ((Double) -> Void)? = nil,
        completion: (ZSNetworkConfigure.ZSCompletion<Any>)? = nil) {
        
        Download(path, to: url, progress: progress, completion: completion)
    }
}
