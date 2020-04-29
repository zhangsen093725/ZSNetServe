//
//  ZSNetWorkingTool+HEAD.swift
//  Alamofire
//
//  Created by 张森 on 2020/3/12.
//

import Foundation
import Alamofire

public extension ZSNetWorkingTool {
    
    /// head请求
    /// - Parameters:
    ///   -  url: 请求的基础url，比如 https://www.baidu.com/ 或 https://www.baidu.com/search/page
    ///   -  path: 请求的url path，比如 search/page，若url为完整链接，则path为“”
    ///   - parameters: 请求的参数
    ///   - completion: 网络请求回调
    class func HEAD<ResultType>(url: String,
                                path: String = "",
                                parameters: Parameters? = nil,
                                completion: (ZSCompletion<ResultType>)?) {
        
        HEAD(url,
             path: "",
             parameters: parameters,
             completion: completion)
    }
    
    /// head请求
    /// - Parameters:
    ///   - base: 请求的基础url，比如 https://www.baidu.com/
    ///   - path: 请求的url path，比如 search/page
    ///   - parameters: 请求的参数
    ///   - timeOut: 请求超时 默认为 30 秒
    ///   - encoding: 请求编码，默认为 URLDefult
    ///   - response: 响应编码，默认为 JSON
    ///   - headers: 请求httpHeader
    ///   - contentType: 请求的contentType
    ///   - completion: 网络请求回调
    class func HEAD<ResultType>(_ base: String,
                                path: String,
                                parameters: Parameters? = nil,
                                timeOut: TimeInterval = zs_timeOut,
                                encoding: RequestEncoding = zs_requestEncoding,
                                response: ResponseEncoding = zs_responseEncoding,
                                headers: [String: String] = zs_httpHeaders,
                                contentType: Set<String> = zs_contentType,
                                completion: (ZSCompletion<ResultType>)?) {
        
        zs_request(base,
                   path: path,
                   parameters: parameters,
                   timeOut: timeOut,
                   method: .head,
                   encoding: encoding,
                   response: response,
                   headers: headers,
                   contentType: contentType,
                   completion: completion)
    }
}
