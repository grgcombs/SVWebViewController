//
//  RootViewController.m
//  SVWebViewController
//
//  Created by Sam Vermette on 21.02.11.
//  Copyright 2011 Sam Vermette. All rights reserved.
//

#import "ViewController.h"
#import "SVWebViewController.h"

@implementation ViewController


#pragma mark -
#pragma mark View lifecycle

- (void)pushWebViewController {

	SVWebViewController *webViewController = [[SVWebViewController alloc] initWithAddress:@"http://en.wikipedia.org/wiki/Friday_(Rebecca_Black_song)"];
	[self.navigationController pushViewController:webViewController animated:YES];
	[webViewController release];
}


- (void)presentWebViewController {
	
	SVWebViewController *webViewController = [[SVWebViewController alloc] initWithAddress:@"http://en.wikipedia.org/wiki/Friday_(Rebecca_Black_song)"];
	webViewController.modalPresentationStyle = UIModalPresentationPageSheet;
	[self presentModalViewController:webViewController animated:YES];	
	[webViewController release];
}


#pragma mark -
#pragma mark Memory management

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Overriden to allow any orientation.
	
	return YES;
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidLoad {
	[super viewDidLoad];
	self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:0.301f green:0.353f blue:0.384f alpha:1.0];
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
	[super viewDidUnload];
}


- (void)dealloc {
    [super dealloc];
}


@end

