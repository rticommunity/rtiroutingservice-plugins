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
#include "TestFramework.h"
#include "TopicFilterTester.h"
#include "Infrastructure.h"


void
mqtt_infrastructure_test_topic_filter_match(void **state)
{
#define test_filter_y(f_,t_) \
{\
    DDS_Boolean match = DDS_BOOLEAN_FALSE; \
    assert_retcode_ok(RTI_MQTT_TopicFilter_match((f_),(t_),&match)); \
    assert_true(match); \
}
#define test_filter_n(f_,t_) \
{\
    DDS_Boolean match = DDS_BOOLEAN_FALSE; \
    assert_retcode_ok(RTI_MQTT_TopicFilter_match((f_),(t_),&match)); \
    assert_false(match); \
}
#define test_filter_err(f_,t_) \
{\
    DDS_Boolean match = DDS_BOOLEAN_FALSE; \
    assert_retcode_err(RTI_MQTT_TopicFilter_match((f_),(t_),&match)); \
}
    test_filter_y("bar/#","bar/foo/baz");
    test_filter_y("bar/+/+/+/baz","bar/foo/foo/foo/baz");
    test_filter_y("#","foo");
    test_filter_y("#","foo/really *$()@any12312 character, even +");
    test_filter_n("bar/#","foo");
    test_filter_n("bar/+/+/baz","bar/foo/foo/foo/baz");
    test_filter_y("/bar/#","/bar/foo");
    test_filter_err("/bar/#foo","/bar/foo");
    test_filter_err("/bar/#","/bar//foo")
}
