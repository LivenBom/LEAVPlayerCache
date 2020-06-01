//
//  ViewController.m
//  LEAVPlayerCache
//
//  Created by Liven on 2020/6/1.
//  Copyright © 2020 Liven. All rights reserved.
//

/**
    1. NSURLSession下载视频文件   -- OK
        不能使用downloadTask，因为需要一边下载一边获取数据传给播放器播放
        使用GET方式请求
    2.将下载的数据填充到播放器中 -- OK
    3.分片下载处理    --OK
    4.数据缓存  ---OK
    5.处理不能边播边下载的mp4文件(moov文件在mdat文件之后的视频文件)
    6.avplayer在tableView视频列表顺畅的问题
 */

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "LEResourceLoaderManager.h"

@interface ViewController ()
@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, strong) AVPlayerLayer *playerLayer;
@property (nonatomic, strong) AVURLAsset *urlAsset;
@property (nonatomic, strong) AVPlayerItem *playerItem;

@property (nonatomic, strong) LEResourceLoaderManager *loaderManager;
@end


@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor blackColor];
    
    self.loaderManager = [[LEResourceLoaderManager alloc]init];

    // URL
    NSString *url = @"http://vfx.mtime.cn/Video/2019/03/18/mp4/190318231014076505.mp4";
    
    // PlayerItem
    _playerItem = [self.loaderManager playerItemWithURL:[NSURL URLWithString:url]];
    [_playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];

    // Player
    _player = [[AVPlayer alloc]initWithPlayerItem:self.playerItem];
    
    // 决定音频是否马上开始播放的关键性参数！！！
    if (@available(iOS 10.0, *)) {
        _player.automaticallyWaitsToMinimizeStalling = NO;
    }
    
    // PlayerLayer
    _playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
    _playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
    _playerLayer.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    [self.view.layer addSublayer:_playerLayer];
}


#pragma mark - KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"status"]) {
        switch (self.playerItem.status) {
            case AVPlayerItemStatusUnknown: {
                // 未知状态，不能播放
                NSLog(@"AVPlayerItemStatusUnknown");
            }
                break;
            case AVPlayerItemStatusReadyToPlay: {
                // 准备完毕，可以播放
                // 此方法可以在视频未播放的时候，获取视频的总时长(备注：一定要在AVPlayer预加载状态status是AVPlayerItemStatusReadyToPlay才能获取)
                // NSLog(@"total %f",CMTimeGetSeconds(self.playerItem.asset.duration));
                [self.player play];
                NSLog(@"AVPlayerItemStatusReadyToPlay");
            }
                break;
            case AVPlayerItemStatusFailed: {
                // 加载失败，网络或者服务器出现问题
                NSLog(@"AVPlayerItemStatusFailed");
            }
                break;
            default:
                break;
        }
    }
}

@end
