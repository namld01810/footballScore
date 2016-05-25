//
//  BDLiveGestureRecognizer.h
//  BDLive
//
//  Created by Khanh Le on 12/12/14.
//  Copyright (c) 2014 Khanh Le. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LivescoreModel;

@interface BDLiveGestureRecognizer : UITapGestureRecognizer

@property(nonatomic, strong)NSString* iID_MaGiai;
@property(nonatomic, strong)NSString* iID_MaTran;
@property(nonatomic, strong)NSString* iID_MaDoi;
@property(nonatomic, strong)NSString* sTenGiai;
@property(nonatomic, strong)NSString* logoGiaiUrl;

@property(nonatomic, weak) UIImageView *pinButton;

@property(nonatomic, strong) id mModel;
@property(nonatomic, strong) id mCell;

@end

@interface BDSwipeGestureRecognizer : UISwipeGestureRecognizer

@property(nonatomic, strong) LivescoreModel *model;
@property(nonatomic, strong) NSIndexPath *indexPath;





@end
