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
#include <stdarg.h>
#include <stddef.h>
#include <setjmp.h>
#include <cmocka.h>

#include "ndds/ndds_c.h"

#ifndef UNUSED_ARG
#define UNUSED_ARG(x_)  ((void)(x_))
#endif /* UNUSED_ARG */


#define assert_retcode_ok(expr_) assert_int_equal(DDS_RETCODE_OK,(expr_))

#define assert_retcode_err(expr_) assert_int_equal(DDS_RETCODE_ERROR,(expr_))

#define assert_time_equal(a_,b_) \
    assert_true(RTI_MQTT_Time_is_equal((a_),(b_)))

#define assert_string_seq_equal(a_,b_) \
    assert_true(DDS_StringSeq_is_equal((a_),(b_)))

#define assert_octet_seq_equal(a_,b_) \
    assert_true(DDS_OctetSeq_is_equal((a_),(b_)))

#define assert_string_equal_or_null(a_,b_) \
    assert_true(RTI_MQTT_String_is_equal((a_), (b_)));

#define assert_string_seq_equal_or_null(a_,b_) \
    assert_true(((a_) == NULL && (b_) == NULL) ||\
                ((a_) == NULL && (b_) == NULL && \
                    DDS_StringSeq_is_equal((a_),(b_))))

#define assert_octet_seq_equal_or_null(a_,b_) \
    assert_true(((a_) == NULL && (b_) == NULL) ||\
                ((a_) == NULL && (b_) == NULL && \
                    DDS_OctetSeq_is_equal((a_),(b_))))

DDS_Boolean
DDS_StringSeq_is_equal(const struct DDS_StringSeq *const self,
                       const struct DDS_StringSeq *const other);

DDS_Boolean
DDS_OctetSeq_is_equal(const struct DDS_OctetSeq *const self,
                      const struct DDS_OctetSeq *const other);