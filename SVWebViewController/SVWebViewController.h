//
//  SVWebViewController.h
//
//  Created by Sam Vermette on 08.11.10.
//  Copyright 2010 Sam Vermette. All rights reserved.
//

#import <MessageUI/MessageUI.h>

@interface SVWebViewController : UIViewController <UISplitViewControllerDelegate, UIWebViewDelegate, UIActionSheetDelegate, MFMailComposeViewControllerDelegate> {
	UIWebView *rWebView;
    UINavigationBar *navBar;
    UIToolbar *toolbar;
    
	// iPhone UI
	UINavigationItem *navItem;
	UIBarButtonItem *backBarButton, *forwardBarButton, *refreshStopBarButton, *actionBarButton;
	
	// iPad UI
	UIButton *backButton, *forwardButton, *refreshStopButton, *actionButton;
	UILabel *titleLabel;
	CGFloat titleLeftOffset;
	
	BOOL deviceIsTablet, stoppedLoading;
}

@property (nonatomic, strong) UIWebView *webView;
@property (nonatomic, strong) NSString *urlString;
@property (nonatomic, weak) NSString *address;
@property (nonatomic, strong) UIPopoverController *masterPopover;

- (instancetype)initWithAddress:(NSString*)string;

@end
