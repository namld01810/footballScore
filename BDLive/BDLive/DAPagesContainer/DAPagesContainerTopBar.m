//
//  DAPagesContainerTopBar.m
//  DAPagesContainerScrollView
//
//  Created by Daria Kopaliani on 5/29/13.
//  Copyright (c) 2013 Daria Kopaliani. All rights reserved.
//

#import "DAPagesContainerTopBar.h"



@interface TopBarItemView_UITapGestureRecognizer : UITapGestureRecognizer

@property(nonatomic, weak) id itemView;

@end


@implementation TopBarItemView_UITapGestureRecognizer
@end




@interface DAPagesContainerTopBar ()

@property (strong, nonatomic) UIImageView *backgroundImageView;
@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) NSArray *itemViews;


@property (strong, nonatomic) TopBarItemView *reuseTopBarView;

- (void)layoutItemViews;

@end


@implementation DAPagesContainerTopBar

CGFloat const DAPagesContainerTopBarItemViewWidth = 80.;
CGFloat const DAPagesContainerTopBarItemsOffset = 0.;

CGFloat const DAPagesContainerTopBarItem_MarginLeftRight = 50.f;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
        self.scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.scrollView.showsHorizontalScrollIndicator = NO;
        [self addSubview:self.scrollView];
        self.font = [UIFont systemFontOfSize:14];
        self.itemTitleColor = [UIColor whiteColor];
    }
    return self;
}

#pragma mark - Public

- (CGPoint)centerForSelectedItemAtIndex:(NSUInteger)index
{
    CGPoint center = ((UIView *)self.itemViews[index]).center;
    CGPoint offset = [self contentOffsetForSelectedItemAtIndex:index];
    center.x -= offset.x - (CGRectGetMinX(self.scrollView.frame));
    return center;
}

- (CGPoint)contentOffsetForSelectedItemAtIndex:(NSUInteger)index
{
    if (self.itemViews.count < index || self.itemViews.count == 1) {
        return CGPointZero;
    } else {
        CGFloat totalOffset = self.scrollView.contentSize.width - CGRectGetWidth(self.scrollView.frame);
        return CGPointMake(index * totalOffset / (self.itemViews.count - 1), 0.);
    }
}

- (void)setItemTitleColor:(UIColor *)itemTitleColor
{
    if (![_itemTitleColor isEqual:itemTitleColor]) {
        _itemTitleColor = itemTitleColor;
        for (UILabel *button in self.itemViews) {

            button.textColor =_itemTitleColor;
        }
    }
}

#pragma mark * Overwritten setters

- (void)setBackgroundImage:(UIImage *)backgroundImage
{
    self.backgroundImageView.image = backgroundImage;
}

- (void)setItemTitles:(NSArray *)itemTitles
{
    if (_itemTitles != itemTitles) {
        _itemTitles = itemTitles;
        NSMutableArray *mutableItemViews = [NSMutableArray arrayWithCapacity:itemTitles.count];
        for (NSUInteger i = 0; i < itemTitles.count; i++) {
            
            TopBarItemView *itemView = [self addItemView:itemTitles[i]];
            itemView.itemIndex = i;
            itemView.itemImageView.image = [UIImage imageNamed:[self.imageViews objectAtIndex:i]];
            
            
            
            
            [mutableItemViews addObject:itemView];
        }
        self.itemViews = [NSArray arrayWithArray:mutableItemViews];
        [self layoutItemViews];
    }
}

- (void)setFont:(UIFont *)font
{
    if (![_font isEqual:font]) {
        _font = font;
        for (UILabel *itemView in self.itemViews) {
            [itemView setFont:font];
        }
    }
}

#pragma mark - Private

- (TopBarItemView *)addItemView:(NSString*)itemTitle
{
    TopBarItemView* itemView = [[[NSBundle mainBundle] loadNibNamed:@"TopBarItemView" owner:nil options:nil] objectAtIndex:0];
    itemView.frame = CGRectMake(0., 0., DAPagesContainerTopBarItemViewWidth, CGRectGetHeight(self.frame));
    itemView.itemLabel.text = itemTitle;
    
    itemView.userInteractionEnabled = YES;
    TopBarItemView_UITapGestureRecognizer* tap = [[TopBarItemView_UITapGestureRecognizer alloc] initWithTarget:self action:@selector(itemViewTapped:)];
    tap.numberOfTapsRequired = 1;
    tap.itemView = itemView;

    [itemView addGestureRecognizer:tap];
    
    
    [self.scrollView addSubview:itemView];
    return itemView;
}

- (void)itemViewTapped:(TopBarItemView_UITapGestureRecognizer*)sender
{
    for (TopBarItemView *itemViewTmp in self.itemViews) {
        itemViewTmp.topViewLine.hidden = YES;
    }
    
    
    ((TopBarItemView*)sender.itemView).topViewLine.hidden = NO;
    [self.delegate itemAtIndex:[self.itemViews indexOfObject:sender.itemView] didSelectInPagesContainerTopBar:self];
}

- (void)layoutItemViews
{
    CGFloat x = DAPagesContainerTopBarItemsOffset;
    CGFloat marginLR = (DAPagesContainerTopBarItem_MarginLeftRight / 280.f) * [UIScreen mainScreen].bounds.size.width;
    //CGFloat marginLR = DAPagesContainerTopBarItem_MarginLeftRight;
    CGFloat width = 0.f;
    for (NSUInteger i = 0; i < self.itemViews.count; i++) {
        width = [self.itemTitles[i] sizeWithFont:self.font].width ;
        TopBarItemView *itemView = self.itemViews[i];
        
        width += marginLR;

        itemView.frame = CGRectMake(x, 0., width, CGRectGetHeight(self.frame));
        x += width + DAPagesContainerTopBarItemsOffset;
    }
    
    
    if ([UIScreen mainScreen].bounds.size.width > 320.f) {
        x = x + marginLR; // khanh add this to make scroll available
    }
    
    
    self.scrollView.contentSize = CGSizeMake(x, CGRectGetHeight(self.scrollView.frame));
    CGRect frame = self.scrollView.frame;
    if (CGRectGetWidth(self.frame) > x) {
        frame.origin.x = (CGRectGetWidth(self.frame) - x) / 2.;
        frame.size.width = x;
    } else {
        frame.origin.x = 0.;
        frame.size.width = CGRectGetWidth(self.frame);
    }
    self.scrollView.frame = frame;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self layoutItemViews];
}

#pragma mark * Lazy getters

- (UIImageView *)backgroundImageView
{
    if (!_backgroundImageView) {
        _backgroundImageView = [[UIImageView alloc] initWithFrame:self.bounds];
        _backgroundImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self insertSubview:_backgroundImageView belowSubview:self.scrollView];
    }
    return _backgroundImageView;
}

@end