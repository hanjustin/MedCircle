
import Foundation

class DataService {
    private typealias JSON = [String : AnyObject]
    private static let defaultBaseURL = NSURL(string: "https://medcircle-coding-project.s3.amazonaws.com/api")
    
    enum FileType: String {
        case json
    }
    
    enum FetchError: ErrorType {
        case invalidURL
        case responseError(NSError)
        case failedFetchingJSON(NSData?)
        case failedJSONMapping([String : AnyObject])
        
        var description: String {
            switch self {
            case .invalidURL: return "Invalid URL"
            case .responseError(let error): return error.localizedDescription
            case .failedFetchingJSON(_): return "Failed downloading data or converting data to JSON"
            case .failedJSONMapping(_): return "Failed Mapping JSON to Resource"
            }
        }
    }
    
    var baseURL: NSURL?
    
    init(baseURL: NSURL? = DataService.defaultBaseURL) {
        self.baseURL = baseURL
    }
}

// MARK: - Public Methods

extension DataService {
    func fetchAllResources<Resource: DatabaseObject>(fileType: FileType = .json, completion: ([Resource]?, FetchError?) -> Void) {
        guard let url = urlWithPathComponents(Resource.pathComponent, fileType: fileType) else { return completion(nil, FetchError.invalidURL) }
        
        let session = NSURLSession.sharedSession()
        let request = NSURLRequest(URL: url)
        let fetchTask = session.dataTaskWithRequest(request) { (data, response, error) in
            var resources: [Resource]?
            var fetchError: FetchError?
            
            defer { completion(resources, fetchError) }
            
            if let error = error { fetchError = .responseError(error); return }
            
            guard
                let downloadedData = data,
                let json = (try? NSJSONSerialization.JSONObjectWithData(downloadedData, options: [])) as? [JSON]
                else { fetchError = .failedFetchingJSON(data); return }
            
            resources = []
            for dict in json {
                guard let resource = Resource.instanceFrom(dict) else { resources = nil; fetchError = .failedJSONMapping(dict); return }
                resources?.append(resource)
            }
        }
        
        fetchTask.resume()
    }
    
    func fetchResource<Resource: DatabaseObject>(withID id: String, fileType: FileType = .json, completion: (Resource?, FetchError?) -> Void) {
        guard let url = urlWithPathComponents(Resource.pathComponent, id, fileType: fileType) else { return completion(nil, FetchError.invalidURL) }
        
        let session = NSURLSession.sharedSession()
        let request = NSURLRequest(URL: url)
        let fetchTask = session.dataTaskWithRequest(request) { (data, response, error) in
            var resource: Resource?
            var fetchError: FetchError?
            
            defer { completion(resource, fetchError) }
            
            if let error = error { fetchError = .responseError(error); return }
            
            guard
                let downloadedData = data,
                let json = (try? NSJSONSerialization.JSONObjectWithData(downloadedData, options: [])) as? JSON
                else { fetchError = .failedFetchingJSON(data); return }
            
            resource = Resource.instanceFrom(json)
            if resource == nil { fetchError = .failedJSONMapping(json) }
        }
        
        fetchTask.resume()
    }
}

// MARK: - Private Methods

private extension DataService {
    func urlWithPathComponents(pathComponents: String..., fileType: FileType) -> NSURL? {
        var url = baseURL
        pathComponents.forEach { url = url?.URLByAppendingPathComponent($0) }
        url = url?.URLByAppendingPathExtension(fileType.rawValue)
        return url
    }
}
