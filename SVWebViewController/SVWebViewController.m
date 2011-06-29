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

@implementation UIViewController (SVWebViewControllerAdditions)

- (void) presentWebViewControllerWithURL:(NSString *)url {
	SVWebViewController *browser = [[SVWebViewController alloc] initWithAddress:url];
	
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		browser.modalPresentationStyle = UIModalPresentationPageSheet;
	}
	else {
		browser.modalPresentationStyle = UIModalPresentationCurrentContext;
	}
	
	browser.modalParentVC = self;
	[self presentModalViewController:browser animated:YES];
	[browser release];	
}

@end

@implementation SVWebViewController
@synthesize masterPopover;
@synthesize modalParentVC;
@synthesize webView = _webView;
@synthesize toolbar = _toolbar;

- (id)init {
	if ((self = [super init])) {
		
		deviceIsTablet = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad);
		urlString = nil;
		navItem = nil;
		actionBarButton = nil;
		stoppedLoading = YES;
		isQuitting = NO;
		
	}
	
	return self;
}

- (id)initWithAddress:(NSString*)string {
	
	if ((self = [self init])) {
		urlString = [string copy];	
	}
		
	return self;
}

- (void)dealloc {
	stoppedLoading = YES;
	
	if (_webView) {
		_webView.delegate = nil;
		if (_webView.loading) {
			[_webView stopLoading];	
		}
		[_webView release];
		_webView = nil;
	}
	
	
	if (urlString) {
		[urlString release];
		urlString = nil;
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
	
	self.toolbar = nil;
	self.masterPopover = nil;
	
    [super dealloc];
}

- (void)loadView {
	[super loadView];
	
	UIWebView *webview1 = [[UIWebView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 372.0)];
	webview1.autoresizesSubviews = YES;
	webview1.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	webview1.clearsContextBeforeDrawing = YES;
	webview1.clipsToBounds = NO;
	webview1.contentMode = UIViewContentModeScaleToFill;
	webview1.multipleTouchEnabled = YES;
	webview1.opaque = YES;
	webview1.scalesPageToFit = YES;
	webview1.delegate = self;
	self.webView = webview1;
	
	
	UIToolbar *tool = [[UIToolbar alloc] initWithFrame:CGRectMake(0.0, 372.0, 320.0, 44.0)];
	tool.frame = CGRectMake(0.0, 372.0, 320.0, 44.0);
	tool.autoresizesSubviews = YES;
	tool.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
	tool.clearsContextBeforeDrawing = NO;
	tool.clipsToBounds = NO;
	tool.contentMode = UIViewContentModeScaleToFill;
	tool.multipleTouchEnabled = NO;
	tool.opaque = NO;
	tool.tintColor = [UIColor colorWithRed:0.301f green:0.353f blue:0.384f alpha:1.0];
	self.toolbar = tool;

	//UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 416.0)];
	self.view.frame = CGRectMake(0.0, 0.0, 320.0, 416.0);
	self.view.autoresizesSubviews = YES;
	self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	self.view.clearsContextBeforeDrawing = YES;
	self.view.clipsToBounds = NO;
	self.view.contentMode = UIViewContentModeScaleToFill;
	self.view.multipleTouchEnabled = NO;
	self.view.opaque = YES;
	
	[self.view addSubview:tool];
	[self.view addSubview:webview1];
	
	[webview1 release];
	[tool release];

}

- (void)viewDidLoad {

	[super viewDidLoad];
	
	isQuitting = NO;
	self.webView.delegate = self;
	CGRect deviceBounds = [[UIApplication sharedApplication] keyWindow].bounds;
	CGFloat buttonWidth = 18.f;
	
	if (!deviceIsTablet) // if we're in a tab bar controller
		self.hidesBottomBarWhenPushed = YES;
	
	backBarButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"SVWebViewController.bundle/iPhone/back"] 
													 style:UIBarButtonItemStylePlain 
													target:self.webView 
													action:@selector(goBack)];
	backBarButton.width = buttonWidth;
	
	forwardBarButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"SVWebViewController.bundle/iPhone/forward"] 
														style:UIBarButtonItemStylePlain 
													   target:self.webView 
													   action:@selector(goForward)];
	forwardBarButton.width = buttonWidth;
	
	actionBarButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction 
																	target:self 
																	action:@selector(showActions)];
		
	if(self.navigationController == nil) {
		
		UINavigationBar *navBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0,0,CGRectGetWidth(deviceBounds),44)];
		navBar.tintColor = [UIColor colorWithRed:0.301f green:0.353f blue:0.384f alpha:1.0];
		navBar.autoresizesSubviews = YES;
		navBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
					
		UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone 
																					target:self 
																					action:@selector(dismissController)];
		
		self.webView.frame = CGRectMake(0, CGRectGetMaxY(navBar.frame), CGRectGetWidth(deviceBounds), CGRectGetMinY(self.toolbar.frame)-88);
		
		navItem = [[UINavigationItem alloc] initWithTitle:self.title];
		[navBar setItems:[NSArray arrayWithObject:navItem] animated:YES];
		[navItem setLeftBarButtonItem:doneButton animated:YES];
		
		[self.view addSubview:navBar];
		
		[doneButton release];
		[navBar release];
	}
	
}

