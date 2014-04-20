//
//  WDEventVCViewController.m
//  wd
//
//  Created by Joseph Schaffer on 4/20/14.
//  Copyright (c) 2014 Who's Down. All rights reserved.
//

#import "WDEventVC.h"

#import "WDConstants.h"
#import "WDRootToEventTransition.h"
#import "WDEventDelegate.h"
#import "WDEventDataSource.h"

@interface WDEventVC ()
@property (nonatomic, weak) WDRootToEventTransition *transitionor;

@property (nonatomic, weak) NSObject<WDEventDelegate> *delegate;
@property (nonatomic, weak) NSObject<WDEventDataSource> *dataSource;

@property (nonatomic, strong) UITableViewController *messageList;
@property (nonatomic, strong) UINavigationBar *navBar;
@property (nonatomic, strong) UINavigationItem *navBarItem;

@property NSArray *recipients;

@end

@implementation WDEventVC

- (id)initWithTranstionor:(WDRootToEventTransition *)transitionor
                 delegate:(NSObject<WDEventDelegate> *)delegate
               dataSource:(NSObject<WDEventDataSource> *)dataSource {
  self = [super init];
  if (self) {
    _delegate = delegate;
    _dataSource = dataSource;
    _transitionor = transitionor;
    self.modalPresentationStyle = UIModalPresentationCustom;
    self.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    self.transitioningDelegate = _transitionor;
  }
  return self;
}

- (void)viewDidLoad {
  [super viewDidLoad];

  self.messageList.refreshControl = [[UIRefreshControl alloc] init];
  [self.messageList.refreshControl addTarget:self
                                      action:@selector(refresh)
                            forControlEvents:UIControlEventValueChanged];
  
  [self refresh];
  [self setUpViews];
  
  NSLog(@" Event : %@", self.dataSource.event);

  [self displayInnerViewController:self.messageList withFrame:self.view.frame];
  [self.view addSubview:self.navBar];
  self.navBarItem.title = [self.dataSource.event objectForKey:WD_modelKey_Event_title];
}

- (void)setUpViews {
  CGFloat viewWidth = self.view.frame.size.width;
  CGFloat statusHeight = [UIApplication sharedApplication].statusBarFrame.size.height;
  CGFloat navBarHeight = 44;
  
  CGRect navBarRect       = self.navBar.frame;
  navBarRect.size = CGSizeMake(viewWidth, statusHeight + navBarHeight);
  navBarRect.origin = CGPointZero;
  
  self.messageList.tableView.contentInset = UIEdgeInsetsMake(navBarRect.size.height, 0, 0, 0);
  self.messageList.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
  
  self.navBar.frame      = navBarRect;
}

- (void)refresh {
  [self.dataSource refreshMessagesFromCurrentEventOnSuccess:^{
        [self.messageList.tableView reloadData];
        [self.messageList.refreshControl endRefreshing];
      }
                                                  onFailure:^{
                                                    NSLog(@"Refresh Failed");
                                                    [self.messageList.refreshControl endRefreshing];
                                                  }];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

#pragma mark UINavigationBarDelegate

- (BOOL)navigationBar:(UINavigationBar *)navigationBar
        shouldPopItem:(UINavigationItem *)item {
  [self.delegate didTapOnCancelButton];
  return NO;
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  // Return the number of sections.
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

  return [self.dataSource.messages count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  static NSString *Recipient = @"Recipient";
  static NSString *WhosDown  = @"WhosDown";
  static NSString *Creator   = @"Creator";

  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:Recipient];

  NSDictionary *messageObj = [self.dataSource.messages objectAtIndex:[indexPath row]];
  NSString *recipientId = [messageObj objectForKey:WD_modelKey_Message_recip];
  
  if (!messageObj) {
    return cell;
  }

  if (!cell) {
    
    // From the Creator
    if (recipientId == nil) {
      cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                    reuseIdentifier:Creator];
      
    // From the Who's Down directly
    } else if ([recipientId  isEqualToString:WD_Message_recipWD]) {
      cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                    reuseIdentifier:WhosDown];
      
      
    // From a normal Recipient
    } else {
      cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                    reuseIdentifier:Recipient];
      cell.textLabel.textAlignment = NSTextAlignmentRight;
    }
  }

  
  NSString *message = [messageObj objectForKey:WD_modelKey_Message_message];
  
  cell.textLabel.font = [UIFont fontWithName:WD_conv_messageFont size:WD_conv_messageSize];
  cell.textLabel.text = message;

  return cell;
}

#pragma mark Lazy Initializers

- (UINavigationBar *)navBar {
  if (!_navBar) {
    _navBar = [[UINavigationBar alloc] initWithFrame:CGRectZero];
    _navBar.translucent = YES;
    _navBar.barTintColor = WD_UIColor_green;
    _navBar.tintColor = [UIColor whiteColor];

    _navBar.items = @[[[UINavigationItem alloc] init], self.navBarItem];
    _navBar.titleTextAttributes =
    @{ NSFontAttributeName            : [UIFont fontWithName:WD_comp_newEventTitleFont
                                                        size:WD_comp_newEventTitleSize],
       NSForegroundColorAttributeName : [UIColor whiteColor]
    };

    _navBar.delegate = self;
  }
  return _navBar;
}

- (UINavigationItem *)navBarItem {
  if (!_navBarItem) {
    _navBarItem = [[UINavigationItem alloc] init];
    
  }
  return _navBarItem;
}

- (UITableViewController *)messageList {
  if (!_messageList) {
    _messageList = [[UITableViewController alloc] initWithStyle:UITableViewStylePlain];
    _messageList.tableView.dataSource = self;
    
  }
  return _messageList;
}

#pragma mark Child View Management

- (void) displayInnerViewController:(UIViewController *)innerVC withFrame:(CGRect)frame {
  [self addChildViewController:innerVC];
  innerVC.view.frame = frame;
  [self.view addSubview:innerVC.view];
  [innerVC didMoveToParentViewController:self];
}

- (void) hideInnerViewController:(UIViewController *)innerVC {
  //  UIViewController *viewControllerToRemove = [[self childViewControllers] firstObject];
  [innerVC willMoveToParentViewController:nil];
  [innerVC.view removeFromSuperview];
  [innerVC removeFromParentViewController];
}

@end
