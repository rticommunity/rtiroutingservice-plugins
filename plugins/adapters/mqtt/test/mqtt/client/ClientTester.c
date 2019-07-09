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

#include "ClientWrap.h"

#include "Infrastructure.h"
#include "Client.h"

#define RTI_MQTT_LOG_ARGS       "ClientTester"

struct mqtt_client_test_state
{
    RTI_MQTT_ClientConfig *config;
    RTI_MQTT_ClientConfig *config_default;
    struct RTI_MQTT_Client *client;
};

#define mqtt_client_new(s_) \
{ \
    will_return(__wrap_MQTTAsync_create, MQTTASYNC_SUCCESS); \
    will_return(__wrap_MQTTAsync_setCallbacks, MQTTASYNC_SUCCESS); \
    (s_)->client = NULL; \
    assert_retcode_ok(RTI_MQTT_Client_new((s_)->config, &(s_)->client)); \
    mqtt_gv_client = (s_)->client; \
}

#define mqtt_client_connect(s_) \
{\
    will_return(__wrap_MQTTAsync_connect, RTI_MQTT_ClientStateKind_CONNECTED); \
    will_return(__wrap_MQTTAsync_connect, DDS_BOOLEAN_TRUE); \
    will_return(__wrap_MQTTAsync_connect, MQTTASYNC_SUCCESS); \
    assert_retcode_ok(RTI_MQTT_Client_connect((s_)->client)); \
}\

#define mqtt_client_disconnect(s_) \
{\
    will_return(__wrap_MQTTAsync_disconnect, RTI_MQTT_ClientStateKind_DISCONNECTED); \
    will_return(__wrap_MQTTAsync_disconnect, DDS_BOOLEAN_TRUE); \
    will_return(__wrap_MQTTAsync_disconnect, MQTTASYNC_SUCCESS); \
    assert_retcode_ok(RTI_MQTT_Client_disconnect((s_)->client)); \
}

#define mqtt_client_subscribe(s_,sub_i_,sub_,sub_cfg_) \
{\
    will_return(__wrap_MQTTAsync_subscribeMany, (sub_i_));\
    will_return(__wrap_MQTTAsync_subscribeMany, RTI_MQTT_SubscriptionStateKind_SUBSCRIBED);\
    will_return(__wrap_MQTTAsync_subscribeMany, DDS_BOOLEAN_TRUE);\
    will_return(__wrap_MQTTAsync_subscribeMany, DDS_RETCODE_OK);\
    assert_null((sub_)); \
    assert_retcode_ok(RTI_MQTT_Client_subscribe(s->client,sub_cfg,&(sub_))); \
    assert_non_null((sub_)); \
}

static int
mqtt_client_setup(void **state)
{
    struct mqtt_client_test_state *s = NULL;
    char **str_ref = NULL,
         *str = NULL;

    s = (struct mqtt_client_test_state*) 
        RTI_MQTT_Heap_allocate(sizeof(struct mqtt_client_test_state));
    assert_non_null(s);

    s->client = NULL;
    s->config = NULL;
    s->config_default = NULL;

    assert_retcode_ok(RTI_MQTT_ClientConfig_default(&s->config_default));
    
    DDS_String_free(s->config_default->id);
    s->config_default->id = DDS_String_dup("a client");

    assert_true(DDS_StringSeq_ensure_length(
                    &s->config_default->server_uris,1,1));
    str = DDS_String_dup("tcp://127.0.0.1:1883");
    assert_non_null(str);
    str_ref = DDS_StringSeq_get_reference(
                    &s->config_default->server_uris,0);
    assert_non_null(str_ref);
    *str_ref = str;

    assert_retcode_ok(
            RTI_MQTT_ClientConfig_new(DDS_BOOLEAN_FALSE, &s->config));
    assert_true(RTI_MQTT_ClientConfig_copy(s->config,s->config_default));

    *state = s;

    return 0;
}

