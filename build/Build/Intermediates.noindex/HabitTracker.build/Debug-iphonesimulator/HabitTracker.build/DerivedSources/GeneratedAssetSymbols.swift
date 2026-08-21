import Foundation
#if canImport(AppKit)
import AppKit
#endif
#if canImport(UIKit)
import UIKit
#endif
#if canImport(SwiftUI)
import SwiftUI
#endif
#if canImport(DeveloperToolsSupport)
import DeveloperToolsSupport
#endif

#if SWIFT_PACKAGE
private let resourceBundle = Foundation.Bundle.module
#else
private class ResourceBundleClass {}
private let resourceBundle = Foundation.Bundle(for: ResourceBundleClass.self)
#endif

// MARK: - Color Symbols -

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
extension DeveloperToolsSupport.ColorResource {

    /// The "Background" asset catalog color resource.
    static let background = DeveloperToolsSupport.ColorResource(name: "Background", bundle: resourceBundle)

    /// The "Border" asset catalog color resource.
    static let border = DeveloperToolsSupport.ColorResource(name: "Border", bundle: resourceBundle)

    /// The "ButtonBackground" asset catalog color resource.
    static let buttonBackground = DeveloperToolsSupport.ColorResource(name: "ButtonBackground", bundle: resourceBundle)

    /// The "CalendarComplete" asset catalog color resource.
    static let calendarComplete = DeveloperToolsSupport.ColorResource(name: "CalendarComplete", bundle: resourceBundle)

    /// The "CalendarEmpty" asset catalog color resource.
    static let calendarEmpty = DeveloperToolsSupport.ColorResource(name: "CalendarEmpty", bundle: resourceBundle)

    /// The "CalendarHigh" asset catalog color resource.
    static let calendarHigh = DeveloperToolsSupport.ColorResource(name: "CalendarHigh", bundle: resourceBundle)

    /// The "CalendarLow" asset catalog color resource.
    static let calendarLow = DeveloperToolsSupport.ColorResource(name: "CalendarLow", bundle: resourceBundle)

    /// The "CalendarMedium" asset catalog color resource.
    static let calendarMedium = DeveloperToolsSupport.ColorResource(name: "CalendarMedium", bundle: resourceBundle)

    /// The "Card" asset catalog color resource.
    static let card = DeveloperToolsSupport.ColorResource(name: "Card", bundle: resourceBundle)

    /// The "Error" asset catalog color resource.
    static let error = DeveloperToolsSupport.ColorResource(name: "Error", bundle: resourceBundle)

    /// The "Primary" asset catalog color resource.
    static let primary = DeveloperToolsSupport.ColorResource(name: "Primary", bundle: resourceBundle)

    /// The "PrimaryDark" asset catalog color resource.
    static let primaryDark = DeveloperToolsSupport.ColorResource(name: "PrimaryDark", bundle: resourceBundle)

    /// The "Success" asset catalog color resource.
    static let success = DeveloperToolsSupport.ColorResource(name: "Success", bundle: resourceBundle)

    /// The "Surface" asset catalog color resource.
    static let surface = DeveloperToolsSupport.ColorResource(name: "Surface", bundle: resourceBundle)

    /// The "TextPrimary" asset catalog color resource.
    static let textPrimary = DeveloperToolsSupport.ColorResource(name: "TextPrimary", bundle: resourceBundle)

    /// The "TextSecondary" asset catalog color resource.
    static let textSecondary = DeveloperToolsSupport.ColorResource(name: "TextSecondary", bundle: resourceBundle)

    /// The "Warning" asset catalog color resource.
    static let warning = DeveloperToolsSupport.ColorResource(name: "Warning", bundle: resourceBundle)

}

// MARK: - Image Symbols -

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
extension DeveloperToolsSupport.ImageResource {

}

// MARK: - Color Symbol Extensions -

#if canImport(AppKit)
@available(macOS 14.0, *)
@available(macCatalyst, unavailable)
extension AppKit.NSColor {

    /// The "Background" asset catalog color.
    static var background: AppKit.NSColor {
#if !targetEnvironment(macCatalyst)
        .init(resource: .background)
#else
        .init()
#endif
    }

    /// The "Border" asset catalog color.
    static var border: AppKit.NSColor {
#if !targetEnvironment(macCatalyst)
        .init(resource: .border)
#else
        .init()
#endif
    }

    /// The "ButtonBackground" asset catalog color.
    static var buttonBackground: AppKit.NSColor {
#if !targetEnvironment(macCatalyst)
        .init(resource: .buttonBackground)
#else
        .init()
#endif
    }

    /// The "CalendarComplete" asset catalog color.
    static var calendarComplete: AppKit.NSColor {
#if !targetEnvironment(macCatalyst)
        .init(resource: .calendarComplete)
#else
        .init()
#endif
    }

