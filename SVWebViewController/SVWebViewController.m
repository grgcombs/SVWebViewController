//
//  SVWebViewController.m
//
//  Created by Sam Vermette on 08.11.10.
//  Copyright 2010 Sam Vermette. All rights reserved.
//

#import "SVWebViewController.h"

@interface SVWebViewController (private)

- (void)layoutWebview;
- (void)setupToolbar;
- (void)stopLoading;

@end

@implementation SVWebViewController
@synthesize masterPopover;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	
	if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
		
		deviceIsTablet = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad);
		urlString = nil;
		navItem = nil;
		actionBarButton = nil;
		stoppedLoading = YES;

	}
	
	return self;
}

- (id)initWithAddress:(NSString*)string {
	
	if ([self initWithNibName:@"SVWebViewController" bundle:nil]) {
		urlString = [string copy];	
	}
		
	return self;
}

- (void)dealloc {
	
	if (urlString) {
		[urlString release];
	}
	
	if (navItem) {
		[navItem release];
		navItem = nil;
	}
	
	if (backBarButton) {
		[backBarButton release];
		backBarButton = nil;
	}
	
	if (forwardBarButton) {
		[forwardBarButton release];
		forwardBarButton = nil;
	}
	
	if (actionBarButton) {
		[actionBarButton release];
		actionBarButton = nil;
	}
	
	self.masterPopover = nil;
	
    [super dealloc];
}

- (void)viewDidLoad {

	[super viewDidLoad];
	
	rWebView.delegate = self;
	CGRect deviceBounds = [[UIApplication sharedApplication] keyWindow].bounds;
	CGFloat buttonWidth = 18.f;
	
	if (!deviceIsTablet) // if we're in a tab bar controller
		self.hidesBottomBarWhenPushed = YES;
	
	backBarButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"SVWebViewController.bundle/iPhone/back"] 
													 style:UIBarButtonItemStylePlain 
													target:rWebView 
													action:@selector(goBack)];
	backBarButton.width = buttonWidth;
	
	forwardBarButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"SVWebViewController.bundle/iPhone/forward"] 
														style:UIBarButtonItemStylePlain 
													   target:rWebView 
													   action:@selector(goForward)];
	forwardBarButton.width = buttonWidth;
	
	actionBarButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction 
																	target:self 
																	action:@selector(showActions)];

	toolbar.tintColor = [UIColor colorWithRed:0.301f green:0.353f blue:0.384f alpha:1.0];
		
	if(self.navigationController == nil) {
		
		UINavigationBar *navBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0,0,CGRectGetWidth(deviceBounds),44)];
		navBar.tintColor = [UIColor colorWithRed:0.301f green:0.353f blue:0.384f alpha:1.0];
		navBar.autoresizesSubviews = YES;
		navBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		
		UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone 
																					target:self 
																					action:@selector(dismissController)];
		
		rWebView.frame = CGRectMake(0, CGRectGetMaxY(navBar.frame), CGRectGetWidth(deviceBounds), CGRectGetMinY(toolbar.frame)-88);
		
		navItem = [[UINavigationItem alloc] initWithTitle:self.title];
		[navBar setItems:[NSArray arrayWithObject:navItem] animated:YES];
		[navItem setLeftBarButtonItem:doneButton animated:YES];
		
		[self.view addSubview:navBar];
		
		[doneButton release];
		[navBar release];
	}
	
}

- (void)viewDidUnload {
	
	if (navItem) {
		[navItem release];
		navItem = nil;
	}

	if (backBarButton) {
		[backBarButton release];
		backBarButton = nil;
	}
	
	if (forwardBarButton) {
		[forwardBarButton release];
		forwardBarButton = nil;
	}
	
	if (actionBarButton) {
		[actionBarButton release];
		actionBarButton = nil;
	}
		
	[super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated {
	
	[super viewWillAppear:animated];
	
	rWebView.delegate = self;
	
	if (urlString && [urlString length]) {
		NSURL *searchURL = [NSURL URLWithString:urlString];
		[rWebView loadRequest:[NSURLRequest requestWithURL:searchURL]];
	}
	
	[self setupToolbar];
	
	[self layoutWebview];
	
}



- (void)viewWillDisappear:(BOOL)animated {

	[self stopLoading];
	rWebView.delegate = nil;
	
	[super viewWillDisappear:animated];
	
}

#pragma mark -
#pragma mark Layout Methods

- (void)layoutWebview {	
	if (rWebView) {
		CGRect deviceBounds = [[UIApplication sharedApplication] keyWindow].bounds;
		if (self.view)
			deviceBounds = self.view.bounds;
		
		if(self.navigationController)
			rWebView.frame = CGRectMake(0, 0, CGRectGetWidth(deviceBounds), CGRectGetHeight(deviceBounds)-44);
		else
			rWebView.frame = CGRectMake(0, 44, CGRectGetWidth(deviceBounds), CGRectGetHeight(deviceBounds)-88);
	}
}


- (void)setupToolbar {
	if (!rWebView)
		return;
	
	NSString *evalString = [rWebView stringByEvaluatingJavaScriptFromString:@"document.title"];
	
	if(self.navigationController != nil)
		self.navigationItem.title = evalString;
	else if (navItem)
		navItem.title = evalString;
	
	if(![rWebView canGoBack])
		backBarButton.enabled = NO;
	else
		backBarButton.enabled = YES;

	if(![rWebView canGoForward])
		forwardBarButton.enabled = NO;
	else
		forwardBarButton.enabled = YES;
		
	UIBarButtonItem *refreshStopBarButton = nil;
	if(rWebView.loading && !stoppedLoading) {
		refreshStopBarButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop 
																			 target:self 
																			 action:@selector(stopLoading)];
	}		
	else {
		refreshStopBarButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh 
																			 target:rWebView 
																			 action:@selector(reload)];
	}
		
	UIBarButtonItem *flSeparator = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
	flSeparator.enabled = NO;
	
	NSArray *newButtons = nil;
	if (urlString && [urlString length] && [urlString hasPrefix:@"file://"]) {	// it's an internal/local web page
		newButtons = [[NSArray alloc] initWithObjects:flSeparator, backBarButton, flSeparator, 
							   refreshStopBarButton, flSeparator, forwardBarButton, flSeparator, nil];
	}
	else {
		newButtons = [[NSArray alloc] initWithObjects:flSeparator, backBarButton, flSeparator, 
						   refreshStopBarButton, flSeparator, forwardBarButton, flSeparator, actionBarButton, nil];
	}
	[toolbar setItems:newButtons animated:YES];
	[newButtons release];
	
	[refreshStopBarButton release];
	[flSeparator release];

}


