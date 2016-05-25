//
//  LiveScoreViewController.m
//  BDLive
//
//  Created by Khanh Le on 12/9/14.
//  Copyright (c) 2014 Khanh Le. All rights reserved.
//

#import "LiveScoreViewController.h"
#import "RDVTabBarController.h"
#import "xs_common_inc.h"
#import "LiveScoreHeaderSection.h"
#import "LiveScoreTableViewCell.h"
#import "SVPullToRefresh.h"
#import "DetailMatchController.h"
#import "StatsViewController.h"
#import "../Models/ScheduleCollection.h"
#import "../Models/LeagueMenuModel.h"
#import "../Models/AccInfo.h"

#import "../SOAPHandler/SOAPHandler.h"
#import "../SOAPHandler/PresetSOAPMessage.h"
#import "../Models/CountryModel.h"
#import "../Models/LivescoreModel.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "../Models/LivescoreGroupModel.h"
#import "BDLiveGestureRecognizer.h"
#import "SettingsViewController.h"
#import "Perform/PViewController.h"
#import "LiveBDController.h"
#import "ToastAlert.h"
#import <AudioToolbox/AudioServices.h>
#import "ExpertReview.h"
#import "ChatZone/ChatViewController.h"
#import "GamePredictorViewController.h"
#import "HelpViewController.h"
#import "DAPagesContainer.h"
#import "../AdNetwork/AdNetwork.h"

//#import <StartApp/StartApp.h>

#define FILTER_QUICK_MENU 9
#define FILTER_FULLTIME_MATCH 1
#define FILTER_LIVE_MATCH 2
#define SCORE_CHANGED_VALUE_INTERVAL 20.f
#define FILTER_TODAY_MATCH 2

static NSString* nib_LivescoreHeaderSection = @"nib_LivescoreHeaderSection";
static NSString* nib_LivescoreCell = @"nib_LivescoreCell";

@interface LeagueDataTapGestureRecognizer : UITapGestureRecognizer
@property (nonatomic) int iID_MaGiai;
@property (nonatomic) int iEvent;
@property (nonatomic) NSString* leagueName;
@end



@interface LiveScoreViewController () <UITableViewDataSource, UITableViewDelegate, SOAPHandlerDelegate, UIAlertViewDelegate, UISearchBarDelegate, UISearchDisplayDelegate, DAPagesContainerTopBarDelegate, GADBannerViewDelegate> {

}

//@property(nonatomic, strong) IBOutlet UIActivityIndicatorView *loadingIndicator;

@property(nonatomic, strong) IBOutlet UIImageView *loadingIndicator;

@property(nonatomic, strong) IBOutlet UIActivityIndicatorView *myIndicator;

// scroll view
@property(nonatomic, strong) IBOutlet UIScrollView *leagueMenu;

// button
@property(nonatomic, strong) IBOutlet UIButton *fulltimeBtn;
@property(nonatomic, strong) IBOutlet UIButton *liveBtn;

@property(nonatomic, strong) IBOutlet UIView *hdrLiveView;

@property(nonatomic, strong) IBOutlet UIView *lichContainer;
@property (strong, nonatomic) DAPagesContainer *pagesContainer;
@property(nonatomic, strong) NSMutableDictionary* lichDict;
@property(nonatomic, strong) ScheduleCollection* currCollection;

@property (nonatomic, strong) NSMutableArray *dataSource;

@property(nonatomic, strong) SOAPHandler *soapHandler;

@property(nonatomic, strong) SOAPHandler *autoSoapHandler;

//@property(nonatomic, strong) NSMutableArray* listLivescore;

@property(nonatomic, strong) NSMutableDictionary* listLivescore;
@property(nonatomic, strong) NSMutableArray* listLivescoreKeys;

// filter for search
@property(nonatomic, strong) NSMutableArray* listLivescore_Filter;

// end filter


//live
@property(nonatomic, strong) NSMutableDictionary* listLivescore_Live;
@property(nonatomic, strong) NSMutableArray* listLivescoreKeys_Live;

@property(nonatomic, strong) NSMutableDictionary* listLivescore_FT;
@property(nonatomic, strong) NSMutableArray* listLivescoreKeys_FT;

@property(atomic, strong) SDWebImageManager *manager;

@property(nonatomic) int totalPage;
@property(nonatomic) int currPage;
@property(nonatomic) int selectedDateIndex;


@property(nonatomic) int filterType; // 0: normal, 1: fulltime, 2: live match

@property(nonatomic) BOOL isForeground;

@property(nonatomic) BOOL isSearching;

@property(nonatomic) BOOL isVisible;

@property(nonatomic, strong)NSTimer* timer; // auto reload after each 30s


@property(nonatomic) BOOL isAutoUpdate;
@property(nonatomic) BOOL isReloadData;
@property(atomic, strong) NSObject *autoLockObj;
@property(atomic, strong) LiveScoreHeaderSection *viewHeaderTable;


@property(nonatomic, strong)NSMutableArray* leagueMenuList;

@property(nonatomic) int selectedMenuID;


@end

@implementation LiveScoreViewController {
    
}

@synthesize tableView = tableView;
@synthesize livescoreSearchBar;

-(void)setupDummyDataLeague {
    LeagueMenuModel* m1 = [LeagueMenuModel new];
    m1.sMenuName = @"Premier League";
    m1.iID_MaGiai = 12;
    [self.leagueMenuList addObject:m1];
    LeagueMenuModel* m2 = [LeagueMenuModel new];
    m2.sMenuName = @"Primera Division";
    m2.iID_MaGiai = 14;
    [self.leagueMenuList addObject:m2];
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.autoLockObj = [NSObject new];
        self.isLoadingData = NO;
        self.totalPage = 1;
        self.isForeground = NO;
        self.currPage = 0;
        self.soapHandler = [[SOAPHandler alloc] init];
        self.soapHandler.delegate = self;
        self.isVisible = NO;
        self.selectedDateIndex = 2;
        self.lichDict =[NSMutableDictionary new];
        self.leagueMenuList = [NSMutableArray new];
        
        // setup dummy data
        //[self setupDummyDataLeague];
        // end
        
        self.isSearching = NO;
        
        self.autoSoapHandler = [[SOAPHandler alloc] init];
        self.autoSoapHandler.delegate = self;
        
        self.listLivescore = [NSMutableDictionary new];
        self.listLivescoreKeys = [NSMutableArray new];
        
        //live
        self.listLivescore_Live = [NSMutableDictionary new];
        self.listLivescoreKeys_Live = [NSMutableArray new];
        
        // fulltime
        self.listLivescore_FT = [NSMutableDictionary new];
        self.listLivescoreKeys_FT = [NSMutableArray new];
        
        // filter
        self.listLivescore_Filter = [NSMutableArray new];
        
        
        _manager = [SDWebImageManager sharedManager];
        self.isAutoUpdate = NO;
        self.filterType = 0;
        self.isReloadData = NO;
        
        [AdNetwork sharedInstance];
        
        [self fetchLivescoreList];
    }
    return self;
    
}

-(void)setupFixtureView {
    self.pagesContainer = [[DAPagesContainer alloc] init];
    self.pagesContainer.delegate = self;
    [self.pagesContainer willMoveToParentViewController:self];
    self.pagesContainer.view.frame = [UIScreen mainScreen].bounds;
    self.pagesContainer.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.lichContainer addSubview:self.pagesContainer.view];
    
    self.pagesContainer.selectedPageItemTitleColor = [UIColor greenColor];
    [self.pagesContainer didMoveToParentViewController:self];
    self.pagesContainer.topBarHeight = 27.f;
    
    NSDate* now = [NSDate date];
    NSString* dateFormat = @"d/M";
    UIViewController *con1 = [[UIViewController alloc] init];

    con1.title = [XSUtils getDateByGivenDateInterval:now dateFormat:dateFormat dateInterval:-2];
    
    UIViewController *con2 = [[UIViewController alloc] init];

    con2.title = [XSUtils getDateByGivenDateInterval:now dateFormat:dateFormat dateInterval:-1];
    
    UIViewController *con3 = [[UIViewController alloc] init];

    NSString* todayTxt = [NSString stringWithFormat:@"%@", NSLocalizedString(@"lich-homnay.txt", @"Today")];
    con3.title = todayTxt;
    
    
    UIViewController *con4 = [[UIViewController alloc] init];

    con4.title = [XSUtils getDateByGivenDateInterval:now dateFormat:dateFormat dateInterval:1];
    UIViewController *con5 = [[UIViewController alloc] init];

    con5.title = [XSUtils getDateByGivenDateInterval:now dateFormat:dateFormat dateInterval:2];
    
    
    
   
    self.pagesContainer.imageViews = @[@"ic_lich_dau.png", @"ic_lich_dau.png", @"ic_lich_dau.png", @"ic_lich_dau.png", @"ic_lich_dau.png"];
    
    self.pagesContainer.viewControllers = @[con1, con2, con3, con4, con5];
    self.pagesContainer.selectedIndex = 2;
}



-(void)setupLeagueMenu:(BOOL)isEn {
    
    CGFloat logoWidth = 33.f;
    CGFloat holderViewWidth = 0.f;
    CGFloat height = self.leagueMenu.frame.size.height;
    CGFloat holderOriginX = 0.f;
    CGFloat logoOriginX = 5.f;
    CGFloat leagueWidth = 0.f;
    
    for (UIView* childView in self.leagueMenu.subviews) {
        [childView removeFromSuperview];
    }
    for (int i = 0; i < self.leagueMenuList.count; i++) {
        LeagueMenuModel* model = [self.leagueMenuList objectAtIndex:i];
        UIImageView* logoImg = [[UIImageView alloc] initWithFrame:CGRectMake(logoOriginX, 3, logoWidth, height - 6)];
        logoImg.image = [UIImage imageNamed:@"France.png"];
        
        UILabel* leagueName = [[UILabel alloc] init];
        
        leagueName.textColor = [UIColor redColor];
        leagueName.text = model.sMenuName;
        
        UIFont *font = [UIFont fontWithName:@"VNF-FUTURA" size:13.f];
        [leagueName setFont:font];
        leagueName.textAlignment = NSTextAlignmentCenter;
        float widthIs = [leagueName.text boundingRectWithSize:leagueName.frame.size options:NSStringDrawingUsesLineFragmentOrigin attributes:@{  NSFontAttributeName:leagueName.font } context:nil].size.width;
        if (widthIs < 40) {
            widthIs = 40;
        }
        leagueName.frame = CGRectMake( logoOriginX + logoWidth, 0.f, widthIs, height);
        
        if (model.iEvent == 1) {
            holderViewWidth = 27 * 311 / 90 ;
        }
        else {
            holderViewWidth = leagueName.frame.origin.x + leagueName.frame.size.width + 10;
        }
        [self.manager downloadWithURL:[NSURL URLWithString:model.sLogo]
                              options:0
                             progress:^(NSInteger receivedSize, NSInteger expectedSize)
         {
             // progression tracking code
         }
                            completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished)
         {
             if (image)
             {
                 
                 [XSUtils adjustUIImageView:logoImg image:image];
                 [logoImg setImage:image];
                 
             }
         }];
        
        
        UIView* holderView = [[UIView alloc] initWithFrame:CGRectMake(holderOriginX, 0, holderViewWidth, height)];
        //Add bottom border line
        CALayer *bottomBorder = [CALayer layer];
        bottomBorder.frame = CGRectMake(4.0f, 26.0f, holderView.frame.size.width, 1.0f);
        bottomBorder.backgroundColor = [UIColor grayColor].CGColor;
        [holderView.layer addSublayer:bottomBorder];
        
        //Add right border line
        CALayer *rightBorder = [CALayer layer];
        rightBorder.frame = CGRectMake(holderViewWidth - 1, 0.f, 1.0f, holderView.frame.size.height);
        rightBorder.backgroundColor = [UIColor grayColor].CGColor;
        [holderView.layer addSublayer:rightBorder];
        
        if (model.iEvent == 1 && model.iID_MaGiai == 78) {
            UIImageView *eventBackground = [[UIImageView alloc] init];
            eventBackground.frame = CGRectMake(0, 0, 27*311/90 , 27);
            eventBackground.image = [UIImage imageNamed:@"screen1-cut_02.png"];
            [holderView addSubview:eventBackground];
        }
//        else if (model.iEvent == 1 && model.iID_MaGiai == 60) {
//            
//        }
        else {
            [holderView addSubview:logoImg];
            [holderView addSubview:leagueName];
        }
        
        [self.leagueMenu addSubview:holderView];
        
        holderView.userInteractionEnabled = YES;
        holderView.tag = model.iID_MaGiai;
        LeagueDataTapGestureRecognizer* tap = [[LeagueDataTapGestureRecognizer alloc] initWithTarget:self action:@selector(onLeagueMenuClick:)];
        tap.numberOfTapsRequired = 1;
        tap.iID_MaGiai = model.iID_MaGiai;
        tap.iEvent = model.iEvent;
        tap.leagueName = model.sMenuName;
        [holderView addGestureRecognizer:tap];
        
        //Change value
        holderOriginX += holderViewWidth;
        leagueWidth += holderViewWidth;
    }
    self.leagueMenu.contentSize = CGSizeMake(leagueWidth + 4, height);
    self.leagueMenu.showsHorizontalScrollIndicator = NO;
}
-(void)onLeagueMenuClick:(LeagueDataTapGestureRecognizer*)sender {

    int iID_MaGiai = sender.iID_MaGiai;
    self.selectedMenuID = iID_MaGiai;
    self.filterType = FILTER_QUICK_MENU;
    
    for (UIView *i in self.leagueMenu.subviews){
        if([i isKindOfClass:[UIView class]] && sender.iEvent != 1){
            UIView *holder = (UIView *)i;
            if(holder.tag == iID_MaGiai){
                holder.backgroundColor = [UIColor colorWithRed:102.0/255.0 green:178.0/255.0 blue:1.0 alpha:0.5f];
            }
            else {
                holder.backgroundColor = [UIColor clearColor];
            }
            
        }
    }
    if (sender.iID_MaGiai == 60) {
        LiveBDController *bd = [[LiveBDController alloc] initWithNibName:@"LiveBDController" bundle:nil];
        bd.iID_MaGiai = iID_MaGiai;
        bd.bGiaiCup = 1;
        bd.selectedDateIndex = 2;
        bd.sTenGiai = @"";
        
        // khanh add this
        if (bd.bGiaiCup) {
            [bd fetch_wsFootBall_VongDau];
            [bd fetch_wsFootBall_BangXepHang];
            [bd fetch_wsFootBall_SVD];
        } else {
            [bd fetchListLeageLiveByCountry:[NSString stringWithFormat:@"%d", iID_MaGiai]];
        }
        [self.navigationController pushViewController:bd animated:YES];
        //
    }
    if (sender.iEvent == 1) {
        LiveBDController *bd = [[LiveBDController alloc] initWithNibName:@"LiveBDController" bundle:nil];
        bd.iID_MaGiai = iID_MaGiai;
        bd.bGiaiCup = 1;
        bd.selectedDateIndex = 2;
        bd.sTenGiai = @"";
        
        // khanh add this
        if (bd.bGiaiCup) {
            [bd fetch_wsFootBall_VongDau];
            [bd fetch_wsFootBall_BangXepHang];
            [bd fetch_wsFootBall_SVD];
        } else {
            [bd fetchListLeageLiveByCountry:[NSString stringWithFormat:@"%d", iID_MaGiai]];
        }
        [self.navigationController pushViewController:bd animated:YES];
        //
    }
    else {
        
        ScheduleCollection *ret = [self.lichDict objectForKey:[NSString stringWithFormat:@"menu-%d", self.selectedMenuID]];
        
        if(ret) {
            self.currCollection = ret;
            [self.tableView reloadData];
        } else {
            dispatch_queue_t myQueue = dispatch_queue_create("com.ptech.bdlive_menu", NULL);
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.05 * NSEC_PER_SEC)), myQueue, ^{
                [self.soapHandler sendSOAPRequest:[PresetSOAPMessage get_wsFootBall_wsFootBall_LiveScore_VongDau_SoapMessage:iID_MaGiai] soapAction:[PresetSOAPMessage get_wsFootBall_wsFootBall_LiveScore_VongDau_SoapAction]];
                
            });
        }
    }
    
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self addNotification];
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_7_1) {
        self.searchDisplayController.searchResultsTableView.translatesAutoresizingMaskIntoConstraints = NO;
        CGRect tableFrame= self.searchDisplayController.searchResultsTableView.frame;
        tableFrame.size.height = [UIScreen mainScreen].bounds.size.height;
        tableFrame.size.width = [UIScreen mainScreen].bounds.size.width;
        [self.searchDisplayController.searchResultsTableView setFrame:tableFrame];

    }

    
    if (self.rdv_tabBarController.tabBar.translucent) {
        UIEdgeInsets insets = UIEdgeInsetsMake(0,
                                               0,
                                               CGRectGetHeight(self.rdv_tabBarController.tabBar.frame),
                                               0);
        
    }
    
    
    
    
    self.navigationController.navigationBarHidden = YES;
    
    // setup nib files
    UINib *livescoreCell = [UINib nibWithNibName:@"LiveScoreTableViewCell" bundle:nil];
    [self.tableView registerNib:livescoreCell forCellReuseIdentifier:nib_LivescoreCell];
    
    
    [self.tableView registerNib:[UINib nibWithNibName:@"LiveScoreHeaderSection" bundle:nil] forHeaderFooterViewReuseIdentifier:@"LiveScoreHeaderSection"];
    
    // end setup nib files
    
    [self setupDataSource];
    
    __weak LiveScoreViewController *weakSelf = self;
    
