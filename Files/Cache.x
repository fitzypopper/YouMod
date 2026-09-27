#import "Headers.h"

// Auto clear cache
%hook YTAppDelegate
%new
- (void)YouModAutoClearCache {
    NSString *cachePath = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject;
    // Clear the contents, not the directory itself - removing NSCachesDirectory
    // leaves every later cache write failing with ENOENT until it is recreated.
    NSArray <NSString *> *contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:cachePath error:nil];
    for (NSString *item in contents) {
        [[NSFileManager defaultManager] removeItemAtPath:[cachePath stringByAppendingPathComponent:item] error:nil];
    }
}
- (BOOL)application:(id)application didFinishLaunchingWithOptions:(id)launchOptions {
    BOOL result = %orig;
    if (IS_ENABLED(AutoClearCache)) {
        // Clear cache on app launch
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self YouModAutoClearCache];
        });
    }
    return result;
}
%end