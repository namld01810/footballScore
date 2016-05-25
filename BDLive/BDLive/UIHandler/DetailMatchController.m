//
//  DetailMatchController.m
//  BDLive
//
//  Created by Khanh Le on 12/10/14.
//  Copyright (c) 2014 Khanh Le. All rights reserved.
//

#import "DetailMatchController.h"
#import "DetailMatchTableViewCell.h"
#import "GameTableViewCell.h"
#import "xs_common_inc.h"
#import "BDLiveGestureRecognizer.h"
#import "../Models/LivescoreModel.h"
#import "../SOAPHandler/SOAPHandler.h"
#import "../SOAPHandler/PresetSOAPMessage.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "StatsViewController.h"
#import "../Utils/XSUtils.h"
#import "../Models/DetailMatchModel.h"
#import "../Models/CommentModel.h"
#import "Perform/PViewController.h"
#import "PPiFlatSegmentedControl.h"
#import "MDStatsTableViewCell.h"
#import "../Models/MDStatsModel.h"
#import "../Models/PlayerModel.h"

#import "ChatZone/ChatViewController.h"

#import "LineupsTableViewCell.h"
#import "CommentTableViewCell.h"
#import "CommentBoxView.h"
#import "../Utils/NSString+MD5.h"
#import "UIGamePredictorRecognizer.h"
#import "../Models/AccInfo.h"
#import "GameAlertView.h"
#import "SettingsViewController.h"
#import "GamePredictorViewController.h"
#import "LineupTableHeaderSection.h"
#import "CoachTableViewCell.h"
#import "../AdNetwork/AdNetwork.h"



#define SEGMENTED_HEIGHT 27
#define NUMBER_PLAYER 11
#define MAX_LENGTH_SAO_INPUT 10


// SET BET ERROR CODE

static const int _BET_CODE_SUCCESS_ = 1; // ok
static const int _BET_CODE_ERROR_EBANK_ = -2; // ebank ko cho them dữ liệu
static const int _BET_CODE_ERROR_BALANCE_ = -3; // balance not enough
static const int _BET_CODE_ERROR_GENERIC_ = -1; // general error
static const int _BET_CODE_ERROR_AUTHEN_ = -4; // not login yet
static const int _BET_CODE_ERROR_REQUIRE_MIN_100_ = -5; // not login yet


@interface DetailMatchController () <UITableViewDelegate, UITableViewDataSource, SOAPHandlerDelegate, UITextFieldDelegate, UIAlertViewDelegate, GADBannerViewDelegate>

@property(nonatomic, strong) IBOutlet UITableView *tableView;

@property(nonatomic, strong) IBOutlet UIView *bxhView;

@property(nonatomic, strong) IBOutlet UIImageView *backImg;

@property(nonatomic, strong) IBOutlet UIActivityIndicatorView *actIndiView;

@property(nonatomic, strong) IBOutlet UIButton *reloadButton;

@property(nonatomic, strong) IBOutlet UIActivityIndicatorView *loadingIndicator;

@property(nonatomic, strong) NSMutableArray* datasource;

@property(nonatomic, strong) SOAPHandler *soapHandler;

@property(nonatomic, strong) NSTimer *timer;

@property(nonatomic, strong) NSTimer *commentTimer;

@property(nonatomic, strong) IBOutlet UILabel* hdrDetailMatch;


@property(nonatomic, strong) NSLayoutConstraint* gocConstraint;
@property(nonatomic, strong) NSLayoutConstraint* possConstraint;


//pin
@property(nonatomic, weak) IBOutlet UIImageView *pinImgView;
@property(nonatomic, weak) IBOutlet UIView *pinView;
@property(nonatomic, weak) IBOutlet UILabel *apRetLabel;


@property(nonatomic, strong) IBOutlet UIButton *gamePredictBtn;
@property(nonatomic, strong) IBOutlet UIButton *compPredictBtn;
@property(nonatomic, strong) IBOutlet UIButton *pdo_PredictBtn;


//goc, so huu bong
@property(nonatomic, strong) IBOutlet UILabel *gocLabel1;
@property(nonatomic, strong) IBOutlet UILabel *gocLabel2;
@property(nonatomic, strong) IBOutlet UILabel *gocLabel3;

@property(nonatomic, strong) IBOutlet UILabel *possLabel1;
@property(nonatomic, strong) IBOutlet UILabel *possLabel2;
@property(nonatomic, strong) IBOutlet UILabel *possLabel3;


@property(nonatomic) NSUInteger segmentedIndex;


@property(nonatomic, strong) NSMutableArray* statsList;
@property(nonatomic, strong) NSMutableDictionary* statsDict;


@property(nonatomic, strong) NSMutableArray* lineups_Nha;
@property(nonatomic, strong) NSMutableArray* lineups_Khach;

// subs
@property(nonatomic, strong) NSMutableArray* subs_Nha;
@property(nonatomic, strong) NSMutableArray* subs_Khach;

// coach
@property(nonatomic, strong) NSMutableArray* coach_Nha;
@property(nonatomic, strong) NSMutableArray* coach_Khach;

//referee
@property(nonatomic, strong) NSMutableArray* refereeList;

@property(nonatomic, strong) NSMutableArray* commentList;
@property(nonatomic, strong) NSMutableDictionary* commentDict;


@property(nonatomic, strong) UIView* commentBoxHolder;
@property(nonatomic, strong) CommentBoxView* commentBoxView;


@property(nonatomic, strong) PPiFlatSegmentedControl *segmentedView;


@property(nonatomic, strong) UIButton* commentButtonView;
@property(nonatomic, strong) UIView* commentHdrView;

@end

@implementation DetailMatchController


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if(self) {
        self.soapHandler = [[SOAPHandler alloc] init];
        self.soapHandler.delegate = self;
        self.datasource = [NSMutableArray new];
        self.segmentedIndex = 0;
        self.lineups_Khach = [NSMutableArray new];
        self.lineups_Nha = [NSMutableArray new];
        self.commentDict = [NSMutableDictionary new];
        self.commentList = [NSMutableArray new];
        
        self.commentButtonView = nil;

        
        
        self.subs_Nha = [NSMutableArray new];
        self.subs_Khach = [NSMutableArray new];
        self.coach_Nha = [NSMutableArray new];
        self.coach_Khach = [NSMutableArray new];
        self.refereeList = [NSMutableArray new];
        
        
        
        
        [self setupMDData];

    }
    
    return self;
}


-(void) setupCommentButtonView {
    
    self.commentHdrView = [[UIView alloc] initWithFrame:CGRectMake(0.f, 0, [UIScreen mainScreen].bounds.size.width-0.f, 33.f)];

    NSString* localizedTxt = [NSString stringWithFormat:@"%@", NSLocalizedString(@"CommentBoxView-comment.text", @"Comment")];
    self.commentButtonView = [[UIButton alloc] initWithFrame:CGRectMake(50.f, 3, self.commentHdrView.frame.size.width-100.f, 26.f)];
    self.commentButtonView.backgroundColor = [UIColor colorWithRed:(51.f/255.f) green:(51.f/255.f) blue:(51.f/255.f) alpha:1.f];
    [self.commentButtonView setTitle:localizedTxt forState:UIControlStateNormal];
    
    [self.commentButtonView addTarget:self action:@selector(onGamePredictClick:) forControlEvents:UIControlEventTouchUpInside];
    
    
    
    [[self.commentButtonView layer] setCornerRadius:3.0f];
    [[self.commentButtonView layer] setMasksToBounds:YES];
    
    
    [self.commentHdrView addSubview:self.commentButtonView];
    
}

-(void)setupCommentBoxView {
    CommentBoxView *boxView = [[[NSBundle mainBundle] loadNibNamed:@"CommentBoxView" owner:nil options:nil] objectAtIndex:0];
    [boxView.closeButton addTarget:self action:@selector(onCloseCommentBoxClicked:) forControlEvents:UIControlEventTouchUpInside];
    [boxView.sendButton addTarget:self action:@selector(onSendCommentBoxClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    self.commentBoxHolder = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
    self.commentBoxHolder.backgroundColor = [UIColor colorWithRed:207/255 green:207/255 blue:207/255 alpha:0.3f];
    boxView.frame = CGRectMake([UIScreen mainScreen].bounds.size.width/2 - 150, 50, 300.f, 200.f);
    [self.commentBoxHolder addSubview:boxView];
    self.commentBoxView = boxView;
}

-(void)setupMDData {
    self.statsDict = [NSMutableDictionary new];
    self.statsList = [NSMutableArray new];
    [self.statsList addObjectsFromArray:@[@"Poss", @"Corner", @"Shoot", @"Shoot_on_target", @"Shoot_off", @"Fouls", @"Yellow_cards", @"Red_cards", @"Off_side", @"Throw_in"]];
    
    
    
    [self.statsDict addEntriesFromDictionary:[MDStatsModel createDatasource]];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    
    [self renderData];
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:AUTO_REFRESH_MATCH_DETAIL target:self selector:@selector(autoRefreshData:) userInfo:nil repeats:YES];

    [self addNotification];
    
    [self setupBxhView];
    
    [self setupCornerPossessionInfo];
    
    
    [self setupCommentButtonView];
    
    [self setupSegmentedView];
    
    
    // setup nib files
    UINib *cell1 = [UINib nibWithNibName:@"MDStatsTableViewCell" bundle:nil];
    [self.tableView registerNib:cell1 forCellReuseIdentifier:@"MDStatsTableViewCell"];
    
    UINib *cell2 = [UINib nibWithNibName:@"LineupsTableViewCell" bundle:nil];
    [self.tableView registerNib:cell2 forCellReuseIdentifier:@"LineupsTableViewCell"];
    
    UINib *cell3 = [UINib nibWithNibName:@"CommentTableViewCell" bundle:nil];
    [self.tableView registerNib:cell3 forCellReuseIdentifier:@"CommentTableViewCell"];
    
    UINib *cell4 = [UINib nibWithNibName:@"GameTableViewCell" bundle:nil];
    [self.tableView registerNib:cell4 forCellReuseIdentifier:@"GameTableViewCell"];
    
    
    UINib *cell5 = [UINib nibWithNibName:@"CoachTableViewCell" bundle:nil];
    [self.tableView registerNib:cell5 forCellReuseIdentifier:@"CoachTableViewCell"];
    
    UINib *headerSectionLineup = [UINib nibWithNibName:@"LineupTableHeaderSection" bundle:nil];
    [self.tableView registerNib:headerSectionLineup forHeaderFooterViewReuseIdentifier:@"LineupTableHeaderSection"];
    
    
    

    

    
    // end setup nib files
    
    
    self.commentTimer = [NSTimer scheduledTimerWithTimeInterval:5.f target:self selector:@selector(doGet_List_MatchComment:) userInfo:nil repeats:YES];
    
    [self doGet_List_MatchComment:nil];
    

    
    NSString* localizeTxt = [NSString stringWithFormat:@"%@", NSLocalizedString(@"hdr-details.text", @"CHI TIẾT TRẬN ĐẤU")];
    self.hdrDetailMatch.text = localizeTxt;
    
    
    [self setupCommentBoxView];
    
    
    self.compPredictBtn.hidden = !self.matchModel.bMayTinhDuDoan;
    
    [self fetchGameDetailByMaTran];
    
    
    //pin
    self.pinView.hidden = NO;
    BDLiveGestureRecognizer* pin_tap = [[BDLiveGestureRecognizer alloc] initWithTarget:self action:@selector(onPinTap:)];
    pin_tap.sTenGiai = self.tenGiaiDau.text;
    pin_tap.iID_MaTran = [NSString stringWithFormat:@"%lu", self.matchModel.iID_MaTran];
    pin_tap.iID_MaGiai = [NSString stringWithFormat:@"%lu", self.matchModel.iID_MaGiai];
    pin_tap.numberOfTapsRequired = 1;
    pin_tap.logoGiaiUrl = self.matchModel.sLogoGiai;
    
//    pin_tap.pinButton = view.pinImageView;
    
    self.pinView.userInteractionEnabled = YES;
    [self.pinView addGestureRecognizer:pin_tap];
    
    
    NSString* val1 = [[NSUserDefaults standardUserDefaults] objectForKey:pin_tap.iID_MaGiai];
    if(val1) {
        self.pinImgView.image = [UIImage imageNamed:@"ic_pinned.png"];
    } else {
        self.pinImgView.image = [UIImage imageNamed:@"ic_pin.png"];
    }
    
    if (self.matchModel.iTrangThai == 9 || self.matchModel.iTrangThai == 15) {
        self.apRetLabel.hidden = NO;
        self.apRetLabel.text = [NSString stringWithFormat:@"AP %lu - %lu",self.matchModel.iCN_BanThang_DoiNha_Pen, self.matchModel.iCN_BanThang_DoiKhach_Pen];
    }

    [XSUtils setFontFamily:@"VNF-FUTURA" forView:self.view andSubViews:YES];
    
    
    [[AdNetwork sharedInstance] createAdMobBannerView:self admobDelegate:self tableView:self.tableView];
}

-(void)setupCornerPossessionInfo {
    float screenWidth = [UIScreen mainScreen].bounds.size.width;
    
    UIColor* greenC = [UIColor colorWithRed:(72/255.f) green:(174/255.f) blue:(34/255.f) alpha:1.0f];
    UIColor* redC = [UIColor colorWithRed:(230/255.f) green:0.f blue:0.f alpha:1.0f];
    
//    UIColor* blackC = [UIColor colorWithRed:(51/255.f) green:(51/255.f) blue:(51/255.f) alpha:1.0f];
    
    NSString* localizeTxt1 = [NSString stringWithFormat:@"%@", NSLocalizedString(@"hdr-goc-details-info.text", @"Goc")];
    NSString* localizeTxt2 = [NSString stringWithFormat:@"%@", NSLocalizedString(@"hdr-poss-details-info.text", @"So Huu bong")];
    self.gocLabel1.text = localizeTxt1;
    self.possLabel1.text = localizeTxt2;
    
    self.gocLabel2.backgroundColor = greenC;
    self.gocLabel3.backgroundColor = redC;
    self.gocLabel2.text = @"-";
    self.gocLabel3.text = @"-";
    
    self.possLabel2.backgroundColor = greenC;
    self.possLabel3.backgroundColor = redC;
    self.possLabel2.text = @"%";
    self.possLabel3.text = @"%";
    
    float tmp = (screenWidth-94)/2;
    

    self.possConstraint = [NSLayoutConstraint constraintWithItem:self.possLabel3
                                                       attribute:NSLayoutAttributeWidth
                                                       relatedBy:NSLayoutRelationEqual
                                                          toItem:nil
                                                       attribute:NSLayoutAttributeNotAnAttribute
                                                      multiplier:1.0
                                                        constant:tmp];
    self.gocConstraint = [NSLayoutConstraint constraintWithItem:self.gocLabel3
                                                      attribute:NSLayoutAttributeWidth
                                                      relatedBy:NSLayoutRelationEqual
                                                         toItem:nil
                                                      attribute:NSLayoutAttributeNotAnAttribute
                                                     multiplier:1.0
                                                       constant:tmp];
    
    
    
    [self.view addConstraint:self.possConstraint];
    [self.view addConstraint:self.gocConstraint];
}


-(void) setupSegmentedView
{
    
    NSString* tt = [NSString stringWithFormat:@"%@", NSLocalizedString(@"md-chi-tiet.text", @"Chi tiết")];
    NSString* lsdd = [NSString stringWithFormat:@"%@", NSLocalizedString(@"md-doi-hinh.text", @"Đội hình")];
    NSString* topdd = [NSString stringWithFormat:@"%@", NSLocalizedString(@"md-thong-ke.text", @"Thống kê")];
    NSString* comment = [NSString stringWithFormat:@"%@", NSLocalizedString(@"md-comment.text", @"Comment")];
    
    PPiFlatSegmentItem* item1 = [[PPiFlatSegmentItem alloc] initWithTitle:tt andIcon:nil];
    PPiFlatSegmentItem* item2 = [[PPiFlatSegmentItem alloc] initWithTitle:lsdd andIcon:nil];
    PPiFlatSegmentItem* item3 = [[PPiFlatSegmentItem alloc] initWithTitle:topdd andIcon:nil];
    PPiFlatSegmentItem* item4 = [[PPiFlatSegmentItem alloc] initWithTitle:comment andIcon:nil];
    PPiFlatSegmentItem* item5 = [[PPiFlatSegmentItem alloc] initWithTitle:@"Game" andIcon:nil];
    
    
    ZLog(@"view widthhh: %f", self.view.frame.size.width);
    
    
    PPiFlatSegmentedControl *segmented = [[PPiFlatSegmentedControl alloc] initWithFrame:CGRectMake(3, 225, [UIScreen mainScreen].bounds.size.width-6, SEGMENTED_HEIGHT) items:@[item1, item2, item3, item4, item5] iconPosition:IconPositionRight andSelectionBlock:^(NSUInteger segmentIndex) {
        ZLog(@"segment Index: %lu", segmentIndex);
        
        
        self.segmentedIndex = segmentIndex;
        
        if (segmentIndex == 3) {
            // discussion
            self.tableView.tableHeaderView = self.commentHdrView;
            
        } else {
            self.tableView.tableHeaderView = nil;
        }
        [self.tableView reloadData];
        
    } iconSeparation:0.0f];
    
    
    self.segmentedView = segmented;
 

    

    
    UIColor* mycolor = [UIColor colorWithRed:222.0f/255.0 green:83.0f/255.0 blue:0.0f/255.0 alpha:1];;
    segmented.color = mycolor;
    segmented.borderWidth=0.5f;
    segmented.borderColor=mycolor;
    segmented.selectedColor=[UIColor colorWithRed:255.0f/255.0 green:255.0f/255.0 blue:255.0f/255.0 alpha:1];
    segmented.textAttributes=@{NSFontAttributeName:[UIFont systemFontOfSize:9],
                               NSForegroundColorAttributeName:[UIColor whiteColor]};
    segmented.selectedTextAttributes=@{NSFontAttributeName:[UIFont systemFontOfSize:9],
                                       NSForegroundColorAttributeName:mycolor};
    
    
    
    
//    [self.infoView addSubview:segmented];
    
    [self.view addSubview:segmented];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)renderData
{

    self.clockImg.hidden = YES;

    __weak LivescoreModel *model = self.matchModel;
    self.tenDoiKhach.text = self.matchModel.sTenDoiKhach;
    self.tenDoiNha.text = self.matchModel.sTenDoiNha;
    self.tenGiaiDau.text = self.matchModel.sTenGiai;
    self.thoigianThiDau.text = [XSUtils toDayOfWeek:self.matchModel.dThoiGianThiDau];

    if(model.iTrangThai == 2 || model.iTrangThai == 4 || model.iTrangThai == 3)  {
        // live
        self.labelFT.text = @"LIVE";
        if(model.iTrangThai == 3) {
            self.labelFT.text = @"HT";
            
        } else {
            self.labelFT.text = [NSString stringWithFormat:@"%lu'",model.iCN_Phut];
        }
        
        //FT
        NSString* resultFT = [NSString stringWithFormat:@"%lu - %lu", (unsigned long)model.iCN_BanThang_DoiNha_FT, (unsigned long)model.iCN_BanThang_DoiKhach_FT];
        NSString* resultHT = [NSString stringWithFormat:@"HT %lu - %lu", (unsigned long)model.iCN_BanThang_DoiNha_HT, (unsigned long)model.iCN_BanThang_DoiKhach_HT];
        
        self.labelResult.text = resultFT;
        self.labelHT.text = resultHT;
        
    } else if(model.iTrangThai <= 1) {
        // chua da
        
        self.labelFT.text = model.sThoiGian;
        self.labelResult.text = @"";
        self.labelHT.text = @"";
        self.clockImg.hidden = NO;
        
    } else if(model.iTrangThai == 5 || model.iTrangThai == 8 ||
              model.iTrangThai == 9 || model.iTrangThai == 15){
        //FT
        NSString* resultFT = @"";
        if (model.iTrangThai == 8) {
            resultFT = [NSString stringWithFormat:@"%lu - %lu", model.iCN_BanThang_DoiNha_ET, model.iCN_BanThang_DoiKhach_ET];
        } else {
            resultFT = [NSString stringWithFormat:@"%lu - %lu", model.iCN_BanThang_DoiNha_FT, model.iCN_BanThang_DoiKhach_FT];
        }
        
        NSString* resultHT = [NSString stringWithFormat:@"HT %lu - %lu", model.iCN_BanThang_DoiNha_HT, model.iCN_BanThang_DoiKhach_HT];
        
        self.labelHT.text = resultHT;
        self.labelResult.text = resultFT;
        self.labelFT.text = @"FT";
        if (model.iTrangThai == 8 || model.iTrangThai == 9) {
            self.labelFT.text = @"AET";
            if(model.iTrangThai == 9) {
                if(model.iCN_BanThang_DoiNha_Pen > model.iCN_BanThang_DoiKhach_Pen) {
                    self.tenDoiNha.text = [NSString stringWithFormat:@"* %@", self.matchModel.sTenDoiNha];
                } else {
                    self.tenDoiKhach.text = [NSString stringWithFormat:@"* %@", self.matchModel.sTenDoiKhach];
                }
               
            }
        }
    } else if(model.iTrangThai == 6) {
        // extra time
        self.labelFT.text = [NSString stringWithFormat:@"90' + %lu'",model.iPhutThem];
        //FT
        NSString* resultFT = [NSString stringWithFormat:@"%lu - %lu", (unsigned long)model.iCN_BanThang_DoiNha_FT, (unsigned long)model.iCN_BanThang_DoiKhach_FT];
        NSString* resultHT = [NSString stringWithFormat:@"HT %lu - %lu", (unsigned long)model.iCN_BanThang_DoiNha_HT, (unsigned long)model.iCN_BanThang_DoiKhach_HT];
        
        self.labelResult.text = resultFT;
        self.labelHT.text = resultHT;
    }else if(model.iTrangThai == 7 || model.iTrangThai == 14) {
        // extra time
        self.labelFT.text = @"Pens";

        NSString* resultFT = [NSString stringWithFormat:@"%lu - %lu", model.iCN_BanThang_DoiNha_FT, model.iCN_BanThang_DoiKhach_FT];
        NSString* resultHT = [NSString stringWithFormat:@"HT %lu - %lu", model.iCN_BanThang_DoiNha_HT, model.iCN_BanThang_DoiKhach_HT];
        
        self.labelHT.text = resultHT;
        self.labelResult.text = resultFT;
    } else if(model.iTrangThai == 11) {
        // posts.
        self.labelResult.text = @"";
        self.labelHT.text = @"";
        self.clockImg.hidden = NO;
        
        NSString* localizedTxt = [NSString stringWithFormat:@"%@", NSLocalizedString(@"livescore-post-txt", @"Hoãn")];
        
        self.labelFT.text = localizedTxt;
    } else if(model.iTrangThai == 12 || model.iTrangThai == 99) {
        // extra time

        
        self.labelResult.text = @"";
        self.labelHT.text = @"";
        self.clockImg.hidden = NO;
        self.labelFT.text = @"CXĐ";
    } else if(model.iTrangThai == 13) {
        // extra time

        self.labelResult.text = @"";
        self.labelHT.text = @"";
        self.clockImg.hidden = NO;
        self.labelFT.text = @"Dừng";
    }else if(model.iTrangThai == 16) {
        // extra time

        self.labelResult.text = @"";
        self.labelHT.text = @"";
        self.clockImg.hidden = NO;
        self.labelFT.text = @"W.O";
    }
    
    
    
    
    [[SDWebImageManager sharedManager] downloadWithURL:[NSURL URLWithString:self.matchModel.sLogoGiai]
                                               options:0
                                              progress:^(NSInteger receivedSize, NSInteger expectedSize)
     {
         // progression tracking code
     }
                                             completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished)
     {
         if (image)
         {
             
             [XSUtils adjustUIImageView:self.flagImg image:image];
             self.flagImg.image = image;
             
         }
     }];
    
    
    [[SDWebImageManager sharedManager] downloadWithURL:[NSURL URLWithString:self.matchModel.sLogoDoiNha]
                                               options:0
                                              progress:^(NSInteger receivedSize, NSInteger expectedSize)
     {
         // progression tracking code
     }
                                             completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished)
     {
         if (image)
         {
             [XSUtils adjustUIImageView:self.logoDoiNha image:image];
             
             self.logoDoiNha.image = image;
             
         }
     }];
    
    [[SDWebImageManager sharedManager] downloadWithURL:[NSURL URLWithString:self.matchModel.sLogoDoiKhach]
                                               options:0
                                              progress:^(NSInteger receivedSize, NSInteger expectedSize)
     {
         // progression tracking code
     }
                                             completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished)
     {
         if (image)
         {
             
             [XSUtils adjustUIImageView:self.logoDoiKhach image:image];
             self.logoDoiKhach.image = image;
             
         }
     }];
    
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
    
    self.pinImgView.image = [UIImage imageNamed:imageNamed];
    
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.segmentedIndex == 1) {
        if(section == 0) {
            return NUMBER_PLAYER;
        } else if(section == 1){
            if(self.subs_Nha.count > 0) {
                return self.subs_Nha.count;
            } else {
                return self.subs_Khach.count;
            }
            
        }else if(section == 2){
            if(self.coach_Nha.count > 0) {
                return self.coach_Nha.count;
            } else {
                return self.coach_Khach.count;
            }
            
        } else {
            return self.refereeList.count;
        }
        
    } else if(self.segmentedIndex == 2) {
        return self.statsList.count;
    } else if(self.segmentedIndex == 3) {
        return self.commentList.count;
    } else if(self.segmentedIndex == 4) {
        if(self.matchModel && self.matchModel.bGameDuDoan) {
            return 1;
        }
        return 0;
    }
    return self.datasource.count;
}


