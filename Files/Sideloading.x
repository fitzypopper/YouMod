// All Codes are adapt from YTLite and uYouEnhanced + Some of my research
#import "Headers.h"

extern void YouModConfigureDownloadButton(_ASDisplayView *view);

// AccessGroupID
static NSString *accessGroupID() {
    NSDictionary *query = [NSDictionary dictionaryWithObjectsAndKeys:
                           (__bridge NSString *)kSecClassGenericPassword, (__bridge NSString *)kSecClass,
                           @"bundleSeedID", kSecAttrAccount,
                           @"", kSecAttrService,
                           (id)kCFBooleanTrue, kSecReturnAttributes,
                           nil];
    CFDictionaryRef result = nil;
    OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef)query, (CFTypeRef *)&result);
    if (status == errSecItemNotFound) {
        status = SecItemAdd((__bridge CFDictionaryRef)query, (CFTypeRef *)&result);
        if (status != errSecSuccess) {
            return nil;
        }
    }
    NSString *accessGroup = [(__bridge NSDictionary *)result objectForKey:(__bridge NSString *)kSecAttrAccessGroup];
    return accessGroup;
}

// _ASDisplayView filters
// This hook can hide A LOT of things
%hook _ASDisplayView

- (void)didMoveToWindow {
    %orig;
    // Hot path: this runs for every view that gets attached, so read the identifier
    // once instead of once per check below.
    NSString *identifier = self.accessibilityIdentifier;
    if (identifier.length == 0) return;
    YouModConfigureDownloadButton(self);
    // if (IS_ENABLED(HideShortsShelf) && [identifier isEqualToString:@"eml.shorts-shelf"]) self.hidden = YES;
    if (IS_ENABLED(HideGenMusicShelf) && [identifier isEqualToString:@"feed_nudge.view"]) self.hidden = YES;
    if (IS_ENABLED(HideFeedPost) && [identifier isEqualToString:@"id.ui.backstage.original_post"]) self.hidden = YES;
    if (IS_ENABLED(HideLikeButton) && [identifier isEqualToString:@"id.video.like.button"]) self.hidden = YES;
    if (IS_ENABLED(HideDisLikeButton) && [identifier isEqualToString:@"id.video.dislike.button"]) self.hidden = YES;
    if (IS_ENABLED(HideShareButton) && [identifier isEqualToString:@"id.video.share.button"]) self.hidden = YES;
    if (IS_ENABLED(HideDownloadButton) && [identifier isEqualToString:@"id.ui.add_to.offline.button"]) self.hidden = YES;
    if (IS_ENABLED(HideClipButton) && [identifier isEqualToString:@"clip_button.eml"]) self.hidden = YES;
    if (IS_ENABLED(HideRemixButton) && [identifier isEqualToString:@"id.video.remix.button"]) self.hidden = YES;
    if (IS_ENABLED(HideSaveButton) && [identifier isEqualToString:@"id.video.add_to.button"]) self.hidden = YES;
    if (IS_ENABLED(HideShortsLikeButton) && [identifier isEqualToString:@"id.reel_like_button"]) self.hidden = YES;
    if (IS_ENABLED(HideShortsDisLikeButton) && [identifier isEqualToString:@"id.reel_dislike_button"]) self.hidden = YES;
    if (IS_ENABLED(HideShortsCommentButton) && [identifier isEqualToString:@"id.reel_comment_button"]) self.hidden = YES;
    if (IS_ENABLED(HideShortsShareButton) && [identifier isEqualToString:@"id.reel_share_button"]) self.hidden = YES;
    if (IS_ENABLED(HideShortsRemixButton) && [identifier isEqualToString:@"id.reel_remix_button"]) self.hidden = YES;
    if (IS_ENABLED(HideShortsMetaButton) && [identifier isEqualToString:@"id.reel_pivot_button"]) self.hidden = YES;
    if (IS_ENABLED(HideShortsProducts) && [identifier isEqualToString:@"product_sticker.main_target"]) self.hidden = YES;
    if (IS_ENABLED(HideShortsProducts) && [identifier isEqualToString:@"product_sticker.secondary_target"]) self.hidden = YES;
    if (IS_ENABLED(HideShortsRecbar) && [identifier isEqualToString:@"id.elements.components.suggested_action"]) self.hidden = YES;
    if (IS_ENABLED(HideShortsCommit) && [identifier isEqualToString:@"eml.shorts-disclosures"]) self.hidden = YES;
    if (IS_ENABLED(HideShortsSubscriptButton) && [identifier isEqualToString:@"id.ui.shorts_paused_state.subscriptions_button"]) self.hidden = YES;
    if (IS_ENABLED(HideShortsLiveButton) && [identifier isEqualToString:@"id.ui.shorts_paused_state.live_button"]) self.hidden = YES;
    if (IS_ENABLED(HideShortsLensButton) && [identifier isEqualToString:@"id.ui.shorts_paused_state.lens_button"]) self.hidden = YES;
    if (IS_ENABLED(HideShortsTrendsButton) && [identifier isEqualToString:@"id.ui.shorts_paused_state.trends_button"]) self.hidden = YES;
    if (IS_ENABLED(HideShortsToVideo) && [identifier isEqualToString:@"id.reel_multi_format_link"]) self.hidden = YES;
    if (IS_ENABLED(HideSubButton) && [identifier isEqualToString:@"eml.animated_subscribe_button"]) self.hidden = YES;
    if (IS_ENABLED(HideShoppingButton) && [identifier isEqualToString:@"eml.header_store_button"]) self.hidden = YES;
    if (IS_ENABLED(HideMemberButton) && [identifier isEqualToString:@"id.sponsor_button"]) self.hidden = YES;
}

