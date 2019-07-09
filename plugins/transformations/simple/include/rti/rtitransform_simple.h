/*
 * (c) 2019 Copyright, Real-Time Innovations, Inc.  All rights reserved.
 *
 * RTI grants Licensee a license to use, modify, compile, and create derivative
 * works of the Software.  Licensee has the right to distribute object form
 * only for use with RTI products.  The Software is provided "as is", with no
 * warranty of any type, including any warranty for fitness for any purpose.
 * RTI is under no obligation to maintain or support the Software.  RTI shall
 * not be liable for any incidental or consequential damages arising out of the
 * use or inability to use the software.
 */

#ifndef rtitransform_simple_h
#define rtitransform_simple_h

#include "rtitransform_simple_platform.h"

/*****************************************************************************
 *                         Library Version
 *****************************************************************************/

#define RTI_TSFM_TRANSFORMATION_VERSION_MAJOR        1
#define RTI_TSFM_TRANSFORMATION_VERSION_MINOR        0
#define RTI_TSFM_TRANSFORMATION_VERSION_RELEASE      0
#define RTI_TSFM_TRANSFORMATION_VERSION_REVISION     0

/*****************************************************************************
 *                         Configuration Properties
 *****************************************************************************/
#define RTI_TSFM_PLUGIN_PROPERTY_PREFIX \
        ""

#define RTI_TSFM_TRANSFORMATION_PROPERTY_PREFIX \
        ""

#define RTI_TSFM_PROPERTY_PLUGIN_DLL \
        RTI_TSFM_PLUGIN_PROPERTY_PREFIX "dll"

#define RTI_TSFM_PROPERTY_CREATE_FN \
        RTI_TSFM_PLUGIN_PROPERTY_PREFIX "create_fn"

#define RTI_TSFM_PROPERTY_TRANSFORMATION_TYPE \
        RTI_TSFM_TRANSFORMATION_PROPERTY_PREFIX "transform_type"

#define RTI_TSFM_PROPERTY_TRANSFORMATION_INPUT_TYPE \
        RTI_TSFM_TRANSFORMATION_PROPERTY_PREFIX "input_type"

#define RTI_TSFM_PROPERTY_TRANSFORMATION_OUTPUT_TYPE \
        RTI_TSFM_TRANSFORMATION_PROPERTY_PREFIX "output_type"

/*****************************************************************************
 *                        User Type Plugin Class
 *****************************************************************************/

typedef struct RTI_TSFM_TransformationImpl RTI_TSFM_Transformation;
typedef struct RTI_TSFM_TransformationPluginImpl RTI_TSFM_TransformationPlugin;
typedef struct RTI_TSFM_UserTypePluginImpl RTI_TSFM_UserTypePlugin;

typedef RTI_TSFM_UserTypePlugin *
(*RTI_TSFM_UserTypePlugin_CreateFn)(
        RTI_TSFM_UserTypePlugin *plugin,
        const struct RTI_RoutingServiceProperties *properties,
        RTI_RoutingServiceEnvironment *env);

typedef DDS_ReturnCode_t 
(*RTI_TSFM_UserTypePlugin_SerializeSampleFn)(
        RTI_TSFM_UserTypePlugin *plugin,
        RTI_TSFM_Transformation *transform,
        DDS_DynamicData *sample_in,
        DDS_DynamicData *sample_out);

typedef DDS_ReturnCode_t 
(*RTI_TSFM_UserTypePlugin_DeserializeSampleFn)(
        RTI_TSFM_UserTypePlugin *plugin,
        RTI_TSFM_Transformation *transform,
        DDS_DynamicData *sample_in,
        DDS_DynamicData *sample_out);

typedef void
(*RTI_TSFM_UserTypePlugin_DeletePluginFn)(
        RTI_TSFM_UserTypePlugin *self,
        RTI_TSFM_TransformationPlugin *plugin);

typedef struct RTI_TSFM_UserTypePluginImpl
{
    RTI_TSFM_UserTypePlugin_DeletePluginFn          delete_plugin;
    RTI_TSFM_UserTypePlugin_SerializeSampleFn       serialize_sample;
    RTI_TSFM_UserTypePlugin_DeserializeSampleFn     deserialize_sample;
    void                                           *user_object;
} RTI_TSFM_UserTypePlugin;

#define RTI_TSFM_UserTypePlugin_initialize(p_) \
{\
    (p_)->serialize_sample = NULL; \
    (p_)->deserialize_sample = NULL; \
    (p_)->user_object = NULL; \
}

RTI_TSFM_UserTypePlugin*
RTI_TSFM_UserTypePlugin_create_static(
    RTI_TSFM_TransformationPlugin *transform_plugin,
    RTI_TSFM_UserTypePlugin_SerializeSampleFn serialize_sample,
    RTI_TSFM_UserTypePlugin_DeserializeSampleFn deserialize_sample);

void
RTI_TSFM_UserTypePlugin_delete_default(
    RTI_TSFM_UserTypePlugin *self,
    RTI_TSFM_TransformationPlugin *transform_plugin);

DDS_SEQUENCE(RTI_TSFM_DDS_DynamicDataPtrSeq, DDS_DynamicData*);
/*****************************************************************************
 *                       Base Transformation Class
 *****************************************************************************/

const RTI_TSFM_TransformationConfig RTI_TSFM_TransformationConfig_DEFAULT;