- (DetailMatchTableViewCell*) createDetailMatchTableViewCell:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DetailMatchTableViewCell *cell = [[[NSBundle mainBundle] loadNibNamed:@"DetailMatchTableViewCell" owner:nil options:nil] objectAtIndex:0];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    DetailMatchModel *model = [self.datasource objectAtIndex:indexPath.row];
    
    if(indexPath.row % 2 == 1) {
        cell.contentView.backgroundColor = [UIColor colorWithRed:(240/255.f) green:(240/255.f) blue:(240/255.f) alpha:0.9f];
    }
    
    
    if(model.isHost == NO) {
        // khach
        cell.item1Label.hidden = YES;
        cell.item2Img.hidden = YES;
        cell.item3Label.hidden = YES;
        cell.item4Img.hidden = NO;
        cell.item5Img.hidden = NO;
        cell.item6Label.hidden = NO;
        
        
        ////0: the vang, 1: the do, 2: ghi ban, 3: ghi ban = pens
        if(model.stype == 0) {
            // the vang
            cell.item4Img.image = [UIImage imageNamed:@"chitiettrandau_40.png"];
        } else if(model.stype == 1) {
            // the do
            cell.item4Img.image = [UIImage imageNamed:@"chitiettrandau_43.png"];
        } else if(model.stype == 2) {
            // ghi ban
            cell.item4Img.image = [UIImage imageNamed:@"ball.png"];
        }else if(model.stype == 3) {
            // ghi ban = pens
            cell.item4Img.image = [UIImage imageNamed:@"ball-P.png"];
        }
        cell.item5Img.text = model.sPlayerName;
        cell.item6Label.text = model.sMinute;
    } else {
        // host
        cell.item1Label.hidden = NO;
        cell.item2Img.hidden = NO;
        cell.item3Label.hidden = NO;
        cell.item4Img.hidden = YES;
        cell.item5Img.hidden = YES;
        cell.item6Label.hidden = YES;
        if(model.stype == 0) {
            // the vang
            cell.item2Img.image = [UIImage imageNamed:@"chitiettrandau_40.png"];
        } else if(model.stype == 1) {
            // the do
            cell.item2Img.image = [UIImage imageNamed:@"chitiettrandau_43.png"];
        } else if(model.stype == 2) {
            // ghi ban
            cell.item2Img.image = [UIImage imageNamed:@"ball.png"];
        }else if(model.stype == 3) {
            // ghi ban = pens
            cell.item2Img.image = [UIImage imageNamed:@"ball-P.png"];
        }
        if([model.sMinute hasPrefix:@"0"] && NO) {
            cell.item1Label.text = [model.sMinute substringFromIndex:[@"0" length]];
        } else {
            cell.item1Label.text = model.sMinute;
        }
        
        cell.item3Label.text = model.sPlayerName;
    }
    return cell;
}

-(MDStatsTableViewCell*) createMDStatsTableViewCell:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MDStatsTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"MDStatsTableViewCell"];
    NSString* key = [self.statsList objectAtIndex:indexPath.row];
    MDStatsModel* model = [self.statsDict objectForKey:key];
    cell.sTitleLabel.text = model.val2;
    

    if ([key isEqualToString:@"Poss"]) {
        cell.sLeftInfoLabel.text = [NSString stringWithFormat:@"%@", @"%"];
        cell.sRightInfoLabel.text = [NSString stringWithFormat:@"%@", @"%"];
        if(model.val1 > 0 && model.val3 > 0) {
            cell.sLeftInfoLabel.text = [NSString stringWithFormat:@"%d%@", model.val1, @"%"];
            cell.sRightInfoLabel.text = [NSString stringWithFormat:@"%d%@", model.val3, @"%"];
            
            float lWidth = (cell.lpView.frame.size.width * model.val1) / 100.f;
            float rWidth = cell.lpView.frame.size.width - lWidth;
            
            if (lWidth > rWidth) {
                cell.lView.backgroundColor = [UIColor colorWithRed:(20/255.f) green:(103/255.f) blue:(148/255.f) alpha:1.f];
                cell.rView.backgroundColor = [UIColor colorWithRed:(128/255.f) green:(128/255.f) blue:(128/255.f) alpha:1.f];
            } else {
                cell.lView.backgroundColor = [UIColor colorWithRed:(128/255.f) green:(128/255.f) blue:(128/255.f) alpha:1.f];
                cell.rView.backgroundColor = [UIColor colorWithRed:(20/255.f) green:(103/255.f) blue:(148/255.f) alpha:1.f];
            }

            [cell.contentView addConstraint:[NSLayoutConstraint constraintWithItem:cell.lView
                                                                  attribute:NSLayoutAttributeWidth
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:nil
                                                                  attribute:NSLayoutAttributeNotAnAttribute
                                                                 multiplier:1.0
                                                                          constant:lWidth]];
            [cell.contentView addConstraint:[NSLayoutConstraint constraintWithItem:cell.rView
                                                                         attribute:NSLayoutAttributeWidth
                                                                         relatedBy:NSLayoutRelationEqual
                                                                            toItem:nil
                                                                         attribute:NSLayoutAttributeNotAnAttribute
                                                                        multiplier:1.0
                                                                          constant:rWidth]];
        }
    } else {
        cell.sLeftInfoLabel.text = [NSString stringWithFormat:@"-"];
        cell.sRightInfoLabel.text = [NSString stringWithFormat:@"-"];
        if (model.val1 >= 0) {
            cell.sLeftInfoLabel.text = [NSString stringWithFormat:@"%d", model.val1];
        }
        if(model.val3 >= 0) {
            cell.sRightInfoLabel.text = [NSString stringWithFormat:@"%d", model.val3];
        }
        

        float tong = model.val1 + model.val3;
        if (model.val1 >= 0 && model.val3 >= 0 && tong > 0) {


            float lWidth = (cell.lpView.frame.size.width * model.val1) / tong;
            float rWidth = cell.lpView.frame.size.width - lWidth;
            
            if (lWidth > rWidth) {
                cell.lView.backgroundColor = [UIColor colorWithRed:(20/255.f) green:(103/255.f) blue:(148/255.f) alpha:1.f];
                cell.rView.backgroundColor = [UIColor colorWithRed:(128/255.f) green:(128/255.f) blue:(128/255.f) alpha:1.f];
            } else {
                cell.lView.backgroundColor = [UIColor colorWithRed:(128/255.f) green:(128/255.f) blue:(128/255.f) alpha:1.f];
                cell.rView.backgroundColor = [UIColor colorWithRed:(20/255.f) green:(103/255.f) blue:(148/255.f) alpha:1.f];
            }
            
            [cell.contentView addConstraint:[NSLayoutConstraint constraintWithItem:cell.lView
                                                                         attribute:NSLayoutAttributeWidth
                                                                         relatedBy:NSLayoutRelationEqual
                                                                            toItem:nil
                                                                         attribute:NSLayoutAttributeNotAnAttribute
                                                                        multiplier:1.0
                                                                          constant:lWidth]];
            [cell.contentView addConstraint:[NSLayoutConstraint constraintWithItem:cell.rView
                                                                         attribute:NSLayoutAttributeWidth
                                                                         relatedBy:NSLayoutRelationEqual
                                                                            toItem:nil
                                                                         attribute:NSLayoutAttributeNotAnAttribute
                                                                        multiplier:1.0
                                                                          constant:rWidth]];
        }
    }
    
    
    return cell;
}




