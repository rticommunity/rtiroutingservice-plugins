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
#include "InfrastructureTester.h"
#include "Infrastructure.h"

#define RTI_MQTT_LOG_ARGS       "InfrastructureTester"

void
mqtt_infrastructure_test_message_to_dyndata(void **state)
{
    RTI_MQTT_QosLevel   msg_qos = RTI_MQTT_QosLevel_TWO,
                            dynmsg_qos = RTI_MQTT_QosLevel_UNKNOWN;
    DDS_Boolean             msg_ret = DDS_BOOLEAN_FALSE,
                            msg_dup = DDS_BOOLEAN_FALSE,
                            dynmsg_ret = DDS_BOOLEAN_FALSE,
                            dynmsg_dup = DDS_BOOLEAN_FALSE;
    DDS_Long                msg_id  = 1234,
                            dynmsg_id = 0;
    const char             *msg_topic = "a/message/topic",
                           *msg_payload = "This is the payload of the message",
                           *dynmsg_payload = NULL;
    char                   *dynmsg_topic = NULL;
    DDS_UnsignedLong        msg_payload_len = 0,
                            dynmsg_payload_len = 0,
                            dymsg_topic_len = 0;
    struct DDS_OctetSeq     dynmsg_payload_seq = DDS_SEQUENCE_INITIALIZER;

#define set_message_fields(m_) \
{\
    (m_)->info->id = msg_id; \
    assert_non_null(DDS_String_replace(&(m_)->topic,msg_topic)); \
    (m_)->info->qos_level = msg_qos; \
    (m_)->info->retained = msg_ret; \
    (m_)->info->duplicate = msg_dup; \
    msg_payload_len = RTI_MQTT_String_length(msg_payload) + 1; \
    assert_true( \
        DDS_OctetSeq_ensure_length(\
            &(m_)->payload.data,msg_payload_len,msg_payload_len)); \
    RTI_MQTT_Memory_copy( \
        DDS_OctetSeq_get_contiguous_buffer(&(m_)->payload.data), \
        msg_payload, \
        msg_payload_len); \
}

#define alloc_message(m_) \
{\
    struct DDS_TypeAllocationParams_t alloc_params = \
                        DDS_TYPE_ALLOCATION_PARAMS_DEFAULT;\
    alloc_params.allocate_memory = RTI_TRUE;\
    alloc_params.allocate_pointers = RTI_TRUE;\
    alloc_params.allocate_optional_members = RTI_TRUE;\
    (m_) = RTI_MQTT_MessageTypeSupport_create_data_w_params(&alloc_params);\
    assert_non_null((m_));\
    set_message_fields((m_));\
}

#define convert_to_and_test(m_,dm_) \
{\
    assert_int_equal(DDS_RETCODE_OK, \
                        RTI_MQTT_Message_to_dynamic_data((m_),(dm_))); \
    assert_int_equal(DDS_RETCODE_OK, \
        DDS_DynamicData_get_long((dm_),&dynmsg_id,"info.id",\
            DDS_DYNAMIC_DATA_MEMBER_ID_UNSPECIFIED)); \
    assert_int_equal(msg_id,dynmsg_id); \
    assert_int_equal(DDS_RETCODE_OK, \
        DDS_DynamicData_get_long((dm_),&dynmsg_id,"info.qos_level",\
            DDS_DYNAMIC_DATA_MEMBER_ID_UNSPECIFIED)); \
    assert_int_equal(msg_qos,dynmsg_qos); \
    assert_int_equal(DDS_RETCODE_OK, \
        DDS_DynamicData_get_boolean( \
            (dm_),&dynmsg_ret,"info.retained",\
            DDS_DYNAMIC_DATA_MEMBER_ID_UNSPECIFIED)); \
    assert_int_equal(msg_ret,dynmsg_ret); \
    assert_int_equal(DDS_RETCODE_OK, \
        DDS_DynamicData_get_boolean( \
            (dm_),&dynmsg_dup,"info.duplicate",\
            DDS_DYNAMIC_DATA_MEMBER_ID_UNSPECIFIED)); \
    assert_int_equal(msg_dup,dynmsg_dup); \
    assert_int_equal(DDS_RETCODE_OK, \
        DDS_DynamicData_get_octet_seq( \
            (dm_),&dynmsg_payload_seq,"payload.data",\
            DDS_DYNAMIC_DATA_MEMBER_ID_UNSPECIFIED)); \
    dynmsg_payload_len = DDS_OctetSeq_get_length(&dynmsg_payload_seq); \
    dynmsg_payload = \
            DDS_OctetSeq_get_contiguous_buffer(&dynmsg_payload_seq); \
    assert_int_equal(msg_payload_len,dynmsg_payload_len); \
    assert_int_equal(0, \
            RTI_MQTT_Memory_compare( \
                msg_payload,dynmsg_payload,sizeof(char)*msg_payload_len)); \
    DDS_DynamicDataTypeSupport_delete_data(dyndata_support,dynmsg); \
    dynmsg = NULL; \
}

    RTI_MQTT_Message *msg = NULL;
    DDS_DynamicData *dynmsg = NULL;
    struct DDS_TypeCode *type_code = NULL;
    struct DDS_DynamicDataTypeSupport *dyndata_support = NULL;

    type_code = RTI_MQTT_Message_get_typecode();
    assert_non_null(type_code);
    
    dyndata_support = DDS_DynamicDataTypeSupport_new(type_code,
                            &DDS_DYNAMIC_DATA_TYPE_PROPERTY_DEFAULT);
    assert_non_null(dyndata_support);

    {
        DDS_UnsignedLong tot = 1000,
                         i = 0;
        
        for (i = 0; i < tot; i++)
        {
            alloc_message(msg);

            dynmsg = DDS_DynamicDataTypeSupport_create_data(dyndata_support);
            assert_non_null(dynmsg);

            assert_int_equal(DDS_RETCODE_OK, \
                        RTI_MQTT_Message_to_dynamic_data(msg,dynmsg)); \
            
            /* At this point we can delete msg */
            RTI_MQTT_MessageTypeSupport_delete_data(msg);
            msg = NULL;

            assert_int_equal(DDS_RETCODE_OK, \
                DDS_DynamicData_get_string(dynmsg,
                    &dynmsg_topic,&dymsg_topic_len,"topic",\
                    DDS_DYNAMIC_DATA_MEMBER_ID_UNSPECIFIED)); \
            assert_string_equal(msg_topic,dynmsg_topic); \
            assert_int_equal(DDS_RETCODE_OK, \
                DDS_DynamicData_get_long(dynmsg,&dynmsg_id,"info.id",\
                    DDS_DYNAMIC_DATA_MEMBER_ID_UNSPECIFIED)); \
            assert_int_equal(msg_id,dynmsg_id); \
            assert_int_equal(DDS_RETCODE_OK, \
                DDS_DynamicData_get_boolean( \
                    dynmsg,&dynmsg_ret,"info.retained",\
                    DDS_DYNAMIC_DATA_MEMBER_ID_UNSPECIFIED)); \
            assert_int_equal(msg_ret,dynmsg_ret); \
            assert_int_equal(DDS_RETCODE_OK, \
                DDS_DynamicData_get_boolean( \
                    dynmsg,&dynmsg_dup,"info.duplicate",\
                    DDS_DYNAMIC_DATA_MEMBER_ID_UNSPECIFIED)); \
            assert_int_equal(msg_dup,dynmsg_dup); \
            assert_int_equal(DDS_RETCODE_OK, \
                DDS_DynamicData_get_long(dynmsg,
                    (DDS_Long *)&dynmsg_qos,"info.qos_level",\
                    DDS_DYNAMIC_DATA_MEMBER_ID_UNSPECIFIED)); \
            assert_int_equal(msg_qos, dynmsg_qos); \
            assert_int_equal(DDS_RETCODE_OK, \
                DDS_DynamicData_get_octet_seq( \
                    dynmsg,&dynmsg_payload_seq,"payload.data",\
                    DDS_DYNAMIC_DATA_MEMBER_ID_UNSPECIFIED)); \
            dynmsg_payload_len = DDS_OctetSeq_get_length(&dynmsg_payload_seq); \
            dynmsg_payload = \
                    DDS_OctetSeq_get_contiguous_buffer(&dynmsg_payload_seq); \
            assert_int_equal(msg_payload_len,dynmsg_payload_len); \
            assert_int_equal(0, \
                    RTI_MQTT_Memory_compare( \
                        msg_payload,dynmsg_payload,sizeof(char)*msg_payload_len)); \
            DDS_DynamicDataTypeSupport_delete_data(dyndata_support,dynmsg); \
            dynmsg = NULL; 
            RTI_MQTT_MessageTypeSupport_delete_data(msg);
            msg = NULL;
        }
        
    }

    DDS_DynamicDataTypeSupport_delete(dyndata_support);
    
}


int main(void) {
    const struct CMUnitTest tests[] = {
        cmocka_unit_test(mqtt_infrastructure_test_topic_filter_match),
        cmocka_unit_test(mqtt_infrastructure_test_client_config_default),
        cmocka_unit_test(mqtt_infrastructure_test_subscription_config_default),
        cmocka_unit_test(mqtt_infrastructure_test_publication_config_default),
        cmocka_unit_test(mqtt_infrastructure_test_message_to_dyndata)
    };
    return cmocka_run_group_tests(tests, NULL, NULL);
}