//    // setup pull-to-refresh
//    [self.tableView addPullToRefreshWithActionHandler:^{
//        [weakSelf insertRowAtTop];
//    }];
    
    // setup infinite scrolling
    [self.tableView addInfiniteScrollingWithActionHandler:^{
        [weakSelf insertRowAtBottom];
    }];
    
    [self animateLoadingIndicator];
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:AUTO_REFRESH_LIVESCORE target:self selector:@selector(onAutoRefreshLivescoreData:) userInfo:nil repeats:YES];
    
    
    UITapGestureRecognizer *tapGesture =
    [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onHomeSiteClick:)];
    [XSUtils setTableFooter:self.tableView tap:tapGesture];
    
    
    [self setupFixtureView];
    [[AdNetwork sharedInstance] createAdMobBannerView:self admobDelegate:self tableView:self.tableView];
    [self setupLeagueMenu:YES];
    
    dispatch_queue_t myQueue = dispatch_queue_create("com.ptech.bdlive_menu", NULL);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.05 * NSEC_PER_SEC)), myQueue, ^{
        
        [self.soapHandler sendSOAPRequest:[PresetSOAPMessage get_wsFootBall_wsFootBall_Menu_ChonNhanh_SoapMessage] soapAction:[PresetSOAPMessage get_wsFootBall_wsFootBall_Menu_ChonNhanh_SoapAction]];
        
    });
}

-(void)onHomeSiteClick:(id)sender {
    NSString *livescoreLink = @"http://livescore007.com/";
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:livescoreLink]];
}

-(void) animateLoadingIndicator
{
//    UIImageView* animatedImageView = self.loadingIndicator;
//    animatedImageView.animationImages = [NSArray arrayWithObjects:
//                                         [UIImage imageNamed:@"info-match3-cut_071.png"],
//                                         [UIImage imageNamed:@"info-match3-cut_072.png"],
//                                         [UIImage imageNamed:@"info-match3-cut_073.png"],
//                                         [UIImage imageNamed:@"info-match3-cut_074.png"],
//                                         [UIImage imageNamed:@"info-match3-cut_075.png"],
//                                         [UIImage imageNamed:@"info-match3-cut_076.png"],
//                                         [UIImage imageNamed:@"info-match3-cut_077.png"],
//                                         [UIImage imageNamed:@"info-match3-cut_078.png"],
//                                         [UIImage imageNamed:@"info-match3-cut_079.png"],
//                                         [UIImage imageNamed:@"info-match3-cut_0710.png"],
//                                         [UIImage imageNamed:@"info-match3-cut_0711.png"],
//                                         [UIImage imageNamed:@"info-match3-cut_0712.png"],
//                                         nil];
//    animatedImageView.animationDuration = 1.0f;
//    animatedImageView.animationRepeatCount = 0;
//    [animatedImageView startAnimating];
    

    UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onRefreshTouch:)];
    tap.numberOfTapsRequired = 1;
    
    self.loadingIndicator.userInteractionEnabled = YES;
    [self.loadingIndicator addGestureRecognizer:tap];
    self.myIndicator.hidden = YES;
    
    
    [XSUtils setFontFamily:@"VNF-FUTURA" forView:self.view andSubViews:YES];
}



- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    

    
    
}

-(void)onRefreshTouch:(UITapGestureRecognizer*) sender
{
    self.isAutoUpdate = NO;
    self.myIndicator.hidden = NO;
    self.loadingIndicator.hidden = YES;
    self.totalPage = 1;
    self.currPage = 0;
    self.isReloadData = YES;
//    [self.listLivescore removeAllObjects];
//    [self.listLivescoreKeys removeAllObjects];
    
    self.filterType = 0;
    
    [self.fulltimeBtn setBackgroundImage:[UIImage imageNamed:@"ic_fulltime.png"] forState:UIControlStateNormal];
    [self.liveBtn setBackgroundImage:[UIImage imageNamed:@"ic_live.png"] forState:UIControlStateNormal];
    
    ZLog(@"refresh button touched to re-load data");
//    self.tableView.contentOffset = CGPointMake(0, 0);
    
    
    if (self.selectedDateIndex == FILTER_TODAY_MATCH) {
        [self fetchLivescoreList];
    } else {
        [self fetchLich_LivescoreList];
    }
    //
    for (UIView *i in self.leagueMenu.subviews){
        if([i isKindOfClass:[UIView class]]){
            UIView *holder = (UIView *)i;
            holder.backgroundColor = [UIColor clearColor];
        }
    }
    
}

-(void)viewDidDisappear:(BOOL)animated {
    self.isVisible = NO;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.isVisible = YES;
    [tableView triggerPullToRefresh];
    @try {
        if (self.selectedDateIndex == FILTER_TODAY_MATCH) {
            [self.tableView reloadRowsAtIndexPaths:[self.tableView indexPathsForVisibleRows]
                                  withRowAnimation:UITableViewRowAnimationNone];
        }
        
    }
    @catch (NSException *exception) {
        // exception
        ZLog(@"exception: %@", exception);
    }
    
    
    NSString *firstUse = [[NSUserDefaults standardUserDefaults] objectForKey:TYSO24H_FIRST_USE];
    if (firstUse == nil || ![firstUse isEqualToString:@"1"] || NO) {
        [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:TYSO24H_FIRST_USE];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [self showHelpViewControllerAtFirstTimeUse];
    }
    
    
    
    
}

-(void)showHelpViewControllerAtFirstTimeUse {
    HelpViewController* help = [self.storyboard instantiateViewControllerWithIdentifier:@"HelpViewController"];
    UIViewController *navController = [[UINavigationController alloc]
                                       initWithRootViewController:help];
    
    
    
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_7_1) {
        // ios8 and later
        navController.modalPresentationStyle = UIModalPresentationOverFullScreen;
        
    } else {
        //ios7 and ealier
        navController.modalPresentationStyle = UIModalPresentationFullScreen;
    }
    
    
    
    [self presentViewController:navController animated:NO completion:nil];
    
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (NSUInteger)supportedInterfaceOrientations {
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        return UIInterfaceOrientationMaskAll;
    } else {
        return UIInterfaceOrientationMaskPortrait;
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        return YES;
    }
    return toInterfaceOrientation == UIInterfaceOrientationPortrait;
}

-(IBAction)onSettingsClick:(id)sender
{
    ZLog(@"click on settings");
    SettingsViewController *set = [self.storyboard instantiateViewControllerWithIdentifier:@"SettingsViewController"];
    
    
    UIViewController *navController = [[UINavigationController alloc]
                                       initWithRootViewController:set];
    
    
        
    [self presentViewController:navController animated:YES completion:nil];
    
//    NSString* keyReg = [[NSUserDefaults standardUserDefaults] objectForKey:REGISTRATION_DEVICE_TOKEN_KEY];
//    if(keyReg == nil) {
//        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:nil message:@"Hãy đăng nhập để tham gia thảo luận và bình chọn!!" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
//        
//        [alert show];
//        
//        return;
//    }
//    
//    
//    ChatViewController* set = [[ChatViewController alloc] initWithNibName:@"ChatViewController" bundle:nil];
//    [self presentViewController:set animated:YES completion:nil];
    
    
    

}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    
    
    SettingsViewController *set = [self.storyboard instantiateViewControllerWithIdentifier:@"SettingsViewController"];
    
        UIViewController *navController = [[UINavigationController alloc]
                                                       initWithRootViewController:set];

        [self presentViewController:navController animated:YES completion:nil];
    
//        [self.navigationController pushViewController:set animated:YES];
}


#pragma tableview

- (void)setupDataSource {
    self.dataSource = [NSMutableArray array];
//    for(int i=0; i<15; i++)
//        [self.dataSource addObject:[NSDate dateWithTimeIntervalSinceNow:-(i*90)]];
    
    self.hdrLiveView.userInteractionEnabled = YES;

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onHeaderLiveScoreViewTapped:)];
    tap.numberOfTapsRequired = 1;
    [self.hdrLiveView addGestureRecognizer:tap];
}

-(void)onHeaderLiveScoreViewTapped:(id)sender {
    if(self.filterType != 0) {
        self.filterType = 0;
        
        [self.fulltimeBtn setBackgroundImage:[UIImage imageNamed:@"ic_fulltime.png"] forState:UIControlStateNormal];
        [self.liveBtn setBackgroundImage:[UIImage imageNamed:@"ic_live.png"] forState:UIControlStateNormal];
        
        [self.tableView reloadData];
        
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{

    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return 1;
    } else {
    
        if(self.filterType == FILTER_FULLTIME_MATCH) {
            return self.listLivescoreKeys_FT.count;
        } else if(self.filterType == FILTER_LIVE_MATCH) {
            return self.listLivescoreKeys_Live.count;
        }else if(self.filterType == FILTER_QUICK_MENU && self.currCollection) {
            return self.currCollection.listLivescoreKeys.count;
        }else if(self.selectedDateIndex != FILTER_TODAY_MATCH && self.currCollection) {
            return self.currCollection.listLivescoreKeys.count;
        }
        
        
        return self.listLivescoreKeys.count;
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 27.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 96.0f;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        
        
        return self.listLivescore_Filter.count;
    } else {
    
    
        if(self.filterType == FILTER_FULLTIME_MATCH) {
            NSString *sortedKey = [self.listLivescoreKeys_FT objectAtIndex:section];
            NSArray *liveList = [self.listLivescore_FT objectForKey:sortedKey];
            
            return liveList.count;
        } else if(self.filterType == FILTER_LIVE_MATCH) {
            NSString *sortedKey = [self.listLivescoreKeys_Live objectAtIndex:section];
            NSArray *liveList = [self.listLivescore_Live objectForKey:sortedKey];
            
            return liveList.count;
        } else if(self.filterType == FILTER_QUICK_MENU && self.currCollection) {
            NSString *sortedKey = [self.currCollection.listLivescoreKeys objectAtIndex:section];
            NSArray *liveList = [self.currCollection.listLivescore objectForKey:sortedKey];
            
            return liveList.count;
        }
        else if(self.selectedDateIndex != FILTER_TODAY_MATCH && self.currCollection) {
            NSString *sortedKey = [self.currCollection.listLivescoreKeys objectAtIndex:section];
            NSArray *liveList = [self.currCollection.listLivescore objectForKey:sortedKey];
            
            return liveList.count;
        }
        else {
            NSString *sortedKey = [self.listLivescoreKeys objectAtIndex:section];
            NSArray *liveList = [self.listLivescore objectForKey:sortedKey];
            
            return liveList.count;
        }
    }
    
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {

    
    LiveScoreHeaderSection *view = [self.tableView dequeueReusableHeaderFooterViewWithIdentifier:@"LiveScoreHeaderSection"];
    NSString *sortedKey = nil;
    
    NSArray *liveList = nil;
    
    LivescoreModel *model = nil;
    
    if (self.tableView == self.searchDisplayController.searchResultsTableView) {
        return nil;
    } else {
        if(self.filterType == FILTER_FULLTIME_MATCH) {
            sortedKey = [self.listLivescoreKeys_FT objectAtIndex:section];
            liveList = [self.listLivescore_FT objectForKey:sortedKey];
            model = [liveList objectAtIndex:0];
        } else if(self.filterType == FILTER_LIVE_MATCH) {
            sortedKey = [self.listLivescoreKeys_Live objectAtIndex:section];
            liveList = [self.listLivescore_Live objectForKey:sortedKey];
            model = [liveList objectAtIndex:0];
        } else if(self.filterType == FILTER_QUICK_MENU && self.currCollection) {
            sortedKey = [self.currCollection.listLivescoreKeys objectAtIndex:section];
            liveList = [self.currCollection.listLivescore objectForKey:sortedKey];
            model = [liveList objectAtIndex:0];
        }else if(self.selectedDateIndex != FILTER_TODAY_MATCH && self.currCollection) {
            sortedKey = [self.currCollection.listLivescoreKeys objectAtIndex:section];
            liveList = [self.currCollection.listLivescore objectForKey:sortedKey];
            model = [liveList objectAtIndex:0];
        }
        else {
            sortedKey = [self.listLivescoreKeys objectAtIndex:section];
            liveList = [self.listLivescore objectForKey:sortedKey];
            model = [liveList objectAtIndex:0];
        }
    }
    

    view.aliasLabel.text = model.sTenGiai;
    
    view.pinView.hidden = NO;
    
    

    
    
    BDLiveGestureRecognizer* tap = [[BDLiveGestureRecognizer alloc] initWithTarget:self action:@selector(onBxhTap:)];
    tap.sTenGiai = view.aliasLabel.text;
    tap.iID_MaTran = sortedKey;
    tap.numberOfTapsRequired = 1;
    tap.logoGiaiUrl = model.sLogoGiai;
    view.bxhView.userInteractionEnabled = YES;
    [view.bxhView addGestureRecognizer:tap];
    
    
    
    BDLiveGestureRecognizer* pin_tap = [[BDLiveGestureRecognizer alloc] initWithTarget:self action:@selector(onPinTap:)];
    pin_tap.sTenGiai = view.aliasLabel.text;
    pin_tap.iID_MaTran = sortedKey;
    pin_tap.iID_MaGiai = [NSString stringWithFormat:@"%lu", model.iID_MaGiai];
    pin_tap.numberOfTapsRequired = 1;
    pin_tap.logoGiaiUrl = model.sLogoGiai;
    
    pin_tap.pinButton = view.pinImageView;

    view.pinView.userInteractionEnabled = YES;
    [view.pinView addGestureRecognizer:pin_tap];
    
    
    NSString* val1 = [[NSUserDefaults standardUserDefaults] objectForKey:pin_tap.iID_MaGiai];
    if(val1) {
        view.pinImageView.image = [UIImage imageNamed:@"ic_pinned.png"];
    } else {
        view.pinImageView.image = [UIImage imageNamed:@"ic_pin.png"];
    }
    
    
    
    
    if(model!= nil) {
    
        [self.manager downloadWithURL:[NSURL URLWithString:model.sLogoGiai]
                              options:0
                             progress:^(NSInteger receivedSize, NSInteger expectedSize)
         {
             // progression tracking code
         }
                completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished)
         {
             if (image)
             {
                 
                 [XSUtils adjustUIImageView:view.countryFlag image:image];
                 [view.countryFlag setImage:image];
                 
             }
         }];
    }

    
    return view;

        
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    LiveScoreTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:nib_LivescoreCell];
    
    [cell resetViewState]; // khanh add to reset view
    
    
    NSString *sortedKey = nil;
    NSArray *liveList = nil;
    LivescoreModel *model = nil;
    
    
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        
        model = [self.listLivescore_Filter objectAtIndex:indexPath.row];
    } else {
        if(self.filterType == FILTER_FULLTIME_MATCH) {
            sortedKey = [self.listLivescoreKeys_FT objectAtIndex:indexPath.section];
            liveList = [self.listLivescore_FT objectForKey:sortedKey];
            model = [liveList objectAtIndex:indexPath.row];
        } else if(self.filterType == FILTER_LIVE_MATCH) {
            sortedKey = [self.listLivescoreKeys_Live objectAtIndex:indexPath.section];
            liveList = [self.listLivescore_Live objectForKey:sortedKey];
            model = [liveList objectAtIndex:indexPath.row];
        }
        else if(self.filterType == FILTER_QUICK_MENU && self.currCollection) {
            sortedKey = [self.currCollection.listLivescoreKeys objectAtIndex:indexPath.section];
            liveList = [self.currCollection.listLivescore objectForKey:sortedKey];
            model = [liveList objectAtIndex:indexPath.row];
        }else if(self.selectedDateIndex != FILTER_TODAY_MATCH && self.currCollection) {
            sortedKey = [self.currCollection.listLivescoreKeys objectAtIndex:indexPath.section];
            liveList = [self.currCollection.listLivescore objectForKey:sortedKey];
            model = [liveList objectAtIndex:indexPath.row];
        }
        else {
            sortedKey = [self.listLivescoreKeys objectAtIndex:indexPath.section];
            liveList = [self.listLivescore objectForKey:sortedKey];
            model = [liveList objectAtIndex:indexPath.row];
        }
    }
    
    // ADD THE FOLLOWING LINES
