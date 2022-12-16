import CoreGraphics
import SwiftUI


public struct SvgPath: InsettableShape {
    private let compiledPath: Path
    private let viewBox: CGRect?
    private var inset = 0.0

    public static func compile(_ paths: [String]) -> Path { Self.compile(Self.parse(paths)) }
    public static func compile(_ path: String) -> Path { Self.compile(Self.parse([path])) }

    public static func parse(_ paths: [String]) -> [SvgCommand] {
        var parser = SvgPathDataParser()
        return paths.flatMap { parser.parse(str: $0) }
    }
    
    public static func compile(_ commands: [SvgCommand]) -> Path {
        var path = Path()
        // Some commands needs this parameter from previous commands
        var secondControlPointOfPreviousCommand: CGPoint? = nil
        
        for command in commands {
            switch command {
            
                case .moveAbsolute(xy: let xy):
                    path.move(to: xy)

                case .moveRelative(dx: let x, dy: let y):
                    if let currentPoint = path.currentPoint {
                        path.move(to: CGPoint(x: currentPoint.x + x, y: currentPoint.y + y))
                    } else {
                        expectedCurrentPoint(command: command)
                    }

                case .closePath:
                    path.closeSubpath()
                
                case .lineToAbsolute(xy: let xy):
                    path.addLine(to: xy)

                case .lineToRelative(dx: let dx, dy: let dy):
                    if let currentPoint = path.currentPoint {
                        path.addLine(to: CGPoint(x: currentPoint.x + dx, y: currentPoint.y + dy))
                    } else {
                        expectedCurrentPoint(command: command)
                    }

                case .horizontalLineToAbsolute(x: let x):
                    if let currentPoint = path.currentPoint {
                        path.addLine(to: CGPoint(x: x, y: currentPoint.y))
                    } else {
                        expectedCurrentPoint(command: command)
                    }

                case .horizontalLineToRelative(dx: let dx):
                    if let currentPoint = path.currentPoint {
                        path.addLine(to: CGPoint(x: currentPoint.x + dx, y: currentPoint.y))
                    } else {
                        expectedCurrentPoint(command: command)
                    }

                case .verticalLineToAbsolute(y: let y):
                    if let currentPoint = path.currentPoint {
                        path.addLine(to: CGPoint(x: currentPoint.x, y: y))
                    } else {
                        expectedCurrentPoint(command: command)
                    }

                case .verticalLineToRelative(dy: let dy):
                    if let currentPoint = path.currentPoint {
                        path.addLine(to: CGPoint(x: currentPoint.x, y: dy + currentPoint.y))
                    } else {
                        expectedCurrentPoint(command: command)
                    }

                case .curveToAbsolute(xy1: let xy1, xy2: let xy2, xy: let xy):
                    secondControlPointOfPreviousCommand = xy2
                    path.addCurve(to: xy, control1: xy1, control2: xy2)

                case .curveToRelative(dx1: let dx1, dy1: let dy1, dx2: let dx2, dy2: let dy2, dx: let dx, dy: let dy):
                    if let currentPoint = path.currentPoint {
                        secondControlPointOfPreviousCommand = CGPoint(x: currentPoint.x + dx2, y: currentPoint.y + dy2)
                        path.addCurve(to: CGPoint(x: currentPoint.x + dx, y: currentPoint.y + dy), control1: CGPoint(x: currentPoint.x + dx1, y: currentPoint.y + dy1), control2: CGPoint(x: currentPoint.x + dx2, y: currentPoint.y + dy2))
                    } else {
                        expectedCurrentPoint(command: command)
                    }

                case .smoothCurveToAbsolute(xy2: let xy2, xy: let xy):
                    
                    // https://stackoverflow.com/questions/5287559/calculating-control-points-for-a-shorthand-smooth-svg-path-bezier-curve
                    if let secondControlPointOfPreviousCommand = secondControlPointOfPreviousCommand,
                       let currentPoint = path.currentPoint{
                        let x1 = 2 * currentPoint.x - secondControlPointOfPreviousCommand.x
                        let y1 = 2 * currentPoint.y - secondControlPointOfPreviousCommand.y
                        path.addCurve(to: xy, control1: CGPoint(x: x1, y: y1), control2: xy2)
                    } else {
                        expectedCurrentPoint(command: command)
                    }
                    secondControlPointOfPreviousCommand = xy2
                    
                case .smoothCurveToRelative(dx2: _, dy2:  _, dx:  _, dy:  _):
                    unhandled(command: command)

                case .quadraticBezierCurveToAbsolute(xy1: let xy1, xy: let xy):
                    path.addQuadCurve(to: xy, control: xy1)

                case .quadraticBezierCurveToRelative(dx1: let dx1, dy1: let dy1, dx: let dx, dy: let dy):
                    if let currentPoint = path.currentPoint {
                        path.addQuadCurve(to: CGPoint(x: currentPoint.x + dx, y: currentPoint.y + dy), control: CGPoint(x: currentPoint.x + dx1, y: currentPoint.y + dy1))
                    } else {
                        expectedCurrentPoint(command: command)
                    }

                case .smoothQuadraticBezierCurveToAbsolute(xy: let xy):
                    if let secondControlPointOfPreviousCommand = secondControlPointOfPreviousCommand,
                       let currentPoint = path.currentPoint {
                        let x1 = 2 * currentPoint.x - secondControlPointOfPreviousCommand.x
                        let y1 = 2 * currentPoint.y - secondControlPointOfPreviousCommand.y
                        path.addQuadCurve(to: xy, control: CGPoint(x: x1, y: y1))
                    } else {
                        expectedCurrentPoint(command: command)
                    }

                case .smoothQuadraticBezierCurveToRelative(dx: _, dy: _):
                    unhandled(command: command)

                case .elllipticalArcAbsolute(rx: _, ry: _, xAxisRotation: _, largeArcFlag: _, sweepFlag: _, xy: _):
                    unhandled(command: command)

                case .elllipticalArcRelative(rx: _, ry: _, xAxisRotation: _, largeArcFlag: _, sweepFlag: _, dx: _, dy: _):
                    unhandled(command: command)

                case .invalid(command: _, expected: _, actual: _):
                    unhandled(command: command)
            }
        }
        
        return path
    }

    
    public init(path: Path, viewBox: CGRect? = nil) {
        self.compiledPath = path
        self.viewBox = viewBox
    }

    public func inset(by amount: CGFloat) -> SvgPath {
        var path = self
        path.inset += amount
        return path
    }

    public func path(in rect: CGRect) -> Path { self.path().scaled(toFit: rect.deflated(by: self.inset),
                                                                   viewBox: self.viewBox) }
    
    private func path() -> Path { self.compiledPath }
    
    private static func expectedCurrentPoint(command: SvgCommand) {
        assertionFailure("No current point for \(command)")
    }
    
    private static func unhandled(command: SvgCommand) {
        assertionFailure("Don't know how to handle \(command)")
    }
}


fileprivate extension Path {
    /// Returns a copy of the path scaled to fit the specified rectangle
    func scaled(toFit rect: CGRect, viewBox: CGRect? = nil) -> Path {
        let nativeSize = (viewBox ?? self.boundingRect).size
        let scale = rect.size / nativeSize
        let scaleFactor = min(scale.width, scale.height)
        let offset = (rect.size - nativeSize * scaleFactor) / 2
        return self.applying(.init(scaleX: scaleFactor, y: scaleFactor))
                   .offsetBy(dx: offset.width, dy: offset.height)
    }
}