    /// The "CalendarEmpty" asset catalog color.
    static var calendarEmpty: AppKit.NSColor {
#if !targetEnvironment(macCatalyst)
        .init(resource: .calendarEmpty)
#else
        .init()
#endif
    }

    /// The "CalendarHigh" asset catalog color.
    static var calendarHigh: AppKit.NSColor {
#if !targetEnvironment(macCatalyst)
        .init(resource: .calendarHigh)
#else
        .init()
#endif
    }

    /// The "CalendarLow" asset catalog color.
    static var calendarLow: AppKit.NSColor {
#if !targetEnvironment(macCatalyst)
        .init(resource: .calendarLow)
#else
        .init()
#endif
    }

    /// The "CalendarMedium" asset catalog color.
    static var calendarMedium: AppKit.NSColor {
#if !targetEnvironment(macCatalyst)
        .init(resource: .calendarMedium)
#else
        .init()
#endif
    }

    /// The "Card" asset catalog color.
    static var card: AppKit.NSColor {
#if !targetEnvironment(macCatalyst)
        .init(resource: .card)
#else
        .init()
#endif
    }

    /// The "Error" asset catalog color.
    static var error: AppKit.NSColor {
#if !targetEnvironment(macCatalyst)
        .init(resource: .error)
#else
        .init()
#endif
    }

    /// The "Primary" asset catalog color.
    static var primary: AppKit.NSColor {
#if !targetEnvironment(macCatalyst)
        .init(resource: .primary)
#else
        .init()
#endif
    }

    /// The "PrimaryDark" asset catalog color.
    static var primaryDark: AppKit.NSColor {
#if !targetEnvironment(macCatalyst)
        .init(resource: .primaryDark)
#else
        .init()
#endif
    }

    /// The "Success" asset catalog color.
    static var success: AppKit.NSColor {
#if !targetEnvironment(macCatalyst)
        .init(resource: .success)
#else
        .init()
#endif
    }

    /// The "Surface" asset catalog color.
    static var surface: AppKit.NSColor {
#if !targetEnvironment(macCatalyst)
        .init(resource: .surface)
#else
        .init()
#endif
    }

    /// The "TextPrimary" asset catalog color.
    static var textPrimary: AppKit.NSColor {
#if !targetEnvironment(macCatalyst)
        .init(resource: .textPrimary)
#else
        .init()
#endif
    }

    /// The "TextSecondary" asset catalog color.
    static var textSecondary: AppKit.NSColor {
#if !targetEnvironment(macCatalyst)
        .init(resource: .textSecondary)
#else
        .init()
#endif
    }

    /// The "Warning" asset catalog color.
    static var warning: AppKit.NSColor {
#if !targetEnvironment(macCatalyst)
        .init(resource: .warning)
#else
        .init()
#endif
    }

}
#endif

#if canImport(UIKit)
@available(iOS 17.0, tvOS 17.0, *)
@available(watchOS, unavailable)
extension UIKit.UIColor {

    /// The "Background" asset catalog color.
    static var background: UIKit.UIColor {
#if !os(watchOS)
        .init(resource: .background)
#else
        .init()
#endif
    }

    /// The "Border" asset catalog color.
    static var border: UIKit.UIColor {
#if !os(watchOS)
        .init(resource: .border)
#else
        .init()
#endif
    }

    /// The "ButtonBackground" asset catalog color.
    static var buttonBackground: UIKit.UIColor {
#if !os(watchOS)
        .init(resource: .buttonBackground)
#else
        .init()
#endif
    }

    /// The "CalendarComplete" asset catalog color.
    static var calendarComplete: UIKit.UIColor {
#if !os(watchOS)
        .init(resource: .calendarComplete)
#else
        .init()
#endif
    }

    /// The "CalendarEmpty" asset catalog color.
    static var calendarEmpty: UIKit.UIColor {
#if !os(watchOS)
        .init(resource: .calendarEmpty)
#else
        .init()
#endif
    }

    /// The "CalendarHigh" asset catalog color.
    static var calendarHigh: UIKit.UIColor {
#if !os(watchOS)
        .init(resource: .calendarHigh)
#else
        .init()
#endif
    }

    /// The "CalendarLow" asset catalog color.
    static var calendarLow: UIKit.UIColor {
#if !os(watchOS)
        .init(resource: .calendarLow)
#else
        .init()
#endif
    }

    /// The "CalendarMedium" asset catalog color.
    static var calendarMedium: UIKit.UIColor {
#if !os(watchOS)
        .init(resource: .calendarMedium)
#else
        .init()
#endif
    }

