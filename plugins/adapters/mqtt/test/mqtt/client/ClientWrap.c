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


struct RTI_MQTT_Client *mqtt_gv_client = NULL;

int 
__wrap_MQTTAsync_create(MQTTAsync* handle, 
    const char* serverURI, const char* clientId,
    int persistence_type, void* persistence_context)
{
    return mock_type(int);
}

int 
__wrap_MQTTAsync_setCallbacks(MQTTAsync handle, void* context,
                              MQTTAsync_connectionLost* cl,
                              MQTTAsync_messageArrived* ma,
                              MQTTAsync_deliveryComplete* dc)
{
    return mock_type(int);
}

void
__wrap_MQTTAsync_destroy(MQTTAsync* handle)
{

}

int 
__wrap_MQTTAsync_connect(MQTTAsync handle, const MQTTAsync_connectOptions* options)
{
    RTI_MQTT_ClientStateKind client_state = 
                mock_type(RTI_MQTT_ClientStateKind);
    DDS_Boolean trigger_condition = mock_type(DDS_Boolean);

#if 0
    assert_retcode_ok(
        RTI_MQTT_Client_set_state(mqtt_gv_client, client_state, NULL));
    if (trigger_condition)
    {
        assert_retcode_ok(
            DDS_GuardCondition_set_trigger_value(
                mqtt_gv_client->cond_connect, DDS_BOOLEAN_TRUE));
    }
#endif
    return mock_type(int);
}

int 
__wrap_MQTTAsync_disconnect(MQTTAsync handle, const MQTTAsync_disconnectOptions* options)
{
    RTI_MQTT_ClientStateKind client_state = 
                mock_type(RTI_MQTT_ClientStateKind);
    DDS_Boolean trigger_condition = mock_type(DDS_Boolean);

#if 0
    assert_retcode_ok(
        RTI_MQTT_Client_set_state(mqtt_gv_client, client_state, NULL));
    if (trigger_condition)
    {
        assert_retcode_ok(
            DDS_GuardCondition_set_trigger_value(
                mqtt_gv_client->cond_disconnect, DDS_BOOLEAN_TRUE));
    }
#endif
    return mock_type(int);
}


int
__wrap_MQTTAsync_subscribeMany(MQTTAsync handle, int count, char* const* topic, int* qos, MQTTAsync_responseOptions* response)
{
    DDS_UnsignedLong sub_i = mock_type(DDS_UnsignedLong);
    RTI_MQTT_SubscriptionStateKind sub_state = 
                mock_type(RTI_MQTT_SubscriptionStateKind);
    DDS_Boolean trigger_condition = mock_type(DDS_Boolean);
    static struct RTI_MQTT_Subscription *sub = NULL;

    assert_non_null(mqtt_gv_client);
    sub = *RTI_MQTT_SubscriptionPtrSeq_get_reference(
                                &mqtt_gv_client->subscriptions, sub_i);
    assert_non_null(sub);

    /* TODO FIX this function is currently wrong. It should trigger the
     * conditiong from the RTI_MQTT_PendingSubscription passed as context */

#if 0
    if (trigger_condition)
    {
        assert_retcode_ok(
            DDS_GuardCondition_set_trigger_value(
                sub->cond_subscribe, DDS_BOOLEAN_TRUE));
    }
#endif

    return mock_type(int);
}


int
__wrap_MQTTAsync_unsubscribeMany(
    MQTTAsync handle, int count, char* const* topic, MQTTAsync_responseOptions* response)
{
    DDS_UnsignedLong sub_i = mock_type(DDS_UnsignedLong);
    RTI_MQTT_SubscriptionStateKind sub_state = 
                mock_type(RTI_MQTT_SubscriptionStateKind);
    DDS_Boolean trigger_condition = mock_type(DDS_Boolean);
    static struct RTI_MQTT_Subscription *sub = NULL;

    assert_non_null(mqtt_gv_client);
    sub = *RTI_MQTT_SubscriptionPtrSeq_get_reference(
                                &mqtt_gv_client->subscriptions, sub_i);
    assert_non_null(sub);

    /* TODO FIX this function is currently wrong. It should trigger the
     * conditiong from the RTI_MQTT_PendingSubscription passed as context */

#if 0
    assert_retcode_ok(
        RTI_MQTT_Subscription_set_state(sub, sub_state, NULL));

    if (trigger_condition)
    {
        assert_retcode_ok(
            DDS_GuardCondition_set_trigger_value(
                sub->cond_unsubscribe, DDS_BOOLEAN_TRUE));
    }
#endif

    return mock_type(int);
}