static int
mqtt_client_teardown(void **state)
{
    struct mqtt_client_test_state *s = 
            *((struct mqtt_client_test_state**)state);
    
    if (s->client != NULL)
    {
        RTI_MQTT_Client_delete(s->client);
    }
    RTI_MQTT_ClientConfig_delete(s->config);
    RTI_MQTT_ClientConfig_delete(s->config_default);
    RTI_MQTT_Heap_free(s);

    *state = NULL;

    return 0;
}

static void 
mqtt_client_test_new(void **state) 
{
    struct mqtt_client_test_state *s = 
                *((struct mqtt_client_test_state**)state);

    /* Assume MQTT library will return successfully */
    will_return(__wrap_MQTTAsync_create, MQTTASYNC_SUCCESS);
    will_return(__wrap_MQTTAsync_setCallbacks, MQTTASYNC_SUCCESS);

    assert_retcode_ok(RTI_MQTT_Client_new(s->config, &s->client));
    assert_non_null(s->client);
}

static void 
mqtt_client_test_new_invalid_id(void **state) 
{
    struct mqtt_client_test_state *s = 
                *((struct mqtt_client_test_state**)state);

    /* Test invalid client id */
    RTI_MQTT_Heap_free(s->config->id);
    s->config->id = DDS_String_dup("");
    assert_retcode_err(RTI_MQTT_Client_new(s->config, &s->client));
    assert_null(s->client);
}

static void 
mqtt_client_test_new_no_server_uris(void **state) 
{
    struct mqtt_client_test_state *s = 
                *((struct mqtt_client_test_state**)state);

    /* Test invalid server URIs (no URIs) */
    assert_true(DDS_StringSeq_set_length(&s->config->server_uris,0));
    assert_retcode_err(RTI_MQTT_Client_new(s->config, &s->client));
    assert_null(s->client);
}

static void 
mqtt_client_test_new_invalid_server_uris(void **state) 
{
    struct mqtt_client_test_state *s = 
                *((struct mqtt_client_test_state**)state);
    char **str_ref = NULL,
         *str = NULL;

    /* Test invalid server URIs (empty URI) */
    str = DDS_String_dup("");
    assert_non_null(str);
    str_ref = DDS_StringSeq_get_reference(&s->config->server_uris,0);
    assert_non_null(str_ref);
    assert_non_null(*str_ref);
    RTI_MQTT_Heap_free(*str_ref);
    *str_ref = str;

    assert_retcode_err(RTI_MQTT_Client_new(s->config, &s->client));
    assert_null(s->client);
}


static void
mqtt_client_test_connect(void **state)
{
    struct mqtt_client_test_state *s = 
                *((struct mqtt_client_test_state**)state);
    
    mqtt_client_new(s);
    
    will_return(__wrap_MQTTAsync_connect, RTI_MQTT_ClientStateKind_CONNECTED);
    will_return(__wrap_MQTTAsync_connect, DDS_BOOLEAN_TRUE);
    will_return(__wrap_MQTTAsync_connect, MQTTASYNC_SUCCESS);

    assert_retcode_ok(RTI_MQTT_Client_connect(s->client));
}

static void
mqtt_client_test_connect_error(void **state)
{
    struct mqtt_client_test_state *s = 
                *((struct mqtt_client_test_state**)state);
    
    mqtt_client_new(s);
    
    will_return(__wrap_MQTTAsync_connect, RTI_MQTT_ClientStateKind_DISCONNECTED);
    will_return(__wrap_MQTTAsync_connect, DDS_BOOLEAN_TRUE);
    will_return(__wrap_MQTTAsync_connect, MQTTASYNC_SUCCESS);

    assert_retcode_err(RTI_MQTT_Client_connect(s->client));
}


static void
mqtt_client_test_connect_timeout(void **state)
{
    struct mqtt_client_test_state *s = 
                *((struct mqtt_client_test_state**)state);
    
    s->config->connect_timeout.seconds = 1;
    s->config->connect_timeout.nanoseconds = 0;
    mqtt_client_new(s);

    will_return(__wrap_MQTTAsync_connect, s->client->data->state);
    will_return(__wrap_MQTTAsync_connect, DDS_BOOLEAN_FALSE);
    will_return(__wrap_MQTTAsync_connect, MQTTASYNC_SUCCESS);

    assert_retcode_err(RTI_MQTT_Client_connect(s->client));
}