-(LineupsTableViewCell*) createSubsTableViewCell:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    LineupsTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"LineupsTableViewCell"];
    cell.leftLabel.text = @"-";
    cell.rightLabel.text = @"-";
    cell.leftNoLabel.text = @"-";
    cell.rightNoLabel.text = @"-";
    cell.leftSubImage.hidden = YES;
    cell.leftSubLabel.hidden = YES;
    cell.rightSubImage.hidden = YES;
    cell.rightSubLabel.hidden = YES;
    


    @try {
        PlayerModel* model_Nha = [self.subs_Nha objectAtIndex:indexPath.row];
        cell.leftLabel.text = model_Nha.playerName;
        cell.leftNoLabel.text = model_Nha.playerNo;

        if (model_Nha.subsType == SUBS_PLAYER_IN) {
            cell.leftSubLabel.hidden = NO;
            cell.leftSubImage.hidden = NO;
            cell.leftSubLabel.text = model_Nha.subsMin;
            cell.leftSubImage.image = [UIImage imageNamed:@"player_in.png"];
        } else if (model_Nha.subsType == SUBS_PLAYER_OUT) {
            cell.leftSubLabel.hidden = NO;
            cell.leftSubImage.hidden = NO;
            cell.leftSubLabel.text = model_Nha.subsMin;
            cell.leftSubImage.image = [UIImage imageNamed:@"player_out.png"];
        }
        
    }
    @catch (NSException *exception) {
        
    }
    
    @try {
        PlayerModel* model_Khach = [self.subs_Khach objectAtIndex:indexPath.row];
        cell.rightLabel.text = model_Khach.playerName;
        cell.rightNoLabel.text = model_Khach.playerNo;
        
        
        if (model_Khach.subsType == SUBS_PLAYER_IN) {
            cell.rightSubLabel.hidden = NO;
            cell.rightSubLabel.text = model_Khach.subsMin;
            cell.rightSubImage.image = [UIImage imageNamed:@"player_in.png"];
            cell.rightSubImage.hidden = NO;
        } else if (model_Khach.subsType == SUBS_PLAYER_OUT) {
            cell.rightSubLabel.hidden = NO;
            cell.rightSubLabel.text = model_Khach.subsMin;
            cell.rightSubImage.image = [UIImage imageNamed:@"player_out.png"];
            cell.rightSubImage.hidden = NO;
        }
    }
    @catch (NSException *exception) {
        
    }
    
    
    if(indexPath.row % 2 == 1) {
        cell.contentView.backgroundColor = [UIColor colorWithRed:(148/255.f) green:(193/255.f) blue:(250/255.f) alpha:0.9f];
    } else {
        cell.contentView.backgroundColor = [UIColor colorWithRed:(191/255.f) green:(214/255.f) blue:(255/255.f) alpha:0.9f];
    }
    
    return cell;
    
}



-(LineupsTableViewCell*) createLineupsTableViewCell:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    LineupsTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"LineupsTableViewCell"];
    cell.leftLabel.text = @"-";
    cell.rightLabel.text = @"-";
    cell.leftNoLabel.text = @"-";
    cell.rightNoLabel.text = @"-";
    cell.leftSubImage.hidden = YES;
    cell.leftSubLabel.hidden = YES;
    cell.rightSubImage.hidden = YES;
    cell.rightSubLabel.hidden = YES;
    
    
    
    
    @try {
        PlayerModel* model_Nha = [self.lineups_Nha objectAtIndex:indexPath.row];
        cell.leftLabel.text = model_Nha.playerName;
        cell.leftNoLabel.text = model_Nha.playerNo;
        
        if (model_Nha.subsType == SUBS_PLAYER_IN) {
            cell.leftSubLabel.hidden = NO;
            cell.leftSubLabel.text = model_Nha.subsMin;
            cell.leftSubImage.image = [UIImage imageNamed:@"player_in.png"];
        } else if (model_Nha.subsType == SUBS_PLAYER_OUT) {
            cell.leftSubLabel.hidden = NO;
            cell.leftSubLabel.text = model_Nha.subsMin;
            cell.leftSubImage.image = [UIImage imageNamed:@"player_out.png"];
            cell.leftSubImage.hidden = NO;
        }
        
    }
    @catch (NSException *exception) {
        
    }
    
    @try {
        PlayerModel* model_Khach = [self.lineups_Khach objectAtIndex:indexPath.row];
        cell.rightLabel.text = model_Khach.playerName;
        cell.rightNoLabel.text = model_Khach.playerNo;
        
        
        if (model_Khach.subsType == SUBS_PLAYER_IN) {
            cell.rightSubLabel.hidden = NO;
            cell.rightSubLabel.text = model_Khach.subsMin;
            cell.rightSubImage.image = [UIImage imageNamed:@"player_in.png"];
        } else if (model_Khach.subsType == SUBS_PLAYER_OUT) {
            cell.rightSubLabel.hidden = NO;
            cell.rightSubLabel.text = model_Khach.subsMin;
            cell.rightSubImage.image = [UIImage imageNamed:@"player_out.png"];
            cell.rightSubImage.hidden = NO;
        }
    }
    @catch (NSException *exception) {
        
    }
    
    
    if(indexPath.row % 2 == 1) {
        cell.contentView.backgroundColor = [UIColor colorWithRed:(148/255.f) green:(193/255.f) blue:(250/255.f) alpha:0.9f];
    } else {
        cell.contentView.backgroundColor = [UIColor colorWithRed:(191/255.f) green:(214/255.f) blue:(255/255.f) alpha:0.9f];
    }
    
    return cell;
    
}


-(CommentTableViewCell*) createCommentTableViewCell:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CommentTableViewCell* cell = [self.tableView dequeueReusableCellWithIdentifier:@"CommentTableViewCell"];
    
    
    NSString* key = [self.commentList objectAtIndex:indexPath.row];
    CommentModel *model = [self.commentDict objectForKey:key];
    
    cell.commentTxtView.scrollEnabled = NO;
    cell.commentTxtView.text = model.commentTxt;
    cell.dispNameLabel.text = model.displayName;
    
    cell.likeLabel.text = [NSString stringWithFormat:@"%ld", model.like];
    cell.dislikeLabel.text = [NSString stringWithFormat:@"%ld", model.unlike];
    
    NSDateFormatter *dateFormatter=[[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"HH:mm"];
    cell.dateLabel.text = [dateFormatter stringFromDate:model.commentDate];

    
    if (indexPath.row %2 == 1) {
        UIColor* color = [UIColor colorWithRed:(240/255.f) green:(240/255.f) blue:(240/255.f) alpha:0.9f];
        cell.contentView.backgroundColor = color;
        cell.commentTxtView.backgroundColor = color;
    } else {
        cell.contentView.backgroundColor = [UIColor whiteColor];
        cell.commentTxtView.backgroundColor = [UIColor whiteColor];
    }
    
    
    [cell.btnLike addTarget:self action:@selector(onLikeClicked:) forControlEvents:UIControlEventTouchUpInside];
    [cell.btnDislike addTarget:self action:@selector(onDisLikeClicked:) forControlEvents:UIControlEventTouchUpInside];
    cell.btnLike.model = model;
    cell.btnLike.cell = cell;
    cell.btnDislike.model = model;
    cell.btnDislike.cell = cell;
    
    BDLiveGestureRecognizer* likeTap = [[BDLiveGestureRecognizer alloc] initWithTarget:self action:@selector(onLikeClicked:)];
    likeTap.numberOfTapsRequired = 1;
    likeTap.mModel = model;
    likeTap.mCell = cell;
    [cell.likeLabel addGestureRecognizer:likeTap];
    
    
    
    BDLiveGestureRecognizer* dislikeTap = [[BDLiveGestureRecognizer alloc] initWithTarget:self action:@selector(onDisLikeClicked:)];
    dislikeTap.numberOfTapsRequired = 1;
    dislikeTap.mModel = model;
    dislikeTap.mCell = cell;
    [cell.dislikeLabel addGestureRecognizer:dislikeTap];
    
    


    return cell;
    
}

-(void)submitLikeRequest:(int)isLike sHash:(NSString*)sHash UserName:(NSString*)UserName {
    dispatch_queue_t myQueue = dispatch_queue_create("com.ptech.bxh", NULL);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), myQueue, ^{
        SOAPHandler* handler = [SOAPHandler new];
//        handler.delegate = self;
        [handler sendSOAPRequest:[PresetSOAPMessage get_Like_DisLike_MatchComment_SoapMessage:UserName iID_MaTran:[NSString stringWithFormat:@"%ld", self.iID_MaTran] Like_disLike:isLike sHash:sHash] soapAction:[PresetSOAPMessage get_Like_DisLike_MatchComment_SoapAction]];
    });
}

-(void)onLikeClicked:(id)sender {
    CommentTableViewCell* cell = nil;
    CommentModel* model = nil;
    
    if([sender isKindOfClass:[BDLiveGestureRecognizer class]]) {
        cell = ((CommentTableViewCell*)((BDLiveGestureRecognizer*)sender).mCell);
        model = ((BDLiveGestureRecognizer*)sender).mModel;
    } else {
        cell = ((CommentTableViewCell*)((BDButton*)sender).cell);
        model = ((BDButton*)sender).model;
    }
    
    
    model.like++;
    NSString* sHash = model.commentHash;
    NSString* UserName = model.displayName;
    cell.likeLabel.text = [NSString stringWithFormat:@"%ld", model.like];
    
    
    
    [self submitLikeRequest:1 sHash:sHash UserName:UserName];
}
-(void)onDisLikeClicked:(id)sender {
    
    CommentTableViewCell* cell = nil;
    CommentModel* model = nil;
    
    if([sender isKindOfClass:[BDLiveGestureRecognizer class]]) {
        cell = ((CommentTableViewCell*)((BDLiveGestureRecognizer*)sender).mCell);
        model = ((BDLiveGestureRecognizer*)sender).mModel;
    } else {
        cell = ((CommentTableViewCell*)((BDButton*)sender).cell);
        model = ((BDButton*)sender).model;
    }
    
    
    
    model.unlike++;

    NSString* sHash = model.commentHash;
    NSString* UserName = model.displayName;
    cell.dislikeLabel.text = [NSString stringWithFormat:@"%ld", model.unlike];
    
    [self submitLikeRequest:0 sHash:sHash UserName:UserName];
}


- (CGFloat)heightForText:(NSString *)bodyText havingWidth:(CGFloat)widthValue andFont:(UIFont *)font
{
    UIFont *cellFont = font;
    
    if (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_6_1) {
        NSAttributedString *attributedText =[[NSAttributedString alloc] initWithString:bodyText attributes:@
                                             {
                                             NSFontAttributeName: font
                                             }];
        
        CGRect rect = [attributedText boundingRectWithSize:(CGSize){widthValue, CGFLOAT_MAX}
                                                   options:NSStringDrawingUsesLineFragmentOrigin
                                                   context:nil];
        
        return rect.size.height + 20;
    } else {
        CGSize constraintSize = CGSizeMake(widthValue, MAXFLOAT);
        CGSize labelSize = [bodyText sizeWithFont:cellFont constrainedToSize:constraintSize lineBreakMode:UILineBreakModeWordWrap];
        CGFloat height = labelSize.height + 20;
        return height;
    }
    
    
    
    
    
    
    
    
    
    
}


- (CGFloat)findHeightForText:(NSString *)text havingWidth:(CGFloat)widthValue andFont:(UIFont *)font
{
    CGFloat result = font.pointSize + 4;

    
    if(YES) {
        result =  60.f + [self heightForText:text havingWidth:widthValue andFont:font];
        
        
        return result;
    }
    if (text)
    {
//        CGSize textSize = { widthValue, CGFLOAT_MAX };       //Width and height of text area
        CGSize size;
        if (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_6_1 && NO) { // khanh add for ios8 sdk
            CGRect stringRect = [text boundingRectWithSize:CGSizeMake(widthValue, CGFLOAT_MAX)
                                                  options:NSStringDrawingUsesLineFragmentOrigin
                                               attributes:@{ NSFontAttributeName : font }
                                                  context:nil];
            
            size = CGRectIntegral(stringRect).size;
        }
        else {
            size = [text sizeWithFont:font
                         constrainedToSize:CGSizeMake(widthValue, CGFLOAT_MAX)];
        }
        result = MAX(size.height, result); //At least one row
    }
    return result;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if(self.segmentedIndex == 1) {
        // lineup
        return 4;
        
    }
    return 1;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if(self.segmentedIndex == 1) {
        // lineup
        if(section > 0) {
            return 64.f;
        }
        return 0.f;
        
    }
    return 0.f;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    
    LineupTableHeaderSection *view = [self.tableView dequeueReusableHeaderFooterViewWithIdentifier:@"LineupTableHeaderSection"];
    NSString* hdrImage = @"ic_coach.png";
    NSString* hdrTitle = @"Coach";
    
//    view.frame = CGRectMake(0, 0, self.tableView.frame.size.width, 64.f);
    
    UIColor* bgColor = [[UIColor alloc] initWithRed:12.0/255.f green:40.0/255.f blue:26.0/255.f alpha:1.f];
    
    if(section == 1) {
        hdrImage = @"ic_subs.png";
        bgColor = [[UIColor alloc] initWithRed:23.0/255.f green:28.0/255.f blue:34.0/255.f alpha:1.f];
        hdrTitle = [NSString stringWithFormat:@"%@", NSLocalizedString(@"title_lineup1.txt", @"Subs")];
    } else if(section == 2) {
        hdrImage = @"ic_coach.png";
        hdrTitle = [NSString stringWithFormat:@"%@", NSLocalizedString(@"title_lineup2.txt", @"Coach")];
    } else if(section == 3) {
        hdrTitle = [NSString stringWithFormat:@"%@", NSLocalizedString(@"title_lineup3.txt", @"Reference")];
        hdrImage = @"ic_reference.png";
    }
    
    view.bgView.backgroundColor = bgColor;
    
    view.headerImage.image = [UIImage imageNamed:hdrImage];
    view.headerTitle.text = hdrTitle;

    
    return view;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.segmentedIndex == 0) {
        return 44.f;
    } else if(self.segmentedIndex == 1) {
        if(indexPath.section == 0 || indexPath.section == 1) {
            return 33.f;
        }
        return 55.f;
    } else if(self.segmentedIndex == 3) {
        NSString* key = [self.commentList objectAtIndex:indexPath.row];
        CommentModel* model = [self.commentDict objectForKey:key];
        float h =  model.commentHeight;
        
        if (h < 44.f) {
            h = 44.f;
        }
        return h;
    } else if(self.segmentedIndex == 4) {
        return 210.f;
    } else {
        return 25.0f;
    }
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (self.segmentedIndex == 0) {
        return [self createDetailMatchTableViewCell:tableView cellForRowAtIndexPath:indexPath];
    } else if(self.segmentedIndex == 1) {
        
        if (indexPath.section == 0) {
            return [self createLineupsTableViewCell:tableView cellForRowAtIndexPath:indexPath];
        } else if(indexPath.section == 1) {
            return [self createSubsTableViewCell:tableView cellForRowAtIndexPath:indexPath];
        } else {
          // referee
            
            CoachTableViewCell* cell = [self.tableView dequeueReusableCellWithIdentifier:@"CoachTableViewCell"];
            
            @try {
                cell.leftLabel.text = [self.coach_Nha objectAtIndex:0];
            }
            @catch (NSException *exception) {
                
            }
            @try {
                cell.rightLabel.text = [self.coach_Khach objectAtIndex:0];
            }
            @catch (NSException *exception) {
                
            }
            
            if(indexPath.section == 3) {
                cell.rightLabel.hidden = YES;
                cell.leftLabel.text = [self.refereeList objectAtIndex:0];
            } else {
                cell.rightLabel.hidden = NO;
            }
            
            return cell;
        }
        
        
        
        
        
    } else if(self.segmentedIndex == 2) {
        return [self createMDStatsTableViewCell:tableView cellForRowAtIndexPath:indexPath];
    } else if(self.segmentedIndex == 4) {
        // game
        return [self createGameTableViewCell:tableView cellForRowAtIndexPath:indexPath];
    } else {
        return [self createCommentTableViewCell:tableView cellForRowAtIndexPath:indexPath];
    }
    
    
}

-(GameTableViewCell*) createGameTableViewCell:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    LivescoreModel *model = self.matchModel;
    
    GameTableViewCell* cell = [self.tableView dequeueReusableCellWithIdentifier:@"GameTableViewCell"];
    cell.dateLabel.hidden = YES;
    cell.pdoBtn.hidden = YES;
    cell.compBtn.hidden = YES;
    cell.expertBtn.hidden = YES;
    cell.hostTeam.hidden = YES;
    cell.oppositeTeam.hidden = YES;
    cell.finalPredict.hidden = YES;
    BOOL isEnglish = YES;
    
    
    cell.pdoBtn.model = model;
    cell.compBtn.model = model;
    cell.expertBtn.model = model;
    
    
    NSArray* list = [[NSUserDefaults standardUserDefaults] objectForKey:@"AppleLanguages"];
    if (list.count > 0) {
        NSString* lang = [list objectAtIndex:0];
        if ([lang isEqualToString:@"vi"]) {
            isEnglish = NO;
        } else {
            isEnglish = YES;
        }
    }
    
    if (isEnglish) {
        //        [cell.g_underBtn setBackgroundImage:[UIImage imageNamed:@"ic_bet_box_u.png"] forState:UIControlStateNormal];
        //        [cell.g_overBtn setBackgroundImage:[UIImage imageNamed:@"ic_bet_box_o.png"] forState:UIControlStateNormal];
    } else {
        [cell.g_underBtn setBackgroundImage:[UIImage imageNamed:@"ic_bet_box_u_vn.png"] forState:UIControlStateNormal];
        [cell.g_overBtn setBackgroundImage:[UIImage imageNamed:@"ic_bet_box_o_vn.png"] forState:UIControlStateNormal];
    }
    
    [GamePredictorViewController updateLiveScoreTableViewCell:cell model:model];
    
    
    cell.iTrangThai = model.iTrangThai;
    cell.originalKeo.hidden = YES;
    
    if (model.iTrangThai == 2 || model.iTrangThai == 4 ||
        model.iTrangThai == 3 || model.iTrangThai == 5 ||
        model.iTrangThai == 8 || model.iTrangThai == 9 || model.iTrangThai == 15) {
        // Fulltime match
        if(model.iTrangThai == 5 || model.iTrangThai == 8 ||
           model.iTrangThai == 9 || model.iTrangThai == 15) {
            cell.tyleCuoc.text = @"FT";
            if (model.iTrangThai == 8 || model.iTrangThai == 9) {
                cell.tyleCuoc.text = @"AET";
            }
        } else if(model.iTrangThai == 3) {
            cell.tyleCuoc.text = @"HT";
        } else {
            cell.tyleCuoc.text = [NSString stringWithFormat:@"%d'", model.iCN_Phut];
        }
        
        [cell setNSBorder:[UIColor grayColor]];
        cell.originalKeo.hidden = NO;
        cell.originalKeo.text = [model get_sTyLe_ChapBong:model.sTyLe_ChapBong];
    } else {
        cell.tyleCuoc.text = [model get_sTyLe_ChapBong:model.sTyLe_ChapBong];
        [cell setNSBorder:nil];
    }
    