%end

// IAmYouTube (https://github.com/PoomSmart/IAmYouTube)
%hook YTVersionUtils
+ (NSString *)appName { return YT_NAME; }
+ (NSString *)appID { return YT_BUNDLE_ID; }
%end

%hook GCKBUtils
+ (NSString *)appIdentifier { return YT_BUNDLE_ID; }
%end

%hook GPCDeviceInfo
+ (NSString *)bundleId { return YT_BUNDLE_ID; }
%end

%hook OGLBundle
+ (NSString *)shortAppName { return YT_NAME; }
%end

%hook GVROverlayView
+ (NSString *)appName { return YT_NAME; }
%end

%hook OGLPhenotypeFlagServiceImpl
- (NSString *)bundleId { return YT_BUNDLE_ID; }
%end

%hook APMAEU
+ (BOOL)isFAS { return YES; }
%end

%hook GULAppEnvironmentUtil
+ (BOOL)isFromAppStore { return YES; }
%end

%hook SSOClientLogin
+ (NSString *)defaultSourceString { return YT_BUNDLE_ID; }
%end

%hook SSOConfiguration
- (id)initWithClientID:(id)clientID supportedAccountServices:(id)supportedAccountServices {
    self = %orig;
    [self setValue:YT_NAME forKey:@"_shortAppName"];
    [self setValue:YT_BUNDLE_ID forKey:@"_applicationIdentifier"];
    return self;
}
%end

%hook YTHotConfig
- (BOOL)clientInfraClientConfigIosEnableFillingEncodedHacksInnertubeContext { return NO; }
%end

%hook NSBundle
+ (NSBundle *)bundleWithIdentifier:(NSString *)identifier {
    if ([identifier isEqualToString:YT_BUNDLE_ID])
        return NSBundle.mainBundle;
    return %orig(identifier);
}
- (NSString *)bundleIdentifier {
    return [self isEqual:NSBundle.mainBundle] ? YT_BUNDLE_ID : %orig;
}
- (NSDictionary *)infoDictionary {
    NSDictionary *dict = %orig;
    if (![self isEqual:NSBundle.mainBundle])
        return %orig;
    NSMutableDictionary *info = [dict mutableCopy];
    if (info[@"CFBundleIdentifier"]) info[@"CFBundleIdentifier"] = YT_BUNDLE_ID;
    if (info[@"CFBundleDisplayName"]) info[@"CFBundleDisplayName"] = YT_NAME;
    if (info[@"CFBundleName"]) info[@"CFBundleName"] = YT_NAME;
    return info;
}
- (id)objectForInfoDictionaryKey:(NSString *)key {
    if (![self isEqual:NSBundle.mainBundle])
        return %orig;
    if ([key isEqualToString:@"CFBundleIdentifier"])
        return YT_BUNDLE_ID;
    if ([key isEqualToString:@"CFBundleDisplayName"] || [key isEqualToString:@"CFBundleName"])
        return YT_NAME;
    return %orig;
}
%end

// AccessGroupID
%hook SSOKeychainHelper
+ (id)accessGroup { return accessGroupID(); }
+ (id)sharedAccessGroup { return accessGroupID(); }
%end

%hook SSOFolsomKeychainUtils
- (id)sharedAccessGroup { return accessGroupID(); }
%end

%hook GULKeychainStorage
- (void)getObjectForKey:(id)key objectClass:(Class)objectClass accessGroup:(id)accessGroup completionHandler:(id)handler {
    accessGroup = accessGroupID();
    %orig(key, objectClass, accessGroup, handler);
}
- (void)setObject:(id)object forKey:(id)key accessGroup:(id)accessGroup completionHandler:(id)handler {
    accessGroup = accessGroupID();
    %orig(object, key, accessGroup, handler);
}
- (void)removeObjectForKey:(id)key accessGroup:(id)accessGroup completionHandler:(id)handler {
    accessGroup = accessGroupID();
    %orig(key, accessGroup, handler);
}
- (void)getObjectFromKeychainForKey:(id)key objectClass:(Class)objectClass accessGroup:(id)accessGroup completionHandler:(id)handler {
    accessGroup = accessGroupID();
    %orig(key, objectClass, accessGroup, handler);
}
- (id)keychainQueryWithKey:(id)key accessGroup:(id)accessGroup {
    accessGroup = accessGroupID();
    return %orig(key, accessGroup);
}
%end

%hook GNPEncryptionConfiguration
- (id)initWithKeychainAccessGroup:(id)arg {
    arg = accessGroupID();
    return %orig(arg);
}
- (id)keychainAccessGroup { return accessGroupID(); }
%end

%hook FIRInstallationsStore
- (id)initWithSecureStorage:(id)arg1 accessGroup:(id)arg2 {
    arg2 = accessGroupID();
    return %orig(arg1, arg2);
}
- (id)accessGroup { return accessGroupID(); }
%end

%hook CHMConfiguration
- (void)setKeychainAccessGroup:(id)arg {
    arg = accessGroupID();
    %orig(arg);
}
- (id)keychainAccessGroup { return accessGroupID(); }
%end

// Fixes crash/data saving
%hook NSFileManager
- (NSURL *)containerURLForSecurityApplicationGroupIdentifier:(NSString *)groupIdentifier {
    if (groupIdentifier != nil) {
        NSArray *paths = [[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask];
        NSURL *documentsURL = [paths lastObject];
        return [documentsURL URLByAppendingPathComponent:@"AppGroup"];
    }
    return %orig(groupIdentifier);
}
%end