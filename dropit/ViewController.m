//
//  ViewController.m
//  dropit
//
//  Created by Armour on 4/22/15.
//  Copyright (c) 2015 ZJU. All rights reserved.
//

#import "ViewController.h"
#import "DropitBehavior.h"
#import "BezierPathView.h"

@interface ViewController () <UIDynamicAnimatorDelegate>

@property (weak, nonatomic) IBOutlet BezierPathView *gameView;
@property (strong, nonatomic) UIDynamicAnimator *animator;
//@property (strong, nonatomic) UIGravityBehavior *gravity;
//@property (strong, nonatomic) UICollisionBehavior *collider;
@property (strong, nonatomic) DropitBehavior *dropitBehavior;
@property (strong, nonatomic) UIAttachmentBehavior *attachment;
@property (strong, nonatomic) UIView *droppingView;

@end

@implementation ViewController

static const CGSize DROP_SIZE = {42, 42};

- (IBAction)tap:(UITapGestureRecognizer *)sender {
    [self drop];
}

- (IBAction)grabDrop:(UIPanGestureRecognizer *)sender {
    CGPoint gesturePoint = [sender locationInView:self.gameView];
    if (sender.state == UIGestureRecognizerStateBegan) {
        [self attachDroppingViewToPoint:gesturePoint];
    } else if (sender.state == UIGestureRecognizerStateChanged) {
        self.attachment.anchorPoint = gesturePoint;
    } else if (sender.state == UIGestureRecognizerStateEnded) {
        [self.animator removeBehavior:self.attachment];
        self.gameView.path = nil;
    }
}

- (void)attachDroppingViewToPoint:(CGPoint)anchorPoint {
    if (self.droppingView) {
        self.attachment = [[UIAttachmentBehavior alloc] initWithItem:self.droppingView attachedToAnchor:anchorPoint];
        UIView *droppingView = self.droppingView;
        __weak ViewController *weakSelf = self;
        self.attachment.action = ^{
            UIBezierPath *path = [[UIBezierPath alloc] init];
            [path moveToPoint:weakSelf.attachment.anchorPoint];
            [path addLineToPoint:droppingView.center];
            weakSelf.gameView.path = path;
        };
        self.droppingView = nil;
        [self.animator addBehavior:self.attachment];
    }
}

- (UIDynamicAnimator *)animator {
    if (!_animator) {
        _animator = [[UIDynamicAnimator alloc] initWithReferenceView:self.gameView];
        _animator.delegate = self;
    }
    return _animator;
}

- (void)dynamicAnimatorDidPause:(UIDynamicAnimator *)animator {
    [self removeCompletedRows];
}

- (BOOL)removeCompletedRows {
    NSMutableArray *dropsToRemove = [[NSMutableArray alloc] init];

    for (CGFloat y = self.gameView.bounds.size.height - DROP_SIZE.height/2; y>0; y -= DROP_SIZE.height) {
        BOOL rowIsCompleted = YES;
        NSMutableArray *dropsFound = [[NSMutableArray alloc] init];
        for (CGFloat x = DROP_SIZE.width/2; x <= self.gameView.bounds.size.width - DROP_SIZE.width/2; x += DROP_SIZE.width) {
            UIView *hitView = [self.gameView hitTest:CGPointMake(x, y) withEvent:NULL];
            if ([hitView superview] == self.gameView) {
                [dropsFound addObject:hitView];
            } else {
                rowIsCompleted = NO;
                break;
            }
        }
        if (![dropsFound count]) break;
        if (rowIsCompleted) [dropsToRemove addObjectsFromArray:dropsFound];
    }

    if ([dropsToRemove count]) {
        for (UIView *drop in dropsToRemove) {
            [self.dropitBehavior removeItem:drop];
        }
        [self animateRemovingDrops:dropsToRemove];
    }

    return NO;
}

- (void)animateRemovingDrops:(NSArray *)dropsToRemove {
    [UIView animateWithDuration:1.0
                     animations:^{
                         for (UIView* drop in dropsToRemove) {
                             int x = (arc4random()%(int)(self.gameView.bounds.size.width * 5)) - (int)(self.gameView.bounds.size.width * 2);
                             int y = self.gameView.bounds.size.height;
                             drop.center = CGPointMake(x, -y);
                         }
                     }
                     completion:^(BOOL finished) {
                         [dropsToRemove makeObjectsPerformSelector:@selector(removeFromSuperview)];
                     }];
}

/*-(UIGravityBehavior *)gravity {
    if (!_gravity) {
        _gravity = [[UIGravityBehavior alloc] init];
        _gravity.magnitude = 0.98;
        [self.animator addBehavior:_gravity];
    }
    return _gravity;
}

-(UICollisionBehavior *)collider {
    if (!_collider) {
        _collider = [[UICollisionBehavior alloc] init];
        _collider.translatesReferenceBoundsIntoBoundary = YES;
        [self.animator addBehavior:_collider];
    }
    return _collider;
}*/

-(DropitBehavior *)dropitBehavior {
    if (!_dropitBehavior) {
        _dropitBehavior = [[DropitBehavior alloc] init];
        [self.animator addBehavior:_dropitBehavior];
    }
    return _dropitBehavior;
}

- (void)drop {
    CGRect frame;
    frame.origin = CGPointZero;
    frame.size = DROP_SIZE;
    int x = (arc4random() % (int)self.view.bounds.size.width/ DROP_SIZE.width);
    frame.origin.x = x * DROP_SIZE.width;

    UIView *dropview = [[UIView alloc] initWithFrame:frame];
    dropview.backgroundColor = [self randomColor];
    [self.gameView addSubview:dropview];

    //[self.gravity addItem:dropview];
    //[self.collider addItem:dropview];
    [self.dropitBehavior addItem:dropview];

    self.droppingView =dropview;
}

- (UIColor *)randomColor {
    switch (arc4random()%5) {
        case 0: return [UIColor greenColor]; break;
        case 1: return [UIColor blueColor]; break;
        case 2: return [UIColor orangeColor]; break;
        case 3: return [UIColor redColor]; break;
        case 4: return [UIColor purpleColor]; break;
    }
    return [UIColor blackColor];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
