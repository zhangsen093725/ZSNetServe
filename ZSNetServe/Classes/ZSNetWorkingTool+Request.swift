//
//  ZSNetWorkingTool+Request.swift
//  Alamofire
//
//  Created by 张森 on 2020/3/12.
//

import Foundation
import Alamofire

@objc public enum RequestEncoding: Int {
    case JSONString = 1, URLDefult = 2, URLQueryString = 3, HTTPBody = 4
}

@objc public enum ZSHTTPMethod: Int {
    case option = 1, post = 2, get = 3, put = 4, head = 5, delete = 6, connect = 7
}

extension ZSNetWorkingTool {
    
    /// defaultHTTPHeaders
    public static let zs_defaultHTTPHeaders: HTTPHeaders = {
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
                        let afInfo = Bundle(for: Session.self).infoDictionary,
                        let build = afInfo["CFBundleShortVersionString"]
                        else { return "Unknown" }
                    
                    return "Alamofire/\(build)"
                }()
                
                return "\(executable)/\(appVersion) (\(bundle); build:\(appBuild); \(osName); \(osNameVersion)) \(alamofireVersion)"
            }
            
            return "Alamofire"
        }()
        
        return HTTPHeaders([
            "Accept-Encoding": acceptEncoding,
            "Accept-Language": acceptLanguage,
            "User-Agent"     : userAgent
        ])
    }()
    
    
    /// contentType
    public static let zs_contentType: Set<String> = {
        
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
    
    
    public class func zs_parameterEncoding(encoding: RequestEncoding) -> ParameterEncoding {
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
    
    public class func zs_method(_ method: ZSHTTPMethod) -> HTTPMethod {
        
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
        case .head:
            _method_ = .head
        case .option:
            _method_ = .options
        case .connect:
            _method_ = .connect
        }
        return _method_
    }
}
