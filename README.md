# LEAVPlayerCache
边缓存边播放：Cache while playing

## 系列文章：

[边播放边缓存01](https://callliven.github.io/2020/05/19/AVPlayer边播放边缓存01/)

[边播放边缓存02](https://callliven.github.io/2020/05/22/AVPlayer边播放边缓存02/)



## 使用方法

实例LEResourceLoaderManager类，并使用该对象创建AVPlayerItem即可

```objc
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
```



