//
//  LoadingViewController.h
//  betterreader
//
//  Created by reflog on 10/10/12.
//
//

#import <UIKit/UIKit.h>
#import "TKEmptyView.h"

@interface LoadingViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) TKEmptyView *emptyView;
- (id)initWithTitle:(NSString *)title subtitle:(NSString *)subtitle image:(TKEmptyViewImage)image ;
- (void)setLoading:(BOOL)loading;
@end
