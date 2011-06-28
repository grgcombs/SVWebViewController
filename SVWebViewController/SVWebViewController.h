//
//  SVWebViewController.h
//
//  Created by Sam Vermette on 08.11.10.
//  Copyright 2010 Sam Vermette. All rights reserved.
//

#import <MessageUI/MessageUI.h>


@interface SVWebViewController : UIViewController <UIWebViewDelegate, UIActionSheetDelegate, MFMailComposeViewControllerDelegate> {
	IBOutlet UIWebView *rWebView;
	NSString *urlString;
	
	UINavigationItem *navItem;
	IBOutlet UIBarButtonItem *backBarButton, *forwardBarButton, *actionBarButton;
	IBOutlet UIToolbar *toolbar;
	
	BOOL deviceIsTablet, stoppedLoading;
}

@property (nonatomic,retain) UIPopoverController *masterPopover;
@property (nonatomic, assign) NSString *address;
- (id)initWithAddress:(NSString*)string;

@end