    /// The "Card" asset catalog color.
    static var card: UIKit.UIColor {
#if !os(watchOS)
        .init(resource: .card)
#else
        .init()
#endif
    }

    /// The "Error" asset catalog color.
    static var error: UIKit.UIColor {
#if !os(watchOS)
        .init(resource: .error)
#else
        .init()
#endif
    }

    /// The "Primary" asset catalog color.
    static var primary: UIKit.UIColor {
#if !os(watchOS)
        .init(resource: .primary)
#else
        .init()
#endif
    }

    /// The "PrimaryDark" asset catalog color.
    static var primaryDark: UIKit.UIColor {
#if !os(watchOS)
        .init(resource: .primaryDark)
#else
        .init()
#endif
    }

    /// The "Success" asset catalog color.
    static var success: UIKit.UIColor {
#if !os(watchOS)
        .init(resource: .success)
#else
        .init()
#endif
    }

    /// The "Surface" asset catalog color.
    static var surface: UIKit.UIColor {
#if !os(watchOS)
        .init(resource: .surface)
#else
        .init()
#endif
    }

    /// The "TextPrimary" asset catalog color.
    static var textPrimary: UIKit.UIColor {
#if !os(watchOS)
        .init(resource: .textPrimary)
#else
        .init()
#endif
    }

    /// The "TextSecondary" asset catalog color.
    static var textSecondary: UIKit.UIColor {
#if !os(watchOS)
        .init(resource: .textSecondary)
#else
        .init()
#endif
    }

    /// The "Warning" asset catalog color.
    static var warning: UIKit.UIColor {
#if !os(watchOS)
        .init(resource: .warning)
#else
        .init()
#endif
    }

}
#endif

#if canImport(SwiftUI)
@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
extension SwiftUI.Color {

    /// The "Background" asset catalog color.
    static var background: SwiftUI.Color { .init(.background) }

    /// The "Border" asset catalog color.
    static var border: SwiftUI.Color { .init(.border) }

    /// The "ButtonBackground" asset catalog color.
    static var buttonBackground: SwiftUI.Color { .init(.buttonBackground) }

    /// The "CalendarComplete" asset catalog color.
    static var calendarComplete: SwiftUI.Color { .init(.calendarComplete) }

    /// The "CalendarEmpty" asset catalog color.
    static var calendarEmpty: SwiftUI.Color { .init(.calendarEmpty) }

    /// The "CalendarHigh" asset catalog color.
    static var calendarHigh: SwiftUI.Color { .init(.calendarHigh) }

    /// The "CalendarLow" asset catalog color.
    static var calendarLow: SwiftUI.Color { .init(.calendarLow) }

    /// The "CalendarMedium" asset catalog color.
    static var calendarMedium: SwiftUI.Color { .init(.calendarMedium) }

    /// The "Card" asset catalog color.
    static var card: SwiftUI.Color { .init(.card) }

    /// The "Error" asset catalog color.
    static var error: SwiftUI.Color { .init(.error) }

    #warning("The \"Primary\" color asset name resolves to a conflicting Color symbol \"primary\". Try renaming the asset.")

    /// The "PrimaryDark" asset catalog color.
    static var primaryDark: SwiftUI.Color { .init(.primaryDark) }

    /// The "Success" asset catalog color.
    static var success: SwiftUI.Color { .init(.success) }

    /// The "Surface" asset catalog color.
    static var surface: SwiftUI.Color { .init(.surface) }

    /// The "TextPrimary" asset catalog color.
    static var textPrimary: SwiftUI.Color { .init(.textPrimary) }

    /// The "TextSecondary" asset catalog color.
    static var textSecondary: SwiftUI.Color { .init(.textSecondary) }

    /// The "Warning" asset catalog color.
    static var warning: SwiftUI.Color { .init(.warning) }

}

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
extension SwiftUI.ShapeStyle where Self == SwiftUI.Color {

    /// The "Background" asset catalog color.
    static var background: SwiftUI.Color { .init(.background) }

    /// The "Border" asset catalog color.
    static var border: SwiftUI.Color { .init(.border) }

    /// The "ButtonBackground" asset catalog color.
    static var buttonBackground: SwiftUI.Color { .init(.buttonBackground) }

    /// The "CalendarComplete" asset catalog color.
    static var calendarComplete: SwiftUI.Color { .init(.calendarComplete) }

    /// The "CalendarEmpty" asset catalog color.
    static var calendarEmpty: SwiftUI.Color { .init(.calendarEmpty) }

    /// The "CalendarHigh" asset catalog color.
    static var calendarHigh: SwiftUI.Color { .init(.calendarHigh) }

    /// The "CalendarLow" asset catalog color.
    static var calendarLow: SwiftUI.Color { .init(.calendarLow) }