//    if(bannerView == nil)
//    {
//        bannerView = [[STABannerView alloc] initWithSize:STA_AutoAdSize autoOrigin:STAAdOrigin_Top  withView:cell withDelegate:self];
//        [bannerView addSTABannerToCell:cell withIndexPath:indexPath atIntexPathRow:1 repeatEach:1];
//    }
    
    
    

    cell.matchModel = model;
    BDSwipeGestureRecognizer *swipeGesture = [[BDSwipeGestureRecognizer alloc]initWithTarget:self action:@selector(onCellSwipeGestureFired:)];
    swipeGesture.indexPath = indexPath;
    [cell addGestureRecognizer:swipeGesture];
    
    [cell.performanceInfo addTarget:self action:@selector(onPerformClick:) forControlEvents:UIControlEventTouchUpInside];
    cell.performanceInfo.model = model;
    
    [cell.compPredictor addTarget:self action:@selector(onComputerClick:) forControlEvents:UIControlEventTouchUpInside];
    cell.compPredictor.model = model;
    
    [cell.expertPredictor addTarget:self action:@selector(onExpertClick:) forControlEvents:UIControlEventTouchUpInside];
    cell.expertPredictor.model = model;
    
    
    // game du doan
    
    [cell.setbetButton addTarget:self action:@selector(onMoneyBagClick:) forControlEvents:UIControlEventTouchUpInside];
    cell.setbetButton.model = model;
    
    if (model.iTrangThai == 5 || model.iTrangThai == 8 || model.iTrangThai == 9 || model.iTrangThai == 15) {
        cell.setbetButton.alpha = 0.0f;
    }
    else
        cell.setbetButton.alpha = 1.0f;
    
    [cell.favouriteBtn addTarget:self action:@selector(onFavouriteClick:) forControlEvents:UIControlEventTouchUpInside];
    cell.favouriteBtn.model = model;

    LiveScoreTableViewCell* lastCell = (LiveScoreTableViewCell*)[self.tableView cellForRowAtIndexPath:indexPath];
    

    
    // render data now
    [self renderLivescoreDataForCell:cell model:model lastCell: lastCell];
    
    return cell;
}

-(void)onFavouriteClick:(BDButton*)sender {
    LivescoreModel *model = sender.model;
    model.isFavourite = !model.isFavourite;
    int favo = 0;
    NSString* matran = [NSString stringWithFormat:@"%lu", model.iID_MaTran];
    
    if (model.isFavourite) {
        [sender setBackgroundImage:[UIImage imageNamed:@"heart_fill.png"] forState:UIControlStateNormal];
        favo = 1;
        [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:matran];
    } else {
        [sender setBackgroundImage:[UIImage imageNamed:@"heart_hidden.png"] forState:UIControlStateNormal];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:matran];
    }
    
    
    // get device token
    NSString* deviceToken = (NSString*)[[NSUserDefaults standardUserDefaults] objectForKey:DEVICE_TOKEN_KEY];
    if(deviceToken!=nil) {
        [self submitFavouriteMatch:deviceToken matran:matran type:favo];
    }
    
}

-(void)onPerformClick:(BDButton*)sender
{
    LivescoreModel *model = sender.model;
    PViewController *p = [[PViewController alloc] initWithNibName:@"PViewController" bundle:nil];
    p.p_type = 0; // phong do
    p.model = model;
//    [self presentViewController:p animated:YES completion:nil];
    [self.navigationController pushViewController:p animated:YES];
    
}
-(void)onComputerClick:(BDButton*)sender
{
    LivescoreModel *model = sender.model;
    PViewController *p = [[PViewController alloc] initWithNibName:@"PViewController" bundle:nil];
    p.p_type = 1; // may tinh du doan
    p.model = model;
//    [self presentViewController:p animated:YES completion:nil];
    [self.navigationController pushViewController:p animated:YES];
    
}

-(void)onExpertClick:(BDButton*)sender
{

    LivescoreModel *model = sender.model;
    ExpertReview* exp = [[ExpertReview alloc] initWithNibName:@"ExpertReview" bundle:nil];
    exp.model = model;
    [self.navigationController pushViewController:exp animated:YES];
    
}

-(void)onMoneyBagClick:(BDButton*)sender
{
    
    LivescoreModel *model = sender.model;
    GamePredictorViewController *game = [[GamePredictorViewController alloc] initWithNibName:@"GamePredictorViewController" bundle:nil];
    game.selectedModel = model;
    [self.navigationController pushViewController:game animated:YES];
    
}

-(void)renderLivescoreDataForCell:(LiveScoreTableViewCell*)cell model:(LivescoreModel*)liveScoreModel lastCell:(LiveScoreTableViewCell*)lastCell
{
    [LiveScoreViewController updateLiveScoreTableViewCell:cell model:liveScoreModel];
    
    
    
    
    cell.iID_MaTran = liveScoreModel.iID_MaTran;
    
    cell.matchTimeLabel.text = [XSUtils toDayOfWeek:liveScoreModel.dThoiGianThiDau];
    
    
    
    if (YES||liveScoreModel.bGameDuDoan) {
        cell.keoLabel.text = [liveScoreModel get_sTyLe_ChapBong:liveScoreModel.sTyLe_ChapBong];
        cell.xLabel.text = liveScoreModel.sTyLe_ChauAu_Live;
        cell.uoLabel.text = liveScoreModel.sTyLe_TaiSuu_Live;
//        U/O: 2 3/4
//        1X2:1.37 - 4.80 - 9.50
    }



    //Trạng thái trận đấu: <=1:Chưa đá; 2,4: Đang đá; 3: HT; 5,8,9,15: FT; 6: Bù giờ; 7,14: Pens; 11: Hoãn;  12: CXĐ; 13: Dừng; 16: W.O
    if(liveScoreModel.iTrangThai == 2 || liveScoreModel.iTrangThai == 4 || liveScoreModel.iTrangThai == 3)  {
        // live
        [cell animateFlashLive];
        cell.liveLabel.hidden = NO;
        if(liveScoreModel.iTrangThai == 3) {

            cell.fullTimeLabel.text = @"HT";
            
        } else {
            cell.fullTimeLabel.text = [NSString stringWithFormat:@"%lu'",liveScoreModel.iCN_Phut];
        }
        
        //FT
        NSString* resultFT = [NSString stringWithFormat:@"%lu - %lu", (unsigned long)liveScoreModel.iCN_BanThang_DoiNha_FT, (unsigned long)liveScoreModel.iCN_BanThang_DoiKhach_FT];
        NSString* resultHT = [NSString stringWithFormat:@"HT %lu - %lu", (unsigned long)liveScoreModel.iCN_BanThang_DoiNha_HT, (unsigned long)liveScoreModel.iCN_BanThang_DoiKhach_HT];
        
        
//        if (lastCell != nil && lastCell.finishRetLabel.text != nil && [resultFT rangeOfString:lastCell.finishRetLabel.text].location == NSNotFound) {
//            // highlighted view
//            [XSUtils popupHighlightedView:cell.highlightedView];
//        } else if(lastCell!=nil && [lastCell.highlightedView isHidden] == NO) {
//            [XSUtils popupHighlightedView:cell.highlightedView];
//        }
        
        if (liveScoreModel.isHighlightedView) {
//            [XSUtils popupHighlightedView:cell.highlightedView];
            cell.highlightedView.hidden = NO;
            cell.highlightedView.alpha = 1.0f;
        } else {
            cell.highlightedView.hidden = YES;
            cell.highlightedView.alpha = 0.0f;
        }
        
        
        
        cell.finishRetLabel.text = resultFT;
        cell.halfTimeLabel.text = resultHT;
    } else if(liveScoreModel.iTrangThai <= 1) {
        // chua da
        cell.clockImg.hidden = NO;
        cell.fullTimeLabel.text = liveScoreModel.sThoiGian;
        cell.halfTimeLabel.hidden = YES;
        cell.finishRetLabel.hidden = YES;
        
        [cell stopAnimateFlashLive];
    } else if(liveScoreModel.iTrangThai == 5 || liveScoreModel.iTrangThai == 8 ||
              liveScoreModel.iTrangThai == 9 || liveScoreModel.iTrangThai == 15){
        //FT
        NSString* resultFT = @"";
        if (liveScoreModel.iTrangThai == 8) {
            resultFT = [NSString stringWithFormat:@"%lu - %lu", liveScoreModel.iCN_BanThang_DoiNha_ET, liveScoreModel.iCN_BanThang_DoiKhach_ET];
            cell.fullTimeLabel.text = @"AET";
            
        }
        else if (liveScoreModel.iTrangThai == 15 || liveScoreModel.iTrangThai == 9) {
            resultFT = [NSString stringWithFormat:@"%lu - %lu", liveScoreModel.iCN_BanThang_DoiNha_Pen, liveScoreModel.iCN_BanThang_DoiKhach_Pen];
            cell.fullTimeLabel.text = @"AP";
        }
        
        else {
            resultFT = [NSString stringWithFormat:@"%lu - %lu", liveScoreModel.iCN_BanThang_DoiNha_FT, liveScoreModel.iCN_BanThang_DoiKhach_FT];
        }
        
        NSString* resultHT = [NSString stringWithFormat:@"HT %lu - %lu", (unsigned long)liveScoreModel.iCN_BanThang_DoiNha_HT, (unsigned long)liveScoreModel.iCN_BanThang_DoiKhach_HT];
        
        cell.finishRetLabel.text = resultFT;
        cell.halfTimeLabel.text = resultHT;
        [cell stopAnimateFlashLive];
        
        
    } else if(liveScoreModel.iTrangThai == 6) {
        // extra time
        cell.fullTimeLabel.text = [NSString stringWithFormat:@"90' + %lu'",liveScoreModel.iPhutThem];
        cell.liveLabel.text = @"ET";
        
        NSString* resultFT = [NSString stringWithFormat:@"%lu - %lu", (unsigned long)liveScoreModel.iCN_BanThang_DoiNha_FT, (unsigned long)liveScoreModel.iCN_BanThang_DoiKhach_FT];
        NSString* resultHT = [NSString stringWithFormat:@"HT %lu - %lu", (unsigned long)liveScoreModel.iCN_BanThang_DoiNha_HT, (unsigned long)liveScoreModel.iCN_BanThang_DoiKhach_HT];
        
        cell.finishRetLabel.text = resultFT;
        cell.halfTimeLabel.text = resultHT;
    }else if(liveScoreModel.iTrangThai == 7 || liveScoreModel.iTrangThai == 14) {
        // Pens
        cell.fullTimeLabel.text = @"Pens";
        NSString* resultFT = [NSString stringWithFormat:@"%lu - %lu", (unsigned long)liveScoreModel.iCN_BanThang_DoiNha_FT, (unsigned long)liveScoreModel.iCN_BanThang_DoiKhach_FT];
        NSString* resultHT = [NSString stringWithFormat:@"HT %lu - %lu", (unsigned long)liveScoreModel.iCN_BanThang_DoiNha_HT, (unsigned long)liveScoreModel.iCN_BanThang_DoiKhach_HT];
        
        cell.finishRetLabel.text = resultFT;
        cell.halfTimeLabel.text = resultHT;
    } else if(liveScoreModel.iTrangThai == 11) {
        // extra time
        NSString* localizedTxt = [NSString stringWithFormat:@"%@", NSLocalizedString(@"livescore-post-txt", @"Hoãn")];
        
        cell.fullTimeLabel.text = localizedTxt;
        
        cell.clockImg.hidden = YES;
//        cell.fullTimeLabel.text = model.sThoiGian;
        cell.halfTimeLabel.hidden = YES;
        cell.finishRetLabel.text = @"P - P";
        [cell stopAnimateFlashLive];
    } else if(liveScoreModel.iTrangThai == 12 || liveScoreModel.iTrangThai == 99) {
        // extra time
        cell.fullTimeLabel.text = @"CXĐ";
        
        cell.clockImg.hidden = NO;
        cell.fullTimeLabel.text = liveScoreModel.sThoiGian;
        cell.halfTimeLabel.hidden = YES;
        cell.finishRetLabel.hidden = YES;
        [cell stopAnimateFlashLive];
    } else if(liveScoreModel.iTrangThai == 13) {
        // extra time
        cell.fullTimeLabel.text = @"Dừng";
        
        cell.clockImg.hidden = NO;
        cell.fullTimeLabel.text = liveScoreModel.sThoiGian;
        cell.halfTimeLabel.hidden = YES;
        cell.finishRetLabel.hidden = YES;
        [cell stopAnimateFlashLive];
    }else if(liveScoreModel.iTrangThai == 16) {
        // extra time
        cell.fullTimeLabel.text = @"W.O";
        cell.clockImg.hidden = NO;
        cell.fullTimeLabel.text = liveScoreModel.sThoiGian;
        cell.halfTimeLabel.hidden = YES;
        cell.finishRetLabel.hidden = YES;
        [cell stopAnimateFlashLive];
    } else {
        // stop flash live
        [cell stopAnimateFlashLive];
    }
    
    if(liveScoreModel.bNhanDinhChuyenGia) {
        cell.expertPredictor.hidden = NO;
    }
    if(liveScoreModel.bMayTinhDuDoan) {
        cell.compPredictor.hidden = NO;
    }
    
    if(liveScoreModel.isFavourite) {
        cell.favouriteBtn.hidden = NO;
        [cell.favouriteBtn setBackgroundImage:[UIImage imageNamed:@"heart_fill.png"] forState:UIControlStateNormal];
    }
    
    if(liveScoreModel.bGameDuDoan) {
        cell.setbetButton.hidden = NO;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    //iID_MaTran
    
    LiveScoreTableViewCell *cell = (LiveScoreTableViewCell*)[tableView cellForRowAtIndexPath:indexPath];
    LivescoreModel* model = cell.matchModel;
    DetailMatchController *detail = [[DetailMatchController alloc] initWithNibName:@"DetailMatchController" bundle:nil];
    detail.iID_MaTran = model.iID_MaTran;
    detail.matchModel = model;
    [detail fetchMatchDetailById];
    [self.navigationController pushViewController:detail animated:YES];
}



- (void)insertRowAtTop {
    __weak LiveScoreViewController *weakSelf = self;
    
    int64_t delayInSeconds = 1.3;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [weakSelf.tableView beginUpdates];
        [weakSelf.dataSource insertObject:[NSDate date] atIndex:0];
        [weakSelf.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationBottom];
        [weakSelf.tableView endUpdates];
        
        [weakSelf.tableView.pullToRefreshView stopAnimating];
    });
}


- (void)insertRowAtBottom {
    

    if (self.selectedDateIndex == FILTER_TODAY_MATCH) {
        self.isAutoUpdate = NO;
        [self fetchLivescoreList];
    } else {
        __weak LiveScoreViewController *weakSelf = self;
        [weakSelf.tableView.infiniteScrollingView stopAnimating];
    }
//    __weak LiveScoreViewController *weakSelf = self;
//    
//    int64_t delayInSeconds = 1.8;
//    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
//    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
//        [weakSelf.tableView beginUpdates];
////        [weakSelf.dataSource addObject:[weakSelf.dataSource.lastObject dateByAddingTimeInterval:-90]];
//        
////        for(int i=0;i<weakSelf.tableView.numberOfSections;++i) {
////            [weakSelf.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:weakSelf.dataSource.count-1 inSection:weakSelf.tableView.numberOfSections-1]] withRowAnimation:UITableViewRowAnimationTop];
////        }
//        
//        [self fetchLivescoreList];
//        
//        [weakSelf.tableView endUpdates];
//
//
//        
////        [weakSelf.tableView.infiniteScrollingView stopAnimating];
//    });
}


-(void)showRefreshIcon
{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.loadingIndicator.hidden = NO;
        self.myIndicator.hidden = YES;
    });
}

