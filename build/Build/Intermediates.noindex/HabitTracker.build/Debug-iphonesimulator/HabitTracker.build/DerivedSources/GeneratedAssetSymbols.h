#import <Foundation/Foundation.h>

#if __has_attribute(swift_private)
#define AC_SWIFT_PRIVATE __attribute__((swift_private))
#else
#define AC_SWIFT_PRIVATE
#endif

/// The resource bundle ID.
static NSString * const ACBundleID AC_SWIFT_PRIVATE = @"com.myorganization.HabitTracker";

/// The "Background" asset catalog color resource.
static NSString * const ACColorNameBackground AC_SWIFT_PRIVATE = @"Background";

/// The "Border" asset catalog color resource.
static NSString * const ACColorNameBorder AC_SWIFT_PRIVATE = @"Border";

/// The "ButtonBackground" asset catalog color resource.
static NSString * const ACColorNameButtonBackground AC_SWIFT_PRIVATE = @"ButtonBackground";

/// The "CalendarComplete" asset catalog color resource.
static NSString * const ACColorNameCalendarComplete AC_SWIFT_PRIVATE = @"CalendarComplete";

/// The "CalendarEmpty" asset catalog color resource.
static NSString * const ACColorNameCalendarEmpty AC_SWIFT_PRIVATE = @"CalendarEmpty";

/// The "CalendarHigh" asset catalog color resource.
static NSString * const ACColorNameCalendarHigh AC_SWIFT_PRIVATE = @"CalendarHigh";

/// The "CalendarLow" asset catalog color resource.
static NSString * const ACColorNameCalendarLow AC_SWIFT_PRIVATE = @"CalendarLow";

/// The "CalendarMedium" asset catalog color resource.
static NSString * const ACColorNameCalendarMedium AC_SWIFT_PRIVATE = @"CalendarMedium";

/// The "Card" asset catalog color resource.
static NSString * const ACColorNameCard AC_SWIFT_PRIVATE = @"Card";

/// The "Error" asset catalog color resource.
static NSString * const ACColorNameError AC_SWIFT_PRIVATE = @"Error";

/// The "Primary" asset catalog color resource.
static NSString * const ACColorNamePrimary AC_SWIFT_PRIVATE = @"Primary";

/// The "PrimaryDark" asset catalog color resource.
static NSString * const ACColorNamePrimaryDark AC_SWIFT_PRIVATE = @"PrimaryDark";

/// The "Success" asset catalog color resource.
static NSString * const ACColorNameSuccess AC_SWIFT_PRIVATE = @"Success";

/// The "Surface" asset catalog color resource.
static NSString * const ACColorNameSurface AC_SWIFT_PRIVATE = @"Surface";

/// The "TextPrimary" asset catalog color resource.
static NSString * const ACColorNameTextPrimary AC_SWIFT_PRIVATE = @"TextPrimary";

/// The "TextSecondary" asset catalog color resource.
static NSString * const ACColorNameTextSecondary AC_SWIFT_PRIVATE = @"TextSecondary";

/// The "Warning" asset catalog color resource.
static NSString * const ACColorNameWarning AC_SWIFT_PRIVATE = @"Warning";

#undef AC_SWIFT_PRIVATE
