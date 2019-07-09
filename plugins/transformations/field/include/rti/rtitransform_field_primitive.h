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

#ifndef rtitransform_field_primitive_h
#define rtitransform_field_primitive_h

#ifdef RTI_TSFM_FIELD_ENABLE_LOG
#define RTI_TSFM_ENABLE_LOG
#endif /* RTI_TSFM_FIELD_ENABLE_LOG */

#ifdef RTI_TSFM_FIELD_DISABLE_LOG
#define RTI_TSFM_DISABLE_LOG
#endif /* RTI_TSFM_FIELD_DISABLE_LOG */

#ifdef RTI_TSFM_FIELD_ENABLE_TRACE
#define RTI_TSFM_ENABLE_TRACE
#endif /* RTI_TSFM_FIELD_ENABLE_TRACE */

#include "rtitransform_simple.h"

#include "rtitransform_field_typesSupport.h"

#define T               RTI_TSFM_Field_PrimitiveTransformation
#define TConfig         RTI_TSFM_Field_PrimitiveTransformationConfig
#define TState          RTI_TSFM_Field_PrimitiveTransformationState
#define T_static
#include "rtitransform_simple_tmplt_declare.h"

/*****************************************************************************
 *                         Configuration Properties
 *****************************************************************************/
#define RTI_TSFM_FIELD_PRIMITIVE_TRANSFORMATION_PROPERTY_PREFIX \
        ""

#define RTI_TSFM_FIELD_PRIMITIVE_PROPERTY_TRANSFORMATION_BUFFER_MEMBER \
        RTI_TSFM_FIELD_PRIMITIVE_TRANSFORMATION_PROPERTY_PREFIX "buffer_member"

#define RTI_TSFM_FIELD_PRIMITIVE_PROPERTY_TRANSFORMATION_FIELD \
        RTI_TSFM_FIELD_PRIMITIVE_TRANSFORMATION_PROPERTY_PREFIX "field"

#define RTI_TSFM_FIELD_PRIMITIVE_PROPERTY_TRANSFORMATION_FIELD_TYPE \
        RTI_TSFM_FIELD_PRIMITIVE_TRANSFORMATION_PROPERTY_PREFIX "field_type"

#define RTI_TSFM_FIELD_PRIMITIVE_PROPERTY_TRANSFORMATION_MAX_SERIALIZED_SIZE \
        RTI_TSFM_FIELD_PRIMITIVE_TRANSFORMATION_PROPERTY_PREFIX "max_serialized_size"

#define RTI_TSFM_FIELD_PRIMITIVE_PROPERTY_TRANSFORMATION_SERIALIZATION_FORMAT \
        RTI_TSFM_FIELD_PRIMITIVE_TRANSFORMATION_PROPERTY_PREFIX "serialization_format"

#endif /* rtitransform_field_primitive_h */