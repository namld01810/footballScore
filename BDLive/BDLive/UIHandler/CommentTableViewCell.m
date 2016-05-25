//
//  CommentTableViewCell.m
//  BDLive
//
//  Created by Khanh Le on 5/12/15.
//  Copyright (c) 2015 Khanh Le. All rights reserved.
//

#import "CommentTableViewCell.h"
#import "../Utils/XSUtils.h"

@implementation CommentTableViewCell

- (void)awakeFromNib {
    // Initialization code
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    [XSUtils setFontFamily:@"VNF-FUTURA" forView:self.contentView andSubViews:YES];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
