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

#ifndef Transformation_h
#define Transformation_h

DDS_ReturnCode_t
RTI_TSFM_TransformationConfig_default(
    RTI_TSFM_TransformationConfig **config_out);

DDS_ReturnCode_t
RTI_TSFM_TransformationConfig_new(
    DDS_Boolean allocate_optional,
    RTI_TSFM_TransformationConfig **config_out);

void
RTI_TSFM_TransformationConfig_delete(
    RTI_TSFM_TransformationConfig *self);

RTIBool
RTI_TSFM_TransformationPtr_initialize_w_params(
    RTI_TSFM_Transformation **self,
    const struct DDS_TypeAllocationParams_t * allocParams);

RTIBool
RTI_TSFM_TransformationPtr_finalize_w_params(
    RTI_TSFM_Transformation **self,
    const struct DDS_TypeDeallocationParams_t * deallocParams);

RTIBool
RTI_TSFM_TransformationPtr_copy(
    RTI_TSFM_Transformation **dst,
    const RTI_TSFM_Transformation **src);

#endif /* Transformation_h */