#import "RawMultitouch.h"
#import <dlfcn.h>

// MultitouchSupport.framework function types
typedef void *MTDeviceRef;
typedef void (*MTFrameCallbackFunction)(MTDeviceRef device, RMTTouch *touches, int numTouches, double timestamp, int frame);

// Function pointers loaded at runtime
static CFArrayRef (*pMTDeviceCreateList)(void);
static OSStatus (*pMTDeviceStart)(MTDeviceRef, int);
static OSStatus (*pMTDeviceStop)(MTDeviceRef);
static void (*pMTRegisterContactFrameCallback)(MTDeviceRef, MTFrameCallbackFunction);
static void (*pMTUnregisterContactFrameCallback)(MTDeviceRef, MTFrameCallbackFunction);

static RawTouchCallback globalCallback = nil;
static NSArray *activeDevices = nil;

static NSString *stateToString(int state) {
    switch (state) {
        case 0: return @"notTouching";
        case 1: return @"starting";
        case 2: return @"hovering";
        case 3: return @"making";
        case 4: return @"touching";
        case 5: return @"breaking";
        case 6: return @"lingering";
        case 7: return @"leaving";
        default: return @"unknown";
    }
}

static NSString *fingerName(int fingerId) {
    switch (fingerId) {
        case 0: return @"thumb";
        case 1: return @"index";
        case 2: return @"middle";
        case 3: return @"ring";
        case 4: return @"pinky";
        default: return [NSString stringWithFormat:@"f%d", fingerId];
    }
}

static void touchCallback(MTDeviceRef device, RMTTouch *touches, int numTouches, double timestamp, int frame) {
    if (!globalCallback) return;

    NSMutableArray<NSDictionary *> *array = [NSMutableArray arrayWithCapacity:numTouches];
    for (int i = 0; i < numTouches; i++) {
        RMTTouch t = touches[i];
        NSDictionary *dict = @{
            @"id": @(t.identifier),
            @"state": stateToString(t.state),
            @"stateRaw": @(t.state),
            @"fingerId": @(t.fingerId),
            @"fingerName": fingerName(t.fingerId),
            @"handId": @(t.handId),
            @"posX": @(t.normalizedPosition.position.x),
            @"posY": @(t.normalizedPosition.position.y),
            @"velX": @(t.normalizedPosition.velocity.x),
            @"velY": @(t.normalizedPosition.velocity.y),
            @"absPosX": @(t.absolutePosition.position.x),
            @"absPosY": @(t.absolutePosition.position.y),
            @"absVelX": @(t.absolutePosition.velocity.x),
            @"absVelY": @(t.absolutePosition.velocity.y),
            @"total": @(t.total),
            @"pressure": @(t.pressure),
            @"angle": @(t.angle),
            @"majorAxis": @(t.majorAxis),
            @"minorAxis": @(t.minorAxis),
            @"density": @(t.density),
            @"timestamp": @(t.timestamp),
            @"frame": @(t.frame),
        };
        [array addObject:dict];
    }

    dispatch_async(dispatch_get_main_queue(), ^{
        if (globalCallback) {
            globalCallback(array);
        }
    });
}

@implementation RawTouchFrame
@end

@implementation RawMultitouchBridge

+ (instancetype)shared {
    static RawMultitouchBridge *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[RawMultitouchBridge alloc] init];
    });
    return instance;
}

- (BOOL)startWithCallback:(RawTouchCallback)callback {
    void *handle = dlopen("/System/Library/PrivateFrameworks/MultitouchSupport.framework/MultitouchSupport", RTLD_LAZY);
    if (!handle) {
        NSLog(@"Failed to load MultitouchSupport.framework");
        return NO;
    }

    pMTDeviceCreateList = dlsym(handle, "MTDeviceCreateList");
    pMTDeviceStart = dlsym(handle, "MTDeviceStart");
    pMTDeviceStop = dlsym(handle, "MTDeviceStop");
    pMTRegisterContactFrameCallback = dlsym(handle, "MTRegisterContactFrameCallback");
    pMTUnregisterContactFrameCallback = dlsym(handle, "MTUnregisterContactFrameCallback");

    if (!pMTDeviceCreateList || !pMTDeviceStart || !pMTRegisterContactFrameCallback) {
        NSLog(@"Failed to resolve MultitouchSupport symbols");
        return NO;
    }

    globalCallback = callback;

    CFArrayRef deviceList = pMTDeviceCreateList();
    NSMutableArray *devices = [NSMutableArray array];

    for (CFIndex i = 0; i < CFArrayGetCount(deviceList); i++) {
        MTDeviceRef device = (MTDeviceRef)CFArrayGetValueAtIndex(deviceList, i);
        pMTRegisterContactFrameCallback(device, touchCallback);
        pMTDeviceStart(device, 0);
        [devices addObject:[NSValue valueWithPointer:device]];
    }

    activeDevices = [devices copy];
    CFRelease(deviceList);
    return YES;
}

- (void)stop {
    if (!pMTDeviceStop || !pMTUnregisterContactFrameCallback) return;

    for (NSValue *val in activeDevices) {
        MTDeviceRef device = [val pointerValue];
        pMTUnregisterContactFrameCallback(device, touchCallback);
        pMTDeviceStop(device);
    }
    activeDevices = nil;
    globalCallback = nil;
}

@end
