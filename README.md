# `SvgPath` view for SwiftUI

A reworked fork of [Damian Mehers' `SvgVectorView`](https://github.com/DamianMehers/SvgVectorView), with a slightly 
different take on the API for improved performance and a few extra features:

```swift
struct SvgPath_Previews: PreviewProvider {
    static var previews: some View {
        circle.fixedSize() // "ideal" size as specified by the viewbox
  
        circle.frame(width: 100, height: 100) // fit into an explicitly specified frame
              .foregroundColor(.red)
    }

    static let circle = SvgPath.compile(paths: ["M48,24c0,13.255-10.745,24-24,24S0,37.255,0,24S10.745,0,24,0S48,10.745,48,24z"],
                                        viewBox: .init(width: 48, height: 48))
}
```