- (void)viewDidUnload {
	
	isQuitting = YES;
	
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
	
	stoppedLoading = YES;
	self.toolbar = nil;
	if (_webView) {
		_webView.delegate = nil;
		if (_webView.loading) {
			[_webView stopLoading];	
		}
		[_webView release];
		_webView = nil;
	}
	[super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated {
	
	[super viewWillAppear:animated];
	
	isQuitting = NO;
	
	if (urlString && [urlString length] && _webView) {
		NSURL *searchURL = [NSURL URLWithString:urlString];
		_webView.delegate = self;
		[_webView loadRequest:[NSURLRequest requestWithURL:searchURL]];
	}
	
	[self setupToolbar];
	
	[self layoutWebview];
	
}



- (void)viewWillDisappear:(BOOL)animated {

	isQuitting = YES;
	stoppedLoading = YES;
	if (_webView) {
		_webView.delegate = nil;
		if (_webView.loading) {
			[_webView stopLoading];	
		}
	}		
	[super viewWillDisappear:animated];
	
}

#pragma mark -
#pragma mark Layout Methods

- (void)layoutWebview {	
	if (_webView) {
		//CGRect deviceBounds = [[UIApplication sharedApplication] keyWindow].bounds;
		CGRect deviceBounds = self.view.bounds;
		
		if(self.navigationController)
			_webView.frame = CGRectMake(0, 0, CGRectGetWidth(deviceBounds), CGRectGetHeight(deviceBounds)-44);
		else
			_webView.frame = CGRectMake(0, 44, CGRectGetWidth(deviceBounds), CGRectGetHeight(deviceBounds)-88);
	}
}


- (void)setupToolbar {
	if (!_webView || isQuitting)
		return;
	
	NSString *evalString = [_webView stringByEvaluatingJavaScriptFromString:@"document.title"];
	
	if(self.navigationController != nil)
		self.navigationItem.title = evalString;
	else if (navItem)
		navItem.title = evalString;
	
	if(![_webView canGoBack])
		backBarButton.enabled = NO;
	else
		backBarButton.enabled = YES;

	if(![_webView canGoForward])
		forwardBarButton.enabled = NO;
	else
		forwardBarButton.enabled = YES;
		
	UIBarButtonItem *refreshStopBarButton = nil;
	if(_webView.loading && !stoppedLoading) {
		refreshStopBarButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop 
																			 target:self 
																			 action:@selector(stopLoading)];
	}		
	else {
		refreshStopBarButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh 
																			 target:_webView 
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
	[self.toolbar setItems:newButtons animated:YES];
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
	if (!isQuitting)
		[self layoutWebview];
}


#pragma mark -
#pragma mark UIWebViewDelegate

- (void)webViewDidStartLoad:(UIWebView *)aWebView {
	if (!self || NO == [self isViewLoaded])
		return;
	
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
	stoppedLoading = NO;

	[self setupToolbar];
	
}

- (void)webViewDidFinishLoad:(UIWebView *)aWebView {
	if (!self || NO == [self isViewLoaded])
		return;

	aWebView.delegate = nil;
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
	stoppedLoading = YES;

	[self setupToolbar];

}

- (void)webView:(UIWebView *)aWebView didFailLoadWithError:(NSError *)error {
	aWebView.delegate = nil;
	
	if (!self || NO == [self isViewLoaded])
		return;
	
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
	stoppedLoading = YES;
}


#pragma mark -
#pragma mark Action Methods

- (void)stopLoading {
	
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
	stoppedLoading = YES;

	if (_webView) {
		_webView.delegate = nil;
		[_webView stopLoading];
	}
	[self setupToolbar];
	
}

- (void)showActions {
	
	if (_webView.request.URL && [[UIApplication sharedApplication] canOpenURL:_webView.request.URL]) {
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
			[actionSheet showFromToolbar:self.toolbar];
		
		[actionSheet release];
	}
	
}


- (void)dismissController {
	isQuitting = YES;
	
	if (_webView)
		_webView.delegate = nil;
	
	UIViewController *parent = self.modalParentVC;
	if (!parent)
		parent = self.parentViewController; //???
	
	[parent dismissModalViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	
	if([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:NSLocalizedString(@"Open in Safari", @"Action sheet button")])
		[[UIApplication sharedApplication] openURL:self.webView.request.URL];
	
	else if([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:NSLocalizedString(@"Email this", @"Action sheet button")]) {
		
		MFMailComposeViewController *emailComposer = [[MFMailComposeViewController alloc] init]; 
		
		[emailComposer setMailComposeDelegate: self]; 
		[emailComposer setSubject:[self.webView stringByEvaluatingJavaScriptFromString:@"document.title"]];
		[emailComposer setMessageBody:self.webView.request.URL.absoluteString isHTML:NO];
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

	if (urlString && [urlString length] && _webView) {
		_webView.delegate = self;
		NSURL *searchURL = [NSURL URLWithString:urlString];
		[_webView loadRequest:[NSURLRequest requestWithURL:searchURL]];
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