-(void)onSoapError:(NSError *)error
{
    ZLog(@"soap error: %@", error);
    
    [self showRefreshIcon];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kBDLive_OnLivescoreData_LoadError object:nil];
}
-(void)onSoapDidFinishLoading:(NSData *)data
{
    [self showRefreshIcon];
    
    @synchronized(_autoLockObj)
    {
    
    @try {
        NSString* xmlData = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        
        if ([xmlData rangeOfString:@"<wsFootBall_GetLichThiDau_LiveScoreResult>"].location != NSNotFound) {
            // handle game du doan
            [self handle_wsFootBall_GetLichThiDau_LiveScoreResult:xmlData];
            return;
        } else if ([xmlData rangeOfString:@"<wsFootBall_Menu_ChonNhanhResult>"].location != NSNotFound) {
            // handle wsFootBall_Menu_ChonNhanhResult
            [self handle_wsFootBall_Menu_ChonNhanhResult:xmlData];
            return;
        } else if ([xmlData rangeOfString:@"<wsFootBall_LiveScore_VongDauResult>"].location != NSNotFound) {
            // handle wsFootBall_Menu_ChonNhanhResult
            [self handle_wsFootBall_VongDauResult:xmlData];
            return;
        }
        

        
        
        
        NSString* jsonStr = [[xmlData componentsSeparatedByString:@"<wsFootBall_LivesResult>"] objectAtIndex:1];
        jsonStr = [[jsonStr componentsSeparatedByString:@"</wsFootBall_LivesResult>"] objectAtIndex:0];
        
        ZLog(@"jsonStr data: %@", jsonStr);
        
        
        // parse data
        NSData* dataJson = [jsonStr dataUsingEncoding:NSUTF8StringEncoding];
        NSError* error = nil;
        
        NSArray *bdDict = [NSJSONSerialization JSONObjectWithData:dataJson options:NSJSONReadingMutableContainers error:&error];
        
        if(error) {
            ZLog(@"error occured: %@", error);
            return;
        } else {
            
            
            if(self.isReloadData) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.tableView.scrollEnabled = NO;
                });
                [self.listLivescore removeAllObjects];
                [self.listLivescoreKeys removeAllObjects];
            }
            
            self.isReloadData = NO;
            
            NSString* rootUrlImg = nil;
            
            
            long currentTime = [[NSDate date] timeIntervalSince1970];
            

            for(int i=0;i<bdDict.count;++i) {
                NSDictionary* dict = [bdDict objectAtIndex:i];
                
//                NSString *tmp_rootUrlImg = [dict objectForKey:@"rootUrl"];
//                
//                
//                if(tmp_rootUrlImg && rootUrlImg == nil) {
//                    rootUrlImg = tmp_rootUrlImg;
//                    [[NSUserDefaults standardUserDefaults] setObject:rootUrlImg forKey:@"ROOT_URL_IMAGE"];
//                    continue;
//                }
                

                
                LivescoreModel *model = [LivescoreModel new];
                
                
               
                NSString* matchTime = [dict objectForKey:@"dThoiGianThiDau"];
                matchTime = [matchTime stringByReplacingOccurrencesOfString:@"/Date(" withString:@""];
                matchTime = [matchTime stringByReplacingOccurrencesOfString:@")/" withString:@""];
                long dateLong =[matchTime integerValue]/1000;
                
                
                dateLong = [(NSNumber*)[dict objectForKey:@"iC0"] longValue];
                
                model.iC0 = dateLong;
                model.iC1 = [(NSNumber*)[dict objectForKey:@"iC1"] longValue];
                model.iC2 = [(NSNumber*)[dict objectForKey:@"iC2"] longValue];
                model.iSoPhut1Hiep = [(NSNumber*)[dict objectForKey:@"iSoPhut1Hiep"] longValue];
                

                NSDate *date = [NSDate dateWithTimeIntervalSince1970:dateLong];
                model.dThoiGianThiDau = date;
                
                NSDateFormatter *dateFormatter=[[NSDateFormatter alloc]init];
                [dateFormatter setDateFormat:@"HH:mm"];
                
                

                
                model.sThoiGian = [dict objectForKey:@"sThoiGian"];
                model.sThoiGian = [dateFormatter stringFromDate:date];
                model.sTenDoiNha = [dict objectForKey:@"sTenDoiNha"];
                model.sTenDoiKhach = [dict objectForKey:@"sTenDoiKhach"];
                model.sTenGiai = [dict objectForKey:@"sTenGiai"];
                
                model.sLogoQuocGia = [dict objectForKey:@"sLogoQuocGia"];
                model.sLogoDoiNha = [dict objectForKey:@"sLogoDoiNha"];
                model.sLogoDoiKhach = [dict objectForKey:@"sLogoDoiKhach"];
                model.sLogoGiai = [dict objectForKey:@"sLogoGiai"];
                
                model.sDoiNha_BXH = [dict objectForKey:@"sDoiNha_BXH"];
                model.sDoiKhach_BXH = [dict objectForKey:@"sDoiKhach_BXH"];
                
                //pens
                model.iCN_BanThang_DoiNha_Pen = [(NSNumber*)[dict objectForKey:@"iCN_BanThang_DoiNha_Pen"] integerValue];
                model.iCN_BanThang_DoiKhach_Pen = [(NSNumber*)[dict objectForKey:@"iCN_BanThang_DoiKhach_Pen"] integerValue];
                
                
                model.iID_MaGiai = [(NSNumber*)[dict objectForKey:@"iID_MaGiai"] integerValue];
                model.iTrangThai = [(NSNumber*)[dict objectForKey:@"iTrangThai"] intValue];
                
                //iID_MaDoiNha, iID_MaDoiKhach
                model.iID_MaDoiNha = [(NSNumber*)[dict objectForKey:@"iID_MaDoiNha"] integerValue];
                model.iID_MaDoiKhach = [(NSNumber*)[dict objectForKey:@"iID_MaDoiKhach"] integerValue];
                model.iID_MaQuocGia = [(NSNumber*)[dict objectForKey:@"iID_MaQuocGia"] integerValue];
                
                
                // get logo new
//                model.sLogoQuocGia = [NSString stringWithFormat:@"%@/Uploads/App/c-%d.png", rootUrlImg,model.iID_MaQuocGia];
//                model.sLogoDoiNha = [NSString stringWithFormat:@"%@/Uploads/App/fc-%d.png", rootUrlImg,model.iID_MaDoiNha];
//                model.sLogoDoiKhach = [NSString stringWithFormat:@"%@/Uploads/App/fc-%d.png", rootUrlImg,model.iID_MaDoiKhach];
//                model.sLogoGiai = [NSString stringWithFormat:@"%@/Uploads/App/l-%d.png", rootUrlImg,model.iID_MaGiai];
                
                
                //sMaDoiNha, sMaDoiKhach
                model.sMaDoiNha = [dict objectForKey:@"sMaDoiNha"];
                model.sMaDoiKhach = [dict objectForKey:@"sMaDoiKhach"];
                
                // may tinh du doan va nhan dinh chuyen gia
                model.bMayTinhDuDoan = NO;
                model.bNhanDinhChuyenGia = NO;
                model.bNhanDinhChuyenGia = [[dict objectForKey:@"bNhanDinhChuyenGia"] boolValue];
                model.bMayTinhDuDoan = [[dict objectForKey:@"bMayTinhDuDoan"] boolValue];
                
                model.bGameDuDoan = [[dict objectForKey:@"bGameDuDoan"] boolValue];
                
                // keo game du doan
                model.sTyLe_ChapBong = [dict objectForKey:@"sTyLe_ChapBong"];
                
                model.sTyLe_ChauAu = [dict objectForKey:@"sTyLe_ChauAu"];
                model.sTyLe_TaiSuu = [dict objectForKey:@"sTyLe_TaiSuu"];
                
                
                if (model.iTrangThai == 5 ||
                    model.iTrangThai == 8 ||
                    model.iTrangThai == 9 ||
                    model.iTrangThai == 15) {
                    
                    model.sTyLe_ChapBong = [dict objectForKey:@"sTyLe_ChapBong_DauTran"];
                    model.sTyLe_ChauAu = [dict objectForKey:@"sTyLe_ChauAu_DauTran"];
                    model.sTyLe_TaiSuu = [dict objectForKey:@"sTyLe_TaiSuu_DauTran"];
                }
                
                model.sTyLe_ChauAu_Live = [model get_sTyLe_ChapBong_ChauAu_Live:model.sTyLe_ChauAu];
                model.sTyLe_TaiSuu_Live = [model get_sTyLe_ChapBong_TaiSuu_Live:model.sTyLe_TaiSuu];
                // end keo ty le
                
                
                
                
                model.iCN_Phut = [(NSNumber*)[dict objectForKey:@"iCN_Phut"] integerValue];
                model.iPhutThem = [(NSNumber*)[dict objectForKey:@"iPhutThem"] integerValue];
                
                
                
                
                
                model.iCN_BanThang_DoiKhach_HT = [(NSNumber*)[dict objectForKey:@"iCN_BanThang_DoiKhach_HT"] integerValue];
                model.iCN_BanThang_DoiNha_HT = [(NSNumber*)[dict objectForKey:@"iCN_BanThang_DoiNha_HT"] integerValue];
                model.iCN_BanThang_DoiNha_FT = [(NSNumber*)[dict objectForKey:@"iCN_BanThang_DoiNha_FT"] integerValue];
                model.iCN_BanThang_DoiKhach_FT = [(NSNumber*)[dict objectForKey:@"iCN_BanThang_DoiKhach_FT"] integerValue];
                model.iID_MaTran = [(NSNumber*)[dict objectForKey:@"iID_MaTran"] integerValue];
                
                
                model.iCN_BanThang_DoiNha_ET = [(NSNumber*)[dict objectForKey:@"iCN_BanThang_DoiNha_ET"] integerValue];
                model.iCN_BanThang_DoiKhach_ET = [(NSNumber*)[dict objectForKey:@"iCN_BanThang_DoiKhach_ET"] integerValue];
                
                [model adjustImageURLForReview];
                
                NSString* matran = [NSString stringWithFormat:@"%lu", model.iID_MaTran];
                NSNumber *number = (NSNumber *)[[NSUserDefaults standardUserDefaults] objectForKey:matran];
                if(number != nil && [number intValue] == 1) {
                    model.isFavourite = YES;
                } else {
                    model.isFavourite = NO;
                }

                [LiveScoreViewController update_iCN_Phut_By_LivescoreModel:model c0:currentTime]; // update iCN_Phut by local time
                
                ZLog(@"iID_MaGiai: %lu", (unsigned long)model.iID_MaGiai);
                
                
                //totalpage
                @try {
                    self.totalPage = [[dict objectForKey:@"totalpage"] intValue];
                }@catch(NSException *ex){
                    self.totalPage = 1;
                }
                
                
                NSString* iID_MaGiai_Str = [NSString stringWithFormat:@"%lu", (unsigned long)model.iID_MaGiai];
                
                NSString* iID_MaGiai_Pinned = [[NSUserDefaults standardUserDefaults] objectForKey:iID_MaGiai_Str];
                
                NSMutableArray* list = [self.listLivescore objectForKey:iID_MaGiai_Str];
                if(list == nil) {
                    // no record
                    list = [NSMutableArray new];
                    if(iID_MaGiai_Pinned) {
                        [self.listLivescoreKeys insertObject:iID_MaGiai_Str atIndex:0];
                    } else {
                        [self.listLivescoreKeys addObject:iID_MaGiai_Str];
                    }
                    
                } else {
                    // existed, update data then
                    LivescoreModel* oldModel = [self findModelByMaTran:list iID_MaTran:model.iID_MaTran];
                    if(oldModel != nil) {
                        ZLog(@"remove old model: %@", oldModel);
                        
                        if (oldModel.iCN_BanThang_DoiNha_FT != model.iCN_BanThang_DoiNha_FT ||
                            oldModel.iCN_BanThang_DoiKhach_FT != model.iCN_BanThang_DoiKhach_FT) {
                            model.isHighlightedView = YES;
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [NSTimer scheduledTimerWithTimeInterval:SCORE_CHANGED_VALUE_INTERVAL target:self selector:@selector(onScoreHighlightFired:) userInfo:@{ @"iID_MaGiai":iID_MaGiai_Str, @"iID_MaTran" : [NSString stringWithFormat:@"%d", model.iID_MaTran]} repeats:NO];
                            });
                        }
                        
                        if(oldModel.isHighlightedView) {
                            model.isHighlightedView = YES;
                        }
                        
                        [list removeObject:oldModel];
                    }
                    
                }
                [list addObject:model];
                
                [self.listLivescore setObject:list forKey:iID_MaGiai_Str];
                
            }

            dispatch_async(dispatch_get_main_queue(), ^{

                ZLog(@"number of sections: %lu", (unsigned long)self.listLivescore.count);
//                [self.tableView reloadData];
                
                self.tableView.scrollEnabled = YES;

                [[NSNotificationCenter defaultCenter] postNotificationName:kBDLive_OnLivescoreData_LoadDone object:nil];
            });
            
            
            
        }
    }@catch(NSException *ex) {
        
        [self onSoapError:nil];
    }
    
    
    } // end autoLockObj
}

-(LivescoreModel*) findModelByMaTran:(NSMutableArray*) list iID_MaTran:(NSUInteger)iID_MaTran
{
    for(NSUInteger i=0;i<list.count;i++) {
        LivescoreModel* model = [list objectAtIndex:i];
        if(model.iID_MaTran == iID_MaTran) {
            
            return model;
        }
    }
    
    return nil;
}


-(void) retryFetchLivescoreList
{
    self.currPage--;
    
    [self fetchLivescoreList];
    

//    [self.tableView reloadRowsAtIndexPaths:[self.tableView indexPathsForVisibleRows] withRowAnimation:UITableViewRowAnimationNone];
    

}

-(void)fetchLich_LivescoreList {
    dispatch_queue_t myQueue = dispatch_queue_create("com.ptech.bdlive_lich", NULL);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), myQueue, ^{
        
        
        NSInteger offset = [[NSTimeZone defaultTimeZone] secondsFromGMTForDate: [NSDate date]];
        NSTimeZone *timeZone = [NSTimeZone timeZoneForSecondsFromGMT: offset];
        
        NSString* timeZoneName = [timeZone name];
        timeZoneName = [timeZoneName stringByReplacingOccurrencesOfString:@"GMT" withString:@""];
        
        
        
        int timeZoneNameInt = [timeZoneName intValue];
        
        int hh = (abs(timeZoneNameInt) / 100) * (timeZoneNameInt/timeZoneNameInt);
        int mm = (abs(timeZoneNameInt) % 100) * (timeZoneNameInt/timeZoneNameInt);
        
        
        NSDate* today = [NSDate date];
        NSDate* getdate = [XSUtils getDateByGivenDateInterval:today dateInterval:(self.selectedDateIndex - 2)];
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
        [dateFormatter setDateFormat:@"dd/MM/yyyy"];

        
        
        
        int dateInterval = (int)(self.selectedDateIndex - 2);
        long currentTime = [[XSUtils getDateByGivenDateInterval:[NSDate date] dateInterval:dateInterval] timeIntervalSince1970];
        
        
        [self.soapHandler sendSOAPRequest:[PresetSOAPMessage get_wsFootBall_GetLichThiDau_LiveScore_SoapMessage:[NSString stringWithFormat:@"%lu", currentTime] HH:[NSString stringWithFormat:@"%d", hh] MM:[NSString stringWithFormat:@"%d", mm] getdate:[dateFormatter stringFromDate:getdate] today:[dateFormatter stringFromDate:today]] soapAction:[PresetSOAPMessage get_wsFootBall_GetLichThiDau_LiveScore_SoapAction]];
        
        
    });
}

-(void) fetchLivescoreList
{
//    if(self.isLoadingData) {
//        ZLog(@"data is being loaded, just wait until it finish");
//        return;
//    }
    self.isLoadingData = YES;
    dispatch_queue_t myQueue = dispatch_queue_create("com.ptech.bdlive", NULL);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), myQueue, ^{
        if(self.currPage >= self.totalPage) {
            dispatch_async(dispatch_get_main_queue(), ^{
//                [self.tableView reloadRowsAtIndexPaths:[self.tableView indexPathsForVisibleRows] withRowAnimation:UITableViewRowAnimationNone];
                [self.tableView.infiniteScrollingView stopAnimating];
            });
            
            return;
        }
        self.currPage++;
        ZLog(@"loading page number: %d/%d", self.currPage, self.totalPage);
        
        
        
        
        [self.soapHandler sendSOAPRequest:[PresetSOAPMessage getListLivescoreSoapMessage:self.currPage] soapAction:[PresetSOAPMessage getListLivescoreSoapAction]];
        

    });
}

-(void)updateVisibleCells:(NSArray*)paths
{
    @try {

        for (NSIndexPath *path in paths) {
            LiveScoreTableViewCell *cell = (LiveScoreTableViewCell*)[self.tableView cellForRowAtIndexPath:path];
            
            NSString* dictKey = [self.listLivescoreKeys objectAtIndex:path.section];
            
            
            LivescoreModel *model = [self findModelByMaTran:[self.listLivescore objectForKey:dictKey] iID_MaTran:cell.iID_MaTran];
            if(model != nil) {
                
                if(model.iTrangThai == 2 || model.iTrangThai == 4 || model.iTrangThai == 3)  {
                    // only live match will be updated automatically
                    ZLog(@"update data for visible cells here");
                    
                    [self renderLivescoreDataForCell:cell model:model lastCell:cell];
                }
                
            }
        }
    }@catch(NSException *ex) {
        ZLog(@"exception: %@", ex);
    }
}

