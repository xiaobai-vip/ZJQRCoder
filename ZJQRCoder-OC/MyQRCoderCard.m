//
//  MyQRCoderCard.m
//  ZJQRCoder-OC
//
//  Created by ad on 17/7/14.
//  Copyright © 2017年 zjhcsoftios. All rights reserved.
//

#import "MyQRCoderCard.h"

@interface MyQRCoderCard ()
@property (weak, nonatomic) IBOutlet UIImageView *cardImg;

@end

@implementation MyQRCoderCard

- (void)viewDidLoad {
    [super viewDidLoad];
    // 创建滤镜
    CIFilter *filter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    // 还原滤镜
    [filter setDefaults];
    // 添加数据
    NSString *dataString = @"https://www.baidu.com";
    NSData *data = [dataString dataUsingEncoding:NSUTF8StringEncoding];
    // 通过kvc设置滤镜的inputMessage数据
    [filter setValue:data forKey:@"inputMessage"];
    // 获取输出的二维码
    CIImage *outputImage = [filter outputImage];
    // 设置图片清晰度
    outputImage = [outputImage imageByApplyingTransform:CGAffineTransformMakeScale(10, 10)];
    UIImage *image = [UIImage imageWithCIImage:outputImage];
    self.cardImg.image = image;
}

@end
