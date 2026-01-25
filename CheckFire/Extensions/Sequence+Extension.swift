extension Sequence {
    /// Computes the sum of the given value `init` and the key path `keyPath`.
    /// - Parameters:
    ///   - keyPath: Key path to sum.
    ///   - initialResult: Initial value to of the sum.
    /// - Returns: Summation.
    func sum<T: AdditiveArithmetic>(_ keyPath: KeyPath<Element, T>, initialResult: T = .zero) -> T {
        reduce(initialResult) { sum, element in sum + element[keyPath: keyPath] }
    }
}