-(void)onNotifyDBLivescoreDataLoadDone
{
    __weak LiveScoreViewController *weakSelf = self;
    ZLog(@"[livescore] >> load data done");
    self.isLoadingData = NO;
    dispatch_async(dispatch_get_main_queue(), ^{
        @try{
            [weakSelf.tableView.infiniteScrollingView stopAnimating];
            [weakSelf.tableView reloadData];
            
        }@catch(NSException *ex) {
            ZLog(@"error: %@", ex);
        }
        
//        [weakSelf.tableView beginUpdates];
//        [weakSelf.tableView reloadRowsAtIndexPaths:[weakSelf.tableView indexPathsForVisibleRows] withRowAnimation:UITableViewRowAnimationNone];
//        [weakSelf.tableView endUpdates];
        
        
        
    });
    
}

-(void)onNotifyDBLivescoreDataLoadError
{
    ZLog(@"[livescore] >> load data error");
    self.isLoadingData = NO;
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString* localizeMsg = [NSString stringWithFormat:@"     %@", NSLocalizedString(@"alert-load-data-error.text", @"Lỗi tải dữ liệu")];
        
        NSString* localize_message = [NSString stringWithFormat:@"     %@", NSLocalizedString(@"alert-network-error.text", kBDLive_OnLoadDataError_Message)];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:localizeMsg message:localize_message delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];        [alert show];
    });
}

-(void) addNotification
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNotifyDBLivescoreDataLoadDone) name:kBDLive_OnLivescoreData_LoadDone object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNotifyDBLivescoreDataLoadError) name:kBDLive_OnLivescoreData_LoadError object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNotifyAppDidBecomeActive) name:kAppDidBecomeActive object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNotifyAppReceiveRemoteNotification:) name:kAppDidReceiveRemoteNotification object:nil];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleAppEnteringForeground) name:UIApplicationWillEnterForegroundNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleAppWillResignActiveNotification) name:UIApplicationWillResignActiveNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleHomeClickNotification) name:@"HOME_CLICKED" object:nil];
    
    
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
//    [center addObserver:self selector:@selector(didShow) name:UIKeyboardDidShowNotification object:nil];
    [center addObserver:self selector:@selector(searchBarKeyboardDidHide) name:UIKeyboardWillHideNotification object:nil];

    
    
    
}

-(void) removeNotification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:kBDLive_OnLivescoreData_LoadDone
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:kBDLive_OnLivescoreData_LoadError
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:kAppDidBecomeActive
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:kAppDidReceiveRemoteNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationWillEnterForegroundNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationWillResignActiveNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"HOME_CLICKED"
                                                  object:nil];
}

-(void)onNotifyAppReceiveRemoteNotification:(NSDictionary*)userInfo
{
//    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    ZLog(@"onNotifyAppReceiveRemoteNotification: Livescore screen");
    
    if(self.rdv_tabBarController.selectedIndex != 2){
        [self.rdv_tabBarController setSelectedIndex:2];
    } else {
        [[NSNotificationCenter defaultCenter] postNotificationName:kAppShouldReloadFavouriteList object:nil userInfo:userInfo];
    }
    
    
    
    
}

-(void)handleAppEnteringForeground
{
    ZLog(@"handleAppEnteringForeground");
//    self.isForeground = YES;
}

-(void)handleAppWillResignActiveNotification
{
    ZLog(@"handleAppWillResignActiveNotification");
    self.isForeground = NO;
}

-(void)onPinTap:(BDLiveGestureRecognizer*) sender {

    NSString* iID_MaTran = sender.iID_MaTran;

    NSString* iID_MaGiai = sender.iID_MaGiai;
    NSString* imageNamed = @"ic_pin.png";
    NSString* val1 = [[NSUserDefaults standardUserDefaults] objectForKey:iID_MaGiai];
    if (val1 == nil) {
        [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:iID_MaGiai];
        imageNamed = @"ic_pinned.png";
    } else {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:iID_MaGiai];
    }
    
    
    [sender.pinButton setImage:[UIImage imageNamed:imageNamed]];
    
    
    [self reorderLiveScoreList];
    
    
    [self.tableView reloadData];
    self.tableView.contentOffset = CGPointMake(0, 0);
}

-(void)reorderLiveScoreList {
    NSMutableArray* newList = [NSMutableArray new];
    for(int i=0;i<self.listLivescoreKeys.count;i++) {
        NSString* key =  [self.listLivescoreKeys objectAtIndex:i];
        NSString* iID_MaGiai_Pinned = [[NSUserDefaults standardUserDefaults] objectForKey:key];
        if(iID_MaGiai_Pinned) {
            [newList insertObject:key atIndex:0];
        } else {
            [newList addObject:key];
        }
    }
    [self.listLivescoreKeys removeAllObjects];
    
    
    [self.listLivescoreKeys addObjectsFromArray:newList];
}

-(void)onBxhTap:(BDLiveGestureRecognizer*) sender
{
    
    NSString* sTenGiai = sender.sTenGiai;
    NSString* iID_MaTran = sender.iID_MaTran;
    NSString* logoGiaiUrl = sender.logoGiaiUrl;
    
    ZLog(@"retreiving data for bxh: %@", sTenGiai);
    NSArray* list = [self.listLivescore objectForKey:iID_MaTran];
    LivescoreModel* model = [list objectAtIndex:0];
    if(model != nil) {
        NSString* iID_MaGiai = [NSString stringWithFormat:@"%lu", model.iID_MaGiai];
        [self fetchBxhByID:iID_MaGiai sTenGiai:sTenGiai logoGiaiUrl:logoGiaiUrl];
    }
    
    
}

-(void) onNotifyAppDidBecomeActive
{
    ZLog(@"[onNotifyAppDidBecomeActive]");
    
    NSDate *currentTime = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd hh:mm:ss"];
    NSString *last_time = [[NSUserDefaults standardUserDefaults] objectForKey:@"TySo24h_LastInBackground"];
    
    if (last_time==nil) {
        ZLog(@"last_time is nil, dont need to compute anything, just auto refresh now");
        [self onAutoRefreshLivescoreData:nil];
        return;
    }
    
    NSDate *lastTime = [dateFormatter dateFromString:last_time];
    
    
    NSTimeInterval distanceBetweenDates = [currentTime timeIntervalSinceDate:lastTime];
    double secondsInAnHour = 3600;
    NSInteger hoursBetweenDates = distanceBetweenDates / secondsInAnHour;
    
    if (distanceBetweenDates > 60*2) {
        // if app's in background since over 20 minutes before, have to reload all
        [self onRefreshTouch:nil];
        ZLog(@"if app's in background since over 20 minutes before, have to reload all");
    } else {
        [self onAutoRefreshLivescoreData:nil];
    }
    
    
    
}

-(void) fetchBxhByID:(NSString*)iID_MaGiai sTenGiai:(NSString*)sTenGiai logoGiaiUrl:(NSString*)logoGiaiUrl
{
    ZLog(@"iID_MaGiai: %@", iID_MaGiai);
    StatsViewController* bxh = [self.storyboard instantiateViewControllerWithIdentifier:@"StatsViewController"];
    bxh.iID_MaGiai = iID_MaGiai;
    bxh.nameBxh = sTenGiai;
    bxh.logoBxh = logoGiaiUrl;
    
    [bxh fetchBxhListById];
    [self.navigationController pushViewController:bxh animated:YES];
}

-(void)onCellSwipeGestureFired:(BDSwipeGestureRecognizer *)gesture
{
    LiveScoreTableViewCell* cell = nil;
    if (self.isSearching) {


        
        cell = (LiveScoreTableViewCell*)[self.searchDisplayController.searchResultsTableView cellForRowAtIndexPath:gesture.indexPath];
    } else {
        cell = (LiveScoreTableViewCell*)[self.tableView cellForRowAtIndexPath:gesture.indexPath];
    }
    

    
    LivescoreModel* model = ((LivescoreModel*)cell.matchModel);
    NSString* matran = [NSString stringWithFormat:@"%lu", ((LivescoreModel*)cell.matchModel).iID_MaTran];
    if (gesture.direction == UISwipeGestureRecognizerDirectionRight)
    {
        // mark as favourite
        int favo = model.isFavourite ? 0 : 1;
        
        
        
        [[NSUserDefaults standardUserDefaults]
         setObject:[NSNumber numberWithInt:favo] forKey:matran];
        
        
        
        
        if(favo != 1) {
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:matran];
        }
        
        // get device token
        NSString* deviceToken = (NSString*)[[NSUserDefaults standardUserDefaults] objectForKey:DEVICE_TOKEN_KEY];
        if(deviceToken!=nil) {
            [self submitFavouriteMatch:deviceToken matran:matran type:favo];
        }
        
        ((LivescoreModel*)cell.matchModel).isFavourite = (favo==1 ? YES : NO);
        
        
        CATransition *animation = [CATransition animation];
        animation.type = kCATransitionFromLeft;
        animation.duration = 0.7;
        [cell.favouriteBtn.layer addAnimation:animation forKey:nil];
        
        
        cell.favouriteBtn.hidden = (favo==1 ? NO : YES);
        if (!cell.favouriteBtn.hidden) {
            [cell.favouriteBtn setBackgroundImage:[UIImage imageNamed:@"heart_fill.png"] forState:UIControlStateNormal];
        } else {
            cell.favouriteBtn.hidden = NO;
            [cell.favouriteBtn setBackgroundImage:[UIImage imageNamed:@"heart_hidden.png"] forState:UIControlStateNormal];
        }
    }
//    else if(gesture.direction == UISwipeGestureRecognizerDirectionLeft) {
//        // unmark favourite
//        [[NSUserDefaults standardUserDefaults]
//         setObject:[NSNumber numberWithInt:0] forKey:matran];
//        ((LivescoreModel*)cell.matchModel).isFavourite = NO;
//        cell.favouriteBtn.hidden = YES;
//    }
}

-(void)onAutoRefreshLivescoreData:(id)sender
{
//    if (YES) {
//        return;
//    }
    ZLog(@"auto refresh called with current page: %d", self.currPage);
    dispatch_queue_t myQueue = dispatch_queue_create("com.ptech.bdlive", NULL);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), myQueue, ^{
        
            
        self.isAutoUpdate = YES;
        if([UIApplication sharedApplication].applicationState == UIApplicationStateBackground) {
            ZLog(@"app is background now, dont need to update");
        } else {
//            for(int i=1;i<=self.currPage;++i) {
//                [self.autoSoapHandler sendAutoSOAPRequest:[PresetSOAPMessage getListLivescoreSoapMessage:i] soapAction:[PresetSOAPMessage getListLivescoreSoapAction]];
//                
//            }
            
            
            [self.autoSoapHandler sendAutoSOAPRequest:[PresetSOAPMessage get_wsFootBall_Livescore_TyLe_Message] soapAction:[PresetSOAPMessage get_wsFootBall_Livescore_TyLe_SoapAction]];
            
            
            [self.autoSoapHandler sendAutoSOAPRequest:[PresetSOAPMessage get_wsFootBall_Livescore_SuKien_Message] soapAction:[PresetSOAPMessage get_wsFootBall_Livescore_SuKien_SoapAction]];
            
            
            
            
        }
        
        
        
        
    });
    
    
//    dispatch_queue_t myQueue2 = dispatch_queue_create("com.ptech.bdlive", NULL);
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), myQueue2, ^{
//        if([UIApplication sharedApplication].applicationState == UIApplicationStateBackground) {
//            ZLog(@"app is background now, dont need to update");
//        } else {
//            
//            [self.autoSoapHandler sendAutoSOAPRequest:[PresetSOAPMessage get_wsFootBall_Livescore_TyLe_Message] soapAction:[PresetSOAPMessage get_wsFootBall_Livescore_TyLe_SoapAction]];
//        }
//    });
}

#if 0
-(void)onAutoSoapDidFinishLoading:(NSData *)data
{
    @synchronized(_autoLockObj)
    {
        
        @try {
            NSString* xmlData = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            
            
            NSString* jsonStr = [[xmlData componentsSeparatedByString:@"<wsFootBall_LivesResult>"] objectAtIndex:1];
            jsonStr = [[jsonStr componentsSeparatedByString:@"</wsFootBall_LivesResult>"] objectAtIndex:0];
            
            ZLog(@"jsonStr data: %@", jsonStr);
            
            
            // parse data
            NSData* dataJson = [jsonStr dataUsingEncoding:NSUTF8StringEncoding];
            NSError* error = nil;
            
            NSArray *bdDict = [NSJSONSerialization JSONObjectWithData:dataJson options:NSJSONReadingMutableContainers error:&error];
            
            if(error) {
                ZLog(@"error occured: %@", error);
                return;
            } else {
                
                NSString* rootUrlImg = [[NSUserDefaults standardUserDefaults] objectForKey:@"ROOT_URL_IMAGE"];
                for(int i=0;i<bdDict.count;++i) {
                    NSDictionary* dict = [bdDict objectAtIndex:i];
                    LivescoreModel *model = [LivescoreModel new];
                    
                    NSString *tmp_rootUrlImg = [dict objectForKey:@"rootUrl"];
                    
                    
                    if(tmp_rootUrlImg) {
                        continue;
                    }
                    
                    
                    NSString* matchTime = [dict objectForKey:@"dThoiGianThiDau"];
                    matchTime = [matchTime stringByReplacingOccurrencesOfString:@"/Date(" withString:@""];
                    matchTime = [matchTime stringByReplacingOccurrencesOfString:@")/" withString:@""];
                    
                    long dateLong =[matchTime integerValue]/1000;
                    
                    dateLong = [(NSNumber*)[dict objectForKey:@"iC0"] longValue];
                    
                    
                    NSDate *date = [NSDate dateWithTimeIntervalSince1970:dateLong];
                    model.dThoiGianThiDau = date;
                    
                    NSDateFormatter *dateFormatter=[[NSDateFormatter alloc]init];
                    [dateFormatter setDateFormat:@"HH:mm"];
                    
                    
                    model.sThoiGian = [dict objectForKey:@"sThoiGian"];
                    model.sThoiGian = [dateFormatter stringFromDate:date];
                    
                    model.sTenDoiNha = [dict objectForKey:@"sTenDoiNha"];
                    model.sTenDoiKhach = [dict objectForKey:@"sTenDoiKhach"];
                    model.sTenGiai = [dict objectForKey:@"sTenGiai"];
                    model.sLogoQuocGia = [dict objectForKey:@"sLogoQuocGia"];
                    model.sLogoDoiNha = [dict objectForKey:@"sLogoDoiNha"];
                    model.sLogoDoiKhach = [dict objectForKey:@"sLogoDoiKhach"];
                    model.sLogoGiai = [dict objectForKey:@"sLogoGiai"];
                    model.iID_MaGiai = [(NSNumber*)[dict objectForKey:@"iID_MaGiai"] integerValue];
                    model.iTrangThai = [(NSNumber*)[dict objectForKey:@"iTrangThai"] integerValue];
                    
                    
                    //iID_MaDoiNha, iID_MaDoiKhach
                    model.iID_MaDoiNha = [(NSNumber*)[dict objectForKey:@"iID_MaDoiNha"] integerValue];
                    model.iID_MaDoiKhach = [(NSNumber*)[dict objectForKey:@"iID_MaDoiKhach"] integerValue];
                    model.iID_MaQuocGia = [(NSNumber*)[dict objectForKey:@"iID_MaQuocGia"] integerValue];
                    
                    
                    // may tinh du doan va nhan dinh chuyen gia
                    model.bMayTinhDuDoan = NO;
                    model.bNhanDinhChuyenGia = NO;
                    model.bNhanDinhChuyenGia = [[dict objectForKey:@"bNhanDinhChuyenGia"] boolValue];
                    model.bMayTinhDuDoan = [[dict objectForKey:@"bMayTinhDuDoan"] boolValue];
                    model.bGameDuDoan = [[dict objectForKey:@"bGameDuDoan"] boolValue];
                    
                    // keo game du doan
                    model.sTyLe_ChapBong = [dict objectForKey:@"sTyLe_ChapBong"];
                    if (model.sTyLe_ChapBong == nil || [model.sTyLe_ChapBong isEqualToString:@""]) {
                        model.sTyLe_ChapBong = [dict objectForKey:@"sTyLe_ChapBong_DauTran"];
                    }
                    
                    model.iCN_Phut = [(NSNumber*)[dict objectForKey:@"iCN_Phut"] integerValue];
                    model.iPhutThem = [(NSNumber*)[dict objectForKey:@"iPhutThem"] integerValue];
                    
                    
                    //sMaDoiNha, sMaDoiKhach
                    model.sMaDoiNha = [dict objectForKey:@"sMaDoiNha"];
                    model.sMaDoiKhach = [dict objectForKey:@"sMaDoiKhach"];
                    
                    
                    
                    // get logo new
//                    model.sLogoQuocGia = [NSString stringWithFormat:@"%@/Uploads/App/c-%d.png", rootUrlImg,model.iID_MaQuocGia];
//                    model.sLogoDoiNha = [NSString stringWithFormat:@"%@/Uploads/App/fc-%d.png", rootUrlImg,model.iID_MaDoiNha];
//                    model.sLogoDoiKhach = [NSString stringWithFormat:@"%@/Uploads/App/fc-%d.png", rootUrlImg,model.iID_MaDoiKhach];
//                    model.sLogoGiai = [NSString stringWithFormat:@"%@/Uploads/App/l-%d.png", rootUrlImg,model.iID_MaGiai];
                    
                    
                    model.iCN_BanThang_DoiKhach_HT = [(NSNumber*)[dict objectForKey:@"iCN_BanThang_DoiKhach_HT"] integerValue];
                    model.iCN_BanThang_DoiNha_HT = [(NSNumber*)[dict objectForKey:@"iCN_BanThang_DoiNha_HT"] integerValue];
                    model.iCN_BanThang_DoiNha_FT = [(NSNumber*)[dict objectForKey:@"iCN_BanThang_DoiNha_FT"] integerValue];
                    model.iCN_BanThang_DoiKhach_FT = [(NSNumber*)[dict objectForKey:@"iCN_BanThang_DoiKhach_FT"] integerValue];
                    model.iID_MaTran = [(NSNumber*)[dict objectForKey:@"iID_MaTran"] integerValue];
                    
                    NSString* matran = [NSString stringWithFormat:@"%lu", model.iID_MaTran];
                    NSNumber *number = (NSNumber *)[[NSUserDefaults standardUserDefaults] objectForKey:matran];
                    if(number != nil && [number intValue] == 1) {
                        model.isFavourite = YES;
                    } else {
                        model.isFavourite = NO;
                    }
                    
                    
                    ZLog(@"iID_MaGiai: %lu", (unsigned long)model.iID_MaGiai);
                    
                    [model adjustImageURLForReview];
                    
                    //totalpage
                    @try {
                        self.totalPage = [[dict objectForKey:@"totalpage"] intValue];
                    }@catch(NSException *ex){
                        self.totalPage = 1;
                    }
                    
                    NSString* iID_MaGiai_Str = [NSString stringWithFormat:@"%lu", (unsigned long)model.iID_MaGiai];
                    NSMutableArray* list = [self.listLivescore objectForKey:iID_MaGiai_Str];
                    if(list == nil) {
                        // no record, dont go anymore
                        continue;
                    } else {
                        // existed, update data then
                        LivescoreModel* oldModel = [self findModelByMaTran:list iID_MaTran:model.iID_MaTran];
                        if(oldModel != nil) {
                            ZLog(@"remove old model: %@", oldModel);
                            
                            if (oldModel.iCN_BanThang_DoiNha_FT != model.iCN_BanThang_DoiNha_FT ||
                                oldModel.iCN_BanThang_DoiKhach_FT != model.iCN_BanThang_DoiKhach_FT) {
                                model.isHighlightedView = YES;
                                
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    [NSTimer scheduledTimerWithTimeInterval:SCORE_CHANGED_VALUE_INTERVAL target:self selector:@selector(onScoreHighlightFired:) userInfo:@{ @"iID_MaGiai":iID_MaGiai_Str, @"iID_MaTran" : [NSString stringWithFormat:@"%d", model.iID_MaTran]} repeats:NO];
                                });
                                
                            }
                            
                            if(oldModel.isHighlightedView) {
                                model.isHighlightedView = YES;
                            }
                            
                            [list removeObject:oldModel];
                        } else {
                            // dont go anymore
                            continue;
                        }
                        
                    }
                    [list addObject:model];
                    
                    [self.listLivescore setObject:list forKey:iID_MaGiai_Str];
                    
                }
                
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    @try{
                        ZLog(@"refresh visible rows");
                        NSArray *paths = [self.tableView indexPathsForVisibleRows];
                        [self updateVisibleCells:paths];
                        
                    }@catch(NSException *ex) {
                        ZLog(@"error: %@", ex);
                    }
                });
                
            }
        }@catch(NSException *ex) {
            
            [self onSoapError:nil];
        }

        
    }
    
}