//    cell.dateLabel.text = [XSUtils toDayOfWeek:model.dThoiGianThiDau];
    
    
    
    NSString* resultFT = @"";
    if (model.iTrangThai == 8) {
        resultFT = [NSString stringWithFormat:@"%lu - %lu", model.iCN_BanThang_DoiNha_ET, model.iCN_BanThang_DoiKhach_ET];
    } else {
        resultFT = [NSString stringWithFormat:@"%lu - %lu", model.iCN_BanThang_DoiNha_FT, model.iCN_BanThang_DoiKhach_FT];
    }
    cell.finalPredict.text = [NSString stringWithFormat:@"[%@]", resultFT];
    
    if(model.iTrangThai == 2 || model.iTrangThai == 4 || model.iTrangThai == 3 || model.iTrangThai == 5 ||
       model.iTrangThai == 8 || model.iTrangThai == 9 || model.iTrangThai == 15)  {
        // live match
    } else {
        cell.finalPredict.text = @"[ ? - ? ]";
    }
    
    
    cell.hostNS.userInteractionEnabled = NO;
    UIGamePredictorRecognizer *tap = [[UIGamePredictorRecognizer alloc] initWithTarget:self action:@selector(onHostNSClick:)];
    tap.numberOfTapsRequired = 1;
    tap.cell = cell;
    [cell.hostNS addGestureRecognizer:tap];
    
    cell.oppositeNS.userInteractionEnabled = NO;
    UIGamePredictorRecognizer *tap2 = [[UIGamePredictorRecognizer alloc] initWithTarget:self action:@selector(onOppositeNSClick:)];
    tap2.numberOfTapsRequired = 1;
    tap2.cell = cell;
    [cell.oppositeNS addGestureRecognizer:tap2];
    
    NSString* localizeDD = [NSString stringWithFormat:@"%@", NSLocalizedString(@"game-DD.txt", @"Đã đặt")];
    
    cell.hostDD.text = [NSString stringWithFormat:@"%@: %@ ☆",localizeDD, [XSUtils format_iBalance:model.SoSaoDatDoiNha]];
    cell.oppositeDD.text = [NSString stringWithFormat:@"%@: %@ ☆",localizeDD, [XSUtils format_iBalance:model.SoSaoDatDoiKhach]];
    
    if(model.SoSaoDatDoiKhach > 0.f) {
        model.isHighlightKhach = YES;
    }
    
    if (model.SoSaoDatDoiNha > 0.f) {
        model.isHighlightNha = YES;
    }
    
    // fill data chau au, tai xiu
    cell.g_DD_1x2_Nha.text = [NSString stringWithFormat:@"%@: %@ ☆",localizeDD, [XSUtils format_iBalance:model.SaoDat1]];
    cell.g_DD_1x2_Khach.text = [NSString stringWithFormat:@"%@: %@ ☆",localizeDD, [XSUtils format_iBalance:model.SaoDat2]];
    cell.g_xLabel.text = [NSString stringWithFormat:@"%@ ☆", [XSUtils format_iBalance:model.SaoDatX]];
    
    cell.g_DD_uo_Nha.text = [NSString stringWithFormat:@"%@: %@ ☆",localizeDD, [XSUtils format_iBalance:model.SaoDatU]];
    
    cell.g_DD_uo_Khach.text = [NSString stringWithFormat:@"%@: %@ ☆",localizeDD, [XSUtils format_iBalance:model.SaoDatO]];
    
    
    
    if (model.SaoDat1 > 0.f) {
        model.isHighlight_1x2_1 = YES;
    }
    if (model.SaoDatX > 0.f) {
        model.isHighlight_1x2_x = YES;
    }
    if (model.SaoDat2 > 0.f) {
        model.isHighlight_1x2_2 = YES;
    }
    
    if (model.SaoDatU > 0.f) {
        model.isHighlight_uo_u = YES;
    }
    if (model.SaoDatO > 0.f) {
        model.isHighlight_uo_o = YES;
    }
    
    
    
    
    UIColor *mColor = [[UIColor alloc] initWithRed:230.0/255.f green:0.f blue:0.f alpha:1.f];
    
    if (model.isHighlightNha) {
        cell.hostDD.textColor = mColor;
    } else {
        cell.hostDD.textColor = [UIColor blackColor];
    }
    
    
    
    if (model.isHighlightKhach) {
        cell.oppositeDD.textColor = mColor;
    } else {
        cell.oppositeDD.textColor = [UIColor blackColor];
    }
    
    
    // highlight now
    if (model.isHighlight_1x2_1) {
        cell.g_DD_1x2_Nha.textColor = mColor;
    } else {
        cell.g_DD_1x2_Nha.textColor = [UIColor blackColor];
    }
    if (model.isHighlight_1x2_x) {
        cell.g_xLabel.textColor = mColor;
    } else {
        cell.g_xLabel.textColor = [UIColor blackColor];
    }
    if (model.isHighlight_1x2_2) {
        cell.g_DD_1x2_Khach.textColor = mColor;
    } else {
        cell.g_DD_1x2_Khach.textColor = [UIColor blackColor];
    }
    
    if (model.isHighlight_uo_u) {
        cell.g_DD_uo_Nha.textColor = mColor;
    } else {
        cell.g_DD_uo_Nha.textColor = [UIColor blackColor];
    }
    
    if (model.isHighlight_uo_o) {
        cell.g_DD_uo_Khach.textColor = mColor;
    } else {
        cell.g_DD_uo_Khach.textColor = [UIColor blackColor];
    }
    
    
    
    
    // fill data for ty le
    
    [self fillData_TyLe_CaCuoc:cell model:model];
    [self setupEventHandlerForCell:cell model:model];
    
    
    
    
    
    cell.htButton.userInteractionEnabled = YES;
    UIGamePredictorRecognizer *tap3 = [[UIGamePredictorRecognizer alloc] initWithTarget:self action:@selector(onHtClick:)];
    tap3.numberOfTapsRequired = 1;
    tap3.cell = cell;
    [cell.htButton addGestureRecognizer:tap3];
    
    [cell.hostSlider addTarget:self action:@selector(onHostSliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    cell.hostSlider.cell = cell;
    
    [cell.oppositeSlider addTarget:self action:@selector(onOppositeSliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    cell.oppositeSlider.cell = cell;

    
    return cell;
}


-(void)onHostSliderValueChanged:(GameSlider*)sender
{
    ZLog(@"onHostSliderValueChanged");
    GameTableViewCell *cell = sender.cell;
    
    NSString* localizeDD = [NSString stringWithFormat:@"%@", NSLocalizedString(@"game-DD.txt", @"Đã đặt")];
    cell.hostDD.text = [NSString stringWithFormat:@"%@: %d",localizeDD, (int)round(sender.value)];
}

-(void)onOppositeSliderValueChanged:(GameSlider*)sender
{
    ZLog(@"onOppositeSliderValueChanged");
    GameTableViewCell *cell = sender.cell;
    NSString* localizeDD = [NSString stringWithFormat:@"%@", NSLocalizedString(@"game-DD.txt", @"Đã đặt")];
    cell.oppositeDD.text = [NSString stringWithFormat:@"%@: %d",localizeDD, (int)round(sender.value)];
    
}


-(void) onHtClick:(UIGamePredictorRecognizer*) sender
{
    
    NSString* keyReg = [[NSUserDefaults standardUserDefaults] objectForKey:REGISTRATION_DEVICE_TOKEN_KEY];
    if(keyReg == nil) {
        NSString* localizeMsg = [NSString stringWithFormat:@"%@", NSLocalizedString(@"game-forbiden.txt", @"Bạn phải đăng nhập để sử dụng chức năng này.")];
        NSString* btnCancel = [NSString stringWithFormat:@"%@", NSLocalizedString(@"btn-decline.txt", @"Huỷ")];
        NSString* btnSignin = [NSString stringWithFormat:@"%@", NSLocalizedString(@"btn-sign-in.txt", @"Đăng nhập")];
        
        
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:nil message:localizeMsg delegate:self cancelButtonTitle:btnCancel otherButtonTitles:btnSignin, nil];
        
        [alert show];
        return;
    }
    
//    GameTableViewCell *cell = sender.cell;
    
    //    [self _onSubmitSetbet:cell];
    
    
}


-(void)onBetGameClick:(BetGameButton*) sender {
    NSString* keyReg = [[NSUserDefaults standardUserDefaults] objectForKey:REGISTRATION_DEVICE_TOKEN_KEY];
    if(keyReg == nil) {
        NSString* localizeMsg = [NSString stringWithFormat:@"%@", NSLocalizedString(@"game-forbiden.txt", @"Bạn phải đăng nhập để sử dụng chức năng này.")];
        NSString* btnCancel = [NSString stringWithFormat:@"%@", NSLocalizedString(@"btn-decline.txt", @"Huỷ")];
        NSString* btnSignin = [NSString stringWithFormat:@"%@", NSLocalizedString(@"btn-sign-in.txt", @"Đăng nhập")];
        
        
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:nil message:localizeMsg delegate:self cancelButtonTitle:btnCancel otherButtonTitles:btnSignin, nil];
        [alert show];
        return;
    }
    
    GameTableViewCell *cell = sender.cell;
    if (cell.iTrangThai != 5 &&
        cell.iTrangThai != 8 && cell.iTrangThai != 9 && cell.iTrangThai != 15) {
        if (sender.bet_type == 0) {
            // bet theo chau a
            if (sender.picked == 1) {
                [self showNSDiaglog:YES cell:cell];
            } else {
                [self showNSDiaglog:NO cell:cell];
            }
            
        } else if(sender.bet_type == 1 || sender.bet_type == 2) {
            // bet theo chau au
            [self showHandicapDiaglog:sender.bet_type cell:cell pick:sender.picked];
        }
        
        
    } else {
        NSString* localizeMsg = [NSString stringWithFormat:@"%@", NSLocalizedString(@"game-match-ft.txt", @"tran dau ket thuc")];
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:nil message:localizeMsg delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert show];
    }
}





-(void) setupEventHandlerForCell:(GameTableViewCell*) cell model:(LivescoreModel*)model {
    
    if(YES) {
        // bet cho chau A
        cell.g_asiaBtn_Nha.cell = cell;
        cell.g_asiaBtn_Nha.bet_type = 0;
        cell.g_asiaBtn_Nha.picked = 1;
        [cell.g_asiaBtn_Nha addTarget:self action:@selector(onBetGameClick:) forControlEvents:UIControlEventTouchUpInside];
        
        cell.g_asiaBtn_Khach.cell = cell;
        cell.g_asiaBtn_Khach.bet_type = 0;
        cell.g_asiaBtn_Khach.picked = 2;
        [cell.g_asiaBtn_Khach addTarget:self action:@selector(onBetGameClick:) forControlEvents:UIControlEventTouchUpInside];
        
    }
    
    
    
    if(YES) {
        // bet cho chau Au
        cell.g_1x2Btn_Nha.cell = cell;
        cell.g_1x2Btn_Nha.bet_type = 1;
        cell.g_1x2Btn_Nha.picked = 1;
        [cell.g_1x2Btn_Nha addTarget:self action:@selector(onBetGameClick:) forControlEvents:UIControlEventTouchUpInside];
        
        
        
        cell.g_1x2Btn_Khach.cell = cell;
        cell.g_1x2Btn_Khach.bet_type = 1;
        cell.g_1x2Btn_Khach.picked = 2;
        [cell.g_1x2Btn_Khach addTarget:self action:@selector(onBetGameClick:) forControlEvents:UIControlEventTouchUpInside];
        
        
        
        cell.g_xButton.cell = cell;
        cell.g_xButton.bet_type = 1;
        cell.g_xButton.picked = 0;
        [cell.g_xButton addTarget:self action:@selector(onBetGameClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    
    
    
    if(YES) {
        // bet tai suu
        cell.g_underBtn.cell = cell;
        cell.g_underBtn.bet_type = 2;
        cell.g_underBtn.picked = 1;
        [cell.g_underBtn addTarget:self action:@selector(onBetGameClick:) forControlEvents:UIControlEventTouchUpInside];
        
        
        cell.g_overBtn.cell = cell;
        cell.g_overBtn.bet_type = 2;
        cell.g_overBtn.picked = 2;
        [cell.g_overBtn addTarget:self action:@selector(onBetGameClick:) forControlEvents:UIControlEventTouchUpInside];
        
    }
}



-(void) fillData_TyLe_CaCuoc:(GameTableViewCell*) cell model:(LivescoreModel*)model {
    //    @"sTyLe_TaiSuu" : @"1.00*2 1/2*0.90"
    @try {
        NSArray* list = [model.sTyLe_TaiSuu componentsSeparatedByString:@"*"];
        cell.g_overTyle.text = [list objectAtIndex:0];
        cell.g_tyleTaiXiu.text = [list objectAtIndex:1];
        cell.g_underTyle.text = [list objectAtIndex:2];
    }
    @catch (NSException *exception) {
        //
    }
    
    
    //@"sTyLe_ChauAu" : @"1.87*3.45*4.65"
    @try {
        NSArray* list = [model.sTyLe_ChauAu componentsSeparatedByString:@"*"];
        cell.g_1x2Tyle_1.text = [list objectAtIndex:0];
        cell.g_1x2Tyle_x.text = [list objectAtIndex:1];
        cell.g_1x2Tyle_2.text = [list objectAtIndex:2];
    }
    @catch (NSException *exception) {
        //
    }
    
    
    //@"sTyLe_ChapBong" : @"0.87*0 : 1/2*-0.93"
    @try {
        NSArray* list = [model.sTyLe_ChapBong componentsSeparatedByString:@"*"];
        cell.g_asiaTyle_Nha.text = [list objectAtIndex:0];
        
        cell.g_asiaTyleKhach.text = [list objectAtIndex:2];
    }
    @catch (NSException *exception) {
        //
    }
}

-(void) onHostNSClick:(UIGamePredictorRecognizer*) sender
{
    NSString* keyReg = [[NSUserDefaults standardUserDefaults] objectForKey:REGISTRATION_DEVICE_TOKEN_KEY];
    if(keyReg == nil) {
        NSString* localizeMsg = [NSString stringWithFormat:@"%@", NSLocalizedString(@"game-forbiden.txt", @"Bạn phải đăng nhập để sử dụng chức năng này.")];
        NSString* btnCancel = [NSString stringWithFormat:@"%@", NSLocalizedString(@"btn-decline.txt", @"Huỷ")];
        NSString* btnSignin = [NSString stringWithFormat:@"%@", NSLocalizedString(@"btn-sign-in.txt", @"Đăng nhập")];
        
        
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:nil message:localizeMsg delegate:self cancelButtonTitle:btnCancel otherButtonTitles:btnSignin, nil];
        [alert show];
        return;
    }
    
    GameTableViewCell *cell = sender.cell;
    if (cell.iTrangThai != 5 &&
        cell.iTrangThai != 8 && cell.iTrangThai != 9 && cell.iTrangThai != 15) {
        
        [self showNSDiaglog:YES cell:cell];
    } else {
        NSString* localizeMsg = [NSString stringWithFormat:@"%@", NSLocalizedString(@"game-match-ft.txt", @"tran dau ket thuc")];
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:nil message:localizeMsg delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert show];
    }
    
    
    //    cell.hostNS.hidden = YES;
    //    cell.hostSlider.hidden = NO;
    
}



-(void) onXButtonNSClick:(UIGamePredictorRecognizer*) sender
{
    NSString* keyReg = [[NSUserDefaults standardUserDefaults] objectForKey:REGISTRATION_DEVICE_TOKEN_KEY];
    if(keyReg == nil) {
        NSString* localizeMsg = [NSString stringWithFormat:@"%@", NSLocalizedString(@"game-forbiden.txt", @"Bạn phải đăng nhập để sử dụng chức năng này.")];
        NSString* btnCancel = [NSString stringWithFormat:@"%@", NSLocalizedString(@"btn-decline.txt", @"Huỷ")];
        NSString* btnSignin = [NSString stringWithFormat:@"%@", NSLocalizedString(@"btn-sign-in.txt", @"Đăng nhập")];
        
        
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:nil message:localizeMsg delegate:self cancelButtonTitle:btnCancel otherButtonTitles:btnSignin, nil];
        
        [alert show];
        return;
    }
    
    
    GameTableViewCell *cell = sender.cell;
    if (cell.iTrangThai != 5 &&
        cell.iTrangThai != 8 && cell.iTrangThai != 9 && cell.iTrangThai != 15) {
        
        [self showNSDiaglog:NO cell:cell];
    }
    
    
    //    cell.oppositeNS.hidden = YES;
    //    cell.oppositeSlider.hidden = NO;
}

