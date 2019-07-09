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
#include "Infrastructure.h"

DDS_Boolean
DDS_StringSeq_is_equal(const struct DDS_StringSeq *const self,
                       const struct DDS_StringSeq *const other)
{
    DDS_Boolean retval = DDS_BOOLEAN_FALSE;
    DDS_UnsignedLong seq_len = 0,
                     other_len = 0,
                     i = 0;

    seq_len = DDS_StringSeq_get_length(self);
    other_len = DDS_StringSeq_get_length(other);

    if (seq_len != other_len)
    {
        goto done;
    }

    for (i = 0; i < seq_len; i++)
    {
        char *ref_1 = *DDS_StringSeq_get_reference(self,i),
             *ref_2 = *DDS_StringSeq_get_reference(other,i);
        if (RTI_MQTT_String_is_equal(ref_1,ref_2))
        {
            goto done;
        }
    }

    retval = DDS_BOOLEAN_TRUE;
done:
    return retval;
}

DDS_Boolean
DDS_OctetSeq_is_equal(const struct DDS_OctetSeq *const self,
                      const struct DDS_OctetSeq *const other)
{
    DDS_Boolean retval = DDS_BOOLEAN_FALSE;
    DDS_UnsignedLong seq_len = 0,
                     other_len = 0,
                     i = 0;

    seq_len = DDS_OctetSeq_get_length(self);
    other_len = DDS_OctetSeq_get_length(other);

    if (seq_len != other_len)
    {
        goto done;
    }

    if (seq_len == 0)
    {
        retval = DDS_BOOLEAN_TRUE;
        goto done;
    }

    if (0 != RTI_MQTT_Memory_compare(
                        DDS_OctetSeq_get_contiguous_buffer(self),
                        DDS_OctetSeq_get_contiguous_buffer(other),
                        sizeof(DDS_Octet)*seq_len))
    {
        goto done;
    }

    retval = DDS_BOOLEAN_TRUE;
done:
    return retval;
}