#pragma mark -
#pragma mark Orientation Support

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return YES;	
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration {
	[self layoutWebview];
}


#pragma mark -
#pragma mark UIWebViewDelegate

- (void)webViewDidStartLoad:(UIWebView *)webView {
	
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
	stoppedLoading = NO;

	[self setupToolbar];
	
}


- (void)webViewDidFinishLoad:(UIWebView *)webView {
	
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
	stoppedLoading = YES;

	[self setupToolbar];

}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
	stoppedLoading = YES;
}


#pragma mark -
#pragma mark Action Methods

- (void)stopLoading {
	
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
	stoppedLoading = YES;

	[rWebView stopLoading];
	
	[self setupToolbar];
	
}

- (void)showActions {
	
	UIActionSheet *actionSheet = [[UIActionSheet alloc] 
						  initWithTitle: nil
						  delegate: self 
						  cancelButtonTitle: nil   
						  destructiveButtonTitle: nil   
						  otherButtonTitles: NSLocalizedString(@"Open in Safari", @"Action sheet button"), nil]; 
	
	
	if([MFMailComposeViewController canSendMail])
		[actionSheet addButtonWithTitle:NSLocalizedString(@"Email this", @"Action sheet button")];
	
	[actionSheet addButtonWithTitle:NSLocalizedString(@"Cancel", @"Action sheet button")];
	actionSheet.cancelButtonIndex = [actionSheet numberOfButtons]-1;
	
	if (actionBarButton)
		[actionSheet showFromBarButtonItem:actionBarButton animated:YES];
	else
		[actionSheet showFromToolbar:toolbar];
	
	[actionSheet release];
	
}


- (void)dismissController {
	[self dismissModalViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	
	if([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:NSLocalizedString(@"Open in Safari", @"Action sheet button")])
		[[UIApplication sharedApplication] openURL:rWebView.request.URL];
	
	else if([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:NSLocalizedString(@"Email this", @"Action sheet button")]) {
		
		MFMailComposeViewController *emailComposer = [[MFMailComposeViewController alloc] init]; 
		
		[emailComposer setMailComposeDelegate: self]; 
		[emailComposer setSubject:[rWebView stringByEvaluatingJavaScriptFromString:@"document.title"]];
		[emailComposer setMessageBody:rWebView.request.URL.absoluteString isHTML:NO];
		emailComposer.modalPresentationStyle = UIModalPresentationFormSheet;
		
		[self presentModalViewController:emailComposer animated:YES];
		[emailComposer release];
	}
	
}

#pragma mark -
#pragma mark MFMailComposeViewControllerDelegate

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
	[controller dismissModalViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark Property Accessors

- (NSString *)address {
	return urlString;
}

- (void)setAddress:(NSString *)newAddress {

	if (masterPopover) {
		[masterPopover dismissPopoverAnimated:YES];
	}
	
	[self willChangeValueForKey: @"address"];
	if (urlString) {
		[urlString release];
	}
	urlString = [newAddress copy];
	[self didChangeValueForKey: @"address"];

	if (![self isViewLoaded])
		return;

	if (urlString && [urlString length]) {
		NSURL *searchURL = [NSURL URLWithString:urlString];
		[rWebView loadRequest:[NSURLRequest requestWithURL:searchURL]];
	}
	
}

#pragma mark -
#pragma mark Popover Support

- (void)splitViewController: (UISplitViewController*)svc willHideViewController:(UIViewController *)aViewController withBarButtonItem:(UIBarButtonItem*)barButtonItem forPopoverController: (UIPopoverController*)pc {
    barButtonItem.title = NSLocalizedString(@"Resources", @"The short title for web view popover");
    [self.navigationItem setRightBarButtonItem:barButtonItem animated:YES];
    self.masterPopover = pc;
}


// Called when the view is shown again in the split view, invalidating the button and popover controller.
- (void)splitViewController: (UISplitViewController*)svc willShowViewController:(UIViewController *)aViewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem {
	if (self.navigationItem)
		[self.navigationItem setRightBarButtonItem:nil animated:YES];
    self.masterPopover = nil;
}

- (void) splitViewController:(UISplitViewController *)svc popoverController: (UIPopoverController *)pc
   willPresentViewController: (UIViewController *)aViewController
{
}	

@end