#else

-(void)onAutoSoapDidFinishLoading:(NSData *)data
{
    @synchronized(_autoLockObj)
    {
        
        @try {
            NSString* xmlData = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSString* jsonStr = @"";
            
            if ([xmlData rangeOfString:@"<wsFootBall_Livescore_SuKienResult>"].location != NSNotFound) {
                jsonStr = [[xmlData componentsSeparatedByString:@"<wsFootBall_Livescore_SuKienResult>"] objectAtIndex:1];
                jsonStr = [[jsonStr componentsSeparatedByString:@"</wsFootBall_Livescore_SuKienResult>"] objectAtIndex:0];
                
                
            } else if([xmlData rangeOfString:@"<wsFootBall_Livescore_TyLeResult>"].location != NSNotFound) {
                // handle game du doan setbet
                ZLog(@"got setbet response: %@", xmlData);
                jsonStr = [[xmlData componentsSeparatedByString:@"<wsFootBall_Livescore_TyLeResult>"] objectAtIndex:1];
                jsonStr = [[jsonStr componentsSeparatedByString:@"</wsFootBall_Livescore_TyLeResult>"] objectAtIndex:0];
                
                
                [self handle_wsFootBall_Livescore_TyLeResult:jsonStr];
                return;
            }
            
            
            // parse data
            NSData* dataJson = [jsonStr dataUsingEncoding:NSUTF8StringEncoding];
            NSError* error = nil;
            
            NSArray *bdDict = [NSJSONSerialization JSONObjectWithData:dataJson options:NSJSONReadingMutableContainers error:&error];
            
            if(error) {
                ZLog(@"error occured: %@", error);
                return;
            } else {
                
                if (bdDict.count >= 1) {
                    NSDictionary* c0_dict = [bdDict objectAtIndex:0];
                    long c0 = [(NSNumber*)[c0_dict objectForKey:@"c0"] longValue];
                    
                    [self update_iCN_Phut_LiveMatches:c0];
                    
                    for(int i=1;i<bdDict.count;++i) {
                        NSDictionary* dict = [bdDict objectAtIndex:i];
                        
                        int iID_MaSuKien_Loai = [(NSNumber*)[dict objectForKey:@"iID_MaSuKien_Loai"] intValue];
                        int iID_MaGiai = [(NSNumber*)[dict objectForKey:@"iID_MaGiai"] intValue];
                        
                        int iID_MaTran = [(NSNumber*)[dict objectForKey:@"iID_MaTran"] intValue];
                        NSString* sThongTin = [dict objectForKey:@"sThongTin"];
                        
                        
                        NSString* iID_MaGiai_Str = [NSString stringWithFormat:@"%d", iID_MaGiai];
                        
                        NSMutableArray* list = [self.listLivescore objectForKey:iID_MaGiai_Str];
                        
                        LivescoreModel* model = [self findModelByMaTran:list iID_MaTran:iID_MaTran];
                        if (model) {
                            
                            if (iID_MaSuKien_Loai == 1) {
                                //1: thay doi trang thai tran dau
                                //sThongTin = iTrangThai (e_type =1)
                                model.iTrangThai = [sThongTin intValue];
                                
                            } else if(iID_MaSuKien_Loai == 2) {
                                // thong tin tran dau cap nhap
                                //thong tin: 1-0,HT:0-0,FT:1-0,ET:1-0,Pen:0-0,TD:0-0
                                [self updateLiveScoreModelByEvent:model sThongTin:sThongTin];
                                
                                
                            }
                        }
                        
                    }
                }
                
                
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    @try{
                        ZLog(@"refresh visible rows");
                        
                        if (self.isVisible && FILTER_TODAY_MATCH == self.selectedDateIndex) {
                            [self.tableView beginUpdates];
                            [self.tableView reloadRowsAtIndexPaths:[self.tableView indexPathsForVisibleRows]
                                                  withRowAnimation:UITableViewRowAnimationNone];
                            [self.tableView endUpdates];
                        }
                        
                        
                    }@catch(NSException *ex) {
                        ZLog(@"error: %@", ex);
                    }
                });
                
            }
        }@catch(NSException *ex) {
            
            [self onSoapError:nil];
        }
        
        
    }
    
}

-(void)handle_wsFootBall_Livescore_TyLeResult:(NSString*)jsonStr {
    // parse data
    NSData* dataJson = [jsonStr dataUsingEncoding:NSUTF8StringEncoding];
    NSError* error = nil;
    
    NSArray *bdDict = [NSJSONSerialization JSONObjectWithData:dataJson options:NSJSONReadingMutableContainers error:&error];
    
    if(error) {
        ZLog(@"error occured: %@", error);
        return;
    } else {
        for(int i=0;i<bdDict.count;++i) {
            NSDictionary* dict = [bdDict objectAtIndex:i];
            NSString* sTenTyLe = [dict objectForKey:@"sTenTyLe"];
            NSUInteger iID_MaTran = [(NSNumber*)[dict objectForKey:@"iID_MaTran"] longValue];
            NSString* sTyLe = [dict objectForKey:@"sTyLe"];
            
            NSArray* allValues = [self.listLivescore allValues];
            NSMutableArray* list = [NSMutableArray new];
            for (int i=0; i<allValues.count; i++) {
                [list addObjectsFromArray:[allValues objectAtIndex:i]];
            }

            LivescoreModel* model = [self findModelByMaTran:list iID_MaTran:iID_MaTran];
            if (model) {
                ZLog(@"found: %@", model);
                if ([sTenTyLe isEqualToString:@"sTyLe_ChauAu"]) {
                    model.sTyLe_ChauAu = sTyLe;
                    
                    model.sTyLe_ChauAu_Live = [model get_sTyLe_ChapBong_ChauAu_Live:model.sTyLe_ChauAu];
                } else if([sTenTyLe isEqualToString:@"sTyLe_TaiSuu"]) {
                    model.sTyLe_TaiSuu = sTyLe;
                    
                    model.sTyLe_TaiSuu_Live = [model get_sTyLe_ChapBong_TaiSuu_Live:model.sTyLe_TaiSuu];
                } else if([sTenTyLe isEqualToString:@"sTyLe_ChapBong"]) {
                    model.sTyLe_ChapBong = sTyLe;
                }
            }
        }
    }
}


+(void) update_iCN_Phut_By_LivescoreModel:(LivescoreModel*)model c0:(long)c0 {
    NSUInteger iCN_Phut = 0;
    NSUInteger phutthem = 0;
    
    if(model.iTrangThai == 4) {
        // hiep 2
        iCN_Phut = floor((c0 - model.iC0 - model.iC1 - model.iC2) / 60) + 1 + model.iSoPhut1Hiep;
        
        //                long tmptmpt = (c0 - model.iC0 - model.iC1 - model.iC2);
        iCN_Phut = floor((c0 - model.iC0 - model.iC1 - model.iC2) / 60) + 1 + model.iSoPhut1Hiep;
        
        
        if (iCN_Phut <= model.iSoPhut1Hiep) {
            iCN_Phut = model.iSoPhut1Hiep + 1;
        }
        
        if (iCN_Phut > 2 * model.iSoPhut1Hiep) {
            phutthem = iCN_Phut - 2 * model.iSoPhut1Hiep;
            iCN_Phut = 2 * model.iSoPhut1Hiep;
        }
        
        
    } else if(model.iTrangThai == 2) {
        // hiep 1
        iCN_Phut = floor((c0 - (model.iC0 + model.iC1)) / 60.0) + 1;
        if (iCN_Phut <= 0) {
            iCN_Phut = 1;
        }
        
        if (iCN_Phut > model.iSoPhut1Hiep) {
            phutthem = iCN_Phut - model.iSoPhut1Hiep;
            iCN_Phut = model.iSoPhut1Hiep;
        }
        
        
        
    }
    
    model.iCN_Phut = iCN_Phut;
    model.iPhutThem = phutthem;
}

-(void)update_iCN_Phut_LiveMatches:(long)c0 {
    for (int i=0; i < self.listLivescoreKeys.count; i++) {
        NSString* key =  [self.listLivescoreKeys objectAtIndex:i];
        NSArray* list = [self.listLivescore objectForKey:key];
        for (int j=0; j < list.count; j++) {
            LivescoreModel* model = [list objectAtIndex:j];
            [LiveScoreViewController update_iCN_Phut_By_LivescoreModel:model c0:c0];

        }
    }
}

-(void) updateLiveScoreModelByEvent:(LivescoreModel*)model sThongTin:(NSString*)sThongTin {
    //sThongTin = 1-0,HT:0-0,FT:1-0,ET:1-0,Pen:0-0,TD:0-0
    @try {
        NSArray* detailList = [sThongTin componentsSeparatedByString:@","];
        if (detailList.count > 3) {
            NSString* goal_tran = [detailList objectAtIndex:0];
            
            NSString* goal_HT = [detailList objectAtIndex:1];
            goal_HT = [goal_HT stringByReplacingOccurrencesOfString:@"HT:" withString:@""];
            NSArray* list_HT = [goal_HT componentsSeparatedByString:@"-"];
            
            
            NSString* goal_FT = [detailList objectAtIndex:2];
            goal_FT = [goal_FT stringByReplacingOccurrencesOfString:@"FT:" withString:@""];
            NSArray* list_FT = [goal_tran componentsSeparatedByString:@"-"];
            
            
            model.iCN_BanThang_DoiNha_HT = [[list_HT objectAtIndex:0] integerValue];
            model.iCN_BanThang_DoiKhach_HT = [[list_HT objectAtIndex:1] integerValue];
            
            
            NSUInteger tmp_iCN_BanThang_DoiNha_FT = [[list_FT objectAtIndex:0] integerValue];
            NSUInteger tmp_iCN_BanThang_DoiKhach_FT = [[list_FT objectAtIndex:1] integerValue];
            
            if(tmp_iCN_BanThang_DoiNha_FT != model.iCN_BanThang_DoiNha_FT ||
               tmp_iCN_BanThang_DoiKhach_FT != model.iCN_BanThang_DoiKhach_FT) {
                model.isHighlightedView = YES;
            }
            model.iCN_BanThang_DoiNha_FT = tmp_iCN_BanThang_DoiNha_FT;
            model.iCN_BanThang_DoiKhach_FT = tmp_iCN_BanThang_DoiKhach_FT;
            
        }
    }
    @catch (NSException *exception) {
        
    }
    
    
}

#endif

-(void)submitFavouriteMatch:(NSString*)deviceToken matran:(NSString*)matran type:(int)type
{
    dispatch_queue_t myQueue = dispatch_queue_create("com.ptech.BDLive.Submit", NULL);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), myQueue, ^{
      
        SOAPHandler* handler = [SOAPHandler new];
        [handler sendAutoSOAPRequest:[PresetSOAPMessage getDeviceLikeSoapMessage:deviceToken matran:matran
                                    type:type] soapAction:[PresetSOAPMessage getDeviceLikeSoapAction]];
    });

}


-(void) getListFullTimeMatch
{
    for (NSUInteger i =0; i<self.listLivescoreKeys.count; i++) {
        NSString* key = [self.listLivescoreKeys objectAtIndex:i];
        NSMutableArray* list = [self.listLivescore objectForKey:key];
        NSMutableArray* tmpList = [NSMutableArray new];
        
        BOOL hasModel = NO;
        for(NSUInteger j=0;j<list.count;j++) {
            LivescoreModel *model = [list objectAtIndex:j];
            
            if(model.iTrangThai == 5 || model.iTrangThai == 8 ||
               model.iTrangThai == 9 || model.iTrangThai == 15) {// fulllllll
               
                hasModel = YES;
                
                [tmpList addObject:model];
            }
        }
        
        if(hasModel) {
            [self.listLivescoreKeys_FT addObject:key];
            [self.listLivescore_FT setObject:tmpList forKey:key];
            
        }
    }
}

-(void) getListLiveMatch
{
    for (NSUInteger i =0; i<self.listLivescoreKeys.count; i++) {
        NSString* key = [self.listLivescoreKeys objectAtIndex:i];
        NSMutableArray* list = [self.listLivescore objectForKey:key];
        NSMutableArray* tmpList = [NSMutableArray new];
        
        BOOL hasModel = NO;
        for(NSUInteger j=0;j<list.count;j++) {
            LivescoreModel *model = [list objectAtIndex:j];
            
            if(model.iTrangThai == 2 || model.iTrangThai == 3 || model.iTrangThai == 4) {
                //Live=2,3,4
                hasModel = YES;
                
                [tmpList addObject:model];
            }
        }
        
        if(hasModel) {
            [self.listLivescoreKeys_Live addObject:key];
            [self.listLivescore_Live setObject:tmpList forKey:key];
            
        }
    }
}


