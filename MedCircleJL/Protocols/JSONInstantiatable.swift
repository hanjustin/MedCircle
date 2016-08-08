
import Foundation
import Unbox

protocol JSONInstantiatable {
    static func instanceFrom(dict: [String : AnyObject]) -> Self?
}

extension JSONInstantiatable where Self : Unboxable {
    static func instanceFrom(dict: [String : AnyObject]) -> Self? {
        return try? Unbox(dict)
    }
}
