//
//  FeedViewToolbar.m
//  betterreader
//
//  Created by reflog on 10/8/12.
//
//

#import "FeedViewToolbar.h"
@interface FeedViewToolbar ()

@property(nonatomic, strong) UIActionSheet *actionSheet;
@end

@implementation FeedViewToolbar
@synthesize delegate = myDelegate;
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.items = @[
            [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh handler:^(id sender) {
                [self.delegate refreshClicked];
            }],
            [[UIBarButtonItem alloc] initWithCustomView:[self makeDisplayModeButton]],
            [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace handler:^(id sender) {
                
            }],
            [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRewind handler:^(id sender) {
                [self.delegate prevFeedItemClicked];
            }],
            [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFastForward handler:^(id sender) {
                [self.delegate nextFeedItemClicked];
            }],
            [self makeViewModeButton],
            [self makeSettingsButton]
        ];
    }
    return self;
}

- (UISegmentedControl *)makeDisplayModeButton {
    __block UISegmentedControl *displaySwitch = [[UISegmentedControl alloc] initWithItems:@[
            [UIImage imageNamed:@"icon-export1.png"],
            [UIImage imageNamed:@"icon-export2.png"]
        ]];
    displaySwitch.selectedSegmentIndex = 0; //TODO: get from user defaults
    displaySwitch.segmentedControlStyle = UISegmentedControlStyleBar;
    [displaySwitch addEventHandler:^(id sender) {
            [self.delegate displayModeChanged:displaySwitch.selectedSegmentIndex == 1];
        } forControlEvents:UIControlEventValueChanged];
    return displaySwitch;
}

- (UIBarButtonItem *)makeViewModeButton {
    __block UIBarButtonItem* viewModeButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"View", nil) style:UIBarButtonItemStyleBordered handler:^(id sender) {
            if (self.actionSheet){
                [self.actionSheet dismissWithClickedButtonIndex:self.actionSheet.cancelButtonIndex animated:YES];
                self.actionSheet = nil;
             
                return;
            }
            self.actionSheet = [UIActionSheet actionSheetWithTitle:NSLocalizedString(@"Feed View Settings", nil)];
            [self.actionSheet addButtonWithTitle:NSLocalizedString(@"All", nil) handler:^{
                [self.delegate viewModeChanged:YES];
            }];
            [self.actionSheet addButtonWithTitle:NSLocalizedString(@"Unread", nil) handler:^{
                [self.delegate viewModeChanged:NO];
            }];
            __block FeedViewToolbar* this = self;
            self.actionSheet.didDismissBlock = ^(UIActionSheet *sheet, NSInteger i) {
                this.actionSheet = nil;
            };

            [self.actionSheet showFromBarButtonItem:viewModeButton animated:YES];
        }];
    return viewModeButton;
}

- (UIBarButtonItem *)makeSettingsButton {
    __block UIBarButtonItem* settingsButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Settings", nil) style:UIBarButtonItemStyleBordered handler:^(id sender) {
            if (self.actionSheet){
                [self.actionSheet dismissWithClickedButtonIndex:self.actionSheet.cancelButtonIndex animated:YES];
                self.actionSheet = nil;
                return;
            }
            self.actionSheet = [UIActionSheet actionSheetWithTitle:NSLocalizedString(@"Feed Settings", nil)];
            [self.actionSheet addButtonWithTitle:NSLocalizedString(@"Sort by: Newest", nil) handler:^{
                [self.delegate sortModeChanged:SORT_MODE_DES];
            }];
            [self.actionSheet addButtonWithTitle:NSLocalizedString(@"Sort by: Oldest", nil) handler:^{
                [self.delegate sortModeChanged:SORT_MODE_ASC];
            }];
            [self.actionSheet addButtonWithTitle:NSLocalizedString(@"Sort by: Magic", nil) handler:^{
                [self.delegate sortModeChanged:SORT_MODE_MAGIC];
            }];
            [self.actionSheet addButtonWithTitle:NSLocalizedString(@"Rename", nil) handler:^{
                [self.delegate renameClicked];
            }];
            [self.actionSheet setDestructiveButtonWithTitle:NSLocalizedString(@"Unsubscribe", nil) handler:^{
                [self.delegate unsubscribeClicked];
            }];
            __block FeedViewToolbar* this = self;
            self.actionSheet.didDismissBlock = ^(UIActionSheet *sheet, NSInteger i) {
                this.actionSheet = nil;
            };
            [self.actionSheet showFromBarButtonItem:settingsButton animated:YES];
        }];
    return settingsButton;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
