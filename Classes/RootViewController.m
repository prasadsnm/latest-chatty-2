//
//    RootViewController.m
//    LatestChatty2
//
//    Created by Alex Wayne on 4/10/09.
//    Copyright 2009. All rights reserved.
//

#import "RootViewController.h"

#import "CustomBadge.h"

@implementation RootViewController

@synthesize selectedIndex, messagesSpinner;

- (id)init {
    self = [super initWithNib];
    self.title = @"Home";
    return self;
}

- (id)initWithStateDictionary:(NSDictionary *)dictionary {
    return [self init];
}

- (NSDictionary *)stateDictionary {
    return [NSDictionary dictionaryWithObject:@"Root" forKey:@"type"];
}

- (NSUInteger)supportedInterfaceOrientations {
    return [LatestChatty2AppDelegate supportedInterfaceOrientations];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return [LatestChatty2AppDelegate shouldAutorotateToInterfaceOrientation:interfaceOrientation];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // fetch messages
    [self.messagesSpinner startAnimating];
    messageLoader = [Message findAllWithDelegate:self];
}

- (void)viewDidLoad {
    if (![[LatestChatty2AppDelegate delegate] isPadDevice]) {
        // root view controller is delegate for view deck on iPhone
        self.viewDeckController.delegate = self;
        
        // initialize the index path to chatty row
        [self setSelectedIndex:[NSIndexPath indexPathForRow:1 inSection:0]];
        [self.tableView selectRowAtIndexPath:self.selectedIndex animated:NO scrollPosition:UITableViewScrollPositionNone];
        
        self.tableView.backgroundView = [[UIImageView alloc] initWithImage:
                                         [UIImage imageNamed:@"Sidebar-bg.png"]];
        self.tableView.backgroundView.contentMode = UIViewContentModeTopLeft;
    }
    
    // Maintain selection while view is still loaded
    [self setClearsSelectionOnViewWillAppear:NO];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pushBrowserForCredits) name:@"PushBrowserForCredits" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pushBrowserForLicenses) name:@"PushBrowserForLicenses" object:nil];
    
    // iOS7
    [self.tableView setContentInset:UIEdgeInsetsMake(40.0, 0, 0, 0)];
}

- (void)viewDeckController:(IIViewDeckController *)viewDeckController willOpenViewSide:(IIViewDeckSide)viewDeckSide animated:(BOOL)animated {
    if ([self centerControllerHasMenuButton:[LatestChatty2AppDelegate delegate].navigationController]) {
        [UIView animateWithDuration:0.3 animations:^{
            [[LatestChatty2AppDelegate delegate].navigationController.topViewController.navigationItem.leftBarButtonItem setTintColor:[UIColor lcIOS7BlueColor]];
        }];
    }
}

- (void)viewDeckController:(IIViewDeckController *)viewDeckController willCloseViewSide:(IIViewDeckSide)viewDeckSide animated:(BOOL)animated {
    if ([self centerControllerHasMenuButton:[LatestChatty2AppDelegate delegate].navigationController]) {
        [UIView animateWithDuration:0.3 animations:^{
            [[LatestChatty2AppDelegate delegate].navigationController.topViewController.navigationItem.leftBarButtonItem setTintColor:[UIColor whiteColor]];
        }];
    }
}

- (BOOL)centerControllerHasMenuButton:(UINavigationController *)navController {
    NSArray *classesWithMenuButton = @[[BrowserViewController class], [ChattyViewController class], [MessagesViewController class], [SearchViewController class], [StoriesViewController class]];
    for (Class cls in classesWithMenuButton) {
        if ([navController.topViewController isKindOfClass:cls]) {
            return YES;
        }
    }
    return NO;
}

- (void)pushBrowserForCredits {
    NSString *urlString = @"http://mccrager.com/latestchatty/credits";
    UIViewController *viewController =
    [[BrowserViewController alloc] initWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlString]]
                                              title:@"Credits"
                                      isForShackLOL:NO
                                       isForCredits:YES];
    if ([[LatestChatty2AppDelegate delegate] isPadDevice]) {
        [[LatestChatty2AppDelegate delegate].contentNavigationController pushViewController:viewController animated:YES];
    } else {
        [[LatestChatty2AppDelegate delegate].navigationController pushViewController:viewController animated:YES];
    }
}

- (void)pushBrowserForLicenses {
    NSString *urlString = @"http://mccrager.com/latestchatty/licenses";
    UIViewController *viewController =
    [[BrowserViewController alloc] initWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlString]]
                                              title:@"Licenses"
                                      isForShackLOL:NO
                                       isForCredits:YES];
    if ([[LatestChatty2AppDelegate delegate] isPadDevice]) {
        [[LatestChatty2AppDelegate delegate].contentNavigationController pushViewController:viewController animated:YES];
    } else {
        [[LatestChatty2AppDelegate delegate].navigationController pushViewController:viewController animated:YES];
    }

}

- (void)didFinishLoadingAllModels:(NSArray *)models otherData:(id)otherData {
    messageCount = 0;
    for (Message *message in models) {
        if (message.unread) messageCount++;
    }
    
//    if (messageCount > 0) {
//        UILocalNotification *messagesNotification = [[UILocalNotification alloc] init];
//        messagesNotification.alertBody = @"You have unread messages.";
//        [[UIApplication sharedApplication] scheduleLocalNotification:messagesNotification];
//    }
    
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:messageCount];
    
    // keep track if an index path had been selected, and reset it after the table is reloaded
    [self.tableView reloadData];
    [self.tableView selectRowAtIndexPath:self.selectedIndex animated:NO scrollPosition:UITableViewScrollPositionNone];
    
    [self.messagesSpinner stopAnimating];
    
    messageLoader = nil;
}