-(IBAction)onFullTimeClick:(id)sender
{
    ZLog(@"filter clicked to get FULLTIME match");
    
    if(self.filterType == FILTER_FULLTIME_MATCH) {
        self.filterType = 0;
        [self.tableView reloadData];
        [self.fulltimeBtn setBackgroundImage:[UIImage imageNamed:@"ic_fulltime.png"] forState:UIControlStateNormal];
        return;
    }
    
    self.filterType = FILTER_FULLTIME_MATCH;
    [self.fulltimeBtn setBackgroundImage:[UIImage imageNamed:@"ic_fulltime_selected.png"] forState:UIControlStateNormal];
    [self.liveBtn setBackgroundImage:[UIImage imageNamed:@"ic_live.png"] forState:UIControlStateNormal];
    
    
    [self.listLivescore_FT removeAllObjects];
    [self.listLivescoreKeys_FT removeAllObjects];
    
    [self.listLivescore_Live removeAllObjects];
    [self.listLivescoreKeys_Live removeAllObjects];
    
    [self getListFullTimeMatch];
    
    [self.tableView reloadData];
}

-(IBAction)onLiveMatchClick:(id)sender
{
    ZLog(@"filter clicked to get Live match");
    
    if(self.filterType == FILTER_LIVE_MATCH) {
        self.filterType = 0;
        [self.tableView reloadData];
        [self.liveBtn setBackgroundImage:[UIImage imageNamed:@"ic_live.png"] forState:UIControlStateNormal];
        
        return;
    }
    
    self.filterType = FILTER_LIVE_MATCH;
    [self.fulltimeBtn setBackgroundImage:[UIImage imageNamed:@"ic_fulltime.png"] forState:UIControlStateNormal];
    [self.liveBtn setBackgroundImage:[UIImage imageNamed:@"ic_live_selected.png"] forState:UIControlStateNormal];

    
    
    [self.listLivescore_FT removeAllObjects];
    [self.listLivescoreKeys_FT removeAllObjects];
    
    [self.listLivescore_Live removeAllObjects];
    [self.listLivescoreKeys_Live removeAllObjects];
    
    
    [self getListLiveMatch];
    
    [self.tableView reloadData];
}

-(void)onScoreHighlightFired:(NSTimer*)timer
{
    NSDictionary* userInfo = timer.userInfo;
    NSString* iID_MaGiai_Str = [userInfo objectForKey:@"iID_MaGiai"];
    NSString* iID_MaTran_Str = [userInfo objectForKey:@"iID_MaTran"];
    
    
    NSMutableArray* list = [self.listLivescore objectForKey:iID_MaGiai_Str];
    
    LivescoreModel* mm = [self findModelByMaTran:list iID_MaTran:[iID_MaTran_Str integerValue]];
    if (mm) {
        mm.isHighlightedView = NO;
    }
}


-(void)handleHomeClickNotification
{
    [self.rdv_tabBarController setSelectedIndex:0]; // goto livescore tab now
}



-(void)viewWillLayoutSubviews {
#if 0
    float devVersion = [[[UIDevice currentDevice] systemVersion] floatValue];
    if (devVersion >= 7 && devVersion < 8)
    {
        self.view.clipsToBounds = YES;
        CGRect screenRect = [[UIScreen mainScreen] bounds];
        CGFloat screenHeight = 0.0;
        if(UIDeviceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation]))
            screenHeight = screenRect.size.height;
        else
            screenHeight = screenRect.size.width;
        CGRect screenFrame = CGRectMake(0, 20, self.view.frame.size.width,screenHeight-20);
        CGRect viewFr = [self.view convertRect:self.view.frame toView:nil];
        if (!CGRectEqualToRect(screenFrame, viewFr))
        {
            self.view.frame = screenFrame;
            self.view.bounds = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
        }
    }
#endif
}


//-(void)scrollViewDidScrollToTop:(UIScrollView *)scrollView {
//    NSLog(@"scrollViewDidScrollToTop");
//}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    if (YES && scrollView.contentOffset.y < -50 && [self.livescoreSearchBar isHidden]) { // TOP
        NSLog(@"scrollViewDidScroll: %f", scrollView.contentOffset.y);
        self.livescoreSearchBar.hidden = NO;
        CATransition *animation = [CATransition animation];
        animation.type = kCATransitionFromTop;
        animation.duration = 0.7;
        [self.livescoreSearchBar becomeFirstResponder];
        [self.livescoreSearchBar.layer addAnimation:animation forKey:nil];

    }
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    NSLog(@"searchText: %@", searchText);
}
//- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
//
//}
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [self hideSearchBarNow];
}

- (void)searchBarKeyboardDidHide
{
    if (self.livescoreSearchBar.text == nil || [self.livescoreSearchBar.text isEqualToString:@""]) {
        [self hideSearchBarNow];
    }
    
}


-(void)hideSearchBarNow {
    [self.livescoreSearchBar resignFirstResponder];
    
    self.isSearching = NO;
    
    self.livescoreSearchBar.hidden = YES;
    CATransition *animation = [CATransition animation];
    animation.type = kCATransitionFromBottom;
    animation.duration = 0.3;
    [self.livescoreSearchBar becomeFirstResponder];
    [self.livescoreSearchBar.layer addAnimation:animation forKey:nil];
}

#pragma mark Content Filtering

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
    // Update the filtered array based on the search text and scope.
    NSLog(@"filterContentForSearchText");
    
    // Remove all objects from the filtered search array
    [self.listLivescore_Filter removeAllObjects];
    
    
    NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(id obj, NSDictionary *bind) {
        //        NSArray* list = (NSArray*)obj;
        //        NSData *dataString = [[searchText lowercaseString] dataUsingEncoding:NSNonLossyASCIIStringEncoding allowLossyConversion:NO];
        //        NSString *cleanedString = [[NSString alloc] initWithData:dataString encoding:NSASCIIStringEncoding];
        //
        
        LivescoreModel *model = obj;
        NSString* nomalizedStr = [searchText lowercaseString];
        
        NSString* nomalizedKhach = [model.sTenDoiKhach lowercaseString];
        NSString* nomalizedNha = [model.sTenDoiNha lowercaseString];
        
        if([nomalizedNha rangeOfString:nomalizedStr].location != NSNotFound ||
           [nomalizedKhach rangeOfString:nomalizedStr].location != NSNotFound) {
            return true;
        }
        
        
        
        return false;

        
    }];
    
    
    
    NSArray* allVals = [self.listLivescore allValues];
    NSMutableArray *flatArray = [NSMutableArray new];
    for (int i = 0; i<allVals.count; i++) {
        [flatArray addObjectsFromArray:[allVals objectAtIndex:i]];
    }
    
    NSArray* tmpList = [flatArray filteredArrayUsingPredicate:predicate];
    
    self.isSearching = YES;
    NSLog(@"tmpList = %ld", [tmpList count]);
    [self.listLivescore_Filter addObjectsFromArray:tmpList];
}

#pragma mark - UISearchDisplayController Delegate Methods
- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    // Tells the table data source to reload when text changes
    NSInteger indexButton = [self.searchDisplayController.searchBar selectedScopeButtonIndex];
    [self filterContentForSearchText:searchString scope:
     [[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:indexButton]];
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}


- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption
{
    // Tells the table data source to reload when scope bar selection changes
    [self filterContentForSearchText:[self.searchDisplayController.searchBar text] scope:
     [[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:searchOption]];
    
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}

-(void) searchDisplayController:(UISearchDisplayController *)controller didShowSearchResultsTableView:(UITableView *)tableView {
    
//    NSDictionary * views = @{ @"searchResultsTableView" : self.searchDisplayController.searchResultsTableView};
//     
//     NSArray * topConstraint = [NSLayoutConstraint
//     constraintsWithVisualFormat:@"V:|-64-[searchResultsTableView]-|"
//     options:0
//     metrics:nil
//     views:views];
//     [self.searchDisplayController.searchResultsTableView.superview addConstraints:topConstraint];
//     
}



+(void)updateLiveScoreTableViewCell:(LiveScoreTableViewCell*)cell model:(LivescoreModel*)model
{
    if (![model.sDoiNha_BXH isKindOfClass:[NSNull class]] && (model.sDoiNha_BXH && ![model.sDoiNha_BXH isEqualToString:@""])) {
        model.sTenDoiNha = [model.sTenDoiNha stringByReplacingOccurrencesOfString:@"(" withString:@" ("];
        NSString* htmlString = [NSString stringWithFormat:@"<p style=\"text-align:right; font-family:VNF-FUTURA\"><span style=\"color:#e60000;\">[%@]</span> %@</p>", model.sDoiNha_BXH, model.sTenDoiNha];
        
        if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1) {
            NSAttributedString *attrStr = [[NSAttributedString alloc] initWithData:[htmlString dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];
            cell.hostTeamLabel.attributedText = attrStr;
        } else {
            cell.hostTeamLabel.text = [NSString stringWithFormat:@"[%@] %@", model.sDoiNha_BXH, model.sTenDoiNha];
        }
    } else {
        cell.hostTeamLabel.text = model.sTenDoiNha;
    }
    
    if (![model.sDoiKhach_BXH isKindOfClass:[NSNull class]] && model.sDoiKhach_BXH && ![model.sDoiKhach_BXH isEqualToString:@""]) {
        
        model.sTenDoiKhach = [model.sTenDoiKhach stringByReplacingOccurrencesOfString:@"(" withString:@" ("];
        NSString* htmlString = [NSString stringWithFormat:@"<p style=\"text-align:left; font-family:VNF-FUTURA\">%@ <span style=\"color:#e60000;\">[%@]</span></p>", model.sTenDoiKhach, model.sDoiKhach_BXH];
        
        
        if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1) {
            NSAttributedString*attrStr = [[NSAttributedString alloc] initWithData:[htmlString dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];
            
            cell.oppositeTeam.attributedText = attrStr;
        } else {
            cell.oppositeTeam.text = [NSString stringWithFormat:@"%@ [%@]", model.sTenDoiKhach, model.sDoiKhach_BXH];
        }
        
        
    } else {
        cell.oppositeTeam.text = model.sTenDoiKhach;
    }
    
}



- (void)itemAtIndex:(NSUInteger)index didSelectInPagesContainerTopBar:(id)sender {
    ZLog(@"index selected: %lu", index);
    
    if (self.filterType == FILTER_QUICK_MENU) {
        
    } else {
        if (self.selectedDateIndex == index) {
            return;
        }
    }
    
    
    
    
    self.selectedDateIndex = (int)index;
    

    ScheduleCollection *ret = [self.lichDict objectForKey:[NSString stringWithFormat:@"%d", self.selectedDateIndex]];
    
    if(ret) {
        self.currCollection = ret;
        [self.tableView reloadData];
    } else {
        [self onRefreshTouch:nil];
    }
    
    
    
}

//
-(void)handle_wsFootBall_VongDauResult:(NSString*)xmlData {
    
    ScheduleCollection *myCollection = [[ScheduleCollection alloc] init];
    @try {
        NSString* jsonStr = [[xmlData componentsSeparatedByString:@"<wsFootBall_LiveScore_VongDauResult>"] objectAtIndex:1];
        jsonStr = [[jsonStr componentsSeparatedByString:@"</wsFootBall_LiveScore_VongDauResult>"] objectAtIndex:0];
        
        // parse data
        NSData* dataJson = [jsonStr dataUsingEncoding:NSUTF8StringEncoding];
        NSError* error = nil;
        
        NSArray *bdDict = [NSJSONSerialization JSONObjectWithData:dataJson options:NSJSONReadingMutableContainers error:&error];
        
        if(error) {
            ZLog(@"error occured: %@", error);
            return;
        } else {
            
            long currentTime = [[NSDate date] timeIntervalSince1970];
            
            
#if 1
            for(int i=0;i<bdDict.count;++i) {
                NSDictionary* dict = [bdDict objectAtIndex:i];
                
                LivescoreModel *model = [LivescoreModel new];
                
                
                
                NSString* matchTime = [dict objectForKey:@"dThoiGianThiDau"];
                matchTime = [matchTime stringByReplacingOccurrencesOfString:@"/Date(" withString:@""];
                matchTime = [matchTime stringByReplacingOccurrencesOfString:@")/" withString:@""];
                long dateLong =[matchTime integerValue]/1000;
                
                
                dateLong = [(NSNumber*)[dict objectForKey:@"iC0"] longValue];
                
                model.iC0 = dateLong;
                model.iC1 = [(NSNumber*)[dict objectForKey:@"iC1"] longValue];
                model.iC2 = [(NSNumber*)[dict objectForKey:@"iC2"] longValue];
                model.iSoPhut1Hiep = [(NSNumber*)[dict objectForKey:@"iSoPhut1Hiep"] longValue];
                
                
                NSDate *date = [NSDate dateWithTimeIntervalSince1970:dateLong];
                model.dThoiGianThiDau = date;
                
                NSDateFormatter *dateFormatter=[[NSDateFormatter alloc]init];
                [dateFormatter setDateFormat:@"HH:mm"];
                
                
                
                
                model.sThoiGian = [dict objectForKey:@"sThoiGian"];
                model.sThoiGian = [dateFormatter stringFromDate:date];
                model.sTenDoiNha = [dict objectForKey:@"sTenDoiNha"];
                model.sTenDoiKhach = [dict objectForKey:@"sTenDoiKhach"];
                model.sTenGiai = [dict objectForKey:@"sTenGiai"];
                
                model.sLogoQuocGia = [dict objectForKey:@"sLogoQuocGia"];
                model.sLogoDoiNha = [dict objectForKey:@"sLogoDoiNha"];
                model.sLogoDoiKhach = [dict objectForKey:@"sLogoDoiKhach"];
                model.sLogoGiai = [dict objectForKey:@"sLogoGiai"];
                
                model.sDoiNha_BXH = [dict objectForKey:@"sDoiNha_BXH"];
                model.sDoiKhach_BXH = [dict objectForKey:@"sDoiKhach_BXH"];
                
                //pens
                model.iCN_BanThang_DoiNha_Pen = [(NSNumber*)[dict objectForKey:@"iCN_BanThang_DoiNha_Pen"] integerValue];
                model.iCN_BanThang_DoiKhach_Pen = [(NSNumber*)[dict objectForKey:@"iCN_BanThang_DoiKhach_Pen"] integerValue];
                
                
                model.iID_MaGiai = [(NSNumber*)[dict objectForKey:@"iID_MaGiai"] integerValue];
                model.iTrangThai = [(NSNumber*)[dict objectForKey:@"iTrangThai"] intValue];
                
                //iID_MaDoiNha, iID_MaDoiKhach
                @try {
                    model.iID_MaDoiNha = [(NSNumber*)[dict objectForKey:@"iID_MaDoiNha"] integerValue];
                    model.iID_MaDoiKhach = [(NSNumber*)[dict objectForKey:@"iID_MaDoiKhach"] integerValue];
                    model.iID_MaQuocGia = [(NSNumber*)[dict objectForKey:@"iID_MaQuocGia"] integerValue];
                }
                @catch (NSException *exception) {
                    
                    continue;
                }
                
                
                
                
                
                //sMaDoiNha, sMaDoiKhach
                model.sMaDoiNha = [dict objectForKey:@"sMaDoiNha"];
                model.sMaDoiKhach = [dict objectForKey:@"sMaDoiKhach"];
                
                // may tinh du doan va nhan dinh chuyen gia
                model.bMayTinhDuDoan = NO;
                model.bNhanDinhChuyenGia = NO;
                model.bNhanDinhChuyenGia = [[dict objectForKey:@"bNhanDinhChuyenGia"] boolValue];
                model.bMayTinhDuDoan = [[dict objectForKey:@"bMayTinhDuDoan"] boolValue];
                
                model.bGameDuDoan = [[dict objectForKey:@"bGameDuDoan"] boolValue];
                
                // keo game du doan
                model.sTyLe_ChapBong = [dict objectForKey:@"sTyLe_ChapBong"];
                
                model.sTyLe_ChauAu = [dict objectForKey:@"sTyLe_ChauAu"];
                model.sTyLe_TaiSuu = [dict objectForKey:@"sTyLe_TaiSuu"];
                
                
                if (model.iTrangThai == 5 ||
                    model.iTrangThai == 8 ||
                    model.iTrangThai == 9 ||
                    model.iTrangThai == 15) {
                    
                    model.sTyLe_ChapBong = [dict objectForKey:@"sTyLe_ChapBong_DauTran"];
                    model.sTyLe_ChauAu = [dict objectForKey:@"sTyLe_ChauAu_DauTran"];
                    model.sTyLe_TaiSuu = [dict objectForKey:@"sTyLe_TaiSuu_DauTran"];
                }
                
                model.sTyLe_ChauAu_Live = [model get_sTyLe_ChapBong_ChauAu_Live:model.sTyLe_ChauAu];
                model.sTyLe_TaiSuu_Live = [model get_sTyLe_ChapBong_TaiSuu_Live:model.sTyLe_TaiSuu];
                // end keo ty le
                
                
                model.iCN_Phut = [(NSNumber*)[dict objectForKey:@"iCN_Phut"] integerValue];
                model.iPhutThem = [(NSNumber*)[dict objectForKey:@"iPhutThem"] integerValue];
                
                
                
                model.iCN_BanThang_DoiKhach_HT = [(NSNumber*)[dict objectForKey:@"iCN_BanThang_DoiKhach_HT"] integerValue];
                model.iCN_BanThang_DoiNha_HT = [(NSNumber*)[dict objectForKey:@"iCN_BanThang_DoiNha_HT"] integerValue];
                model.iCN_BanThang_DoiNha_FT = [(NSNumber*)[dict objectForKey:@"iCN_BanThang_DoiNha_FT"] integerValue];
                model.iCN_BanThang_DoiKhach_FT = [(NSNumber*)[dict objectForKey:@"iCN_BanThang_DoiKhach_FT"] integerValue];
                model.iID_MaTran = [(NSNumber*)[dict objectForKey:@"iID_MaTran"] integerValue];
                
                
                model.iCN_BanThang_DoiNha_ET = [(NSNumber*)[dict objectForKey:@"iCN_BanThang_DoiNha_ET"] integerValue];
                model.iCN_BanThang_DoiKhach_ET = [(NSNumber*)[dict objectForKey:@"iCN_BanThang_DoiKhach_ET"] integerValue];
                
                [model adjustImageURLForReview];
                
                NSString* matran = [NSString stringWithFormat:@"%lu", model.iID_MaTran];
                NSNumber *number = (NSNumber *)[[NSUserDefaults standardUserDefaults] objectForKey:matran];
                if(number != nil && [number intValue] == 1) {
                    model.isFavourite = YES;
                } else {
                    model.isFavourite = NO;
                }
                
                [LiveScoreViewController update_iCN_Phut_By_LivescoreModel:model c0:currentTime]; // update iCN_Phut by local time
                
                ZLog(@"iID_MaGiai: %lu", (unsigned long)model.iID_MaGiai);
                
                
                
                NSString* iID_MaGiai_Str = [NSString stringWithFormat:@"%lu", (unsigned long)model.iID_MaGiai];
                
                NSString* iID_MaGiai_Pinned = [[NSUserDefaults standardUserDefaults] objectForKey:iID_MaGiai_Str];
                
                NSMutableArray* list = [myCollection.listLivescore objectForKey:iID_MaGiai_Str];
                if(list == nil) {
                    // no record
                    list = [NSMutableArray new];
                    if(iID_MaGiai_Pinned) {
                        [myCollection.listLivescoreKeys insertObject:iID_MaGiai_Str atIndex:0];
                    } else {
                        [myCollection.listLivescoreKeys addObject:iID_MaGiai_Str];
                    }
                    
                } else {
                    // existed, update data then
                    LivescoreModel* oldModel = [self findModelByMaTran:list iID_MaTran:model.iID_MaTran];
                    if(oldModel != nil) {
                        ZLog(@"remove old model: %@", oldModel);
                        
                        if (oldModel.iCN_BanThang_DoiNha_FT != model.iCN_BanThang_DoiNha_FT ||
                            oldModel.iCN_BanThang_DoiKhach_FT != model.iCN_BanThang_DoiKhach_FT) {
                            model.isHighlightedView = YES;
                            
                        }
                        
                        if(oldModel.isHighlightedView) {
                            model.isHighlightedView = YES;
                        }
                        
                        [list removeObject:oldModel];
                    }
                    
                }
                [list addObject:model];
                
                [myCollection.listLivescore setObject:list forKey:iID_MaGiai_Str];
                
                
            }
#endif
            
            self.currCollection = myCollection;
            
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.lichDict setValue:myCollection forKey:[NSString stringWithFormat:@"menu-%d", self.selectedMenuID]];
                
                [self.tableView reloadData];
            });
        }
    }@catch(NSException *ex) {
        
    }
}


