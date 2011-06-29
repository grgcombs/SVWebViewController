//
//  SVWebViewController.h
//
//  Created by Sam Vermette on 08.11.10.
//  Copyright 2010 Sam Vermette. All rights reserved.
//

#import <MessageUI/MessageUI.h>


@interface SVWebViewController : UIViewController <UIWebViewDelegate, UIActionSheetDelegate, MFMailComposeViewControllerDelegate> {
	UIWebView *_webView;
	NSString *urlString;
	
	UINavigationItem *navItem;
	IBOutlet UIBarButtonItem *backBarButton, *forwardBarButton, *actionBarButton;
	UIToolbar *_toolbar;
	
	UIViewController *modalParentVC;
	BOOL deviceIsTablet, stoppedLoading, isQuitting;
}

@property (nonatomic,retain) IBOutlet UIToolbar *toolbar;
@property (nonatomic,retain) IBOutlet UIWebView *webView;
@property (nonatomic,assign) UIViewController *modalParentVC;
@property (nonatomic,retain) UIPopoverController *masterPopover;
@property (nonatomic,assign) NSString *address;
- (id)initWithAddress:(NSString*)string;

@end

@interface UIViewController (SVWebViewControllerAdditions) {
}

- (void) presentWebViewControllerWithURL:(NSString *)url;

@end