    /// The "CalendarMedium" asset catalog color.
    static var calendarMedium: SwiftUI.Color { .init(.calendarMedium) }

    /// The "Card" asset catalog color.
    static var card: SwiftUI.Color { .init(.card) }

    /// The "Error" asset catalog color.
    static var error: SwiftUI.Color { .init(.error) }

    /// The "PrimaryDark" asset catalog color.
    static var primaryDark: SwiftUI.Color { .init(.primaryDark) }

    /// The "Success" asset catalog color.
    static var success: SwiftUI.Color { .init(.success) }

    /// The "Surface" asset catalog color.
    static var surface: SwiftUI.Color { .init(.surface) }

    /// The "TextPrimary" asset catalog color.
    static var textPrimary: SwiftUI.Color { .init(.textPrimary) }

    /// The "TextSecondary" asset catalog color.
    static var textSecondary: SwiftUI.Color { .init(.textSecondary) }

    /// The "Warning" asset catalog color.
    static var warning: SwiftUI.Color { .init(.warning) }

}
#endif

// MARK: - Image Symbol Extensions -

#if canImport(AppKit)
@available(macOS 14.0, *)
@available(macCatalyst, unavailable)
extension AppKit.NSImage {

}
#endif

#if canImport(UIKit)
@available(iOS 17.0, tvOS 17.0, *)
@available(watchOS, unavailable)
extension UIKit.UIImage {

}
#endif

// MARK: - Thinnable Asset Support -

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
@available(watchOS, unavailable)
extension DeveloperToolsSupport.ColorResource {

    private init?(thinnableName: Swift.String, bundle: Foundation.Bundle) {
#if canImport(AppKit) && os(macOS)
        if AppKit.NSColor(named: NSColor.Name(thinnableName), bundle: bundle) != nil {
            self.init(name: thinnableName, bundle: bundle)
        } else {
            return nil
        }
#elseif canImport(UIKit) && !os(watchOS)
        if UIKit.UIColor(named: thinnableName, in: bundle, compatibleWith: nil) != nil {
            self.init(name: thinnableName, bundle: bundle)
        } else {
            return nil
        }
#else
        return nil
#endif
    }

}

#if canImport(AppKit)
@available(macOS 14.0, *)
@available(macCatalyst, unavailable)
extension AppKit.NSColor {

    private convenience init?(thinnableResource: DeveloperToolsSupport.ColorResource?) {
#if !targetEnvironment(macCatalyst)
        if let resource = thinnableResource {
            self.init(resource: resource)
        } else {
            return nil
        }
#else
        return nil
#endif
    }

}
#endif

#if canImport(UIKit)
@available(iOS 17.0, tvOS 17.0, *)
@available(watchOS, unavailable)
extension UIKit.UIColor {

    private convenience init?(thinnableResource: DeveloperToolsSupport.ColorResource?) {
#if !os(watchOS)
        if let resource = thinnableResource {
            self.init(resource: resource)
        } else {
            return nil
        }
#else
        return nil
#endif
    }

}
#endif

#if canImport(SwiftUI)
@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
extension SwiftUI.Color {

    private init?(thinnableResource: DeveloperToolsSupport.ColorResource?) {
        if let resource = thinnableResource {
            self.init(resource)
        } else {
            return nil
        }
    }

}

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
extension SwiftUI.ShapeStyle where Self == SwiftUI.Color {

    private init?(thinnableResource: DeveloperToolsSupport.ColorResource?) {
        if let resource = thinnableResource {
            self.init(resource)
        } else {
            return nil
        }
    }

}
#endif

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
@available(watchOS, unavailable)
extension DeveloperToolsSupport.ImageResource {

    private init?(thinnableName: Swift.String, bundle: Foundation.Bundle) {
#if canImport(AppKit) && os(macOS)
        if bundle.image(forResource: NSImage.Name(thinnableName)) != nil {
            self.init(name: thinnableName, bundle: bundle)
        } else {
            return nil
        }
#elseif canImport(UIKit) && !os(watchOS)
        if UIKit.UIImage(named: thinnableName, in: bundle, compatibleWith: nil) != nil {
            self.init(name: thinnableName, bundle: bundle)
        } else {
            return nil
        }
#else
        return nil
#endif
    }

}

#if canImport(UIKit)
@available(iOS 17.0, tvOS 17.0, *)
@available(watchOS, unavailable)
extension UIKit.UIImage {

    private convenience init?(thinnableResource: DeveloperToolsSupport.ImageResource?) {
#if !os(watchOS)
        if let resource = thinnableResource {
            self.init(resource: resource)
        } else {
            return nil
        }
#else
        return nil
#endif
    }

}
#endif

