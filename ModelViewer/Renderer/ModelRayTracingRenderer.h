//
//  ModelRayTracingRenderer.h
//  ModelViewer
//
//  Created by middleware on 6/22/18.
//  Copyright © 2018 middleware. All rights reserved.
//

#import "NuoRayTracingRenderer.h"
#import "NuoMeshSceneRenderPass.h"


@class NuoLightSource;
@class NuoIlluminationTarget;



@interface ModelRayTracingRenderer : NuoRayTracingRenderer


@property (nonatomic, assign) NuoBounds sceneBounds;
@property (nonatomic, assign) NuoRayTracingGlobalIlluminationParam globalIllum;

@property (nonatomic, strong) NSArray<NuoLightSource*>* lightSources;

@property (nonatomic, readonly) NuoIlluminationTarget* rayTracingResult;


- (instancetype)initWithCommandQueue:(id<MTLCommandQueue>)commandQueue;


@end


