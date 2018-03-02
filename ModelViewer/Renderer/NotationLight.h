//
//  NotationLight.h
//  ModelViewer
//
//  Created by middleware on 11/13/16.
//  Copyright © 2016 middleware. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Metal/Metal.h>
#import <simd/simd.h>


@class NuoLightSource;
@class NuoMeshBox;


@interface NotationLight : NSObject


@property (nonatomic, weak) NuoLightSource* lightSourceDesc;

@property (nonatomic, assign) BOOL selected;


- (instancetype)initWithCommandQueue:(id<MTLCommandQueue>)commandQueue isBold:(BOOL)bold;

- (void)drawWithRenderPass:(id<MTLRenderCommandEncoder>)renderPass
              withInFlight:(unsigned int)inFlight;


- (NuoMeshBox*)boundingBox;
- (CGPoint)headPointProjected;


@end
