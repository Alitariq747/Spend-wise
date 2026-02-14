#import <Foundation/Foundation.h>

#if __has_attribute(swift_private)
#define AC_SWIFT_PRIVATE __attribute__((swift_private))
#else
#define AC_SWIFT_PRIVATE
#endif

/// The resource bundle ID.
static NSString * const ACBundleID AC_SWIFT_PRIVATE = @"com.ahmad.SpendWise.SpendWiseWidgets";

/// The "WidgetBackground" asset catalog color resource.
static NSString * const ACColorNameWidgetBackground AC_SWIFT_PRIVATE = @"WidgetBackground";

/// The "WidgetBackgroundimage" asset catalog image resource.
static NSString * const ACImageNameWidgetBackgroundimage AC_SWIFT_PRIVATE = @"WidgetBackgroundimage";

#undef AC_SWIFT_PRIVATE
