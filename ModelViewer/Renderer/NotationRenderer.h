//
//  NotationRenderer.h
//  ModelViewer
//
//  Created by dfeng on 11/8/16.
//  Copyright © 2016 middleware. All rights reserved.
//



#import "NuoRenderPipelinePass.h"


@class NuoLightSource;
@class NuoLua;


@interface NotationRenderer : NuoRenderPipelinePass


@property (nonatomic, readonly) NSArray<NuoLightSource*>* lightSources;

@property (nonatomic, assign) float notationWidthCap;
@property (nonatomic, assign) CGRect notationArea;


// retrieve the currently-selected description

@property (nonatomic, readonly) NuoLightSource* selectedLightSource;


- (instancetype)initWithDevice:(id<MTLDevice>)device;


- (void)selectCurrentLightVector:(CGPoint)point;
- (void)importScene:(NuoLua*)lua;


// manipulator to the current selected light source

- (void)setRotateX:(float)rotateX;
- (void)setRotateY:(float)rotateY;
- (void)setDensity:(float)density;
- (void)setSpacular:(float)spacular;
- (void)setShadowSoften:(float)shadowSoften;
- (void)setShadowOccluderRadius:(float)shadowOccluderRadius;
- (void)setShadowBias:(float)shadowBias;


@end
