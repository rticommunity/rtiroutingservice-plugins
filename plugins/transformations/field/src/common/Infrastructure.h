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

#ifndef Infrastructure_h
#define Infrastructure_h

#include "rtitransform_field.h"

DDS_ReturnCode_t
RTI_TSFM_Field_FieldType_from_string(
        const char *str, RTI_TSFM_Field_FieldType *tck_out);

#endif /* Infrastructure_h */