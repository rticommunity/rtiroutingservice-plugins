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

#ifndef UserPlugin_h
#define UserPlugin_h

RTI_TSFM_UserTypePlugin*
RTI_TSFM_UserTypePlugin_create_dynamic(
    RTI_TSFM_TransformationPlugin *transform_plugin,
    const char *plugin_lib,
    const char *plugin_create_fn);

#endif /* UserPlugin_h */