- (void)didFailToLoadModels {
    NSLog(@"Failed to load messages");
    [self.messagesSpinner stopAnimating];
}

#pragma mark Table view methods

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.01f;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 6;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    RootCell *cell = (RootCell *)[tableView dequeueReusableCellWithIdentifier:@"RootCell"];
    if (cell == nil) {
        cell = [[RootCell alloc] init];
    }
    
    switch (indexPath.row) {
        case 0:
            cell.title = @"Stories";
            break;
            
        case 1:
            cell.title = @"LatestChatty";
            [cell setBadgeWithNumber:0];
			break;
            
        case 2:
            cell.title = @"Messages";
            
            // add activity spinner to messages cell that starts spinning when messages are loading and stops when the messages call has finished
            if ([[LatestChatty2AppDelegate delegate] isPadDevice] && self.messagesSpinner == nil) {
                [self setMessagesSpinner:[[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite]];
                [self.messagesSpinner setColor:[UIColor lightGrayColor]];
                int center = [cell iconImage].frameHeight / 2; //vertical center
                CGFloat spinnerSize = 25.0f;
                
                // place spinner on top of messages icon
                [self.messagesSpinner setFrame:CGRectMake(center - spinnerSize / 2, center - spinnerSize / 2, spinnerSize, spinnerSize)];
                [[cell iconImage] addSubview:self.messagesSpinner];
            }
            
            // set number of unread messages in badge of cell
//            messageCount = 9; // for testing
            [cell setBadgeWithNumber:messageCount];
            
            break;
            
        case 3:
            cell.title = @"Search";
            break;
            
        case 4:
            cell.title = @"Shack[lol]";
            break;
            
        case 5:
            cell.title = @"Settings";
            break;
            
        case 6:
            cell.title = @"About";
            break;
            
        default:
            [NSException raise:@"too many rows" format:@"This table can only have 5 cells!"];
            break;
    }

    return (UITableViewCell *)cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UIViewController *viewController = nil;
    BOOL modal = NO;
    NSString *urlString;
    
    // save the index path selection if this isn't settings
    if (indexPath.row != 5) {
        [self setSelectedIndex:indexPath];
    }
    
    switch (indexPath.row) {
        case 0:
            viewController = [StoriesViewController controllerWithNib];
            //[UIAlertView showSimpleAlertWithTitle:@"Sorry" message:@"Stories are disabled for now.  They were broken by the shacknews.com redesign.  Check back soon!"];
            //[tableView deselectRowAtIndexPath:indexPath animated:YES];
            break;
            
        case 1:
            viewController = [ChattyViewController chattyControllerWithLatest];
            break;
            
        case 2:
            viewController = [MessagesViewController controllerWithNib];
            break;
            
        case 3:
            viewController = [SearchViewController controllerWithNib];
            
            if ([[LatestChatty2AppDelegate delegate] isPadDevice]) {
                LatestChatty2AppDelegate *appDelegate = [LatestChatty2AppDelegate delegate];
                [appDelegate.contentNavigationController setViewControllers:[NSArray arrayWithObject:viewController]];
                viewController = nil;
            }
            break;
            
        case 4:
            // Pass user= on the URL for Shack[LOL] in Browser web view.
            urlString = [[NSString stringWithFormat:@"http://lol.lmnopc.com?lc_webview=1&user=%@", [[NSUserDefaults standardUserDefaults] stringForKey:@"username"]] stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
            viewController = [[BrowserViewController alloc] initWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlString]]
                                                                       title:nil
                                                               isForShackLOL:YES
                                                                isForCredits:NO];
            
            if ([[LatestChatty2AppDelegate delegate] isPadDevice]) {
                LatestChatty2AppDelegate *appDelegate = [LatestChatty2AppDelegate delegate];
                [appDelegate.contentNavigationController setViewControllers:[NSArray arrayWithObject:viewController]];
                viewController = nil;
            }
            break;
            
        case 5:
            modal = YES;
            viewController = [SettingsViewController controllerWithNib];

            // use the saved index path to re-select the previous index since settings selection should not persist as a modal
            [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
            [self.tableView selectRowAtIndexPath:self.selectedIndex animated:YES scrollPosition:UITableViewScrollPositionNone];
            
            break;
            
        default:
            [NSException raise:@"too many rows" format:@"This table can only have 6 cells!"];
            break;
    }
    
    if (viewController) {
        if (modal) {
			if ([[LatestChatty2AppDelegate delegate] isPadDevice]) {
                LatestChatty2AppDelegate *appDelegate = [LatestChatty2AppDelegate delegate];
				viewController.modalPresentationStyle = UIModalPresentationFormSheet;
                [appDelegate.slideOutViewController presentViewController:viewController animated:YES completion:nil];
			} else {
                [self.viewDeckController toggleLeftView];
                [self.viewDeckController presentViewController:viewController animated:YES completion:nil];
            }
        } else {
            if ([[LatestChatty2AppDelegate delegate] isPadDevice]) {
                [self.navigationController pushViewController:viewController animated:YES];
            } else {
                self.viewDeckController.centerController = [[UINavigationController alloc] initWithRootViewController:viewController];
                [LatestChatty2AppDelegate delegate].navigationController = (UINavigationController *)self.viewDeckController.centerController;
                [self.viewDeckController toggleLeftView];
            }
        }
    }
}

#pragma mark Cleanup

- (void)dealloc {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
