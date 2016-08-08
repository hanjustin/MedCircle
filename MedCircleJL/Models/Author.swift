
import Foundation
import Unbox

struct Author {
    let iconURL: String
    let name: String
}

extension Author: DatabaseObject {
    static var pathComponent: String { return "authors" }
    
    init(unboxer: Unboxer) {
        self.iconURL = unboxer.unbox("icon_url")
        self.name = unboxer.unbox("name")
    }
}