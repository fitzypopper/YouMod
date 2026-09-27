#import "Headers.h"

Class YTILikeResponseClass, YTIDislikeResponseClass, YTIRemoveLikeResponseClass;

// Background playback
%group BackgroundPlayback
%hook YTIBackgroundOfflineSettingCategoryEntryRenderer
%new(B@:)
- (BOOL)isBackgroundEnabled { return YES; }
%end
%end

%hook MLVideo
- (BOOL)playableInBackground { return IS_ENABLED(BackgroundPlayback) ? YES : %orig; }
%end

%hook YTIPlayabilityStatus
- (BOOL)isPlayableInBackground { return IS_ENABLED(BackgroundPlayback) ? YES : %orig; }
%end

%hook YTPlaybackData
- (BOOL)isPlayableInBackground { return IS_ENABLED(BackgroundPlayback) ? YES : %orig; }
%end

%hook YTIPlayerResponse
- (BOOL)isPlayableInBackground { return IS_ENABLED(BackgroundPlayback) ? YES : %orig; }
%end

// Try to disable Shorts PiP
%hook YTColdConfig
- (BOOL)shortsPlayerGlobalConfigEnableReelsPictureInPicture { return IS_ENABLED(DisablesShortsPiP) ? NO : %orig; }
- (BOOL)shortsPlayerGlobalConfigEnableReelsPictureInPictureIos { return IS_ENABLED(DisablesShortsPiP) ? NO : %orig; }
%end

%hook YTHotConfig
- (BOOL)shortsPlayerGlobalConfigEnableReelsPictureInPictureAllowedFromPlayer { return IS_ENABLED(DisablesShortsPiP) ? NO : %orig; }
%end

%hook YTReelModel
- (BOOL)isPiPSupported { return IS_ENABLED(DisablesShortsPiP) ? NO : %orig; }
%end

%hook YTReelPlayerViewController
- (BOOL)isPictureInPictureAllowed { return IS_ENABLED(DisablesShortsPiP) ? NO : %orig; }
%end

%hook YTReelWatchRootViewController
- (void)switchToPictureInPicture { if (!IS_ENABLED(DisablesShortsPiP)) %orig; }
%end

// Block upgrade dialogs
%hook YTGlobalConfig
- (BOOL)shouldBlockUpgradeDialog { return IS_ENABLED(BlockUpgradeDialogs) ? YES : %orig; }
- (BOOL)shouldShowUpgradeDialog { return IS_ENABLED(BlockUpgradeDialogs) ? NO : %orig; }
- (BOOL)shouldShowUpgrade { return IS_ENABLED(BlockUpgradeDialogs) ? NO : %orig; }
- (BOOL)shouldForceUpgrade { return IS_ENABLED(BlockUpgradeDialogs) ? NO : %orig; }
%end

// Prevent YouTube from asking "Are you there?"
%hook YTColdConfig
- (BOOL)enableYouthereCommandsOnIos { return IS_ENABLED(BlockUpgradeDialogs) ? NO : %orig; }
%end

%hook YTYouThereController
- (BOOL)shouldShowYouTherePrompt { return IS_ENABLED(HideAreYouThereDialog) ? NO : %orig; }
- (void)showYouTherePrompt { if (!IS_ENABLED(HideAreYouThereDialog)) %orig; }
%end

%hook YTYouThereControllerImpl
- (BOOL)shouldShowYouTherePrompt { return IS_ENABLED(HideAreYouThereDialog) ? NO : %orig; }
- (void)showYouTherePrompt { if (!IS_ENABLED(HideAreYouThereDialog)) %orig; }
%end

// Fixes slow miniplayer
%hook YTColdConfig
- (BOOL)enableIosFloatingMiniplayerDoubleTapToResize { return IS_ENABLED(FixesSlowMiniPlayer) ? NO : %orig; }
%end

// Use old miniplayer
%hook YTColdConfig
- (BOOL)enableIosFloatingMiniplayer { return IS_ENABLED(DisablesNewMiniPlayer) ? NO : %orig; }
%end

// Disables Snackbar
%hook GOOHUDManagerInternal
- (id)sharedInstance { return IS_ENABLED(DisablesSnackBar) ? nil : %orig; }
- (void)showMessageMainThread:(id)arg { if (!IS_ENABLED(DisablesSnackBar)) %orig; }
- (void)activateOverlay:(id)arg { if (!IS_ENABLED(DisablesSnackBar)) %orig; }
- (void)displayHUDViewForMessage:(id)arg { if (!IS_ENABLED(DisablesSnackBar)) %orig; }
%end

// Hide startup animations
%hook YTColdConfig
- (BOOL)mainAppCoreClientIosEnableStartupAnimation { return IS_ENABLED(HideStartupAni) ? NO : %orig; }
%end

// Remove "Play next in queue" from the menu @PoomSmart (https://github.com/qnblackcat/uYouPlus/issues/1138#issuecomment-1606415080)
%hook YTMenuItemVisibilityHandler
- (BOOL)shouldShowServiceItemRenderer:(YTIMenuConditionalServiceItemRenderer *)renderer {
    if (renderer.icon.iconType == 251 && IS_ENABLED(HidePlayInNextQueue)) {
        return NO;
    } return %orig;
}
%end

%hook YTMenuItemVisibilityHandlerImpl
- (BOOL)shouldShowServiceItemRenderer:(YTIMenuConditionalServiceItemRenderer *)renderer {
    if (renderer.icon.iconType == 251 && IS_ENABLED(HidePlayInNextQueue)) {
        return NO;
    } return %orig;
}
%end

/* untested
// Remove Download button from the menu
%hook YTDefaultSheetController
- (void)addAction:(YTActionSheetAction *)action {
    NSString *identifier = [action valueForKey:@"_accessibilityIdentifier"];

    NSDictionary *actionsToRemove = @{
        @"7": @(ytlBool(@"removeDownloadMenu")),
        @"1": @(ytlBool(@"removeWatchLaterMenu")),
        @"3": @(ytlBool(@"removeSaveToPlaylistMenu")),
        @"5": @(ytlBool(@"removeShareMenu")),
        @"12": @(ytlBool(@"removeNotInterestedMenu")),
        @"31": @(ytlBool(@"removeDontRecommendMenu")),
        @"58": @(ytlBool(@"removeReportMenu"))
    };

    if (![actionsToRemove[identifier] boolValue]) {
        %orig;
    }
}
%end
*/

// YTSlientVote (https://github.com/PoomSmart/YTSilentVote)
%group SlientVote
%hook YTInnerTubeResponseWrapper
- (id)initWithResponse:(id)response cacheContext:(id)arg2 requestStatistics:(id)arg3 mutableSharedData:(id)arg4 {
    if ([response isKindOfClass:YTILikeResponseClass]
        || [response isKindOfClass:YTIDislikeResponseClass]
        || [response isKindOfClass:YTIRemoveLikeResponseClass]) return nil;
    return %orig;
}
%end
%end

%ctor {
    YouModRegisterDefaults();
    YTILikeResponseClass = %c(YTILikeResponse);
    YTIDislikeResponseClass = %c(YTIDislikeResponse);
    YTIRemoveLikeResponseClass = %c(YTIRemoveLikeResponse);
    %init;
    if (IS_ENABLED(HideLikeDislikeVotes)) {
        %init(SlientVote);
    }
    if (IS_ENABLED(BackgroundPlayback)) {
        %init(BackgroundPlayback);
    }
}