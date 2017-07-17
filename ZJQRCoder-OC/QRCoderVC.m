//
//  QRCoderVC.m
//  ZJQRCoder-OC
//
//  Created by ad on 17/7/14.
//  Copyright © 2017年 zjhcsoftios. All rights reserved.
//

#import "QRCoderVC.h"
#import <AVFoundation/AVFoundation.h>
#import "MyQRCoderCard.h"

@interface QRCoderVC ()<UITabBarDelegate,AVCaptureMetadataOutputObjectsDelegate,UIAlertViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *heightCos;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomCos;
@property (weak, nonatomic) IBOutlet UIImageView *scanView;
@property (weak, nonatomic) IBOutlet UIView *QRCoderVeiw;
@property (weak, nonatomic) IBOutlet UITabBar *customTabbar;

/// 输入对象
@property (nonatomic,strong) AVCaptureDeviceInput *inputDevice;
/// 输入对象
@property (nonatomic,strong) AVCaptureMetadataOutput *output;
/// 会话对象
@property (nonatomic,strong) AVCaptureSession *session;
/// 取景视图
@property (nonatomic,strong) AVCaptureVideoPreviewLayer *previewLayer;

@end

@implementation QRCoderVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.customTabbar.selectedItem = self.customTabbar.items.firstObject;
    [self startAnima];
    self.navigationItem.title = @"扫一扫";
    [self initNavBtn];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self setupScanQRCoder];
}

- (void)initNavBtn{
    UIButton *leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    leftBtn.frame = CGRectMake(0, 0, 40, 40);
    [leftBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [leftBtn setTitle:@"相册" forState:UIControlStateNormal];
    [leftBtn addTarget:self action:@selector(photoBtn:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:leftBtn];
    self.navigationItem.rightBarButtonItem = item;
}

#pragma mark lazyinit
- (AVCaptureSession *)session{
    if (!_session) {
        _session = [[AVCaptureSession alloc] init];
    }
    return _session;
}

- (AVCaptureDeviceInput *)inputDevice{
    if (!_inputDevice) {
        //获取摄像头设备
        AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        NSError *error = nil;
        
        //创建输入流
        _inputDevice = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
    }
    return _inputDevice;
}

- (AVCaptureMetadataOutput *)output{
    if (!_output) {
        _output = [[AVCaptureMetadataOutput alloc] init];
        CGRect qrcodeFrame = self.QRCoderVeiw.frame;
        CGRect screenFrame = [UIScreen mainScreen].bounds;
        CGFloat x = qrcodeFrame.origin.y / screenFrame.size.height;
        CGFloat y = qrcodeFrame.origin.x / screenFrame.size.width;
        CGFloat width = qrcodeFrame.size.height / screenFrame.size.height;
        CGFloat height = qrcodeFrame.size.width / screenFrame.size.width;
        _output.rectOfInterest = CGRectMake(x, y, width, height);
    }
    return _output;
}

- (AVCaptureVideoPreviewLayer *)previewLayer{
    if (!_previewLayer) {
        _previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:self.session];
    }
    return _previewLayer;
}

// 初始化二维码扫描
- (void)setupScanQRCoder{
    //1.判断输入是否能够添加到会话中
    if (![self.session canAddInput:self.inputDevice]) {
        return;
    }
    //2.判断输出是否能够添加到会话中
    if (![self.session canAddOutput:self.output]) {
        return;
    }
    //3.将输入和输出添加到会话中
    [self.session addInput:self.inputDevice];
    [self.session addOutput:self.output];
    //设置扫码类型
    self.output.metadataObjectTypes = self.output.availableMetadataObjectTypes;
    //设置代理，在主线程刷新
    [self.output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    //设置取景区域
    self.previewLayer.frame = [UIScreen mainScreen].bounds;
    [self.view.layer insertSublayer:self.previewLayer atIndex:0];
    [self.session startRunning];
}

// 开始扫描动画
- (void)startAnima{
    [self.scanView.layer removeAllAnimations];
    self.bottomCos.constant = -self.heightCos.constant;
    [self.view layoutIfNeeded];
    [UIView animateWithDuration:1.5 animations:^{
        [UIView setAnimationRepeatCount:MAXFLOAT];
        self.bottomCos.constant = self.heightCos.constant;
        [self.QRCoderVeiw layoutIfNeeded];
    }];
}

- (void)photoBtn:(id)sender {
    UIImagePickerController *pick = [[UIImagePickerController alloc] init];
    pick.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    pick.delegate = self;
    [self.navigationController presentViewController:pick animated:YES completion:nil];
}

- (IBAction)MyQRCoderCard:(id)sender {
    MyQRCoderCard *vc = [[MyQRCoderCard alloc] init];
    vc.navigationItem.title = @"我的名片";
    [self.navigationController pushViewController:vc animated:YES];
}


#pragma mark avcapture 代理
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection{
    [self.session stopRunning];
    for (AVMetadataMachineReadableCodeObject *metadata in metadataObjects) {
        UIAlertView *alter = [[UIAlertView alloc] initWithTitle:metadata.stringValue message:@"" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alter show];
    }
}

#pragma mark tabbar 代理
- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item{
    if ([item.title isEqualToString:@"条形码"]) {
        self.heightCos.constant = 150;
    }else{
        self.heightCos.constant = 300;
    }
    [self startAnima];
}

#pragma mark alterview 代理
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    [self.session startRunning];
}

#pragma mark imagePicker 代理
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    [picker dismissViewControllerAnimated:YES completion:nil];
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    NSData *data = UIImagePNGRepresentation(image);
    CIImage *ciimge = [CIImage imageWithData:data];
    // 创建探测器
    CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeQRCode context:nil options:@{CIDetectorAccuracy: CIDetectorAccuracyLow}];
    NSArray *feature = [detector featuresInImage:ciimge];
    for (CIQRCodeFeature *codeFeature in feature) {
        UIAlertView *alter = [[UIAlertView alloc] initWithTitle:codeFeature.messageString message:@"" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alter show];
    }
}
@end