#define RTI_TSFM_TransformationConfig_INITIALIZER \
{\
    RTI_TSFM_TransformationKind_SERIALIZER,    /* type */ \
    "",                     /* input_type */      \
    ""                      /* output_type */     \
}

DDS_ReturnCode_t
RTI_TSFM_TransformationConfig_parse_from_properties(
    RTI_TSFM_TransformationConfig *config,
    const struct RTI_RoutingServiceProperties * properties);

typedef struct RTI_TSFM_TransformationImpl
{
    RTI_TSFM_TransformationConfig      *config;
    RTI_TSFM_TransformationPlugin      *plugin;
    struct DDS_DynamicDataTypeSupport  *tsupport;
    struct RTI_TSFM_DDS_DynamicDataPtrSeq        read_buffer;
    DDS_Boolean                         read_buffer_loaned;
#if RTI_TSFM_USE_MUTEX
    RTI_TSFM_Mutex                      lock;
#endif /* RTI_TSFM_USE_MUTEX */
} RTI_TSFM_Transformation;


DDS_ReturnCode_t
RTI_TSFM_Transformation_initialize(
    RTI_TSFM_Transformation *self,
    RTI_TSFM_TransformationPlugin *plugin,
    const struct RTI_RoutingServiceTypeInfo *input_type_info,
    const struct RTI_RoutingServiceTypeInfo *output_type_info,
    const struct RTI_RoutingServiceProperties *properties,
    RTI_RoutingServiceEnvironment *env);

DDS_ReturnCode_t
RTI_TSFM_Transformation_finalize(
    RTI_TSFM_Transformation *self);

DDS_ReturnCode_t
RTI_TSFM_Transformation_transform(
    RTI_TSFM_Transformation *self,
    RTI_RoutingServiceSample **out_sample_lst,
    RTI_RoutingServiceSampleInfo **out_info_lst,
    int *out_count,
    RTI_RoutingServiceSample *in_sample_lst,
    RTI_RoutingServiceSampleInfo *in_info_lst,
    int in_count,
    RTI_RoutingServiceEnvironment *env);

DDS_ReturnCode_t
RTI_TSFM_Transformation_return_loan(
    RTI_TSFM_Transformation *self,
    RTI_RoutingServiceSample *sample_lst,
    RTI_RoutingServiceSampleInfo *info_lst,
    int count,
    RTI_RoutingServiceEnvironment *env);

DDS_ReturnCode_t
RTI_TSFM_Transformation_update(
    RTI_RoutingServiceTransformation transformation,
    const struct RTI_RoutingServiceProperties *properties,
    RTI_RoutingServiceEnvironment *env);


DDS_SEQUENCE(RTI_TSFM_TransformationPtrSeq, RTI_TSFM_Transformation*);

/*****************************************************************************
 *                      Transformation Plugin Class
 *****************************************************************************/

const RTI_TSFM_TransformationConfig RTI_TSFM_TransformationConfig_DEFAULT;

#define RTI_TSFM_TransformationPluginConfig_INITIALIZER \
{\
    "",                     /* dll */ \
    ""                      /* create_fn */ \
}

DDS_ReturnCode_t
RTI_TSFM_TransformationPluginConfig_parse_from_properties(
    RTI_TSFM_TransformationPluginConfig *config,
    const struct RTI_RoutingServiceProperties * properties);


typedef struct RTI_TSFM_TransformationPluginImpl
{
    struct RTI_RoutingServiceTransformationPlugin   parent;
    struct RTI_TSFM_TransformationPtrSeq            transforms;
    RTI_TSFM_TransformationPluginConfig            *config;
    RTI_TSFM_UserTypePlugin                        *user_plugin;
#if RTI_TSFM_USE_MUTEX
    RTI_TSFM_Mutex                                  lock;
#endif /* RTI_TSFM_USE_MUTEX */
} RTI_TSFM_TransformationPlugin;

DDS_ReturnCode_t
RTI_TSFM_TransformationPlugin_initialize(
    RTI_TSFM_TransformationPlugin *self,
    const struct RTI_RoutingServiceProperties *properties, 
    RTI_RoutingServiceEnvironment *env);

DDS_ReturnCode_t
RTI_TSFM_TransformationPlugin_initialize_static(
    RTI_TSFM_TransformationPlugin *self,
    RTI_TSFM_UserTypePlugin *user_plugin,
    RTI_TSFM_TransformationPluginConfig *config,
    const struct RTI_RoutingServiceProperties *properties, 
    RTI_RoutingServiceEnvironment *env);

DDS_ReturnCode_t
RTI_TSFM_TransformationPlugin_finalize(
    RTI_TSFM_TransformationPlugin *self,
    RTI_RoutingServiceEnvironment *env);

DDS_ReturnCode_t
RTI_TSFM_TransformationPlugin_initialize_transformation(
    RTI_TSFM_TransformationPlugin *self,
    RTI_TSFM_Transformation *transform,
    const struct RTI_RoutingServiceTypeInfo *input_type_info,
    const struct RTI_RoutingServiceTypeInfo *output_type_info,
    const struct RTI_RoutingServiceProperties *properties,
    RTI_RoutingServiceEnvironment *env);

DDS_ReturnCode_t
RTI_TSFM_TransformationPlugin_finalize_transformation(
    RTI_TSFM_TransformationPlugin *self,
    RTI_TSFM_Transformation *transform,
    RTI_RoutingServiceEnvironment *env);

#include "rtitransform_simple_log.h"

#endif /* rtitransform_simple_h */