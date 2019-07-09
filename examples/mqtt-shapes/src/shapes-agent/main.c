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

#include "ShapesAgentDds.h"

#define RTI_MQTT_LOG_ARGS           "ShapesAgent::DDS::main"

int main(int argc, const char **argv)
{
    int rc = 1;
    struct ShapesAgent agent;

    if (0 != ShapesAgent_initialize(&agent))
    {
        RTI_MQTT_ERROR("failed to initialize agent")
        goto done;
    }

    if (0 != ShapesAgent_main(&agent))
    {
        RTI_MQTT_ERROR("failed to run agent")
        goto done;
    }

    ShapesAgent_finalize(&agent);

    rc = 0;
done:

    DDS_DomainParticipantFactory_finalize_instance();

    return rc;
}