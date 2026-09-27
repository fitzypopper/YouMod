#import "Headers.h"

// YTUnShorts (https://github.com/PoomSmart/YTUnShorts)
static NSMutableArray <YTIItemSectionRenderer *> *filteredArray(NSArray <YTIItemSectionRenderer *> *array) {
    NSMutableArray <YTIItemSectionRenderer *> *newArray = [array mutableCopy];
    NSIndexSet *removeIndexes = [newArray indexesOfObjectsPassingTest:^BOOL(YTIItemSectionRenderer *sectionRenderer, NSUInteger idx, BOOL *stop) {
        if ([sectionRenderer isKindOfClass:%c(YTIShelfRenderer)]) {
            YTIShelfSupportedRenderers *content = ((YTIShelfRenderer *)sectionRenderer).content;
            YTIHorizontalListRenderer *horizontalListRenderer = content.horizontalListRenderer;
            NSMutableArray <YTIHorizontalListSupportedRenderers *> *itemsArray = horizontalListRenderer.itemsArray;
            NSIndexSet *removeItemsArrayIndexes = [itemsArray indexesOfObjectsPassingTest:^BOOL(YTIHorizontalListSupportedRenderers *horizontalListSupportedRenderers, NSUInteger idx2, BOOL *stop2) {
                YTIElementRenderer *elementRenderer = horizontalListSupportedRenderers.elementRenderer;
                NSString *description = [elementRenderer description];
                BOOL hasShorts = [description containsString:@"shorts_video_cell"];
                if (hasShorts) *stop2 = YES;
                return hasShorts;
            }];
            return removeItemsArrayIndexes.count > 0;
        }
        if ([sectionRenderer isKindOfClass:%c(YTIItemSectionRenderer)]) {
            NSString *description = [sectionRenderer description];
            if ([description containsString:@"shorts_shelf.eml"])
                return YES;
        }
        return NO;
    }];
    [newArray removeObjectsAtIndexes:removeIndexes];
    return newArray;
}

%group Shorts
%hook YTInnerTubeCollectionViewController

- (void)displaySectionsWithReloadingSectionControllerByRenderer:(id)renderer {
    NSMutableArray *sectionRenderers = [self valueForKey:@"_sectionRenderers"];
    [self setValue:filteredArray(sectionRenderers) forKey:@"_sectionRenderers"];
    %orig;
}

- (void)addSectionsFromArray:(NSArray <YTIItemSectionRenderer *> *)array {
    %orig(filteredArray(array));
}

%end
%end

// Hide Subbar
%hook YTMySubsFilterHeaderView
- (void)setChipFilterView:(id)arg1 { if (!IS_ENABLED(HideSubbar)) %orig; }
%end

%hook YTHeaderContentComboView
- (void)enableSubheaderBarWithView:(id)arg1 { if (!IS_ENABLED(HideSubbar)) %orig; }
- (void)setFeedHeaderScrollMode:(int)arg1 { IS_ENABLED(HideSubbar) ? %orig(0) : %orig; }
%end

%hook YTChipCloudCell
- (void)layoutSubviews {
    if (self.superview && IS_ENABLED(HideSubbar)) {
        [self removeFromSuperview];
    } %orig;
}
%end

// Hide voice search button
%hook YTSearchViewController
- (void)viewDidLoad {
    %orig;
    if (IS_ENABLED(HideVoiceSearch)) {
        [self setValue:@(NO) forKey:@"_isVoiceSearchAllowed"];
    }
}
- (void)setSuggestions:(id)arg1 { if (!IS_ENABLED(HideSearchHis)) %orig; }
%end

// Hide search history and suggestions
%hook YTPersonalizedSuggestionsCacheProvider
- (id)activeCache { return IS_ENABLED(HideSearchHis) ? nil : %orig; }
%end

%ctor {
    YouModRegisterDefaults();
    %init;
    if (IS_ENABLED(HideShortsShelf)) {
        %init(Shorts);
    }
}