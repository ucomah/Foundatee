import Foundation

/// Accoding to:
/// https://www.swiftbysundell.com/articles/picking-the-right-data-structure-in-swift/

public struct LinkedList<Value> {
    public private(set) var firstNode: Node?
    public private(set) var lastNode: Node?
}

extension LinkedList {
    open class Node {
        open var value: Value
        public fileprivate(set) weak var previous: Node?
        public fileprivate(set) var next: Node?

        public init(value: Value) {
            self.value = value
        }
    }
}

extension LinkedList: Sequence {
    public func makeIterator() -> AnyIterator<Value> {
        var node = firstNode
        return AnyIterator {
            // Iterate through all of our nodes by continuously
            // moving to the next one and extract its value:
            let value = node?.value
            node = node?.next
            return value
        }
    }
}

extension LinkedList {
    
    @discardableResult
    public mutating func append(_ value: Value) -> Node {
        let node = Node(value: value)
        node.previous = lastNode

        lastNode?.next = node
        lastNode = node

        if firstNode == nil {
            firstNode = node
        }

        return node
    }

    public mutating func remove(_ node: Node) {
        node.previous?.next = node.next
        node.next?.previous = node.previous

        // Using "triple-equals" we can compare two class
        // instances by identity, rather than by value:
        if firstNode === node {
            firstNode = node.next
        }

        if lastNode === node {
            lastNode = node.previous
        }
        
        // Completely disconnect the node by removing its
        // sibling references:
        node.next = nil
        node.previous = nil
    }
}