-(void) onOppositeNSClick:(UIGamePredictorRecognizer*) sender
{
    NSString* keyReg = [[NSUserDefaults standardUserDefaults] objectForKey:REGISTRATION_DEVICE_TOKEN_KEY];
    if(keyReg == nil) {
        NSString* localizeMsg = [NSString stringWithFormat:@"%@", NSLocalizedString(@"game-forbiden.txt", @"Bạn phải đăng nhập để sử dụng chức năng này.")];
        NSString* btnCancel = [NSString stringWithFormat:@"%@", NSLocalizedString(@"btn-decline.txt", @"Huỷ")];
        NSString* btnSignin = [NSString stringWithFormat:@"%@", NSLocalizedString(@"btn-sign-in.txt", @"Đăng nhập")];
        
        
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:nil message:localizeMsg delegate:self cancelButtonTitle:btnCancel otherButtonTitles:btnSignin, nil];
        
        [alert show];
        return;
    }
    
    
    GameTableViewCell *cell = sender.cell;
    if (cell.iTrangThai != 5 &&
        cell.iTrangThai != 8 && cell.iTrangThai != 9 && cell.iTrangThai != 15) {
        
        [self showNSDiaglog:NO cell:cell];
    } else {
        NSString* localizeMsg = [NSString stringWithFormat:@"%@", NSLocalizedString(@"game-match-ft.txt", @"tran dau ket thuc")];
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:nil message:localizeMsg delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert show];
    }
    
    
    //    cell.oppositeNS.hidden = YES;
    //    cell.oppositeSlider.hidden = NO;
}





-(void)textFieldDidChange:(UITextField *)theTextField
{
    ZLog(@"text changed: %@", theTextField.text);
    
    //    NSString *textFieldText = [theTextField.text stringByReplacingOccurrencesOfString:@"," withString:@""];
    //
    //    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    //    [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
    //    NSString *formattedOutput = [formatter stringFromNumber:[NSNumber numberWithInt:[textFieldText integerValue]]];
    //    textField.text = [XSUtils format_iBalance:[textField.text ]];
    if (theTextField.text && theTextField.text.length > 2) {
        theTextField.text = [theTextField.text stringByReplacingOccurrencesOfString:@"," withString:@""];
        theTextField.text = [theTextField.text stringByReplacingOccurrencesOfString:@"." withString:@""];
        theTextField.text = [XSUtils format_iBalance:[theTextField.text integerValue]];
    }
    
    
}

-(void)showHandicapDiaglog:(NSUInteger)bet_type cell:(GameTableViewCell*)cell pick:(NSUInteger)picked {
    NSString* selectedTeam = @"";
    NSString* retKeo = @"";
    NSString* tyleTien = @"";
    
    if (bet_type == 1) {
        if (picked == 1) {
            // pick chu nha
            tyleTien = cell.g_1x2Tyle_1.text;
            selectedTeam = @"1";
        } else if(picked == 2) {
            // pick khach
            tyleTien = cell.g_1x2Tyle_2.text;
            selectedTeam = @"2";
        } else if(picked == 0) {
            // chon X: Hoa
            tyleTien = cell.g_1x2Tyle_x.text;
            selectedTeam = @"X";
        }
    } else if(bet_type == 2) {
        if (picked == 1) {
            // pick under (xiu)
            NSString* localizeX = [NSString stringWithFormat:@"%@", NSLocalizedString(@"game-xiu-txt", @"Xiu")];
            tyleTien = cell.g_underTyle.text;
            selectedTeam = [NSString stringWithFormat:@"%@ %@", localizeX, cell.g_tyleTaiXiu.text];
        } else if(picked == 2) {
            // pick over (tai)
            NSString* localizeX = [NSString stringWithFormat:@"%@", NSLocalizedString(@"game-tai-txt", @"Tai")];
            tyleTien = cell.g_overTyle.text;
            selectedTeam = [NSString stringWithFormat:@"%@ %@", localizeX, cell.g_tyleTaiXiu.text];
            
        }
    }
    
    
    if([tyleTien isEqualToString:@""]) {
        return;
    }
    
    
    NSString* tysoHt = cell.finalPredict.text;
    tysoHt = [tysoHt stringByReplacingOccurrencesOfString:@"?" withString:@"0"];
    tysoHt = [tysoHt stringByReplacingOccurrencesOfString:@"[ " withString:@"["];
    tysoHt = [tysoHt stringByReplacingOccurrencesOfString:@" ]" withString:@"]"];
    
    
    
    
    tyleTien = [NSString stringWithFormat:@"%@ %@%@", tyleTien, @"@", tysoHt];
    
    
    NSString* localizeD = [NSString stringWithFormat:@"%@", NSLocalizedString(@"btn-proceed.txt", @"Đặt")];
    NSString* localizeH = [NSString stringWithFormat:@"%@", NSLocalizedString(@"btn-decline.txt", @"Huỷ")];
    NSString* localizeB = [NSString stringWithFormat:@"%@", NSLocalizedString(@"btn-balance.txt", @"Số dư")];
    NSString* localizeSelect = [NSString stringWithFormat:@"%@", NSLocalizedString(@"btn-select.txt", @"Đặt")];
    
    
    NSString* iBalance = [NSString stringWithFormat:@"%@: %@ ☆", localizeB, [XSUtils format_iBalance:[AccInfo sharedInstance].iBalance]];
    
    
    
    GameAlertView *myAlertView = [[GameAlertView alloc] initWithTitle:[NSString stringWithFormat:@"%@ %@ %@", cell.hostTeam.text, cell.tyleCuoc.text, cell.oppositeTeam.text]
                                                              message:[NSString stringWithFormat:@"%@\n%@ %@ %@ %@%@",iBalance, localizeSelect, selectedTeam, retKeo, @"@", tyleTien] delegate:self cancelButtonTitle:localizeH otherButtonTitles:localizeD, nil];
    myAlertView.isHost = YES;
    myAlertView.cellObj = cell;
    myAlertView.picked = picked;
    myAlertView.bet_type = bet_type;
    myAlertView.iTyLeTien = [tyleTien floatValue];
    
    
    
    
    
    myAlertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    UITextField *textField = [myAlertView textFieldAtIndex:0];
    textField.keyboardType = UIKeyboardTypeNumberPad;
    textField.textAlignment = NSTextAlignmentCenter;
    textField.delegate = self;
    [textField addTarget:self
                  action:@selector(textFieldDidChange:)
        forControlEvents:UIControlEventEditingChanged];
    
    
    [myAlertView show];
}

-(void)showNSDiaglog:(BOOL)isHost cell:(GameTableViewCell*)cell
{
    //    NSLocalizedString(@"Xin mời nhập số sao muốn đặt:", @"NS_dialog_msg")
    NSString* selectedTeam = cell.oppositeTeam.text;
    NSString* retKeo = @"";
    NSString* tyleTien = cell.g_asiaTyle_Nha.text;
    
    if (isHost) {
        selectedTeam = cell.hostTeam.text;
        tyleTien = cell.g_asiaTyle_Nha.text;
    } else {
        tyleTien = cell.g_asiaTyleKhach.text;
    }
    
    if([tyleTien isEqualToString:@""]) {
        return;
    }
    
    
    NSString* tysoHt = cell.finalPredict.text;
    tysoHt = [tysoHt stringByReplacingOccurrencesOfString:@"?" withString:@"0"];
    tysoHt = [tysoHt stringByReplacingOccurrencesOfString:@"[ " withString:@"["];
    tysoHt = [tysoHt stringByReplacingOccurrencesOfString:@" ]" withString:@"]"];
    
    
    
    
    tyleTien = [NSString stringWithFormat:@"%@ %@%@", tyleTien, @"@", tysoHt];
    
    
    float tmpRetKeo = [XSUtils get_tyleChapBong_SetBet:cell.tyleCuoc.text isHost:isHost];
    if(tmpRetKeo > 0) {
        retKeo = [NSString stringWithFormat:@"+%.2f", tmpRetKeo];
    } else {
        retKeo = [NSString stringWithFormat:@"%.2f", tmpRetKeo];
    }
    
    NSString* localizeD = [NSString stringWithFormat:@"%@", NSLocalizedString(@"btn-proceed.txt", @"Đặt")];
    NSString* localizeH = [NSString stringWithFormat:@"%@", NSLocalizedString(@"btn-decline.txt", @"Huỷ")];
    NSString* localizeB = [NSString stringWithFormat:@"%@", NSLocalizedString(@"btn-balance.txt", @"Số dư")];
    NSString* localizeSelect = [NSString stringWithFormat:@"%@", NSLocalizedString(@"btn-select.txt", @"Đặt")];
    
    
    NSString* iBalance = [NSString stringWithFormat:@"%@: %@ ☆", localizeB, [XSUtils format_iBalance:[AccInfo sharedInstance].iBalance]];
    
    
    
    GameAlertView *myAlertView = [[GameAlertView alloc] initWithTitle:[NSString stringWithFormat:@"%@ %@ %@", cell.hostTeam.text, cell.tyleCuoc.text, cell.oppositeTeam.text]
                                                              message:[NSString stringWithFormat:@"%@\n%@ %@ %@ %@%@",iBalance, localizeSelect, selectedTeam, retKeo, @"@", tyleTien] delegate:self cancelButtonTitle:localizeH otherButtonTitles:localizeD, nil];
    myAlertView.isHost = isHost;
    myAlertView.cellObj = cell;
    myAlertView.bet_type = 0;
    myAlertView.picked = isHost ? 1 : 2;
    myAlertView.iTyLeTien = [tyleTien floatValue];
    
    
    
    
    myAlertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    UITextField *textField = [myAlertView textFieldAtIndex:0];
    textField.keyboardType = UIKeyboardTypeNumberPad;
    textField.textAlignment = NSTextAlignmentCenter;
    textField.delegate = self;
    [textField addTarget:self
                  action:@selector(textFieldDidChange:)
        forControlEvents:UIControlEventEditingChanged];
    
    
    [myAlertView show];
}



- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (textField.text.length >= MAX_LENGTH_SAO_INPUT && range.length == 0)
    {
        return NO; // return NO to not change text
    }
    else {
        return YES;
    }
}

-(void) fetchGameDetailByMaTran
{
    
    NSString* username = [[NSUserDefaults standardUserDefaults] objectForKey:REGISTRATION_ACOUNT_KEY];
    
    if(username) {
        dispatch_queue_t myQueue = dispatch_queue_create("com.ptech.bxh", NULL);
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), myQueue, ^{
            
            [self.soapHandler sendSOAPRequest:[PresetSOAPMessage get_wsFootBall_Tran_Co_GameDuDoan_SoapMessage:[NSString stringWithFormat:@"%lu", self.iID_MaTran] username:username] soapAction:[PresetSOAPMessage get_wsFootBall_Tran_Co_GameDuDoan_SoapAction]];
        });
    }
    
    
    
    
    
    
}


-(void) fetchMatchDetailById
{
    if (NO && self.matchModel && (self.matchModel.iTrangThai != 2 &&
                            self.matchModel.iTrangThai != 3 &&
                            self.matchModel.iTrangThai != 4 &&
                            self.matchModel.iTrangThai != 5 &&
                            self.matchModel.iTrangThai != 8 &&
                            self.matchModel.iTrangThai != 9 &&
                            self.matchModel.iTrangThai != 15)) {
        // if not
        dispatch_async(dispatch_get_main_queue(), ^{
            self.reloadButton.hidden = NO;
            [self.actIndiView stopAnimating];
            
        });
        
        return;
    }
    dispatch_queue_t myQueue = dispatch_queue_create("com.ptech.bxh", NULL);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), myQueue, ^{
        
        [self.soapHandler sendSOAPRequest:[PresetSOAPMessage getMatchDetailSoapMessage:[NSString stringWithFormat:@"%lu", self.iID_MaTran]] soapAction:[PresetSOAPMessage getMatchDetailSoapAction]];
    });
    
    
    
    
}

-(void)onSoapError:(NSError *)error
{
    ZLog(@"soap error: %@", error);
    dispatch_async(dispatch_get_main_queue(), ^{
        self.reloadButton.hidden = NO;
        [self.actIndiView stopAnimating];
        
        NSString* localizeMsg = [NSString stringWithFormat:@"     %@", NSLocalizedString(@"alert-load-data-error.text", @"Lỗi tải dữ liệu")];
        
        NSString* localize_message = [NSString stringWithFormat:@"     %@", NSLocalizedString(@"alert-network-error.text", kBDLive_OnLoadDataError_Message)];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:localizeMsg message:localize_message delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];        [alert show];
    });
}

-(void) handle_Add_List_MatchCommentResult:(NSString*)xmlData {
    @try {
        // handle
    }
    @catch (NSException *exception) {
        // handle
    }
}

-(void) handle_Get_List_MatchCommentResult:(NSString*)xmlData {
    @try {
        // handle
        NSString* jsonStr = [[xmlData componentsSeparatedByString:@"<Get_List_MatchCommentResult>"] objectAtIndex:1];
        jsonStr = [[jsonStr componentsSeparatedByString:@"</Get_List_MatchCommentResult>"] objectAtIndex:0];
        
        ZLog(@"jsonStr data: %@", jsonStr);
        
        
        // parse data
        NSData* dataJson = [jsonStr dataUsingEncoding:NSUTF8StringEncoding];
        NSError* error = nil;
        
        NSArray *bdDict = [NSJSONSerialization JSONObjectWithData:dataJson options:NSJSONReadingMutableContainers error:&error];
        
        if(error) {
            ZLog(@"error occured: %@", error);
            return;
        } else {
            

            UIFont *font = [UIFont fontWithName:@"VNF-FUTURA" size:13.f];

            for(int i=0;i<bdDict.count;++i) {
//                [0]	(null)	@"sUserName" : @"0978399714"
//                [1]	(null)	@"Avatar_url" : @""
//                [2]	(null)	@"Display_name" : @"khánh"
//                [3]	(null)	@"sHash" : @"453C6656FC25FA9746F936757678EAF3"
//                [4]	(null)	@"Message" : @"Hdhhhjjjhhhhy"
//                [5]	(null)	@"Timestamp" : (long)1431418433
//
                NSDictionary* dict = [bdDict objectAtIndex:i];
                NSString* sUserName = [dict objectForKey:@"sUserName"];
                NSString* Display_name = [dict objectForKey:@"Display_name"];
                NSString* sHash = [dict objectForKey:@"sHash"];
                NSString* Message = [dict objectForKey:@"Message"];
                Message = [Message xmlSimpleUnescape];
                long Timestamp = [(NSNumber*)[dict objectForKey:@"Timestamp"] longValue];
                NSDate *date = [NSDate dateWithTimeIntervalSince1970:Timestamp];
                
                
                long like = 0, unlike = 0;
                @try {
                    
                    like = [(NSNumber*)[dict objectForKey:@"Like"] longValue];
                    unlike = [(NSNumber*)[dict objectForKey:@"DisLike"] longValue];
                }@catch(NSException *ex) {

                }
                
                
                
                NSUInteger indexOf = [self.commentList indexOfObject:sHash];
                if(indexOf != NSNotFound) {
                    // existed
                } else {
                    CommentModel* model = [CommentModel new];
                    model.commentHash = sHash;
                    model.commentTxt = [NSString stringWithFormat:@"%@", Message];
                    model.commentDate = date;
                    model.displayName = Display_name;
                    
                    model.like = like;
                    model.unlike = unlike;
                    
                    
//                    NSArray* tmpList = [model.commentTxt componentsSeparatedByString:@"\n"];
                    model.commentHeight = [self findHeightForText:model.commentTxt havingWidth:230.f andFont:font];
                    
                    
//                    if (tmpList.count > 0) {
//                        model.commentHeight += 13.f*(tmpList.count);
//                    }
                    
                    [self.commentList insertObject:sHash atIndex:0];
                    [self.commentDict setObject:model forKey:sHash];
                    
                }
                
                
                
                
                
                
                
                
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if (self.segmentedIndex == 3) {
                    [self.tableView reloadData];
                }
            });
        }
    }
    @catch (NSException *exception) {
        // handle
    }
}

