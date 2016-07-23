import Foundation

#if swift(>=3)
#else
    extension Array {
        internal func reversed() -> [Element] {
            return reverse()
        }
    }
#endif
