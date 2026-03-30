#ifndef RawMultitouch_h
#define RawMultitouch_h

#import <Foundation/Foundation.h>

typedef struct {
    float x;
    float y;
} RMTPoint;

typedef struct {
    RMTPoint position;
    RMTPoint velocity;
} RMTVector;

typedef struct {
    int frame;
    double timestamp;
    int identifier;
    int state;       // 0-7
    int fingerId;    // which finger (thumb=0, index=1, middle=2, ring=3, pinky=4)
    int handId;      // which hand (0 or 1)
    RMTVector normalizedPosition;
    float total;
    float pressure;
    float angle;
    float majorAxis;
    float minorAxis;
    RMTVector absolutePosition;
    int field14;
    int field15;
    float density;
} RMTTouch;

// Exported touch data for Swift consumption
@interface RawTouchFrame : NSObject
@property (assign) int fingerCount;
@property (strong) NSArray<NSValue *> *touches; // array of RMTTouch wrapped in NSValue
@end

typedef void (^RawTouchCallback)(NSArray<NSDictionary *> *touches);

@interface RawMultitouchBridge : NSObject
+ (instancetype)shared;
- (BOOL)startWithCallback:(RawTouchCallback)callback;
- (void)stop;
@end

#endif
