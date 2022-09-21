import CoreGraphics


extension CGPoint {
    static func + (lhs: CGPoint, rhs: CGSize) -> CGPoint { .init(x: lhs.x + rhs.width, y: lhs.y + rhs.height) }
    static func - (lhs: CGPoint, rhs: CGSize) -> CGPoint { .init(x: lhs.x - rhs.width, y: lhs.y - rhs.height) }    
}


extension CGSize {
    static prefix func - (value: CGSize) -> CGSize { .init(width: -value.width, height: -value.height) }
    static func + (lhs: CGSize, rhs: CGSize) -> CGSize { .init(width: lhs.width + rhs.width, height: lhs.height + rhs.height) }
    static func * (lhs: CGSize, rhs: CGFloat) -> CGSize { .init(width: lhs.width * rhs, height: lhs.height * rhs) }
    static func / (lhs: CGSize, rhs: CGFloat) -> CGSize { .init(width: lhs.width / rhs, height: lhs.height / rhs) }
    static func / (lhs: CGSize, rhs: CGSize) -> CGSize { .init(width: lhs.width / rhs.width, height: lhs.height / rhs.height) }
}


extension CGRect {
    var center: CGPoint { .init(x: self.midX, y: self.midY) }

    init(center: CGPoint, size: CGSize) { self.init(origin: center - size / 2, size: size) }

    func inflated(by delta: CGFloat) -> CGRect { self.inflated(by: .init(width: delta, height: delta)) }
    func inflated(by delta: CGSize) -> CGRect { .init(center: self.center, size: self.size + delta * 2) }

    func deflated(by delta: CGFloat) -> CGRect { self.inflated(by: -delta) }
    func deflated(by delta: CGSize) -> CGRect { self.inflated(by: -delta) }
}
