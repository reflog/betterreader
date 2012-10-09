//
//  LoadingViewController.m
//  betterreader
//
//  Created by reflog on 10/10/12.
//
//

#import "LoadingViewController.h"

@interface LoadingViewController ()
@end

@implementation LoadingViewController

- (id)initWithTitle:(NSString *)title subtitle:(NSString *)subtitle image:(TKEmptyViewImage)image {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        self.emptyView = [[TKEmptyView alloc] initWithFrame:self.view.bounds emptyViewImage:image title:title subtitle:subtitle];
        [self.view addSubview:self.emptyView];
    }
    return self;
}

- (void)viewDidLayoutSubviews{
    self.emptyView.frame = self.view.bounds;
}

- (void)setLoading:(BOOL)loading
{
    if(loading)
        [self.view bringSubviewToFront:self.emptyView];
    else
        [self.view sendSubviewToBack:self.emptyView];
}

@end
