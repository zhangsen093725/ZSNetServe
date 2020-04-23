//
//  ZSNetWorkingTool+Upload.swift
//  Alamofire
//
//  Created by 张森 on 2020/3/12.
//

import Foundation
import Alamofire

extension ZSNetWorkingTool {
    
    /// 文件上传
    /// - Parameters:
    ///   - request: UploadRequest
    ///   - progress: 进度
    ///   - completion: 上传完成的回调
    class private func Upload<ResultType>(_ request: UploadRequest,
                                          progress: ((Double) -> Void)? = nil,
                                          completion: (ZSCompletion<ResultType>)? = nil) {
        
        request.validate(contentType: zs_contentType).uploadProgress(queue: DispatchQueue.main, closure: { (progressObject) in
            
            if progress != nil {
                progress!(progressObject.fractionCompleted)
            }
            
        }).responseJSON { (responseObject) in
            
            guard completion != nil else { return }
            
            switch responseObject.result {
            case .success(let value):
                completion!(value as? ResultType, true, nil)
                break
            case .failure(let error):
                completion!( nil, false, error as NSError)
                print(error)
                break
            }
        }
    }
    
    
    /// 上传文件进行参数传递的回调
    /// - Parameters:
    ///   - files: 文件数组
    ///   - fileKey: 文件对应的 parameters 的Key
    ///   - mimeType: 文件mimeType
    ///   - parameters: 携带的参数
    class private func multipartFormFiles(_ files: [Any],
                                          fileKey: String,
                                          mimeType: String? = nil,
                                          parameters: [String: String]? = nil) -> (MultipartFormData) -> Void {
        
        let block: (MultipartFormData) -> Void = { multableData in
            
            for (key, value) in parameters! {
                
                guard let valueData: Data = value.data(using: .utf8) else { continue }
                
                multableData.append(valueData, withName: key)
            }
            
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd hh:mm:ss:SSS"
            let fileName = formatter.string(from: Date())
            
            for file in files {
                
                if let image = file as? UIImage {
                    
                    guard let data = image.jpegData(compressionQuality: 0.5) else { continue }
                    multableData.append(data, withName: fileKey, fileName: fileName + ".jpeg", mimeType: "image/jpeg")
                    continue
                }
                
                if let data = file as? Data {
                    
                    guard mimeType != nil else { continue }
                    
                    let ext = mimeType!.split(separator: "/").last ?? ""
                    
                    multableData.append(data, withName: fileKey, fileName: fileName + ext, mimeType: mimeType!)
                    return
                }
                
                if let url = file as? URL {
                    multableData.append(url, withName: fileKey)
                    continue
                }
                
                if let filePath = file as? String {
                    
                    guard let fileUrl: URL = URL.init(string: filePath) else { continue }
                    multableData.append(fileUrl, withName: fileKey)
                    continue
                }
            }
        }
        return block
    }
    
    /// 通过Data上传
    /// - Parameters:
    ///   - data: 文件Data
    ///   - path: 上传到服务器的地址
    ///   - fileKey: 文件对应的 parameters 的Key
    ///   - mimeType: 文件mimeType
    ///   - parameters: 携带的参数
    ///   - method: 请求方式，默认为post
    ///   - headers: 请求头
    ///   - progress: 上传进度
    ///   - completion: 上传完成的回调
    class public func Upload<ResultType>(_ data: Data,
                                         to path: String,
                                         fileKey: String? = nil,
                                         mimeType: String,
                                         parameters: [String: String]? = nil,
                                         method: HTTPMethod = .post,
                                         headers: HTTPHeaders? = nil,
                                         progress: ((Double) -> Void)? = nil,
                                         completion: (ZSCompletion<ResultType>)? = nil) {
        
        guard let requestUrl: URL = URL.init(string: path) else { return }
        
        if parameters == nil && fileKey == nil {
            
            let request = self.default.upload(
                data,
                to: requestUrl,
                method: method,
                headers:headers)
            
            Upload(request,
                   progress: progress,
                   completion: completion)
            return
        }
        
        
        let multipartFormFilesHandle = multipartFormFiles(
            [data],
            fileKey: fileKey!,
            mimeType: mimeType,
            parameters: parameters)
        
        let request = self.default.upload(
            multipartFormData: multipartFormFilesHandle,
            to: requestUrl,
            method: method,
            headers: headers)
        
        Upload(request,
               progress: progress,
               completion: completion)
    }
    
    
    /// 通过本地文件地址上传
    /// - Parameters:
    ///   - filePath: 文件地址
    ///   - path: 上传到服务器的地址
    ///   - fileKey: 文件对应的 parameters 的Key
    ///   - mimeType: 文件mimeType
    ///   - parameters: 携带的参数
    ///   - method: 请求方式，默认为post
    ///   - headers: 请求头
    ///   - progress: 上传进度
    ///   - completion: 上传完成的回调
    class public func Upload<ResultType>(_ filePath: String,
                                         to path: String,
                                         fileKey: String? = nil,
                                         mimeType: String,
                                         parameters: [String: String]? = nil,
                                         method: HTTPMethod = .post,
                                         headers: HTTPHeaders? = nil,
                                         progress: ((Double) -> Void)? = nil,
                                         completion: (ZSCompletion<ResultType>)? = nil) {
        
        guard let fileUrl: URL = URL.init(string: filePath) else { return }
        guard let requestUrl: URL = URL.init(string: path) else { return }
        
        if parameters == nil && fileKey == nil {
            
            let request = self.default.upload(
                fileUrl,
                to: requestUrl,
                method: method,
                headers:headers)
            
            Upload(request,
                   progress: progress,
                   completion: completion)
            return
        }
        
        let multipartFormFilesHandle = multipartFormFiles(
            [fileUrl],
            fileKey: fileKey!,
            mimeType: mimeType,
            parameters: parameters)
        
        let request = self.default.upload(
            multipartFormData: multipartFormFilesHandle,
            to: requestUrl,
            method: method,
            headers: headers)
        
        Upload(request,
               progress: progress,
               completion: completion)
    }
    
    
    
