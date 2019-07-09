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

#ifndef TransformationPlugin_h
#define TransformationPlugin_h

DDS_ReturnCode_t
RTI_TSFM_TransformationPluginConfig_default(
    RTI_TSFM_TransformationPluginConfig **config_out);

DDS_ReturnCode_t
RTI_TSFM_TransformationPluginConfig_new(
    DDS_Boolean allocate_optional,
    RTI_TSFM_TransformationPluginConfig **config_out);

void
RTI_TSFM_TransformationPluginConfig_delete(
    RTI_TSFM_TransformationPluginConfig *self);


#endif /* TransformationPlugin_h */