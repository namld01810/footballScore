//
//  LeagueTableViewCell.m
//  BDLive
//
//  Created by Khanh Le on 12/9/14.
//  Copyright (c) 2014 Khanh Le. All rights reserved.
//

#import "LeagueTableViewCell.h"
#import "../Utils/XSUtils.h"



@implementation LeagueTableViewCell

- (void)awakeFromNib {
    // Initialization code
    [XSUtils setFontFamily:@"VNF-FUTURA" forView:self.contentView andSubViews:YES];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
