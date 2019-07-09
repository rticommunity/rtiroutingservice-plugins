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

#ifndef Client_h
#define Client_h

#include "rtiadapt_mqtt.h"

#include "Subscription.h"
#include "Publication.h"
#include "Infrastructure.h"
#include "ClientApi.h"

struct RTI_MQTT_Client 
{
    RTI_MQTT_ClientStatus                   *data;
    RTI_MQTT_ClientMqttApi_Client           client;
    struct RTI_MQTT_PendingRequest          *req_connect;
    struct RTI_MQTT_PendingRequest          *req_disconnect;
    struct RTI_MQTT_PendingRequest          *req_sub;
    struct RTI_MQTT_PendingRequest          *req_unsub;
    struct RTI_MQTT_SubscriptionRequestContext req_ctx_sub;
    struct RTI_MQTT_SubscriptionParamsSeq   params_sub;
    struct RTI_MQTT_SubscriptionPtrSeq      subscriptions;
    struct RTI_MQTT_PublicationPtrSeq       publications;
    RTI_MQTT_Mutex                          lock;
};

#define RTI_MQTT_Client_INITIALIZER \
{ \
    NULL, /* data */\
    RTI_MQTT_ClientMqttApi_Client_INITIALIZER, /* client */\
    NULL, /* req_connect */\
    NULL, /* req_disconnect */\
    NULL, /* req_sub */\
    NULL, /* req_unsub */\
    RTI_MQTT_SubscriptionRequestContext_INITIALIZER, /* req_ctx_sub */ \
    DDS_SEQUENCE_INITIALIZER, /* params_sub */ \
    DDS_SEQUENCE_INITIALIZER, /* subscriptions */ \
    DDS_SEQUENCE_INITIALIZER, /* publications */ \
    RTI_MQTT_Mutex_INITIALIZER /* lock */ \
}

DDS_ReturnCode_t
RTI_MQTT_Client_write_message(
    struct RTI_MQTT_Client *self,
    struct RTI_MQTT_Publication *pub,
    const char *buffer,
    DDS_UnsignedLong buffer_len,
    const char *topic,
    RTI_MQTT_WriteParams *params);

DDS_ReturnCode_t
RTI_MQTT_Client_wait_for_write_result(
    struct RTI_MQTT_Client *self,
    struct RTI_MQTT_Publication *pub);

DDS_ReturnCode_t
RTI_MQTT_Client_on_connection_lost(struct RTI_MQTT_Client *self);

DDS_ReturnCode_t
RTI_MQTT_Client_on_message_arrived(
    struct RTI_MQTT_Client *self,
    const char *topic,
    const char *buffer,
    DDS_UnsignedLong buffer_len,
    RTI_MQTT_MessageInfo *msg_info);

#endif /* Client_h */