-(void)onSoapDidFinishLoading:(NSData *)data
{
    @try {
        NSString* xmlData = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        
        if ([xmlData rangeOfString:@"<Add_List_MatchCommentResult>"].location != NSNotFound) {
            // user info
            [self handle_Add_List_MatchCommentResult:xmlData];
            return;
        } else if([xmlData rangeOfString:@"<Get_List_MatchCommentResult>"].location != NSNotFound) {
            // top dai gia
            [self handle_Get_List_MatchCommentResult:xmlData];
            return;
        }
        //
        else if([xmlData rangeOfString:@"<wsFootBall_Lives_Co_GameDuDoan_SetBetResult>"].location != NSNotFound) {
            // handle game du doan setbet
            ZLog(@"got setbet response: %@", xmlData);
            [self handle_wsFootBall_Lives_Co_GameDuDoan_SetBetResult:xmlData];
            return;
        }
        //
        //
        else if([xmlData rangeOfString:@"<wsFootBall_Tran_Co_GameDuDoanResult>"].location != NSNotFound) {
            // handle game du doan setbet

            [self handle_wsFootBall_Tran_Co_GameDuDoanResult:xmlData];
            return;
        }
        //
        
        NSString* jsonStr = [[xmlData componentsSeparatedByString:@"<wsFootBall_ChiTiet_TranResult>"] objectAtIndex:1];
        jsonStr = [[jsonStr componentsSeparatedByString:@"</wsFootBall_ChiTiet_TranResult>"] objectAtIndex:0];
        
        ZLog(@"jsonStr data: %@", jsonStr);
        
        
        // parse data
        NSData* dataJson = [jsonStr dataUsingEncoding:NSUTF8StringEncoding];
        NSError* error = nil;
        
        NSArray *bdDict = [NSJSONSerialization JSONObjectWithData:dataJson options:NSJSONReadingMutableContainers error:&error];
        
        if(error) {
            ZLog(@"error occured: %@", error);
            return;
        } else {
            
            [self.subs_Nha removeAllObjects];
            [self.subs_Khach removeAllObjects];
            [self.coach_Nha removeAllObjects];
            [self.coach_Khach removeAllObjects];
            [self.refereeList removeAllObjects];
            
            NSString* lineupStr = @"#10,Benson R. (C),#18,Boyle T.,#1,Corbert N. (G),#17,Doyle J.,#24,Kougoun M.,#3,Langtry M.,#5,Leahy M.,#11,Mulhall C.,#8,O'Neill G.,#15,Swan R.,#26,Watts D.|,#7,Belhout S.,#9,Cannon C.,#21,Harney A.,#19,Kirwan E.,#16,Mackey C. (G),#12,McLaughlin R.,#22,Watson J.|,O'neill C.|76&17_Doyle J.&19_Kirwan E.,88&11_Mulhall C.&7_Belhout S.,56&26_Watts D.&9_Cannon C.";
            
            
            
            
            [self.datasource removeAllObjects]; // remove all objects
            LivescoreModel*model = self.matchModel;
            for(int i=0;i<bdDict.count;++i) {
                NSDictionary* dict = [bdDict objectAtIndex:i];
                
                NSString* sThongTinThe_DoiNha = [dict objectForKey:@"sThongTinThe_DoiNha"];
                NSString* sThongTinThe_DoiKhach = [dict objectForKey:@"sThongTinThe_DoiKhach"];
                
                // ban thang
                NSString* sThongTin_DoiNha = [dict objectForKey:@"sThongTin_DoiNha"];
                NSString* sThongTin_DoiKhach = [dict objectForKey:@"sThongTin_DoiKhach"];
                
                model.iCN_Phut = [(NSNumber*)[dict objectForKey:@"iCN_Phut"] integerValue];
                model.iPhutThem = [(NSNumber*)[dict objectForKey:@"iPhutThem"] integerValue];
                
                //pens
                model.iCN_BanThang_DoiNha_Pen = [(NSNumber*)[dict objectForKey:@"iCN_BanThang_DoiNha_Pen"] integerValue];
                model.iCN_BanThang_DoiKhach_Pen = [(NSNumber*)[dict objectForKey:@"iCN_BanThang_DoiKhach_Pen"] integerValue];
                
                
                
//                iCN_PhatGoc_DoiNha,iCN_PhatGoc_DoiKhach,fPoss_DoiNha,fPoss_DoiKhach
                model.iCN_PhatGoc_DoiNha =[(NSNumber*)[dict objectForKey:@"iCN_PhatGoc_DoiNha"] intValue];
                model.iCN_PhatGoc_DoiKhach =[(NSNumber*)[dict objectForKey:@"iCN_PhatGoc_DoiKhach"] intValue];
                model.fPoss_DoiNha =[(NSNumber*)[dict objectForKey:@"fPoss_DoiNha"] floatValue];
                model.fPoss_DoiKhach =[(NSNumber*)[dict objectForKey:@"fPoss_DoiKhach"] floatValue];
                
                model.iCN_BanThang_DoiKhach_HT = [(NSNumber*)[dict objectForKey:@"iCN_BanThang_DoiKhach_HT"] integerValue];
                model.iCN_BanThang_DoiNha_HT = [(NSNumber*)[dict objectForKey:@"iCN_BanThang_DoiNha_HT"] integerValue];
                model.iCN_BanThang_DoiNha_FT = [(NSNumber*)[dict objectForKey:@"iCN_BanThang_DoiNha_FT"] integerValue];
                model.iCN_BanThang_DoiKhach_FT = [(NSNumber*)[dict objectForKey:@"iCN_BanThang_DoiKhach_FT"] integerValue];
                
                model.iCN_BanThang_DoiNha_ET = [(NSNumber*)[dict objectForKey:@"iCN_BanThang_DoiNha_ET"] integerValue];
                model.iCN_BanThang_DoiKhach_ET = [(NSNumber*)[dict objectForKey:@"iCN_BanThang_DoiKhach_ET"] integerValue];
                
                
//                sDoiHinh_DoiNha,sDoiHinh_DoiKhach,iCN_NemBien_DoiNha,iCN_NemBien_DoiKhach,iCN_VietVi_DoiNha,iCN_VietVi_DoiKhach,iCN_TheDo_DoiNha,iCN_TheDo_DoiKhach,iCN_TheVang_DoiNha,iCN_TheVang_DoiKhach,iCN_PhamLoi_DoiNha,iCN_PhamLoi_DoiKhach,iCN_SutPhat_DoiNha,iCN_SutPhat_DoiKhach,iCN_SutTrung_DoiNha,iCN_SutTrung_DoiKhach,iCN_Sut_DoiNha,iCN_Sut_DoiKhach,iCN_PhatGoc_DoiNha,iCN_PhatGoc_DoiKhach,fPoss_DoiNha,fPoss_DoiKhach
                
                NSString* sDoiHinh_DoiNha = [dict objectForKey:@"sDoiHinh_DoiNha"];
                NSString* sDoiHinh_DoiKhach = [dict objectForKey:@"sDoiHinh_DoiKhach"];
                int iCN_NemBien_DoiNha = [(NSNumber*)[dict objectForKey:@"iCN_NemBien_DoiNha"] intValue];
                int iCN_NemBien_DoiKhach = [(NSNumber*)[dict objectForKey:@"iCN_NemBien_DoiKhach"] intValue];
                int iCN_VietVi_DoiNha = [(NSNumber*)[dict objectForKey:@"iCN_VietVi_DoiNha"] intValue];
                int iCN_VietVi_DoiKhach = [(NSNumber*)[dict objectForKey:@"iCN_VietVi_DoiKhach"] intValue];
                int iCN_TheDo_DoiNha = [(NSNumber*)[dict objectForKey:@"iCN_TheDo_DoiNha"] intValue];
                int iCN_TheDo_DoiKhach = [(NSNumber*)[dict objectForKey:@"iCN_TheDo_DoiKhach"] intValue];
                int iCN_TheVang_DoiNha = [(NSNumber*)[dict objectForKey:@"iCN_TheVang_DoiNha"] intValue];
                int iCN_TheVang_DoiKhach = [(NSNumber*)[dict objectForKey:@"iCN_TheVang_DoiKhach"] intValue];
                int iCN_PhamLoi_DoiNha = [(NSNumber*)[dict objectForKey:@"iCN_PhamLoi_DoiNha"] intValue];
                int iCN_PhamLoi_DoiKhach = [(NSNumber*)[dict objectForKey:@"iCN_PhamLoi_DoiKhach"] intValue];
                
                int iCN_SutPhat_DoiNha = [(NSNumber*)[dict objectForKey:@"iCN_SutPhat_DoiNha"] intValue];
                int iCN_SutPhat_DoiKhach = [(NSNumber*)[dict objectForKey:@"iCN_SutPhat_DoiKhach"] intValue];
                
                int iCN_SutTrung_DoiNha = [(NSNumber*)[dict objectForKey:@"iCN_SutTrung_DoiNha"] intValue];
                int iCN_SutTrung_DoiKhach = [(NSNumber*)[dict objectForKey:@"iCN_SutTrung_DoiKhach"] intValue];
                
                int iCN_Sut_DoiNha = [(NSNumber*)[dict objectForKey:@"iCN_Sut_DoiNha"] intValue];
                int iCN_Sut_DoiKhach = [(NSNumber*)[dict objectForKey:@"iCN_Sut_DoiKhach"] intValue];
                
                int iCN_PhatGoc_DoiNha = [(NSNumber*)[dict objectForKey:@"iCN_PhatGoc_DoiNha"] intValue];
                int iCN_PhatGoc_DoiKhach = [(NSNumber*)[dict objectForKey:@"iCN_PhatGoc_DoiKhach"] intValue];
                
                int fPoss_DoiNha = [(NSNumber*)[dict objectForKey:@"fPoss_DoiNha"] intValue];
                int fPoss_DoiKhach = [(NSNumber*)[dict objectForKey:@"fPoss_DoiKhach"] intValue];
                
                
                
                MDStatsModel* m1 = [self.statsDict objectForKey:@"Poss"];
                m1.val1 = fPoss_DoiNha;
                m1.val3 = fPoss_DoiKhach;
                
                MDStatsModel* m2 = [self.statsDict objectForKey:@"Corner"];
                m2.val1 = iCN_PhatGoc_DoiNha;
                m2.val3 = iCN_PhatGoc_DoiKhach;
                
                MDStatsModel* m3 = [self.statsDict objectForKey:@"Shoot"];
                m3.val1 = iCN_Sut_DoiNha;
                m3.val3 = iCN_Sut_DoiKhach;
                
                MDStatsModel* m4 = [self.statsDict objectForKey:@"Shoot_on_target"];
                m4.val1 = iCN_SutTrung_DoiNha;
                m4.val3 = iCN_SutTrung_DoiKhach;
                
                MDStatsModel* m5 = [self.statsDict objectForKey:@"Shoot_off"];
                m5.val1 = iCN_SutPhat_DoiNha;
                m5.val3 = iCN_SutPhat_DoiKhach;
                
                MDStatsModel* m6 = [self.statsDict objectForKey:@"Fouls"];
                m6.val1 = iCN_PhamLoi_DoiNha;
                m6.val3 = iCN_PhamLoi_DoiKhach;
                
                MDStatsModel* m7 = [self.statsDict objectForKey:@"Yellow_cards"];
                m7.val1 = iCN_TheVang_DoiNha;
                m7.val3 = iCN_TheVang_DoiKhach;
                
                MDStatsModel* m8 = [self.statsDict objectForKey:@"Red_cards"];
                m8.val1 = iCN_TheDo_DoiNha;
                m8.val3 = iCN_TheDo_DoiKhach;
                
                MDStatsModel* m9 = [self.statsDict objectForKey:@"Off_side"];
                m9.val1 = iCN_VietVi_DoiNha;
                m9.val3 = iCN_VietVi_DoiKhach;
                
                MDStatsModel* m10 = [self.statsDict objectForKey:@"Throw_in"];
                m10.val1 = iCN_NemBien_DoiNha;
                m10.val3 = iCN_NemBien_DoiKhach;
                
                if (sDoiHinh_DoiNha) {
                    [self.lineups_Nha removeAllObjects];
                    NSMutableArray* tmpNha = @[].mutableCopy;
                    [tmpNha addObjectsFromArray:[sDoiHinh_DoiNha componentsSeparatedByString:@","]];
                    
                    
                    lineupStr = [self createLineupsFromList:tmpNha];
                    [self parseLineupInfo:lineupStr isHost:YES];
                }
                
                if (sDoiHinh_DoiKhach) {
                    [self.lineups_Khach removeAllObjects];
                    NSMutableArray* tmpKhach = @[].mutableCopy;
                    [tmpKhach addObjectsFromArray:[sDoiHinh_DoiKhach componentsSeparatedByString:@","]];
                    
                    
                    lineupStr = [self createLineupsFromList:tmpKhach];
                    
                    
                    [self parseLineupInfo:lineupStr isHost:NO];
                }
                
                
                [self extractDetailMatch:sThongTinThe_DoiNha isHost:YES isThe:YES];
                [self extractDetailMatch:sThongTinThe_DoiKhach isHost:NO isThe:YES];
                [self extractDetailMatch:sThongTin_DoiNha isHost:YES isThe:NO];
                [self extractDetailMatch:sThongTin_DoiKhach isHost:NO isThe:NO];
                
                
                
                self.matchModel.iTrangThai = [(NSNumber*)[dict objectForKey:@"iTrangThai"] intValue];
                
                
            }
            
            
            [self sortDatasourceByMinute];
            
            // update data on Main UI thread
            dispatch_async(dispatch_get_main_queue(), ^{
//                [self.loadingIndicator stopAnimating];
                self.reloadButton.hidden = NO;
                [self.actIndiView stopAnimating];
                
                [self renderData];
                
                [self showGocPossData];
                
                [self.tableView reloadData];
            });
            
            
            
        }
    }@catch(NSException *ex) {
        
        [self onSoapError:nil];
    }
    
    
    
}

-(void)sortDatasourceByMinute
{
    NSArray* sortedList =  [self.datasource sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
        
        DetailMatchModel *info_a = ((DetailMatchModel*) a);
        DetailMatchModel *info_b = ((DetailMatchModel*) b);
        
        NSUInteger sminA = [info_a.sMinute integerValue];
        NSUInteger sminB = [info_b.sMinute integerValue];
        
        if(sminA > sminB) {
            return NSOrderedDescending;
        } else {
            return NSOrderedAscending;
        }
//        return [info_a.sMinute compare:info_b.sMinute];
    }];
    
    [self.datasource removeAllObjects];
    [self.datasource addObjectsFromArray:sortedList];
}

-(void) extractDetailMatch:(NSString*)str isHost:(BOOL)isHost isThe:(BOOL)isThe
{
    if(str == nil) {
        ZLog(@"no detail match ");
        return ;
    }
    @try {
        
        
        NSArray* list = [str componentsSeparatedByString:@","];
        NSMutableArray* mList = [NSMutableArray new];
        
        for(NSUInteger i=0;i<list.count;i++) {
            DetailMatchModel *model = [DetailMatchModel new];
            model.isHost = isHost;
            //@"32 Pitu(TV)
            NSString* item = [list objectAtIndex:i];
            NSArray* tmpList = [item componentsSeparatedByString:@" "];
            model.sMinute = [tmpList objectAtIndex:0];
            
            
            NSString* remainS = [item substringFromIndex:model.sMinute.length];
            if(model.sMinute.length == 1) {
                model.sMinute = [NSString stringWithFormat:@"0%@", model.sMinute];
            }
            model.sMinute = [model.sMinute stringByAppendingString:@"'"];
            
            
            if([item rangeOfString:@"(TV)"].location != NSNotFound) {
                ////0: the vang, 1: the do, 2: ghi ban, 3: ghi ban = pens
                model.stype = 0;
                remainS =  [remainS stringByReplacingOccurrencesOfString:@"(TV)" withString:@""];
            } else if([item rangeOfString:@"(TĐ)"].location != NSNotFound ||
                      [item rangeOfString:@"(TD)"].location != NSNotFound) {
                model.stype = 1;
                remainS =  [remainS stringByReplacingOccurrencesOfString:@"(TĐ)" withString:@""];
                remainS =  [remainS stringByReplacingOccurrencesOfString:@"(TD)" withString:@""];
            } else if([item rangeOfString:@"(Pen)"].location != NSNotFound) {
                model.stype = 3;
                remainS =  [remainS stringByReplacingOccurrencesOfString:@"(Pen)" withString:@""];
            } else {
                // normal goal
                if (isThe) {
                    model.stype = -1;
                } else {
                    model.stype = 2;
                }
                
            }
            
            model.sPlayerName = remainS;
            
            if(!isThe && (remainS == nil || [remainS isEqualToString:@""])) {
                [mList addObject:model];
            } else if(!isThe) {
                for (int t=0; t<mList.count; ++t) {
                    DetailMatchModel *t_model = [mList objectAtIndex:t];
                    if(t_model == nil || [t_model.sPlayerName isEqualToString:@""]) {
                        t_model.sPlayerName = remainS;
                    }
                }
            }
            
            
            if (model.stype != -1) {
                [self.datasource addObject:model];
            }
            
            

        }
        
        
        
    }@catch(NSException *ex) {
        ZLog(@"erro: %@", ex);
    }
    
    
    
    
}


-(void) fetchBxhByID:(NSString*)iID_MaGiai sTenGiai:(NSString*)sTenGiai logoGiaiUrl:(NSString*)logoGiaiUrl
{
    ZLog(@"iID_MaGiai: %@", iID_MaGiai);
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    StatsViewController* bxh = [storyboard instantiateViewControllerWithIdentifier:@"StatsViewController"];
    bxh.iID_MaGiai = iID_MaGiai;
    bxh.nameBxh = sTenGiai;
    bxh.logoBxh = logoGiaiUrl;
    
    [bxh fetchBxhListById];
    [self.navigationController pushViewController:bxh animated:YES];
}


-(IBAction)onBxhClick:(id)sender
{
    __weak LivescoreModel* model = self.matchModel;
    if(model != nil) {
        NSString* iID_MaGiai = [NSString stringWithFormat:@"%lu", model.iID_MaGiai];
        [self fetchBxhByID:iID_MaGiai sTenGiai:model.sTenGiai logoGiaiUrl:model.sLogoGiai];
    }
}