static void
mqtt_client_test_disconnect(void **state)
{
    struct mqtt_client_test_state *s = 
                *((struct mqtt_client_test_state**)state);
    
    mqtt_client_new(s);
    mqtt_client_connect(s);

    will_return(__wrap_MQTTAsync_disconnect, RTI_MQTT_ClientStateKind_DISCONNECTED);
    will_return(__wrap_MQTTAsync_disconnect, DDS_BOOLEAN_TRUE);
    will_return(__wrap_MQTTAsync_disconnect, MQTTASYNC_SUCCESS);
    assert_retcode_ok(RTI_MQTT_Client_disconnect(s->client));
}

static void
mqtt_client_test_subscribe_unsubscribe(void **state)
{
    struct mqtt_client_test_state *s = 
                *((struct mqtt_client_test_state**)state);
    RTI_MQTT_SubscriptionConfig *sub_cfg = NULL;
    struct RTI_MQTT_Subscription *sub = NULL;
    
    s->config->unsubscribe_on_disconnect = DDS_BOOLEAN_FALSE;
    mqtt_client_new(s);
    mqtt_client_connect(s);

    assert_null(sub_cfg);
    assert_retcode_ok(RTI_MQTT_SubscriptionConfig_default(&sub_cfg));
    assert_non_null(sub_cfg);

    assert_int_equal(
        RTI_MQTT_SubscriptionPtrSeq_get_length(&s->client->subscriptions),0);

    will_return(__wrap_MQTTAsync_subscribeMany, 0);
    will_return(__wrap_MQTTAsync_subscribeMany, RTI_MQTT_SubscriptionStateKind_SUBSCRIBED);
    will_return(__wrap_MQTTAsync_subscribeMany, DDS_BOOLEAN_TRUE);
    will_return(__wrap_MQTTAsync_subscribeMany, DDS_RETCODE_OK);
    assert_null(sub);
    assert_retcode_ok(RTI_MQTT_Client_subscribe(s->client,sub_cfg,&sub));
    assert_non_null(sub);

    assert_int_equal(
        RTI_MQTT_SubscriptionPtrSeq_get_length(&s->client->subscriptions),1);
    
    will_return(__wrap_MQTTAsync_unsubscribeMany, 0);
    will_return(__wrap_MQTTAsync_unsubscribeMany, RTI_MQTT_SubscriptionStateKind_CREATED);
    will_return(__wrap_MQTTAsync_unsubscribeMany, DDS_BOOLEAN_TRUE);
    will_return(__wrap_MQTTAsync_unsubscribeMany, DDS_RETCODE_OK);
    assert_retcode_ok(RTI_MQTT_Client_unsubscribe(s->client,sub));
    
    assert_int_equal(
        RTI_MQTT_SubscriptionPtrSeq_get_length(&s->client->subscriptions),0);

    mqtt_client_disconnect(s);
}

static void
mqtt_client_test_unsubscribe_on_disconnect(void **state)
{
    struct mqtt_client_test_state *s = 
                *((struct mqtt_client_test_state**)state);
    RTI_MQTT_SubscriptionConfig *sub_cfg = NULL;
    struct RTI_MQTT_Subscription *sub = NULL;
    
    assert_null(sub_cfg);
    assert_retcode_ok(RTI_MQTT_SubscriptionConfig_default(&sub_cfg));
    assert_non_null(sub_cfg);

    /* Test automatic unsubscription on disconnection (this is the default) */
    mqtt_client_new(s);
    mqtt_client_connect(s);
    mqtt_client_subscribe(s,0,sub,sub_cfg);

    assert_int_equal(
        RTI_MQTT_SubscriptionPtrSeq_get_length(&s->client->subscriptions),1);
    will_return(__wrap_MQTTAsync_unsubscribeMany, 0);
    will_return(__wrap_MQTTAsync_unsubscribeMany, RTI_MQTT_SubscriptionStateKind_CREATED);
    will_return(__wrap_MQTTAsync_unsubscribeMany, DDS_BOOLEAN_TRUE);
    will_return(__wrap_MQTTAsync_unsubscribeMany, DDS_RETCODE_OK);
    mqtt_client_disconnect(s);
    /* Subscription are not deleted upon disconnection */
    assert_int_equal(
        RTI_MQTT_SubscriptionPtrSeq_get_length(&s->client->subscriptions),1);
    
}

