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

#include "rtitransform_simple_noop.h"

#define RTI_TSFM_LOG_ARGS           "rtitransform::noop"

DDS_ReturnCode_t
RTI_TSFM_NoopTransformation_serialize(
        RTI_TSFM_UserTypePlugin *plugin,
        RTI_TSFM_Transformation *self,
        DDS_DynamicData *sample_in,
        DDS_DynamicData *sample_out)
{
    return DDS_RETCODE_OK;
}

DDS_ReturnCode_t 
RTI_TSFM_NoopTransformation_deserialize(
        RTI_TSFM_UserTypePlugin *plugin,
        RTI_TSFM_Transformation *self,
        DDS_DynamicData *sample_in,
        DDS_DynamicData *sample_out)
{
    return DDS_RETCODE_OK;
}

#define T               RTI_TSFM_NoopTransformation
#define T_static
#define T_serialize     RTI_TSFM_NoopTransformation_serialize
#define T_deserialize   RTI_TSFM_NoopTransformation_deserialize
#include "rtitransform_simple_tmplt_define.h"
