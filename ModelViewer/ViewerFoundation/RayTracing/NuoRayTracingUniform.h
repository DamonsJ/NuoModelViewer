//
//  NuoRayTracingShadersCommon.h
//  ModelViewer
//
//  Created by middleware on 6/11/18.
//  Copyright © 2018 middleware. All rights reserved.
//

#ifndef NuoRayTracingShadersCommon_h
#define NuoRayTracingShadersCommon_h


#include "Meshes/NuoMatrixTypes.h"


typedef enum
{
    kNuoRayMask_Opaue           = 1,
    kNuoRayMask_Translucent     = 2,
    kNuoRayMask_Illuminating    = 4,
    kNuoRayMask_Disabled        = 8,
}
NuoRayMask;


typedef struct
{
    vector4 center;
    float span;
}
NuoBoundsUniform;



typedef struct
{
    matrix44 direction;
    float radius;
}
NuoRayTracingLightSource;


typedef struct
{
    NuoBoundsUniform bounds;
    NuoRayTracingLightSource lightSources[2];
}
NuoRayTracingUniforms;


typedef struct
{
    float uRange;
    float vRange;
    
    uint wViewPort;
    uint hViewPort;
    
    matrix44 viewTrans;
}
NuoRayVolumeUniform;





#endif /* NuoRayTracingShadersCommon_h */
