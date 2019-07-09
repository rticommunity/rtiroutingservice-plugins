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
#ifndef ClientWrap_h
#define ClientWrap_h

#include "Client.h"

extern struct RTI_MQTT_Client *mqtt_gv_client;

int 
__wrap_MQTTAsync_create(MQTTAsync* handle, 
    const char* serverURI, const char* clientId,
    int persistence_type, void* persistence_context);
int 
__wrap_MQTTAsync_setCallbacks(MQTTAsync handle, void* context,
                              MQTTAsync_connectionLost* cl,
                              MQTTAsync_messageArrived* ma,
                              MQTTAsync_deliveryComplete* dc);
void
__wrap_MQTTAsync_destroy(MQTTAsync* handle);
int 
__wrap_MQTTAsync_connect(
    MQTTAsync handle, const MQTTAsync_connectOptions* options);
int 
__wrap_MQTTAsync_disconnect(
    MQTTAsync handle, const MQTTAsync_disconnectOptions* options);
int
__wrap_MQTTAsync_subscribeMany(
    MQTTAsync handle, int count, char* const* topic, int* qos, MQTTAsync_responseOptions* response);
int
__wrap_MQTTAsync_unsubscribeMany(
    MQTTAsync handle, int count, char* const* topic, MQTTAsync_responseOptions* response);

#endif /* ClientWrap_h */