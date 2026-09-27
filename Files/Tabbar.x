#import "Headers.h"

%hook YTPivotBarView
- (void)setRenderer:(YTIPivotBarRenderer *)renderer {
    NSMutableArray <YTIPivotBarSupportedRenderers *> *items = [renderer itemsArray];
    NSMutableIndexSet *indicesToRemove = [NSMutableIndexSet indexSet];
    // Loop through every item in the bar
    for (NSUInteger i = 0; i < items.count; i++) {
        YTIPivotBarSupportedRenderers *item = items[i];
        NSString *pID = [[item pivotBarItemRenderer] pivotIdentifier];
        NSString *pID2 = [[item pivotBarIconOnlyItemRenderer] pivotIdentifier];
        if ([pID isEqualToString:@"FEwhat_to_watch"] && IS_ENABLED(HideHomeTab)) {
             [indicesToRemove addIndex:i];
        }
        if ([pID isEqualToString:@"FEshorts"] && IS_ENABLED(HideShortsTab)) {
            [indicesToRemove addIndex:i];
        }
        if ([pID2 isEqualToString:@"FEuploads"] && IS_ENABLED(HideCreateButton)) {
            [indicesToRemove addIndex:i];
        }
        if ([pID isEqualToString:@"FEsubscriptions"] && IS_ENABLED(HideSubscriptTab)) {
            [indicesToRemove addIndex:i];
        }
    }
    // Remove them all at once so the layout doesn't break
    [items removeObjectsAtIndexes:indicesToRemove];
    %orig(renderer);
}
%end

// Hide Tab Bar Indicators
%hook YTPivotBarIndicatorView
- (void)setFillColor:(id)arg1 { IS_ENABLED(HideTabIndi) ? %orig([UIColor clearColor]) : %orig; }
- (void)setBorderColor:(id)arg1  { IS_ENABLED(HideTabIndi) ? %orig([UIColor clearColor]) : %orig; }
%end

// Hide Tab Labels
%hook YTPivotBarItemView
- (void)setRenderer:(YTIPivotBarRenderer *)renderer {
    %orig;
    if (IS_ENABLED(HideTabLabels)) {
        [self.navigationButton setTitle:@"" forState:UIControlStateNormal];
        [self.navigationButton setSizeWithPaddingAndInsets:NO];
    }
}
%end

// Startup Tab
BOOL isTabSelected = NO;
%hook YTPivotBarViewController
- (void)viewDidAppear:(BOOL)animated {
    %orig;
    if (!isTabSelected) {
        NSArray *pivotIdentifiers = @[@"FEwhat_to_watch", @"FEshorts", @"FEsubscriptions", @"FElibrary"];
        // Clamp so a tampered/imported value can never index out of bounds and crash on launch.
        NSInteger defaultTab = INTFORVAL(DefaultTab);
        if (defaultTab < 0 || defaultTab >= (NSInteger)pivotIdentifiers.count) defaultTab = 0;
        [self selectItemWithPivotIdentifier:pivotIdentifiers[defaultTab]]; // Set int here
        isTabSelected = YES;
    }
}
%end