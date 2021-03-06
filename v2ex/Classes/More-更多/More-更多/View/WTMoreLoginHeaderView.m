//
//  WTMoreLoginHeaderView.m
//  v2ex
//
//  Created by 无头骑士 GJ on 16/7/27.
//  Copyright © 2016年 无头骑士 GJ. All rights reserved.
//

#import "WTMoreLoginHeaderView.h"

#import "WTConst.h"
#import "WTAccountViewModel.h"
#import "UIViewController+Extension.h"

#import "POP.h"
#import "UIImageView+WebCache.h"
#import "SVProgressHUD.h"
@interface WTMoreLoginHeaderView () <POPAnimationDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate>
@property (weak, nonatomic) IBOutlet UIView *avatarbgView1;
@property (weak, nonatomic) IBOutlet UIView *avatarbgView2;

@property (weak, nonatomic) IBOutlet UIView *onlineView;
@property (weak, nonatomic) IBOutlet UIImageView *hasPastImageV;

/** 头像 */
@property (weak, nonatomic) IBOutlet UIImageView *avatarImageV;

/** 用户名 */
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;

/** 签名 */
@property (weak, nonatomic) IBOutlet UILabel *bioLabel;

/** 签到 */
@property (weak, nonatomic) IBOutlet UIButton *pastBtn;

@end

@implementation WTMoreLoginHeaderView

+ (instancetype)moreLoginHeaderView
{
    return [[NSBundle mainBundle] loadNibNamed: @"WTMoreLoginHeaderView" owner: nil options: nil].lastObject;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.backgroundColor = [UIColor clearColor];
    
    self.onlineView.layer.cornerRadius = self.onlineView.width * 0.5;
    
    // 头像
    self.avatarbgView1.layer.cornerRadius = self.avatarbgView1.width * 0.5;
    self.avatarbgView2.layer.cornerRadius = self.avatarbgView2.width * 0.5;
    self.avatarImageV.layer.cornerRadius = self.avatarImageV.width * 0.5;
    self.avatarImageV.layer.masksToBounds = YES;
    
    self.pastBtn.layer.shadowColor = [UIColor blackColor].CGColor;
    self.pastBtn.layer.shadowOffset = CGSizeMake(1, 1);
    self.pastBtn.layer.shadowRadius = 5;
    self.pastBtn.layer.shadowOpacity = 0.5;
    
    UIBezierPath *path = [UIBezierPath bezierPathWithRect: self.pastBtn.bounds];
    [path moveToPoint: CGPointMake(0, self.pastBtn.height)];

}

- (void)setAccount:(WTAccount *)account
{
    _account = account;
    
    self.usernameLabel.text = account.usernameOrEmail;
    
    self.bioLabel.text = account.signature != nil ? account.signature : @"未设置签名";
    [self.avatarImageV sd_setImageWithURL: account.avatarURL placeholderImage: WTIconPlaceholderImage];
    
    NSString *past = @"签到";
    if (account.isPast)
    {
        past = @"已签到";
    }
    [self.pastBtn setTitle: past forState: UIControlStateNormal];
}
#pragma mark - 事件
#pragma mark 签到
- (IBAction)pastBtnClick
{
    if ([self.pastBtn.titleLabel.text isEqualToString: @"已签到"]) 
        return;
    
    // 签到
    [self past];
}

/**
 *  签到
 */
- (void)past
{
    [[WTAccountViewModel shareInstance] pastWithSuccess:^{
        
        // 动画
        [self startAnim];
        
    } failure:^(NSError *error) {
        
        [SVProgressHUD showErrorWithStatus: @"操作异常,请稍候重试"];
        
    }];
}

/**
 *  动画
 */
- (void)startAnim
{
    POPBasicAnimation *shadowColorAnim = [POPBasicAnimation animationWithPropertyNamed: kPOPLayerShadowColor];
    shadowColorAnim.duration = 1;
    shadowColorAnim.toValue = (__bridge id)([[UIColor clearColor] CGColor]);
    shadowColorAnim.autoreverses = YES;
    [self.pastBtn.layer pop_addAnimation: shadowColorAnim forKey: kPOPLayerShadowColor];
    
    
    POPBasicAnimation *backgroundColorAnim = [POPBasicAnimation animationWithPropertyNamed: kPOPViewBackgroundColor];
    backgroundColorAnim.duration = 1;
    backgroundColorAnim.autoreverses = YES;
    backgroundColorAnim.toValue = [UIColor colorWithHexString: WTAppLightColor];
    [self.pastBtn pop_addAnimation: backgroundColorAnim forKey: kPOPViewBackgroundColor];
    
    
    POPBasicAnimation *alphaAnim = [POPBasicAnimation animationWithPropertyNamed: kPOPViewAlpha];
    alphaAnim.duration = 1;
    alphaAnim.toValue = @0;
    alphaAnim.autoreverses = YES;
    [self.pastBtn pop_addAnimation: alphaAnim forKey: kPOPViewAlpha];
    //
    POPSpringAnimation *scaleAnim = [POPSpringAnimation animationWithPropertyNamed: kPOPViewScaleXY];
    scaleAnim.springSpeed = 10;
    scaleAnim.springBounciness = 20;
    alphaAnim.delegate = self;
    scaleAnim.fromValue = [NSValue valueWithCGPoint: CGPointMake(1.5, 1.5)];
    scaleAnim.toValue = [NSValue valueWithCGPoint: CGPointMake(1.0, 1.0)];
    [self.pastBtn pop_addAnimation: scaleAnim forKey: kPOPViewScaleXY];
}

- (void)pop_animationDidStart:(POPAnimation *)anim
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.pastBtn setTitle: @"已签到" forState: UIControlStateNormal];
    });
}

@end