-(void)autoRefreshData:(id)sender
{
    ZLog(@"autoRefreshData called");

    LivescoreModel* model = self.matchModel;
    if(model.iTrangThai == 2 || model.iTrangThai == 4 || model.iTrangThai == 3)  {
        
        // live match, need to auto refresh
        if([UIApplication sharedApplication].applicationState == UIApplicationStateBackground) {
            ZLog(@"app is background now, dont need to update");
        } else {
            [self fetchMatchDetailById];
        }
        
        return;
    } else {
        ZLog(@"invalidate timer, because the match is not living now");
        [self.timer invalidate];
    }
    
    
    
    
}


-(void) viewWillDisappear:(BOOL)animated {
    if ([self.navigationController.viewControllers indexOfObject:self]==NSNotFound) {
        // back button was pressed.  We know this is true because self is no longer
        // in the navigation stack.
        
        ZLog(@"detail match is hidden now, so invalidate timer now");
        
        [self.timer invalidate];
        
        [self.commentTimer invalidate];
        
        [self removeNotification];
    }
}

-(void) setupBxhView
{
    self.bxhView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onBxhClick:)];
    tap.numberOfTapsRequired = 1;
    [self.bxhView addGestureRecognizer:tap];
    
    
    UITapGestureRecognizer *bcktap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onBackClick:)];
    bcktap.numberOfTapsRequired = 1;
    self.backImg.userInteractionEnabled = YES;
    
    [self.backImg addGestureRecognizer:bcktap];
    
//    [self.loadingIndicator stopAnimating];
    
}

-(void)onBackClick:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)onNotifyAppDidBecomeActive
{
    ZLog(@"detail match: onNotifyAppDidBecomeActive");
    
    if(self.matchModel.iTrangThai == 2 ||
       self.matchModel.iTrangThai == 4 ||
       self.matchModel.iTrangThai == 3)  {
        // only fetch for live match!
        [self fetchMatchDetailById];
    }
    
    
}

-(IBAction)onReloadClick:(id)sender
{
    self.reloadButton.hidden = YES;
    [self.actIndiView startAnimating];
    [self fetchMatchDetailById];
    [self fetchGameDetailByMaTran];
}


-(void) addNotification
{
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNotifyAppDidBecomeActive) name:kAppDidBecomeActive object:nil];
    
    
}

-(void) removeNotification
{
   
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:kAppDidBecomeActive
                                                  object:nil];
}


-(IBAction) onChatRoomClick:(id)sender {
    ChatViewController *chat = [[ChatViewController alloc] initWithNibName:@"ChatViewController" bundle:nil];
    
    [self.navigationController pushViewController:chat animated:YES];
}


-(IBAction) onGamePredictClick:(id)sender
{
    [self.view addSubview:self.commentBoxHolder];
    CATransition *animation = [CATransition animation];
    animation.type = kCATransitionFromTop;
    animation.duration = 0.5;

    [self.commentBoxView.commentTxtView becomeFirstResponder];
    [self.commentBoxHolder.layer addAnimation:animation forKey:nil];
}

-(void)onCloseCommentBoxClicked:(id)sender {
    if (self.commentBoxView) {
        self.commentBoxView.commentTxtView.text = @"";
    }
    [self.commentBoxHolder removeFromSuperview];
}

-(void)onSendCommentBoxClicked:(id)sender {
    
    if(self.segmentedIndex != 3) {
        self.segmentedIndex = 3;
        [self.segmentedView setSelected:YES segmentAtIndex:self.segmentedIndex];
    }
    
    __block NSString* messageToSend = self.commentBoxView.commentTxtView.text;
    if (messageToSend == nil || [messageToSend isEqualToString:@""]) {
        if (self.commentBoxView) {
            self.commentBoxView.commentTxtView.text = @"";
        }
        
        [self.commentBoxHolder removeFromSuperview];
//        NSLog(@"nothing to do");
        return;
    }
    

    
    dispatch_queue_t myQueue = dispatch_queue_create("com.ptech.bxh", NULL);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), myQueue, ^{
        
        NSString* username = @"LS365_user";
        NSString* disp = @"LS365 user";
        NSString* keyReg = [[NSUserDefaults standardUserDefaults] objectForKey:REGISTRATION_DEVICE_TOKEN_KEY];
        if(keyReg) {
            username = [[NSUserDefaults standardUserDefaults] objectForKey:REGISTRATION_ACOUNT_KEY];
            disp = [[NSUserDefaults standardUserDefaults] objectForKey:ACOUNT_DISPLAY_NAME];
        }
        
        NSString* sHash = [NSString stringWithFormat:@"%f-%@", [[NSDate date] timeIntervalSince1970], username];
        
        sHash = [sHash MD5String];
        
        
        
        CommentModel *model = [CommentModel new];
        model.commentDate = [NSDate date];
        model.commentHash = sHash;
        model.commentTxt = [NSString stringWithFormat:@"%@", messageToSend];
        model.displayName = disp;
        UIFont *font = [UIFont fontWithName:@"VNF-FUTURA" size:13.f];
        
//        NSArray* tmpList = [model.commentTxt componentsSeparatedByString:@"\n"];
        
        model.commentHeight = [self findHeightForText:model.commentTxt havingWidth:230 andFont:font];
        
//        if (tmpList.count > 0) {
//            model.commentHeight += 13.f*(tmpList.count);
//        }
        
        
        
//        [self.commentList addObject:sHash];
        [self.commentList insertObject:sHash atIndex:0];
        [self.commentDict setObject:model forKey:sHash];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if (self.segmentedIndex == 3) {
                [self.tableView reloadData];
            }
            
        });
        
        
        
        [self.soapHandler sendSOAPRequest:[PresetSOAPMessage get_Add_List_MatchComment_SoapMessage:self.matchModel.iID_MaTran username:username message:[messageToSend xmlSimpleEscape] disp:disp sHash:sHash]soapAction:[PresetSOAPMessage get_Add_List_MatchComment_SoapAction]];
        

        

    });
    
    if (self.commentBoxView) {
        self.commentBoxView.commentTxtView.text = @"";
    }
    
    [self.commentBoxHolder removeFromSuperview];
    
}



-(IBAction) onCompPredictClick:(id)sender
{
    LivescoreModel *model = self.matchModel;
    PViewController *p = [[PViewController alloc] initWithNibName:@"PViewController" bundle:nil];
    p.p_type = 1; // may tinh du doan
    p.model = model;
//    [self presentViewController:p animated:YES completion:nil];
    [self.navigationController pushViewController:p animated:YES];
}

-(IBAction) onPDoClick:(id)sender
{
    PViewController *p = [[PViewController alloc] initWithNibName:@"PViewController" bundle:nil];
    p.p_type = 0; // phong do
    p.model = self.matchModel;
//    [self presentViewController:p animated:YES completion:nil];
    [self.navigationController pushViewController:p animated:YES];
}

-(void)showGocPossData {
    float screenWidth = [UIScreen mainScreen].bounds.size.width;
    
    UIColor* greenC = [UIColor colorWithRed:(72/255.f) green:(174/255.f) blue:(34/255.f) alpha:1.0f];
    UIColor* redC = [UIColor colorWithRed:(230/255.f) green:0.f blue:0.f alpha:1.0f];
    
    if (self.matchModel.iCN_PhatGoc_DoiNha == 0 && self.matchModel.iCN_PhatGoc_DoiKhach == 0) {
        //
    } else {
        self.gocLabel2.backgroundColor = greenC;
        self.gocLabel3.backgroundColor = redC;
        
        self.gocLabel2.text = [NSString stringWithFormat:@"%d", self.matchModel.iCN_PhatGoc_DoiNha];
        self.gocLabel3.text = [NSString stringWithFormat:@"%d", self.matchModel.iCN_PhatGoc_DoiKhach];
        
        int tongGoc = self.matchModel.iCN_PhatGoc_DoiKhach+self.matchModel.iCN_PhatGoc_DoiNha;
        if(tongGoc <= 0.f) {
            tongGoc = 1.f;
        }
        
        float tmp = ((float) self.matchModel.iCN_PhatGoc_DoiKhach)/((float)tongGoc);
        
        tmp =  tmp * (screenWidth-94);
        
        
        [self.view removeConstraint:self.gocConstraint];
        self.gocConstraint = [NSLayoutConstraint constraintWithItem:self.gocLabel3
                                                          attribute:NSLayoutAttributeWidth
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:nil
                                                          attribute:NSLayoutAttributeNotAnAttribute
                                                         multiplier:1.0
                                                           constant:tmp];
        
        [self.view addConstraint:self.gocConstraint];
    }
    
    if (self.matchModel.fPoss_DoiNha == 0 && self.matchModel.fPoss_DoiKhach == 0) {
        //
    } else {
        self.possLabel2.backgroundColor = greenC;
        self.possLabel3.backgroundColor = redC;
        self.possLabel2.text = [NSString stringWithFormat:@"%d%@", (int)self.matchModel.fPoss_DoiNha, @"%"];
        self.possLabel3.text = [NSString stringWithFormat:@"%d%@", (int)self.matchModel.fPoss_DoiKhach, @"%"];
        
        float tongGoc = self.matchModel.fPoss_DoiNha+self.matchModel.fPoss_DoiKhach;
        if(tongGoc <= 0.f) {
            tongGoc = 1.f;
        }
        float tmp = ((float) self.matchModel.fPoss_DoiKhach)/((float)tongGoc);
        
        tmp =  tmp * (screenWidth-94);
        [self.view removeConstraint:self.possConstraint];
        self.possConstraint = [NSLayoutConstraint constraintWithItem:self.possLabel3
                                                           attribute:NSLayoutAttributeWidth
                                                           relatedBy:NSLayoutRelationEqual
                                                              toItem:nil
                                                           attribute:NSLayoutAttributeNotAnAttribute
                                                          multiplier:1.0
                                                            constant:tmp];
        [self.view addConstraint:self.possConstraint];
    }
    
}


-(void)doGet_List_MatchComment:(id)sender {
    if([UIApplication sharedApplication].applicationState == UIApplicationStateBackground) {
        return;
    }
    dispatch_queue_t myQueue = dispatch_queue_create("com.ptech.bxh", NULL);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), myQueue, ^{
        
        [self.soapHandler sendSOAPRequest:[PresetSOAPMessage get_Get_List_MatchComment_SoapMessage:self.matchModel.iID_MaTran] soapAction:[PresetSOAPMessage get_Get_List_MatchComment_SoapAction]];
        
    });
}


- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if ([alertView isKindOfClass:[GameAlertView class]] && buttonIndex != 0) {
        // game alert dialog for NS
        ZLog(@"game alert dialog for NS");
        GameAlertView* gameAlert = (GameAlertView*)alertView;
        GameTableViewCell* cell = gameAlert.cellObj;
        
        
        if (gameAlert.isConfirm) {
            UIColor *mColor = [[UIColor alloc] initWithRed:230.0/255.f green:0.f blue:0.f alpha:1.f];
            if (gameAlert.isHost) {
                
                
                
                NSString* iDD = [NSString stringWithFormat:@"%@ ☆", [XSUtils format_iBalance:(int)gameAlert.starValue]];
                
                
                NSString* localizeDD = [NSString stringWithFormat:@"%@", NSLocalizedString(@"game-DD.txt", @"Đã đặt")];
                
                cell.hostSlider.value = gameAlert.starValue;
                
                if (gameAlert.bet_type == 0) {
                    cell.hostDD.text = [NSString stringWithFormat:@"%@: %@", localizeDD, iDD];
                    cell.hostDD.textColor = mColor;
                } else if(gameAlert.bet_type == 1) {
                    if(gameAlert.picked == 1) {
                        // pick 1
                        cell.g_DD_1x2_Nha.text = [NSString stringWithFormat:@"%@: %@", localizeDD, iDD];
                        cell.g_DD_1x2_Nha.textColor = mColor;
                    } else if(gameAlert.picked == 0) {
                        // pick X
                        cell.g_xLabel.text = [NSString stringWithFormat:@"%@: %@", localizeDD, iDD];
                        cell.g_xLabel.textColor = mColor;
                    } else if(gameAlert.picked == 2) {
                        // pick 2
                        cell.g_DD_1x2_Khach.text = [NSString stringWithFormat:@"%@: %@", localizeDD, iDD];
                        cell.g_DD_1x2_Khach.textColor = mColor;
                    }
                } else if(gameAlert.bet_type == 2) {
                    if(gameAlert.picked == 1) {
                        // pick xiu
                        cell.g_DD_uo_Nha.text = [NSString stringWithFormat:@"%@: %@", localizeDD, iDD];
                        cell.g_DD_uo_Nha.textColor = mColor;
                    } else if(gameAlert.picked == 2) {
                        // pick tai
                        cell.g_DD_uo_Khach.text = [NSString stringWithFormat:@"%@: %@", localizeDD, iDD];
                        cell.g_DD_uo_Khach.textColor = mColor;
                    }
                }
                
                
                cell.hostDDVal = gameAlert.starValue;
            } else {
                
                
                NSString* iDD = [NSString stringWithFormat:@"%@ ☆", [XSUtils format_iBalance:(int)gameAlert.starValue]];
                
                NSString* localizeDD = [NSString stringWithFormat:@"%@", NSLocalizedString(@"game-DD.txt", @"Đã đặt")];
                cell.oppositeDD.text = [NSString stringWithFormat:@"%@: %@", localizeDD, iDD];
                cell.oppositeSlider.value = gameAlert.starValue;
                cell.oppositeDD.textColor = mColor;
                cell.oppositeDDVal = gameAlert.starValue;
            }
            
            // submit to server now
            [self _onSubmitSetbet:gameAlert.cellObj bet_type:gameAlert.bet_type pick:gameAlert.picked iTyLeTien:gameAlert.iTyLeTien];
        } else {
            // show confirm box
            UITextField *textField = [gameAlert textFieldAtIndex:0];
            textField.text = [textField.text stringByReplacingOccurrencesOfString:@"," withString:@""];
            textField.text = [textField.text stringByReplacingOccurrencesOfString:@"." withString:@""];
            if ([textField.text floatValue] > 0) {
                NSString* starStr = [NSString stringWithFormat:@"%@ ☆", [XSUtils format_iBalance:[textField.text integerValue]]];
                
                
                NSString* localizeH = [NSString stringWithFormat:@"%@", NSLocalizedString(@"btn-decline.txt", @"Huỷ")];
                NSString* localizeXN = [NSString stringWithFormat:@"%@", NSLocalizedString(@"btn-confirm.txt", @"Xác nhận")];
                
                GameAlertView *confirmAlert = [[GameAlertView alloc] initWithTitle:gameAlert.title message:[NSString stringWithFormat:@"%@ = %@", gameAlert.message, starStr] delegate:self cancelButtonTitle:localizeH otherButtonTitles:localizeXN, nil];
                confirmAlert.isConfirm = YES;
                confirmAlert.isHost = gameAlert.isHost;
                confirmAlert.starValue = [textField.text floatValue];
                
                confirmAlert.iTyLeTien = gameAlert.iTyLeTien;
                confirmAlert.bet_type = gameAlert.bet_type;
                confirmAlert.picked = gameAlert.picked;
                
                
                confirmAlert.cellObj = gameAlert.cellObj;
                [confirmAlert show];
            }
        }
        
        
        
        
        
        
        
        
    } else {
        if (buttonIndex != 0) {
            // goto login now
            UIStoryboard* story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            SettingsViewController *set = [story instantiateViewControllerWithIdentifier:@"SettingsViewController"];
            UIViewController *navController = [[UINavigationController alloc]
                                               initWithRootViewController:set];
            
            [self presentViewController:navController animated:YES completion:nil];
        }
    }
}


