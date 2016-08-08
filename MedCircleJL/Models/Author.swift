
import Foundation
import Unbox

struct Author {
    let icon_url: String
    let name: String
}

extension Author: DatabaseObject {
    static var pathComponent: String { return "authors" }
    
    init(unboxer: Unboxer) {
        self.icon_url = unboxer.unbox("icon_url")
        self.name = unboxer.unbox("name")
    }
}