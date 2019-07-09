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
#include "ConfigTester.h"
#include "Infrastructure.h"

static void
mqtt_infrastructure_client_config_compare(
    const RTI_MQTT_ClientConfig *const a, 
    const RTI_MQTT_ClientConfig *const b)
{
    assert_string_equal_or_null(a->id, b->id);
    assert_int_equal(a->protocol_version, b->protocol_version);
    assert_string_seq_equal(&a->server_uris, &a->server_uris);
    assert_time_equal(&a->connect_timeout,&b->connect_timeout);
    assert_int_equal(a->max_connection_retries,b->max_connection_retries);
    assert_time_equal(&a->keep_alive_period,&b->keep_alive_period);
    assert_int_equal(a->clean_session,b->clean_session);
    assert_int_equal(a->unsubscribe_on_disconnect,b->unsubscribe_on_disconnect);
    assert_time_equal(&a->max_reply_timeout,&b->max_reply_timeout);
    assert_int_equal(a->reconnect,b->reconnect);
    assert_int_equal(a->max_unack_messages,b->max_unack_messages);
    assert_int_equal(a->persistence_level,b->persistence_level);
    assert_string_equal_or_null(a->persistence_storage,
                                b->persistence_storage);
    assert_string_equal_or_null(a->username,b->username);
    assert_octet_seq_equal_or_null(a->password,b->password);
    /* TODO compare ssl_tls_config */
}

void
mqtt_infrastructure_test_client_config_default(void **state)
{
    RTI_MQTT_ClientConfig *config = NULL,
                           config_default = RTI_MQTT_ClientConfig_INITIALIZER;

    assert_null(config);
    assert_retcode_ok(RTI_MQTT_ClientConfig_default(&config));
    assert_non_null(config);

    mqtt_infrastructure_client_config_compare(config,
                                              &RTI_MQTT_ClientConfig_DEFAULT);
    
    RTI_MQTT_ClientConfig_delete(config);
    config = NULL;

    assert_null(config);
    assert_retcode_ok(RTI_MQTT_ClientConfig_new(DDS_BOOLEAN_FALSE,&config));
    assert_non_null(config);
    assert_retcode_ok(RTI_MQTT_ClientConfig_default(&config));

    mqtt_infrastructure_client_config_compare(config,
                                              &RTI_MQTT_ClientConfig_DEFAULT);
    
    RTI_MQTT_ClientConfig_delete(config);
}


static void
mqtt_infrastructure_subscription_config_compare(
    const RTI_MQTT_SubscriptionConfig *const a, 
    const RTI_MQTT_SubscriptionConfig *const b)
{
    assert_string_seq_equal(&a->topic_filters, &a->topic_filters);
    assert_int_equal(a->max_qos, b->max_qos);
    assert_int_equal(a->message_queue_size, b->message_queue_size);
}

void
mqtt_infrastructure_test_subscription_config_default(void **state)
{
    RTI_MQTT_SubscriptionConfig *config = NULL,
                    config_default = RTI_MQTT_SubscriptionConfig_INITIALIZER;

    assert_null(config);
    assert_retcode_ok(RTI_MQTT_SubscriptionConfig_default(&config));
    assert_non_null(config);

    mqtt_infrastructure_subscription_config_compare(config,
                                        &RTI_MQTT_SubscriptionConfig_DEFAULT);
    
    RTI_MQTT_SubscriptionConfig_delete(config);
    config = NULL;

    assert_null(config);
    assert_retcode_ok(
        RTI_MQTT_SubscriptionConfig_new(DDS_BOOLEAN_FALSE,&config));
    assert_non_null(config);
    assert_retcode_ok(RTI_MQTT_SubscriptionConfig_default(&config));

    mqtt_infrastructure_subscription_config_compare(config,
                                &RTI_MQTT_SubscriptionConfig_DEFAULT);
    
    RTI_MQTT_SubscriptionConfig_delete(config);
}


static void
mqtt_infrastructure_publication_config_compare(
    const RTI_MQTT_PublicationConfig *const a, 
    const RTI_MQTT_PublicationConfig *const b)
{
    assert_string_equal_or_null(a->topic, b->topic);
    assert_int_equal(a->qos, b->qos);
    assert_int_equal(a->retained, b->retained);
    assert_int_equal(a->use_message_info, b->use_message_info);
    assert_time_equal(&a->max_wait_time,&b->max_wait_time);
}


void
mqtt_infrastructure_test_publication_config_default(void **state)
{
    RTI_MQTT_PublicationConfig *config = NULL,
                    config_default = RTI_MQTT_PublicationConfig_INITIALIZER;

    assert_null(config);
    assert_retcode_ok(RTI_MQTT_PublicationConfig_default(&config));
    assert_non_null(config);

    mqtt_infrastructure_publication_config_compare(
        config, &RTI_MQTT_PublicationConfig_DEFAULT);
    
    RTI_MQTT_PublicationConfig_delete(config);
    config = NULL;

    assert_null(config);
    assert_retcode_ok(
        RTI_MQTT_PublicationConfig_new(DDS_BOOLEAN_FALSE,&config));
    assert_non_null(config);
    assert_retcode_ok(RTI_MQTT_PublicationConfig_default(&config));

    mqtt_infrastructure_publication_config_compare(
        config, &RTI_MQTT_PublicationConfig_DEFAULT);
    
    RTI_MQTT_PublicationConfig_delete(config);
}
