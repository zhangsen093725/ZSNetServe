//
//  ZSNetWorkingTool+GET.swift
//  Alamofire
//
//  Created by 张森 on 2020/3/12.
//

import Foundation
import Alamofire

extension ZSNetWorkingTool {
    
    /// get请求
    /// - Parameters:
    ///   -  url: 请求的url
    ///   - parameters: 请求的参数
    ///   - timeOut: 请求超时 默认为 30 秒
    ///   - encoding: 请求编码，默认为 URLDefult
    ///   - response: 响应编码，默认为 JSON
    ///   - headers: 请求httpHeader
    ///   - completion: 网络请求回调
    class open func GET<ResultType>(_ url: String,
                                    parameters: Parameters? = nil,
                                    timeOut: TimeInterval = 30,
                                    encoding: RequestEncoding = .URLDefult,
                                    response: ResponseEncoding = .JSON,
                                    headers: HTTPHeaders? = nil,
                                    completion: (ZSCompletion<ResultType>)?) {
        
        GET(url,
            path: "",
            parameters: parameters,
            timeOut: timeOut,
            encoding: encoding,
            response: response,
            headers: headers,
            completion: completion)
    }
    
    /// get请求
    /// - Parameters:
    ///   - base: 请求的基础url，比如 https://www.baidu.com/
    ///   - path: 请求的url path，比如 search/page
    ///   - parameters: 请求的参数
    ///   - timeOut: 请求超时 默认为 30 秒
    ///   - encoding: 请求编码，默认为 URLDefult
    ///   - response: 响应编码，默认为 JSON
    ///   - headers: 请求httpHeader
    ///   - completion: 网络请求回调
    class public func GET<ResultType>(_ base: String,
                                      path: String,
                                      parameters: Parameters? = nil,
                                      timeOut: TimeInterval = 30,
                                      encoding: RequestEncoding = .URLDefult,
                                      response: ResponseEncoding = .JSON,
                                      headers: HTTPHeaders? = nil,
                                      completion: (ZSCompletion<ResultType>)?) {
        
        zs_request(base,
                   path: path,
                   parameters: parameters,
                   timeOut: timeOut,
                   method: .get,
                   encoding: encoding,
                   response: response,
                   headers: headers,
                   completion: completion)
    }
}
