
import Foundation
import Unbox

struct Article {
    let id: Int
    let title: String
    let media_url: String
    let publishedDate: NSDate
    let author: Author
    
    var likesCount: Int
    var summary: String?
    var body: String?
}

extension Article {
    mutating func updateDataWith(article: Article) {
        self.body = article.body
    }
}

extension Article: DatabaseObject {
    static var pathComponent: String { return "articles" }
    
    init(unboxer: Unboxer) {
        self.id = unboxer.unbox("id")
        self.title = unboxer.unbox("title")
        self.summary = unboxer.unbox("summary")
        self.media_url = unboxer.unbox("media_url")
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH-mm-ss.SSSZ"
        self.publishedDate = unboxer.unbox("published_at", formatter: formatter)
        self.author = unboxer.unbox("author")
        self.likesCount = unboxer.unbox("likes_count")
        self.body = unboxer.unbox("body")
    }
}
