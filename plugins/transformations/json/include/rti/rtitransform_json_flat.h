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

#ifndef rtitransform_json_flat_h
#define rtitransform_json_flat_h

#ifdef RTI_TSFM_JSON_ENABLE_LOG
#define RTI_TSFM_ENABLE_LOG
#endif /* RTI_TSFM_JSON_ENABLE_LOG */

#ifdef RTI_TSFM_JSON_DISABLE_LOG
#define RTI_TSFM_DISABLE_LOG
#endif /* RTI_TSFM_JSON_DISABLE_LOG */

#ifdef RTI_TSFM_JSON_ENABLE_TRACE
#define RTI_TSFM_ENABLE_TRACE
#endif /* RTI_TSFM_JSON_ENABLE_TRACE */


#include "rtitransform_simple.h"

#include "rtitransform_json_typesSupport.h"

typedef struct RTI_TSFM_Json_FlatTypeTransformationImpl
        RTI_TSFM_Json_FlatTypeTransformation;

typedef struct RTI_TSFM_Json_FlatTypeTransformation_MemberMappingImpl
        RTI_TSFM_Json_FlatTypeTransformation_MemberMapping;

typedef struct _json_value json_value;

typedef DDS_ReturnCode_t (*RTI_TSFM_Json_FlatTypeTransformation_ParseMemberFn)(
    RTI_TSFM_Json_FlatTypeTransformation *self,
    RTI_TSFM_Json_FlatTypeTransformation_MemberMapping *member,
    json_value *json_member_val,
    DDS_DynamicData *sample);

struct RTI_TSFM_Json_FlatTypeTransformation_MemberMappingImpl
{
    DDS_UnsignedLong id;
    DDS_TCKind kind;
    DDS_UnsignedLong max_len;
    DDS_Boolean optional;
    const char *name;
    RTI_TSFM_Json_FlatTypeTransformation_ParseMemberFn parse_fn;
};


#define RTI_TSFM_Json_FlatTypeTransformation_parse_member(t_,m_,j_,s_) \
    ((m_)->parse_fn((t_),(m_),(j_),(s_)))


DDS_SEQUENCE(RTI_TSFM_Json_FlatTypeTransformation_MemberMappingSeq, 
             RTI_TSFM_Json_FlatTypeTransformation_MemberMapping);


typedef struct RTI_TSFM_Json_FlatTypeTransformationStateImpl
{
    char                *json_buffer;
    DDS_UnsignedLong    json_buffer_size;
    struct RTI_TSFM_Json_FlatTypeTransformation_MemberMappingSeq output_mappings;
    struct RTI_TSFM_Json_FlatTypeTransformation_MemberMappingSeq input_mappings;
} RTI_TSFM_Json_FlatTypeTransformationState;

#define T               RTI_TSFM_Json_FlatTypeTransformation
#define TConfig         RTI_TSFM_Json_FlatTypeTransformationConfig
#define TState          RTI_TSFM_Json_FlatTypeTransformationState
#define T_static
#include "rtitransform_simple_tmplt_declare.h"

/*****************************************************************************
 *                         Configuration Properties
 *****************************************************************************/
#define RTI_TSFM_JSON_FLATTYPE_TRANSFORMATION_PROPERTY_PREFIX \
        ""

#define RTI_TSFM_JSON_FLATTYPE_PROPERTY_TRANSFORMATION_BUFFER_MEMBER \
        RTI_TSFM_JSON_FLATTYPE_TRANSFORMATION_PROPERTY_PREFIX "buffer_member"

#define RTI_TSFM_JSON_FLATTYPE_PROPERTY_TRANSFORMATION_SERIALIZED_SIZE_MIN \
        RTI_TSFM_JSON_FLATTYPE_TRANSFORMATION_PROPERTY_PREFIX "serialized_size_min"

#define RTI_TSFM_JSON_FLATTYPE_PROPERTY_TRANSFORMATION_SERIALIZED_SIZE_MAX \
        RTI_TSFM_JSON_FLATTYPE_TRANSFORMATION_PROPERTY_PREFIX "serialized_size_max"

#define RTI_TSFM_JSON_FLATTYPE_PROPERTY_TRANSFORMATION_SERIALIZED_SIZE_INCR \
        RTI_TSFM_JSON_FLATTYPE_TRANSFORMATION_PROPERTY_PREFIX "serialized_size_incr"

#define RTI_TSFM_JSON_FLATTYPE_PROPERTY_TRANSFORMATION_INDENT \
        RTI_TSFM_JSON_FLATTYPE_TRANSFORMATION_PROPERTY_PREFIX "indent"

/*****************************************************************************
 *                           JSON Shape Parser
 *****************************************************************************/
DDS_ReturnCode_t
RTI_TSFM_Json_FlatTypeTransformation_deserialize_shape(
    const char *json_buffer,
    DDS_UnsignedLong json_buffer_size,
    DDS_DynamicData *sample);

#endif /* rtitransform_json_flat_h */