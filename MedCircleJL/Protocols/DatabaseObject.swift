
import Foundation
import Unbox

protocol DatabaseObject: JSONInstantiatable, Unboxable {
    static var pathComponent: String { get }
}