-(void)handle_wsFootBall_Menu_ChonNhanhResult:(NSString*)xmlData {

    @try {
        NSString* jsonStr = [[xmlData componentsSeparatedByString:@"<wsFootBall_Menu_ChonNhanhResult>"] objectAtIndex:1];
        jsonStr = [[jsonStr componentsSeparatedByString:@"</wsFootBall_Menu_ChonNhanhResult>"] objectAtIndex:0];
        
        
        
        // parse data
        NSData* dataJson = [jsonStr dataUsingEncoding:NSUTF8StringEncoding];
        NSError* error = nil;
        
        NSArray *bdDict = [NSJSONSerialization JSONObjectWithData:dataJson options:NSJSONReadingMutableContainers error:&error];
        
        if(error) {
            ZLog(@"error occured: %@", error);
            return;
        } else {
            BOOL isReview = [AccInfo sharedInstance].isReview;
            BOOL isEn = YES;
            NSString* sLang = @"en";
            NSArray* list = [[NSUserDefaults standardUserDefaults] objectForKey:@"AppleLanguages"];
            if (list.count > 0) {
                sLang = [list objectAtIndex:0];
                if ([sLang isEqualToString:@"vi"] ||
                    [sLang isEqualToString:@"vn"]) {
                    isEn = NO;
                }
            }
            
            
            [self.leagueMenuList removeAllObjects];

            for(int i=0;i<bdDict.count;++i) {
                NSDictionary* dict = [bdDict objectAtIndex:i];
                LeagueMenuModel* model = [LeagueMenuModel new];
                int iID_MaGiai = [(NSNumber*)[dict objectForKey:@"iID_MaGiai"] intValue];
                int iEvent = [(NSNumber*)[dict objectForKey:@"Event"] intValue];
                NSString* sMenuName = [dict objectForKey:@"sMenuName"];
                NSString* sTenGiai = [dict objectForKey:@"sMenuName_en"];
                if (isEn) {
                    sMenuName = sTenGiai;
                }
                
                
                int iSTT = [(NSNumber*)[dict objectForKey:@"iSTT"] intValue];
                NSString* sLogo = [dict objectForKey:@"sLogo"];
                
                
                if(isReview) {
                    sLogo = [NSString stringWithFormat:@"%@-review", sLogo];
                }
                
                model.iID_MaGiai = iID_MaGiai;
                model.sMenuName = sMenuName;
                model.iSTT = iSTT;
                model.sLogo = sLogo;
                model.iEvent = iEvent;
                
                [self.leagueMenuList addObject:model];
//                if (model.iEvent == 1) {
//                    [self.leagueMenuList insertObject:model atIndex:0];
//                }
//                else
                
                
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self setupLeagueMenu:isEn];
            });
        }
    }@catch(NSException *ex) {
        
    }
}

-(void)handle_wsFootBall_GetLichThiDau_LiveScoreResult:(NSString*)xmlData {
    ScheduleCollection *myCollection = [[ScheduleCollection alloc] init];
    int counterDebug = 0;
    @try {
        NSString* jsonStr = [[xmlData componentsSeparatedByString:@"<wsFootBall_GetLichThiDau_LiveScoreResult>"] objectAtIndex:1];
        jsonStr = [[jsonStr componentsSeparatedByString:@"</wsFootBall_GetLichThiDau_LiveScoreResult>"] objectAtIndex:0];
        
        
        
        // parse data
        NSData* dataJson = [jsonStr dataUsingEncoding:NSUTF8StringEncoding];
        NSError* error = nil;
        
        NSArray *bdDict = [NSJSONSerialization JSONObjectWithData:dataJson options:NSJSONReadingMutableContainers error:&error];
        
        if(error) {
            ZLog(@"error occured: %@", error);
            return;
        } else {
            
            long currentTime = [[NSDate date] timeIntervalSince1970];
            
            
#if 1
            for(int i=0;i<bdDict.count;++i) {
                NSDictionary* dict = [bdDict objectAtIndex:i];
                
                LivescoreModel *model = [LivescoreModel new];
                counterDebug = i;
                
              
                
                NSString* matchTime = [dict objectForKey:@"dThoiGianThiDau"];
                matchTime = [matchTime stringByReplacingOccurrencesOfString:@"/Date(" withString:@""];
                matchTime = [matchTime stringByReplacingOccurrencesOfString:@")/" withString:@""];
                long dateLong =[matchTime integerValue]/1000;
                
                
                dateLong = [(NSNumber*)[dict objectForKey:@"iC0"] longValue];
                
                model.iC0 = dateLong;
                model.iC1 = [(NSNumber*)[dict objectForKey:@"iC1"] longValue];
                model.iC2 = [(NSNumber*)[dict objectForKey:@"iC2"] longValue];
                model.iSoPhut1Hiep = [(NSNumber*)[dict objectForKey:@"iSoPhut1Hiep"] longValue];
                
                
                NSDate *date = [NSDate dateWithTimeIntervalSince1970:dateLong];
                model.dThoiGianThiDau = date;
                
                NSDateFormatter *dateFormatter=[[NSDateFormatter alloc]init];
                [dateFormatter setDateFormat:@"HH:mm"];
                
                
                
                
                model.sThoiGian = [dict objectForKey:@"sThoiGian"];
                model.sThoiGian = [dateFormatter stringFromDate:date];
                model.sTenDoiNha = [dict objectForKey:@"sTenDoiNha"];
                model.sTenDoiKhach = [dict objectForKey:@"sTenDoiKhach"];
                model.sTenGiai = [dict objectForKey:@"sTenGiai"];
                
                model.sLogoQuocGia = [dict objectForKey:@"sLogoQuocGia"];
                model.sLogoDoiNha = [dict objectForKey:@"sLogoDoiNha"];
                model.sLogoDoiKhach = [dict objectForKey:@"sLogoDoiKhach"];
                model.sLogoGiai = [dict objectForKey:@"sLogoGiai"];
                
                model.sDoiNha_BXH = [dict objectForKey:@"sDoiNha_BXH"];
                model.sDoiKhach_BXH = [dict objectForKey:@"sDoiKhach_BXH"];
                
                //pens
                model.iCN_BanThang_DoiNha_Pen = [(NSNumber*)[dict objectForKey:@"iCN_BanThang_DoiNha_Pen"] integerValue];
                model.iCN_BanThang_DoiKhach_Pen = [(NSNumber*)[dict objectForKey:@"iCN_BanThang_DoiKhach_Pen"] integerValue];
                
                
                model.iID_MaGiai = [(NSNumber*)[dict objectForKey:@"iID_MaGiai"] integerValue];
                model.iTrangThai = [(NSNumber*)[dict objectForKey:@"iTrangThai"] intValue];
                
                //iID_MaDoiNha, iID_MaDoiKhach
                @try {
                    model.iID_MaDoiNha = [(NSNumber*)[dict objectForKey:@"iID_MaDoiNha"] integerValue];
                    model.iID_MaDoiKhach = [(NSNumber*)[dict objectForKey:@"iID_MaDoiKhach"] integerValue];
                    model.iID_MaQuocGia = [(NSNumber*)[dict objectForKey:@"iID_MaQuocGia"] integerValue];
                }
                @catch (NSException *exception) {
                 
                    continue;
                }
                
                
                
                
                
                //sMaDoiNha, sMaDoiKhach
                model.sMaDoiNha = [dict objectForKey:@"sMaDoiNha"];
                model.sMaDoiKhach = [dict objectForKey:@"sMaDoiKhach"];
                
                // may tinh du doan va nhan dinh chuyen gia
                model.bMayTinhDuDoan = NO;
                model.bNhanDinhChuyenGia = NO;
                model.bNhanDinhChuyenGia = [[dict objectForKey:@"bNhanDinhChuyenGia"] boolValue];
                model.bMayTinhDuDoan = [[dict objectForKey:@"bMayTinhDuDoan"] boolValue];
                
                model.bGameDuDoan = [[dict objectForKey:@"bGameDuDoan"] boolValue];
                
                // keo game du doan
                model.sTyLe_ChapBong = [dict objectForKey:@"sTyLe_ChapBong"];
                
                model.sTyLe_ChauAu = [dict objectForKey:@"sTyLe_ChauAu"];
                model.sTyLe_TaiSuu = [dict objectForKey:@"sTyLe_TaiSuu"];
                
                
                if (model.iTrangThai == 5 ||
                    model.iTrangThai == 8 ||
                    model.iTrangThai == 9 ||
                    model.iTrangThai == 15) {
                    
                    model.sTyLe_ChapBong = [dict objectForKey:@"sTyLe_ChapBong_DauTran"];
                    model.sTyLe_ChauAu = [dict objectForKey:@"sTyLe_ChauAu_DauTran"];
                    model.sTyLe_TaiSuu = [dict objectForKey:@"sTyLe_TaiSuu_DauTran"];
                }
                
                model.sTyLe_ChauAu_Live = [model get_sTyLe_ChapBong_ChauAu_Live:model.sTyLe_ChauAu];
                model.sTyLe_TaiSuu_Live = [model get_sTyLe_ChapBong_TaiSuu_Live:model.sTyLe_TaiSuu];
                // end keo ty le
                
                
                model.iCN_Phut = [(NSNumber*)[dict objectForKey:@"iCN_Phut"] integerValue];
                model.iPhutThem = [(NSNumber*)[dict objectForKey:@"iPhutThem"] integerValue];
                
                
                
                model.iCN_BanThang_DoiKhach_HT = [(NSNumber*)[dict objectForKey:@"iCN_BanThang_DoiKhach_HT"] integerValue];
                model.iCN_BanThang_DoiNha_HT = [(NSNumber*)[dict objectForKey:@"iCN_BanThang_DoiNha_HT"] integerValue];
                model.iCN_BanThang_DoiNha_FT = [(NSNumber*)[dict objectForKey:@"iCN_BanThang_DoiNha_FT"] integerValue];
                model.iCN_BanThang_DoiKhach_FT = [(NSNumber*)[dict objectForKey:@"iCN_BanThang_DoiKhach_FT"] integerValue];
                model.iID_MaTran = [(NSNumber*)[dict objectForKey:@"iID_MaTran"] integerValue];
                
                
                model.iCN_BanThang_DoiNha_ET = [(NSNumber*)[dict objectForKey:@"iCN_BanThang_DoiNha_ET"] integerValue];
                model.iCN_BanThang_DoiKhach_ET = [(NSNumber*)[dict objectForKey:@"iCN_BanThang_DoiKhach_ET"] integerValue];
                
                [model adjustImageURLForReview];
                
                NSString* matran = [NSString stringWithFormat:@"%lu", model.iID_MaTran];
                NSNumber *number = (NSNumber *)[[NSUserDefaults standardUserDefaults] objectForKey:matran];
                if(number != nil && [number intValue] == 1) {
                    model.isFavourite = YES;
                } else {
                    model.isFavourite = NO;
                }
                
                [LiveScoreViewController update_iCN_Phut_By_LivescoreModel:model c0:currentTime]; // update iCN_Phut by local time
                
                ZLog(@"iID_MaGiai: %lu", (unsigned long)model.iID_MaGiai);
                
                
                
                NSString* iID_MaGiai_Str = [NSString stringWithFormat:@"%lu", (unsigned long)model.iID_MaGiai];
                
                NSString* iID_MaGiai_Pinned = [[NSUserDefaults standardUserDefaults] objectForKey:iID_MaGiai_Str];
                
                NSMutableArray* list = [myCollection.listLivescore objectForKey:iID_MaGiai_Str];
                if(list == nil) {
                    // no record
                    list = [NSMutableArray new];
                    if(iID_MaGiai_Pinned) {
                        [myCollection.listLivescoreKeys insertObject:iID_MaGiai_Str atIndex:0];
                    } else {
                        [myCollection.listLivescoreKeys addObject:iID_MaGiai_Str];
                    }
                    
                } else {
                    // existed, update data then
                    LivescoreModel* oldModel = [self findModelByMaTran:list iID_MaTran:model.iID_MaTran];
                    if(oldModel != nil) {
                        ZLog(@"remove old model: %@", oldModel);
                        
                        if (oldModel.iCN_BanThang_DoiNha_FT != model.iCN_BanThang_DoiNha_FT ||
                            oldModel.iCN_BanThang_DoiKhach_FT != model.iCN_BanThang_DoiKhach_FT) {
                            model.isHighlightedView = YES;
                            
                        }
                        
                        if(oldModel.isHighlightedView) {
                            model.isHighlightedView = YES;
                        }
                        
                        [list removeObject:oldModel];
                    }
                    
                }
                [list addObject:model];
                
                [myCollection.listLivescore setObject:list forKey:iID_MaGiai_Str];
                
                
            }
#endif
            
            self.currCollection = myCollection;
            
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.lichDict setValue:myCollection forKey:[NSString stringWithFormat:@"%d", self.selectedDateIndex]];
                
                [self.tableView reloadData];
            });
            
            
        }
    }
    @catch (NSException *exception) {

        ZLog(@"error: %@", exception.message);
    }
    
    
    

    
    

    
}


#pragma  Admob
- (void)adViewDidReceiveAd:(GADBannerView *)view {

    self.tableView.tableHeaderView = view;

}

@end





@implementation LeagueDataTapGestureRecognizer
@end