static void
mqtt_client_test_publish_unpublish(void **state)
{
    struct mqtt_client_test_state *s = 
                *((struct mqtt_client_test_state**)state);
    RTI_MQTT_PublicationConfig *pub_cfg = NULL;
    struct RTI_MQTT_Publication *pub = NULL;
    
    mqtt_client_new(s);
    mqtt_client_connect(s);

    assert_null(pub_cfg);
    assert_retcode_ok(RTI_MQTT_PublicationConfig_default(&pub_cfg));
    assert_non_null(pub_cfg);

    DDS_String_free(pub_cfg->topic);
    pub_cfg->topic = DDS_String_dup("a topic");

    assert_int_equal(
        RTI_MQTT_PublicationPtrSeq_get_length(&s->client->publications),0);

    assert_null(pub);
    assert_retcode_ok(RTI_MQTT_Client_publish(s->client,pub_cfg,&pub));
    assert_non_null(pub);

    assert_int_equal(
        RTI_MQTT_PublicationPtrSeq_get_length(&s->client->publications),1);
    
    assert_retcode_ok(RTI_MQTT_Client_unpublish(s->client,pub));
    
    assert_int_equal(
        RTI_MQTT_PublicationPtrSeq_get_length(&s->client->publications),0);
}

static void
mqtt_client_test_publish_invalid_topic(void **state)
{
    struct mqtt_client_test_state *s = 
                *((struct mqtt_client_test_state**)state);
    RTI_MQTT_PublicationConfig *pub_cfg = NULL;
    struct RTI_MQTT_Publication *pub = NULL;
    
    mqtt_client_new(s);
    mqtt_client_connect(s);

    assert_null(pub_cfg);
    assert_retcode_ok(RTI_MQTT_PublicationConfig_default(&pub_cfg));
    assert_non_null(pub_cfg);

    assert_int_equal(
        RTI_MQTT_PublicationPtrSeq_get_length(&s->client->publications),0);

    assert_null(pub);
    assert_retcode_err(RTI_MQTT_Client_publish(s->client,pub_cfg,&pub));
    assert_null(pub);

    assert_int_equal(
        RTI_MQTT_PublicationPtrSeq_get_length(&s->client->publications),0);
}


#define mqtt_client_test(t_) \
    cmocka_unit_test_setup_teardown(t_,\
                                    mqtt_client_setup,\
                                    mqtt_client_teardown)

int main(void) {
    const struct CMUnitTest tests[] = {
        mqtt_client_test(mqtt_client_test_new),
        mqtt_client_test(mqtt_client_test_new_invalid_id),
        mqtt_client_test(mqtt_client_test_new_no_server_uris),
        mqtt_client_test(mqtt_client_test_new_invalid_server_uris),
        mqtt_client_test(mqtt_client_test_connect),
        mqtt_client_test(mqtt_client_test_connect_error),
        mqtt_client_test(mqtt_client_test_connect_timeout),
        mqtt_client_test(mqtt_client_test_disconnect),
        mqtt_client_test(mqtt_client_test_subscribe_unsubscribe),
        mqtt_client_test(mqtt_client_test_unsubscribe_on_disconnect),
        mqtt_client_test(mqtt_client_test_publish_unpublish),
        mqtt_client_test(mqtt_client_test_publish_invalid_topic)
    };
    return cmocka_run_group_tests(tests, NULL, NULL);
}