    /// 文件流上传
    /// - Parameters:
    ///   - inputStream: 文件流对象
    ///   - path: 上传到服务器的地址
    ///   - method: 请求方式，默认为post
    ///   - headers: 请求头
    ///   - progress: 上传进度
    ///   - completion: 上传完成的回调
    class public func Upload<ResultType>(_ inputStream: InputStream,
                                         to path: String,
                                         method: HTTPMethod = .post,
                                         headers: HTTPHeaders? = nil,
                                         progress: ((Double) -> Void)? = nil,
                                         completion: (ZSCompletion<ResultType>)? = nil) {
        
        guard let requestUrl: URL = URL.init(string: path) else { return }
        
        let request = self.default.upload(
            inputStream,
            to: requestUrl,
            method: method,
            headers:headers)
        
        Upload(request,
               progress: progress,
               completion: completion)
    }
    
    
    
    /// 单文件上传
    /// - Parameters:
    ///   - file: 文件
    ///   - path: 上传到服务器的地址
    ///   - fileKey: 文件对应的 parameters 的Key
    ///   - mimeType: 文件mimeType
    ///   - parameters: 携带的参数
    ///   - method: 请求方式，默认为post
    ///   - headers: 请求头
    ///   - progress: 上传进度
    ///   - completion: 上传完成的回调
    class public func Upload<ResultType>(_ file: Any,
                                         to path: String,
                                         fileKey: String? = nil,
                                         mimeType: String,
                                         parameters: [String: String]? = nil,
                                         method: HTTPMethod = .post,
                                         headers: HTTPHeaders? = nil,
                                         progress: ((Double) -> Void)? = nil,
                                         completion: (ZSCompletion<ResultType>)? = nil) {
        
        if let image = file as? UIImage {
            guard let data: Data = image.jpegData(compressionQuality: 0.5) else {
                if completion != nil {
                    let userInfo = [ NSLocalizedDescriptionKey : "图片格式不正确"]
                    let error: NSError = NSError(domain: NSURLErrorDomain, code: 404, userInfo: userInfo)
                    completion!(nil, false, error)
                }
                return
            }
            Upload(data,
                   to: path,
                   fileKey: fileKey,
                   mimeType: "image/jpeg",
                   parameters: parameters,
                   method: method,
                   headers: headers,
                   progress: progress,
                   completion: completion)
            return
        }
        
        if let url = file as? URL {
            
            Upload(url.absoluteString,
                   to: path,
                   mimeType: mimeType,
                   parameters: parameters,
                   method: method,
                   headers: headers,
                   progress: progress,
                   completion: completion)
            return
            
        }
        
        if let string = file as? String {
            
            Upload(string,
                   to: path,
                   mimeType: mimeType,
                   parameters: parameters,
                   method: method,
                   headers: headers,
                   progress: progress,
                   completion: completion)
            return
        }
    }
    
    /// 多文件上传
    /// - Parameters:
    ///   - files: 文件数组
    ///   - path: 上传到服务器的地址
    ///   - fileKey: 文件对应的 parameters 的Key
    ///   - parameters: 携带的参数
    ///   - method: 请求方式，默认为post
    ///   - headers: 请求头
    ///   - progress: 上传进度
    ///   - completion: 上传完成的回调
    class public func Upload<ResultType>(files: [Any],
                                         to path: String,
                                         fileKey: String,
                                         parameters: [String: String]? = nil,
                                         method: HTTPMethod = .post,
                                         headers: HTTPHeaders? = nil,
                                         progress: ((Double) -> Void)? = nil,
                                         completion: (ZSCompletion<ResultType>)? = nil) {
        
        guard let requestUrl: URL = URL.init(string: path) else { return }
        
        
        let multipartFormFilesHandle = multipartFormFiles(
            files,
            fileKey: fileKey,
            parameters: parameters)
        
        let request = self.default.upload(
            multipartFormData: multipartFormFilesHandle,
            to: requestUrl,
            method: method,
            headers: headers)
        
        Upload(request,
               progress: progress,
               completion: completion)
    }
}