-(void)_onSubmitSetbet:(GameTableViewCell*)cell bet_type:(NSUInteger)bet_type pick:(NSUInteger)picked iTyLeTien:(float)iTyLeTien
{
    
    NSString* keyReg = [[NSUserDefaults standardUserDefaults] objectForKey:REGISTRATION_DEVICE_TOKEN_KEY];
    if(keyReg == nil) {
        
        NSString* localizeMsg = [NSString stringWithFormat:@"%@", NSLocalizedString(@"game-forbiden.txt", @"Bạn phải đăng nhập để sử dụng chức năng này.")];
        NSString* btnCancel = [NSString stringWithFormat:@"%@", NSLocalizedString(@"btn-decline.txt", @"Huỷ")];
        NSString* btnSignin = [NSString stringWithFormat:@"%@", NSLocalizedString(@"btn-sign-in.txt", @"Đăng nhập")];
        
        
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:nil message:localizeMsg delegate:self cancelButtonTitle:btnCancel otherButtonTitles:btnSignin, nil];
        [alert show];
        return;
    }
    
    cell.hostSlider.hidden = YES;
    cell.oppositeSlider.hidden = YES;
    cell.hostNS.hidden = YES;
    cell.oppositeNS.hidden = YES;
    
    LivescoreModel *model = cell.compBtn.model;
    
    NSString* keoTyle = model.sTyLe_ChapBong;
    
    
    float hostVal = cell.hostDDVal;
    float oppositeVal = cell.oppositeDDVal;
    NSString* account = [[NSUserDefaults standardUserDefaults] objectForKey:REGISTRATION_ACOUNT_KEY];
    
    
    if (hostVal > 0.f || oppositeVal > 0.f) {
        // send bet request now
        dispatch_queue_t myQueue = dispatch_queue_create("com.ptech.setbet", NULL);
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), myQueue, ^{
            
            NSString *tmpkeoTyle = [model get_sTyLe_ChapBong:keoTyle];
            
            
            
            if (hostVal > 0.f) {
                float retKeo = 0.f;
                if (bet_type == 0) {
                    retKeo = [XSUtils get_tyleChapBong_SetBet:tmpkeoTyle isHost:YES];
                } else if(bet_type == 2) {
                    retKeo = [XSUtils convertFloatFromString_SetBet:cell.g_tyleTaiXiu.text];
                }
                
                [self.soapHandler sendSOAPRequest:[PresetSOAPMessage get_wsFootBall_Lives_Co_GameDuDoan_SetBet_Message:[NSString stringWithFormat:@"%d", model.iID_MaTran] iID_MaDoi:[NSString stringWithFormat:@"%d", model.iID_MaDoiNha] sSoDienThoai:account iBet:hostVal iKeo:retKeo sKeo:tmpkeoTyle iBetSelect:picked iTyLeTien:iTyLeTien iLoaiBet:bet_type] soapAction:[PresetSOAPMessage get_wsFootBall_Lives_Co_GameDuDoan_SetBet_SoapAction]];
            }
            
            if(oppositeVal > 0.f) {
                float retKeo = 0.f;
                if (bet_type == 0) {
                    retKeo = [XSUtils get_tyleChapBong_SetBet:tmpkeoTyle isHost:NO];
                } else if(bet_type == 2) {
                    retKeo = [XSUtils convertFloatFromString_SetBet:cell.g_tyleTaiXiu.text];
                }
                
                
                [self.soapHandler sendSOAPRequest:[PresetSOAPMessage get_wsFootBall_Lives_Co_GameDuDoan_SetBet_Message:[NSString stringWithFormat:@"%d", model.iID_MaTran] iID_MaDoi:[NSString stringWithFormat:@"%d", model.iID_MaDoiKhach] sSoDienThoai:account iBet:oppositeVal iKeo:retKeo sKeo:tmpkeoTyle iBetSelect:picked iTyLeTien:iTyLeTien iLoaiBet:bet_type] soapAction:[PresetSOAPMessage get_wsFootBall_Lives_Co_GameDuDoan_SetBet_SoapAction]];
            }
            
            cell.hostDDVal = 0.f;
            cell.oppositeDDVal = 0.f;
            
        });
    } else {
        ZLog(@"nothing to submit for setbettt");
    }
}

-(void)handle_wsFootBall_Tran_Co_GameDuDoanResult:(NSString*) xmlData {
    @try {
        
        NSString* jsonStr = [[xmlData componentsSeparatedByString:@"<wsFootBall_Tran_Co_GameDuDoanResult>"] objectAtIndex:1];
        jsonStr = [[jsonStr componentsSeparatedByString:@"</wsFootBall_Tran_Co_GameDuDoanResult>"] objectAtIndex:0];
        
        
        NSData* dataJson = [jsonStr dataUsingEncoding:NSUTF8StringEncoding];
        NSError* error = nil;
        
        NSArray *bdDict = [NSJSONSerialization JSONObjectWithData:dataJson options:NSJSONReadingMutableContainers error:&error];
        
        if(error) {
            ZLog(@"error occured: %@", error);
            return;
        } else {
            
            
            int iErrCode = -1;
            for(int i=0;i<bdDict.count;++i) {
                NSDictionary* dict = [bdDict objectAtIndex:i];
                
                LivescoreModel *model = self.matchModel;
                
                model.iTrangThai = [(NSNumber*)[dict objectForKey:@"iTrangThai"] intValue];
                
                @try {
                    model.SoSaoDatDoiNha = [(NSNumber*)[dict objectForKey:@"SaoDatDoiNha"] integerValue];
                    model.SoSaoDatDoiKhach = [(NSNumber*)[dict objectForKey:@"SaoDatDoiKhach"] integerValue];
                    model.SaoDat1 = [(NSNumber*)[dict objectForKey:@"SaoDat1"] integerValue];
                    model.SaoDat2 = [(NSNumber*)[dict objectForKey:@"SaoDat2"] integerValue];
                    model.SaoDatX = [(NSNumber*)[dict objectForKey:@"SaoDatX"] integerValue];
                    model.SaoDatU = [(NSNumber*)[dict objectForKey:@"SaoDatU"] integerValue];
                    model.SaoDatO = [(NSNumber*)[dict objectForKey:@"SaoDatO"] integerValue];
                    
                }
                @catch (NSException *exception) {
                    model.SoSaoDatDoiKhach = 0;
                    model.SoSaoDatDoiNha = 0;
                    
                    model.SaoDat1 = 0;
                    model.SaoDat2 = 0;
                    model.SaoDatO = 0;
                    model.SaoDatU = 0;
                    model.SaoDatX = 0;
                }
                
                
                
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
            }
            
            
            if(self.segmentedIndex == 4) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    [self.tableView reloadData];
                });
            }
            
            
        }
    }@catch(NSException *ex) {
        [self onSoapError:nil];
    }
}


-(void)handle_wsFootBall_Lives_Co_GameDuDoan_SetBetResult:(NSString*) xmlData
{
    @try {
        
        NSString* jsonStr = [[xmlData componentsSeparatedByString:@"<wsFootBall_Lives_Co_GameDuDoan_SetBetResult>"] objectAtIndex:1];
        jsonStr = [[jsonStr componentsSeparatedByString:@"</wsFootBall_Lives_Co_GameDuDoan_SetBetResult>"] objectAtIndex:0];
        
        
        NSData* dataJson = [jsonStr dataUsingEncoding:NSUTF8StringEncoding];
        NSError* error = nil;
        
        NSArray *bdDict = [NSJSONSerialization JSONObjectWithData:dataJson options:NSJSONReadingMutableContainers error:&error];
        
        if(error) {
            ZLog(@"error occured: %@", error);
            return;
        } else {
            
            
            int iErrCode = -1;
            for(int i=0;i<bdDict.count;++i) {
                NSDictionary* dict = [bdDict objectAtIndex:i];
                
                iErrCode = [(NSNumber*)[dict objectForKey:@"iErrCode"] intValue];
                NSString* username = [dict objectForKey:@"sUsername"];
                int iBalance = [(NSNumber*)[dict objectForKey:@"iBalance"] intValue];
                NSString* sMaTran = [dict objectForKey:@"sMaTran"];
                
                
                int iSetBet = [(NSNumber*)[dict objectForKey:@"iSetBet"] intValue];
                int iMaGiai = [(NSNumber*)[dict objectForKey:@"iMaGiai"] intValue];
                
                // get bet_type and picked value
                int bet_type = [(NSNumber*)[dict objectForKey:@"iLoaiBet"] intValue];
                int picked = [(NSNumber*)[dict objectForKey:@"iBetSelect"] intValue];
                
                
                LivescoreModel *model = self.matchModel;
                
                
                if (bet_type == 0) {
                    // bet chau A
                    BOOL bDoiNha = (picked == 1) ? YES : NO;
                    if(bDoiNha) {
                        model.SoSaoDatDoiNha += iSetBet;
                    } else {
                        model.SoSaoDatDoiKhach += iSetBet;
                    }
                    
                    if (iErrCode == _BET_CODE_SUCCESS_) {
                        if(bDoiNha) {
                            model.isHighlightNha = bDoiNha;
                        } else {
                            model.isHighlightKhach = !bDoiNha;
                        }
                        
                        
                    }
                } else if(bet_type == 1) {
                    // chau au
                    if (picked == 1) {
                        // pick 1
                        model.SaoDat1 += iSetBet;
                        if (iErrCode == _BET_CODE_SUCCESS_) {
                            model.isHighlight_1x2_1 = YES;
                        }
                    } else if(picked == 0) {
                        // pick hoa: X
                        model.SaoDatX += iSetBet;
                        if (iErrCode == _BET_CODE_SUCCESS_) {
                            model.isHighlight_1x2_x = YES;
                        }
                    }else if(picked == 2) {
                        // pick 2
                        model.SaoDat2 += iSetBet;
                        if (iErrCode == _BET_CODE_SUCCESS_) {
                            model.isHighlight_1x2_2 = YES;
                        }
                    }
                }else if(bet_type == 2) {
                    // tai xiu
                    if (picked == 1) {
                        // xiu
                        model.SaoDatU += iSetBet;
                        if (iErrCode == _BET_CODE_SUCCESS_) {
                            model.isHighlight_uo_u = YES;
                        }
                    } else if(picked == 2) {
                        // tai
                        model.SaoDatO += iSetBet;
                        if (iErrCode == _BET_CODE_SUCCESS_) {
                            model.isHighlight_uo_o = YES;
                        }
                    }
                }
                
                
                [AccInfo sharedInstance].iBalance = iBalance;
                
                if (YES) {
                    break;
                }
            }
            
            
            
            [self setbet_showAlertByErrorCodeGiven:iErrCode];
            
        }
    }@catch(NSException *ex) {
        [self onSoapError:nil];
    }
}

-(void)setbet_showAlertByErrorCodeGiven:(int)iErrCode
{
    // update data on Main UI thread
    NSString* msg = @"";
    //
    //
    //    "game-alert-success.txt" = "Chúc mừng bạn đặt cược thành công";
    //    "game-alert-authen.txt" = "Bạn chưa đăng nhập, vui lòng đăng nhập để đặt cược";
    //    "game-alert-balance.txt" = "Tài khoản không đủ để đặt cược, vui lòng nạp thẻ";
    //    "game-alert-sys.txt" = "Hệ thống quá tải, xin vui lòng trở lại sau";
    //    "game-alert-failed.txt" = "Đặt cược không thành công";
    
    if (iErrCode == _BET_CODE_SUCCESS_) {
        // setbet ok
        NSString* localizeTxt = [NSString stringWithFormat:@"%@", NSLocalizedString(@"game-alert-success.txt", @"Chúc mừng bạn đặt cược thành công")];
        msg = localizeTxt;
        
    } else if (iErrCode == _BET_CODE_ERROR_AUTHEN_) {
        
        
        NSString* localizeTxt = [NSString stringWithFormat:@"%@", NSLocalizedString(@"game-alert-authen.txt", @"Bạn chưa đăng nhập, vui lòng đăng nhập để đặt cược")];
        msg = localizeTxt;
    } else if (iErrCode == _BET_CODE_ERROR_BALANCE_) {
        
        
        NSString* localizeTxt = [NSString stringWithFormat:@"%@", NSLocalizedString(@"game-alert-balance.txt", @"Tài khoản không đủ để đặt cược, vui lòng nạp thẻ")];
        msg = localizeTxt;
    } else if (iErrCode == _BET_CODE_ERROR_EBANK_) {
        
        
        NSString* localizeTxt = [NSString stringWithFormat:@"%@", NSLocalizedString(@"game-alert-sys.txt", @"Hệ thống quá tải, xin vui lòng trở lại sau")];
        msg = localizeTxt;
    } else if (iErrCode == _BET_CODE_ERROR_REQUIRE_MIN_100_) {
        // require at least 100 star
        NSString* localizeTxt = [NSString stringWithFormat:@"%@", NSLocalizedString(@"game-alert-require-100.txt", @"Bạn phải đặt tối thiểu 100 sao trở lên.")];
        msg = localizeTxt;
    } else {
        // setbet failed
        
        NSString* localizeTxt = [NSString stringWithFormat:@"%@", NSLocalizedString(@"game-alert-failed.txt", @"Đặt cược không thành công")];
        msg = localizeTxt;
    }
    
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self.tableView reloadRowsAtIndexPaths:[self.tableView indexPathsForVisibleRows]
                              withRowAnimation:UITableViewRowAnimationNone];
        
        
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:nil message:msg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
    });
}


-(void) parseLineupInfo:(NSString*)lineupStr isHost:(BOOL)isHost {
    NSArray* list = [lineupStr componentsSeparatedByString:@"|"];
    @try {
        NSString* lineup = [list objectAtIndex:0];
        lineup = [lineup stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@",#"]];
        NSArray* listSubs = [lineup componentsSeparatedByString:@",#"];
        for (NSString* coupleStr in listSubs) {
            if([coupleStr rangeOfString:@","].location == NSNotFound) {
                continue;
            }
            PlayerModel* model = [PlayerModel new];
            NSArray* tmpList = [coupleStr componentsSeparatedByString:@","];
            model.playerName = [tmpList objectAtIndex:1];
            model.playerNo = [tmpList objectAtIndex:0];
            
            
            
            if(isHost) {
                [self.lineups_Nha addObject:model];
            } else {
                [self.lineups_Khach addObject:model];
            }
        }
    }
    @catch (NSException *exception) {
        
    }
    
    @try {
        NSString* subs = [list objectAtIndex:1];
        subs = [subs stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@",#"]];
        
        NSArray* listSubs = [subs componentsSeparatedByString:@",#"];
        
        for (NSString* coupleStr in listSubs) {
            if([coupleStr rangeOfString:@","].location == NSNotFound) {
                continue;
            }
            PlayerModel* model = [PlayerModel new];
            NSArray* tmpList = [coupleStr componentsSeparatedByString:@","];
            model.playerName = [tmpList objectAtIndex:1];
            model.playerNo = [tmpList objectAtIndex:0];
            
            
            
            if(isHost) {
                [self.subs_Nha addObject:model];
            } else {
                [self.subs_Khach addObject:model];
            }
        }
        
    }
    @catch (NSException *exception) {
        
    }
    
    
    @try {
        NSString* coachs = [list objectAtIndex:2];
        coachs = [coachs stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@",#"]];
        if(isHost) {
            [self.coach_Nha addObject:coachs];
        } else {
            [self.coach_Khach addObject:coachs];
        }
    }
    @catch (NSException *exception) {
        
    }
    
    @try {
        NSString* subsList = [list objectAtIndex:3];
        subsList = [subsList stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@",#"]];
        
        NSArray* tmpList = [subsList componentsSeparatedByString:@","];
        for (NSString* coupleStr in tmpList) {
            if([coupleStr rangeOfString:@"&"].location == NSNotFound) {
                continue;
            }
            NSArray* tmpList2 = [subsList componentsSeparatedByString:@"&"];
            
            NSString* phut = [tmpList2 objectAtIndex:0];
            NSString* outStr = [tmpList2 objectAtIndex:1];
            NSString* inStr = [tmpList2 objectAtIndex:2];
            
            NSArray* tmpPlayerList1 = [outStr componentsSeparatedByString:@"_"];
            NSArray* tmpPlayerList2 = [inStr componentsSeparatedByString:@"_"];
            
            
            if (isHost) {
                PlayerModel* lineupModel = [self findPlayerModelByPlayerNo:self.lineups_Nha  playerNo:[tmpPlayerList1 objectAtIndex:0]];
                PlayerModel* subsModel = [self findPlayerModelByPlayerNo:self.subs_Nha  playerNo:[tmpPlayerList2 objectAtIndex:0]];
                if(lineupModel) {
                    lineupModel.subsType = SUBS_PLAYER_OUT;
                    lineupModel.subsMin = [NSString stringWithFormat:@"%@'", phut];
                }
                
                if(subsModel) {
                    subsModel.subsType = SUBS_PLAYER_IN;
                    subsModel.subsMin = [NSString stringWithFormat:@"%@'", phut];
                }
            } else {
                PlayerModel* lineupModel = [self findPlayerModelByPlayerNo:self.lineups_Khach  playerNo:[tmpPlayerList1 objectAtIndex:0]];
                PlayerModel* subsModel = [self findPlayerModelByPlayerNo:self.subs_Khach  playerNo:[tmpPlayerList2 objectAtIndex:0]];
                if(lineupModel) {
                    lineupModel.subsType = SUBS_PLAYER_OUT;
                    lineupModel.subsMin = [NSString stringWithFormat:@"%@'", phut];
                }
                
                if(subsModel) {
                    subsModel.subsType = SUBS_PLAYER_IN;
                    subsModel.subsMin = [NSString stringWithFormat:@"%@'", phut];
                }
            }
            
        }
        
        
    }
    @catch (NSException *exception) {
        
    }
    
    


}


-(PlayerModel*) findPlayerModelByPlayerNo:(NSMutableArray*)list playerNo:(NSString*)playerNo {
    for (PlayerModel* model in list) {
        if([model.playerNo isEqualToString:playerNo]) {
            return model;
        }
    }
    return nil;
}


-(NSString*)createLineupsFromList:(NSArray*)list {
    NSString* lineup = @"";
    for (int i=0; i<list.count; i++) {
        // list
        lineup = [lineup stringByAppendingFormat:@"%d,%@,#", (i+1), list[i]];
    }
    
    
    lineup = [lineup stringByAppendingString:@"|"];
    for (int i=0; i<7; i++) {
        // list
        lineup = [lineup stringByAppendingFormat:@"%d,%@,#", (i+1), @"-"];
    }
    
    
    
    lineup = [lineup stringByAppendingString:@"|,-"];
    lineup = [lineup stringByAppendingString:@"|"];
    
    return lineup;
}


#pragma  Admob
- (void)adViewDidReceiveAd:(GADBannerView *)view {
    
    self.tableView.tableFooterView = view;
    
}

@end
