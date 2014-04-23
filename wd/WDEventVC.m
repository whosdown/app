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
#import "WDInviteesVC.h"

@interface WDEventVC ()
@property (nonatomic, weak) WDRootToEventTransition *transitionor;

@property (nonatomic, weak) NSObject<WDEventDelegate> *wdDelegate;
@property (nonatomic, weak) NSObject<WDEventDataSource> *dataSource;

@property (nonatomic, strong) UITableViewController *messageList;
@property (nonatomic, strong) WDInviteesVC *inviteesVC;
@property (nonatomic, strong) UINavigationBar *navBar;
@property (nonatomic, strong) UINavigationItem *navBarItem;

@property (nonatomic, strong) NSMutableDictionary *recipients;

@end

@implementation WDEventVC

- (id)initWithTranstionor:(WDRootToEventTransition *)transitionor
                 delegate:(NSObject<WDEventDelegate> *)delegate
               dataSource:(NSObject<WDEventDataSource> *)dataSource {
  self = [super init];
  if (self) {
    _wdDelegate = delegate;
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
  
  for (NSDictionary *recip in [self.dataSource.event objectForKey:WD_modelKey_Event_recips]) {
    [self.recipients setObject:recip forKey:[recip objectForKey:WD_modelKey_Recip_id]];
  }
  
  UIViewController *vc = [[UIViewController alloc] init];
  [self pushViewController:vc animated:NO];
  [self pushViewController:self.messageList animated:NO];

  self.messageList.navigationItem.title = [self.dataSource.event objectForKey:WD_modelKey_Event_title];
  self.messageList.navigationItem.rightBarButtonItem =
      [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPause
                                                    target:self
                                                    action:@selector(didTapOnStatusButton)];
}

- (void)setUpViews {
  CGFloat viewWidth = self.view.frame.size.width;
  CGFloat statusHeight = [UIApplication sharedApplication].statusBarFrame.size.height;
  CGFloat navBarHeight = 44;
  
  CGRect navBarRect       = self.navBar.frame;
  navBarRect.size = CGSizeMake(viewWidth, statusHeight + navBarHeight);
  navBarRect.origin = CGPointZero;
  
  self.messageList.tableView.contentInset = UIEdgeInsetsMake(10, 0, 0, 0);
  self.messageList.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
  
  self.navBar.frame      = navBarRect;
}

- (void)refresh {
  [self.dataSource refreshMessagesFromCurrentEventOnSuccess:^{
        [self.messageList.tableView reloadData];
        [self.inviteesVC refreshSets];
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

- (void)didTapOnStatusButton {
  [self presentViewController:self.inviteesVC animated:YES completion:nil];
}

#pragma mark UINavigationBarDelegate

- (BOOL)navigationBar:(UINavigationBar *)navigationBar
        shouldPopItem:(UINavigationItem *)item {
  [self.wdDelegate didTapOnCancelButton];
  return NO;
}

#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  NSDictionary *messageObj = [self.dataSource.messages objectAtIndex:[indexPath row]];
  NSString *recipientId = [messageObj objectForKey:WD_modelKey_Message_recip];
  CGFloat nameSpace = recipientId == nil ? 0 : WD_conv_messageNameSpace;

  NSAttributedString *attrString = [[NSAttributedString alloc]
     initWithString:[messageObj objectForKey:WD_modelKey_Message_message]
         attributes: @{
           NSFontAttributeName            : [UIFont fontWithName:WD_conv_messageFont
                                                            size:WD_conv_messageSize],
           NSForegroundColorAttributeName : [UIColor darkTextColor]
         }];
  
  CGRect messageRect = [attrString
    boundingRectWithSize:CGSizeMake(WD_conv_messageBubbleWidth, 100000)
                 options:NSStringDrawingUsesLineFragmentOrigin |
                         NSStringDrawingUsesFontLeading
                 context:nil];
  
  return messageRect.size.height + nameSpace +
         WD_conv_messageBubbleSpacer + WD_conv_messageBubbleOffset;
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

  typedef enum TypeIdentifiers {
    TypeIdentifierRecipient,
    TypeIdentifierWhosDown,
    TypeIdentifierCreator
  } TypeIdentifier;

  
  NSDictionary *messageObj = [self.dataSource.messages objectAtIndex:[indexPath row]];
  NSString *recipientId = [messageObj objectForKey:WD_modelKey_Message_recip];
  
  if (!messageObj) {
    return [[UITableViewCell alloc] init];
  }
  
  NSString *identifier;
  TypeIdentifier typeId;
  
  // From the Creator
  if (!recipientId) {
    identifier = Creator;
    typeId     = TypeIdentifierCreator;
    
  // From the Who's Down directly
  } else if ([recipientId  isEqualToString:WD_Message_recipWD]) {
    identifier = WhosDown;
    typeId     = TypeIdentifierWhosDown;
    
  // From a normal Recipient
  } else {
    identifier = Recipient;
    typeId     = TypeIdentifierRecipient;
  }

  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];


  if (!cell) {
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                  reuseIdentifier:identifier];
  }
  
  UIView  *bubbleView = [[UIView alloc] init];
  bubbleView.layer.cornerRadius = 8;
  UILabel *messageLabel = [[UILabel alloc] init];
  messageLabel.text = [messageObj objectForKey:WD_modelKey_Message_message];
  messageLabel.font = [UIFont fontWithName:WD_conv_messageFont
                                      size:WD_conv_messageSize];
  messageLabel.textColor = [UIColor darkTextColor];
  messageLabel.numberOfLines = 0;
  
  
  CGRect bubbleRect = {
      CGPointZero,
      CGSizeMake(WD_conv_messageBubbleWidth + WD_conv_messageBubbleSpacer,
                 [self tableView:tableView heightForRowAtIndexPath:indexPath]
                     - WD_conv_messageBubbleOffset)
  };
  
  switch (typeId) {
    case TypeIdentifierCreator:
      bubbleView.backgroundColor = WD_conv_messageBubbleCreatorColor;
      bubbleRect.origin.x = cell.contentView.bounds.size.width - bubbleRect.size.width -
          WD_conv_messageBubbleOffset;
      break;
    case TypeIdentifierRecipient: {
      bubbleView.backgroundColor = WD_conv_messageBubbleRecipientColor;
      bubbleRect.origin.x = WD_conv_messageBubbleOffset;
      bubbleRect.size.height = bubbleRect.size.height - WD_conv_messageNameSpace;
      
      UILabel *nameLabel = [[UILabel alloc]
          initWithFrame:CGRectMake(WD_conv_messageBubbleOffset * 2,
                                   bubbleRect.size.height + 2,
                                   cell.contentView.bounds.size.width - WD_conv_messageBubbleOffset * 2,
                                   WD_conv_messageNameSpace)];
      NSDictionary *recip =
          [self.recipients objectForKey:[messageObj objectForKey:WD_modelKey_Message_recip]];
      nameLabel.text = [recip objectForKey:WD_modelKey_Recip_name];
      nameLabel.font = [UIFont fontWithName:WD_conv_messageFont size:WD_conv_nameSize];
      nameLabel.textColor = [UIColor darkTextColor];
      [cell.contentView addSubview:nameLabel];
      break;
    }
    case TypeIdentifierWhosDown:
      break;
    default:
      break;
  }
  
  bubbleView.frame = bubbleRect;
  messageLabel.frame = CGRectMake(bubbleRect.origin.x + (WD_conv_messageBubbleSpacer / 2),
                                  -1,
                                  WD_conv_messageBubbleWidth,
                                  bubbleRect.size.height);
  [cell.contentView addSubview:bubbleView];
  [cell.contentView addSubview:messageLabel];
  
  cell.selectionStyle = UITableViewCellSelectionStyleNone;

  return cell;
}

#pragma mark Lazy Initializers

- (UINavigationBar *)navBar {
  if (!_navBar) {
    _navBar = [[UINavigationBar alloc] initWithFrame:CGRectZero];
    _navBar.translucent = YES;
//    _navBar.barTintColor = WD_UIColor_green;
    _navBar.tintColor = [UIColor darkTextColor];

    _navBar.items = @[[[UINavigationItem alloc] init], self.navBarItem];
    _navBar.titleTextAttributes =
    @{ NSFontAttributeName            : [UIFont fontWithName:WD_comp_newEventTitleFont
                                                        size:WD_comp_newEventTitleSize],
       NSForegroundColorAttributeName : [UIColor darkTextColor]
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

- (NSMutableDictionary *)recipients {
  if (!_recipients) {
    _recipients = [[NSMutableDictionary alloc] init];
  }
  return _recipients;
}

- (UITableViewController *)messageList {
  if (!_messageList) {
    _messageList = [[UITableViewController alloc] initWithStyle:UITableViewStylePlain];
    _messageList.tableView.dataSource = self;
    _messageList.tableView.delegate   = self;
    
  }
  return _messageList;
}

- (WDInviteesVC *)inviteesVC {
  if (!_inviteesVC) {
    _inviteesVC = [[WDInviteesVC alloc] initWithDataSource:self.dataSource];
    _inviteesVC.parent = self;
  }
  return _inviteesVC;
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
