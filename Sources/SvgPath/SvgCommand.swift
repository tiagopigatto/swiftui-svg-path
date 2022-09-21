import CoreGraphics


/// See https://www.w3.org/TR/SVG/paths.html#PathData
public enum SvgCommand {
    case moveAbsolute(xy: CGPoint)
    case moveRelative(dx: CGFloat, dy: CGFloat)
    case closePath
    case lineToAbsolute(xy: CGPoint)
    case lineToRelative(dx: CGFloat, dy: CGFloat)
    case horizontalLineToAbsolute(x: CGFloat)
    case horizontalLineToRelative(dx: CGFloat)
    case verticalLineToAbsolute(y: CGFloat)
    case verticalLineToRelative(dy: CGFloat)
    case curveToAbsolute(xy1: CGPoint, xy2: CGPoint, xy: CGPoint)
    case curveToRelative(dx1: CGFloat, dy1: CGFloat, dx2: CGFloat, dy2: CGFloat, dx: CGFloat, dy: CGFloat)
    case smoothCurveToAbsolute(xy2: CGPoint, xy: CGPoint)
    case smoothCurveToRelative(dx2: CGFloat, dy2: CGFloat, dx: CGFloat, dy: CGFloat)
    case quadraticBezierCurveToAbsolute(xy1: CGPoint, xy: CGPoint)
    case quadraticBezierCurveToRelative(dx1: CGFloat, dy1: CGFloat, dx: CGFloat, dy: CGFloat)
    case smoothQuadraticBezierCurveToAbsolute(xy: CGPoint)
    case smoothQuadraticBezierCurveToRelative(dx: CGFloat, dy: CGFloat)
    case elllipticalArcAbsolute(rx: CGFloat, ry: CGFloat, xAxisRotation: CGFloat, largeArcFlag: Bool, sweepFlag: Bool, xy: CGPoint)
    case elllipticalArcRelative(rx: CGFloat, ry: CGFloat, xAxisRotation: CGFloat, largeArcFlag: Bool, sweepFlag: Bool, dx: CGFloat, dy: CGFloat)
    case invalid(command: String, expected: Int, actual: Int)
}
