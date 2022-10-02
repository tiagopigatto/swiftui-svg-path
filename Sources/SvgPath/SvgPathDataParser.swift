import Foundation
import CoreGraphics


public struct SvgPathDataParser {
    let numberFormatter = NumberFormatter()
    var commands = [SvgCommand]()
    
    var arguments = [CGFloat]()
    var currentArgment = ""
    
    var currentCommand: String = ""
    
    mutating func parse(str: String) -> [SvgCommand] {
        for ch in str {
            if Self.separatorArgmentCounts.keys.contains(String(ch)) {
                addCommand(ch: String(ch))
            } else {
                currentCommand += String(ch)
                if ch == "," || ch == " " {
                    addCurrentArgument()
                    currentArgment = ""
                } else if ch == "-" {
                    addCurrentArgument()
                    currentArgment = "-"
                } else if ch == "." && currentArgment.contains(".") { // a new arg can just start by introducing a new period 0.25.456
                    addCurrentArgument()
                    currentArgment = "."
                } else {
                    currentArgment.append(ch)
                }
            }
        }
        return commands
        
    }
    
    mutating func addCurrentArgument() {
        guard !currentArgment.isEmpty else { return }

        let currentArgment = self.currentArgment // save it because addCommmand wipes it out
        
        
        // Multiple commands can occur by just adding more arguments: L124 456 789 101 // Two L commands: L124 456 and L789 101
        let ch = String(currentCommand.first!)
        if let expectedArgumentCount = Self.separatorArgmentCounts[ch],
           arguments.count == expectedArgumentCount {
            self.currentArgment = ""
            addCommand(ch: ch)
        }
        
        if let n = numberFormatter.number(from: currentArgment) {
            arguments.append(CGFloat(truncating: n))
        } else {
            //assertionFailure("Can't parse number \(currentArgment)")
        }
        
    }
    
    mutating func addCommand(ch: String) {
        if !currentCommand.trimmingCharacters(in: .whitespaces).isEmpty {
            if !currentArgment.trimmingCharacters(in: .whitespaces).isEmpty {
                if let n = numberFormatter.number(from: currentArgment) {
                    arguments.append(CGFloat(truncating: n))
                } else {
                    assertionFailure("Can't parse number \(currentCommand)")
                }
            }
            
            let ch = String(currentCommand.first!)
            if let argumentCount = Self.separatorArgmentCounts[ch],
               argumentCount == arguments.count {
                commands.append(generateCommand(ch: ch, args: arguments))
            } else {
                assertionFailure("Bad arguments: \(currentCommand)")
            }
        }
        currentCommand = String(ch)
        currentArgment = ""
        arguments = [CGFloat]()
        
    }
    
    func generateCommand(ch: String, args: [CGFloat]) -> SvgCommand {
        guard let expectedArgumentCount = Self.separatorArgmentCounts[ch] else {
            assertionFailure("Unknown separator: \(ch)")
            return .invalid(command: ch, expected: 0, actual: args.count)
        }
        
        guard expectedArgumentCount == args.count else {
            return .invalid(command: ch, expected: expectedArgumentCount, actual: args.count)
        }
        
        switch ch {
        case "M":
            return .moveAbsolute(xy: CGPoint(x: args[0], y: args[1]))
        case "m":
            return .moveRelative(dx: args[0], dy: args[1])
        case "Z":
            return .closePath
        case "z":
            return .closePath
        case "L":
            return .lineToAbsolute(xy: CGPoint(x: args[0], y: args[1]))
        case "l":
            return .lineToRelative(dx: args[0], dy: args[1])
        case "H":
            return .horizontalLineToAbsolute(x: args[0])
        case "h":
            return .horizontalLineToRelative(dx: args[0])
        case "V":
            return .verticalLineToAbsolute(y: args[0])
        case "v":
            return .verticalLineToRelative(dy: args[0])
        case "C":
            return .curveToAbsolute(xy1: CGPoint(x: args[0], y: args[1]), xy2: CGPoint(x: args[2], y: args[3]), xy: CGPoint(x: args[4], y: args[5]))
        case "c":
            return .curveToRelative(dx1: args[0], dy1: args[1], dx2: args[2], dy2: args[3], dx: args[4], dy: args[5])
        case "S":
            return .smoothCurveToAbsolute(xy2: CGPoint(x: args[0], y: args[1]), xy: CGPoint( x: args[2], y: args[3]))
        case "s":
            return .smoothCurveToRelative(dx2: args[0], dy2: args[1], dx: args[2], dy: args[3])
        case "Q":
            return .quadraticBezierCurveToAbsolute(xy1: CGPoint(x: args[0], y: args[1]), xy: CGPoint( x: args[2], y: args[3]))
        case "q":
            return .quadraticBezierCurveToRelative(dx1: args[0], dy1: args[1], dx: args[2], dy: args[3])
        case "T":
            return .smoothQuadraticBezierCurveToAbsolute(xy: CGPoint(x: args[0], y: args[1]))
        case "t":
            return .smoothQuadraticBezierCurveToRelative(dx: args[0], dy: args[1])
        case "A":
            return .elllipticalArcAbsolute(rx: args[0], ry: args[1], xAxisRotation: args[2], largeArcFlag: args[3] != 0, sweepFlag: args[4] != 0, xy: CGPoint(x: args[5], y: args[6]))
        case "a":
            return .elllipticalArcRelative(rx: args[0], ry: args[1], xAxisRotation: args[2], largeArcFlag: args[3] != 0, sweepFlag: args[4] != 0, dx: args[5], dy: args[6])
        default:
            return .invalid(command: ch, expected: 0, actual: args.count)
        }
    }
    
    func checkArguments(_ ch: String, _ args: [CGFloat], expected: Int) -> SvgCommand? {
        guard args.count == expected else {
            return .invalid(command: ch, expected: expected, actual: args.count)
        }
        return nil
    }
    
    // How many arguments does each command need
    private static let separatorArgmentCounts = [
        "M": 2,
        "m": 2,
        "Z": 0,
        "z": 0,
        "L": 2,
        "l": 2,
        "H": 1,
        "h": 1,
        "V": 1,
        "v": 1,
        "C": 6,
        "c": 6,
        "S": 4,
        "s": 4,
        "Q": 4,
        "q": 4,
        "T": 2,
        "t": 2,
        "A": 7,
        "a": 7,
    ]
}
