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

/* ========================================================================= */
/* RTI Routing Service File Adapter                                          */
/* ========================================================================= */
/*                                                                           */
/* Conversion between file lines and DDS dynamic data samples                */
/*                                                                           */
/* These functions are used by the file adapter to create dynamic data       */
/* samples from a file line (read_line) or to write into a file a            */
/* dynamic data sample (write_line)                                          */
/*                                                                           */
/* By customizing these functions the file adapter can work with other       */
/* file formats. The implementation we proviced works with the following     */
/* line format:                                                              */
/*                                                                           */
/* <field>=<value>[,<field2>=<value2>[...]]                                  */
/*                                                                           */
/* For example the following file:                                           */
/*                                                                           */
/* x=3,y=5,color=RED                                                         */
/* y=2,x=3,color=BLUE                                                        */
/*                                                                           */
/* Would generate two samples with the given values                          */
/* for a type that contains fields x, y and color                            */
/*                                                                           */
/* ========================================================================= */

#ifdef RTI_WIN32
  /* strtok, fopen warnings */
  #pragma warning( disable : 4996 )
#endif 

#include <stdio.h>
#include <string.h>
#include <ctype.h>

#include "LineConversion.h"

/* ========================================================================= */
/*                                                                           */
/* Read line                                                                 */
/*                                                                           */
/* ========================================================================= */

/**
 * @brief Reads from a file to provide the values of
 * one dynamic data sample
 * 
 * @param sampleOut The sample whose field values shall be set
 * @param file The file from which to read
 * @param buffer A buffer of allocated memory that can be used to read
 * @param maxSampleSize The size of \ref buffer and the user-configured max
 *        characters in the file that a sample can take (including spaces)
 * @param env The environment to report error messages
 * 
 * @return 0 for error, 1 for success, -1 to indicate that the sample
 *         should not be sent.
 */
enum RTIRS_FileAdapter_READ_ACTION RTIRS_FileAdapter_read_sample(
    struct DDS_DynamicData * sampleOut, 
    FILE * file,
    char * buffer, 
    int maxSampleSize,
    RTI_RoutingServiceEnvironment * env)
{
    size_t i;
    size_t length;
    /*
     * 0 => ready to read next assignment
     * 1 => reading field name (left)
     * 2 => reading value (right)
     */
    int state = 0;
    char c;
    char * token = NULL, * field = NULL, * value = NULL;

    /*
     * Read a line or a partial line if the current one is shorter
     * than maxCharsPerRead characters.
     */
    if(fgets(buffer, maxSampleSize, file) == NULL) {
        return -1;
    }

    /*
     * Trim spaces
     */
    buffer = RTIRS_FileAdapter_trim(buffer);
    if (*buffer == 0){
        return -1;
    }

    length = strlen(buffer);

    /*
     * Validate format (<field1>=<value1>,<field2>=<value2>,...)
     */
    for (i = 0; i < length; i++) {
        c = buffer[i];
        switch (state) {
        case 0:
            if (c == '=' || c == ',') {
                RTI_RoutingServiceEnvironment_set_error(
                    env, "Invalid line: %s", buffer);
                return 0;
            } else {
                state = 1;
            }
            break;
        case 1:
            if (c == '=') {
                state = 2;
            } else if (c == ',') {
                RTI_RoutingServiceEnvironment_set_error(
                    env, "Invalid line: %s", buffer);
                return 0;
            }
            break;
        case 2:
            if (c == ',') {
                state = 0;
            } else if (c == '=') {
                RTI_RoutingServiceEnvironment_set_error(
                    env, "Invalid line: %s", buffer);
                return 0;
            }
            break;
        default:
            break;
        }
    }

    if (state != 2) {
        RTI_RoutingServiceEnvironment_set_error(
            env, "Invalid line: %s", buffer);
        return 0;
    }

    token = strtok(buffer, ",=");
    while (token != NULL) {

        /* Remove spaces */
        field = RTIRS_FileAdapter_trim(token);

        token = strtok(NULL, ",=");
        if (token == NULL) {
            return 0;
        }

        /* Remove spaces */
        value = RTIRS_FileAdapter_trim(token);

        /* Remove quotes */
        if (*value == '"') {
            value++;
        }
        length = strlen(value);
        if (length > 0 && value[length-1]=='"') {
            value[length-1]=0;
        }

        if (!RTIRS_FileAdapter_assign(
                sampleOut, field, value, env)) {
            return 0;
        }

        token = strtok(NULL, ",=");
    }

    return 1;
}


/* ========================================================================= */
/*                                                                           */
/* Write line                                                                */
/*                                                                           */
/* ========================================================================= */

int RTIRS_FileAdapter_write_sample(
    struct DDS_SampleInfo  * sample_info,
    struct DDS_DynamicData * sample, 
    FILE * file,
    RTI_RoutingServiceEnvironment * env)
{
    unsigned int memberCount, i;
    DDS_ReturnCode_t retCode;
    struct DDS_DynamicDataMemberInfo info;

    /*
    fprintf(file, "seq_num=%d, source_ts=%d.%d, ",
    		sample_info->publication_sequence_number.low,
    		sample_info->source_timestamp.sec,
    		sample_info->source_timestamp.nanosec);
    */

    /*
     * Get the number of fields of our sample and for each of them
     * write it in the form <field>=<value>
     */
    memberCount = DDS_DynamicData_get_member_count(sample);

    for (i=0; i<memberCount; i++) {

        retCode = DDS_DynamicData_get_member_info_by_index(
            sample, &info, i);

        if (retCode != DDS_RETCODE_OK) {
            return 0;
        }

        /* Print this member */
        if (!RTIRS_FileAdapter_write_member(
                sample, &info, file, env)) {
            return 0;
        }

        /* Separator for next field-value */
        if (i < memberCount-1) {
            fprintf(file, ",");
        }

    }

    fprintf(file, "\n");

    return 1;
}

/* ========================================================================= */
/*                                                                           */
/* Utility                                                                   */
/*                                                                           */
/* ========================================================================= */

char * RTIRS_FileAdapter_trim(char * str)
{
    char * line = str;
    int pos = strlen(line) - 1;
    while (pos >= 0 && isspace(line[pos])) {
        line[pos] = '\0';
        --pos;
    }
    while (isspace(*line) && *line != '\0') {
        line++;
    }

    return line;
}

/*****************************************************************************/

int RTIRS_FileAdapter_assign(
    struct DDS_DynamicData * sample,
    const char * field,
    const char * value,
    RTI_RoutingServiceEnvironment * env) 
{
    DDS_ReturnCode_t retCode;
    struct DDS_DynamicDataMemberInfo info;
    DDS_Long longValue;
    DDS_Double doubleValue;
    DDS_DynamicDataMemberId unspecified = 
        DDS_DYNAMIC_DATA_MEMBER_ID_UNSPECIFIED;

    /*
     * Get information about the field
     */
    retCode = DDS_DynamicData_get_member_info(
        sample, &info, field, unspecified);

    if (retCode != DDS_RETCODE_OK) {
        RTI_RoutingServiceEnvironment_set_error(
                env, "Could not find field %s", field);
        return 0;
    }


    /*
     * Depending on the kind of the field we will convert
     * the string value to the appropiate type and assign it
     * to the dynamic data sample
     *
     * Only top-level primitive types are supported in this example
     *
     */
    switch (info.member_kind) {
    
    case DDS_TK_SHORT:
        longValue = atoi(value);
        retCode = DDS_DynamicData_set_short(
            sample, field, unspecified, (DDS_Short) longValue);
        break;
    case DDS_TK_ENUM:
    case DDS_TK_LONG:
        longValue = atoi(value);
        retCode = DDS_DynamicData_set_long(
            sample, field, unspecified, longValue);
        break;
    case DDS_TK_USHORT:
        longValue = atoi(value);
        retCode = DDS_DynamicData_set_ushort(
            sample, field, unspecified, (DDS_UnsignedShort) longValue);
        break;
    case DDS_TK_ULONG:
        longValue = atoi(value);
        retCode = DDS_DynamicData_set_ulong(
            sample, field, unspecified, (DDS_UnsignedLong) longValue);
        break;
    case DDS_TK_FLOAT:
        doubleValue = atof(value);
        retCode = DDS_DynamicData_set_float(
            sample, field, unspecified, (DDS_Float) doubleValue);
        break;
    case DDS_TK_DOUBLE:
        doubleValue = atof(value);
        retCode = DDS_DynamicData_set_double(
            sample, field, unspecified, doubleValue);
        break;
    case DDS_TK_BOOLEAN:
        if (!strcmp(value, "true") || !strcmp(value, "TRUE")) {
            longValue = 1;
        } else if (!strcmp(value, "false") || !strcmp(value, "FALSE")) {
            longValue = 0;
        } else {
            longValue = atoi(value);
        }
        
        retCode = DDS_DynamicData_set_boolean(
            sample, field, unspecified, 
            longValue ? DDS_BOOLEAN_TRUE : DDS_BOOLEAN_FALSE);
        break;
    case DDS_TK_CHAR:
        retCode = DDS_DynamicData_set_char(
            sample, field, unspecified, value[0]);
        break;
    case DDS_TK_OCTET:
        longValue = atoi(value);
        retCode = DDS_DynamicData_set_octet(
            sample, field, unspecified, (DDS_Octet) longValue);
        return 0;
    case DDS_TK_STRING:
        retCode = DDS_DynamicData_set_string(
            sample, field, unspecified, value);
        break;
    case DDS_TK_ALIAS:
        RTI_RoutingServiceEnvironment_set_error(
                env, "Type of field %s not supported (alias)", field);
        return 0;
    case DDS_TK_LONGLONG:
        RTI_RoutingServiceEnvironment_set_error(
                env, "Type of field %s not supported (long long)", field);
        return 0;
    case DDS_TK_ULONGLONG:
        RTI_RoutingServiceEnvironment_set_error(
                env, "Type of field %s not supported (ulong long)", field);
        return 0;
    case DDS_TK_WCHAR:
        RTI_RoutingServiceEnvironment_set_error(
                env, "Type of field %s not supported (wstring)", field);
        return 0;
    case DDS_TK_WSTRING:
        RTI_RoutingServiceEnvironment_set_error(
                env, "Type of field %s not supported (wstring)", field);
        return 0;
    case DDS_TK_STRUCT:
        RTI_RoutingServiceEnvironment_set_error(
                env, "Type of field %s not supported (struct)", field);
        return 0;
    case DDS_TK_UNION:
        RTI_RoutingServiceEnvironment_set_error(
                env, "Type of field %s not supported (union)", field);
        return 0;
    case DDS_TK_SEQUENCE:
        RTI_RoutingServiceEnvironment_set_error(
                env, "Type of field %s not supported (sequence)", field);
        return 0;
    case DDS_TK_ARRAY:
        RTI_RoutingServiceEnvironment_set_error(
                env, "Type of field %s not supported (array)", field);
        return 0;
    case DDS_TK_LONGDOUBLE:
        RTI_RoutingServiceEnvironment_set_error(
                env, "Type of field %s not supported (long double)", field);
        return 0;
    case DDS_TK_NULL:
        RTI_RoutingServiceEnvironment_set_error(
                env, "Type of field %s not supported (NULL)", field);
        return 0;
    case DDS_TK_VALUE:
        RTI_RoutingServiceEnvironment_set_error(
                env, "Type of field %s not supported (value type)", field);
        return 0;
    case DDS_TK_SPARSE:
        RTI_RoutingServiceEnvironment_set_error(
                env, "Type of field %s not supported (sparse type)", field);
        return 0;
    default:
        RTI_RoutingServiceEnvironment_set_error(
                env, "Type of field %s not supported (%d)", field, 
                (int) info.member_kind);
        return 0;
    }

    if (retCode != DDS_RETCODE_OK) {
        RTI_RoutingServiceEnvironment_set_error(
                env, "Error assigning %s=%s", field, value);
        return 0;
    }

    return 1;

}

/*****************************************************************************/

int RTIRS_FileAdapter_write_member(
    const struct DDS_DynamicData * sample,
    const struct DDS_DynamicDataMemberInfo * info,
    FILE * file,
    RTI_RoutingServiceEnvironment * env) 
{
    DDS_ReturnCode_t retCode;
    DDS_Long longValue;
    DDS_UnsignedLong ulongValue;
    DDS_Double doubleValue;
    DDS_Float floatValue;
    DDS_Short shortValue;
    DDS_UnsignedShort ushortValue;
    DDS_Boolean boolValue;
    DDS_Char charValue;
    DDS_Octet octetValue;
    DDS_DynamicDataMemberId fieldId;
    char * stringValue = NULL;
    const char * field;

    fieldId = info->member_id;
    field = info->member_name;

    /*
     * Depending on the kind of the field we will convert
     * call the appropiate dynamic data method to retreive the
     * value and then write it into the file
     *
     * Only top-level primitive types are supported in this example
     *
     */
    switch (info->member_kind) {
    
    case DDS_TK_SHORT:
        retCode = DDS_DynamicData_get_short(
            sample, &shortValue, NULL, fieldId);
        if (retCode == DDS_RETCODE_OK) {
            fprintf(file, "%s=%d", field, (int) shortValue);
        }
        break;
    case DDS_TK_ENUM:
    case DDS_TK_LONG:
        retCode = DDS_DynamicData_get_long(
            sample, &longValue, NULL, fieldId);
        if (retCode == DDS_RETCODE_OK) {
            fprintf(file, "%s=%d", field, longValue);
        }
        break;
    case DDS_TK_USHORT:
        retCode = DDS_DynamicData_get_ushort(
            sample, &ushortValue, NULL, fieldId);
        if (retCode == DDS_RETCODE_OK) {
            fprintf(file, "%s=%u", field, (unsigned int) ushortValue);
        }
        break;
    case DDS_TK_ULONG:
        retCode = DDS_DynamicData_get_ulong(
            sample, &ulongValue, NULL, fieldId);
        if (retCode == DDS_RETCODE_OK) {
            fprintf(file, "%s=%u", field, (unsigned int) ulongValue);
        }
        break;
    case DDS_TK_FLOAT:
        retCode = DDS_DynamicData_get_float(
            sample, &floatValue, NULL, fieldId);
        if (retCode == DDS_RETCODE_OK) {
            fprintf(file, "%s=%f", field, (double) floatValue);
        }
        break;
    case DDS_TK_DOUBLE:
        retCode = DDS_DynamicData_get_double(
            sample, &doubleValue, NULL, fieldId);
        if (retCode == DDS_RETCODE_OK) {
            fprintf(file, "%s=%f", field, doubleValue);
        }
        break;
    case DDS_TK_BOOLEAN:
        retCode = DDS_DynamicData_get_boolean(
            sample, &boolValue, NULL, fieldId);
        if (retCode == DDS_RETCODE_OK) {
            fprintf(file, "%s=%s", field, boolValue ? "true" : "false");
        }
        break;
    case DDS_TK_CHAR:
        retCode = DDS_DynamicData_get_char(
            sample, &charValue, NULL, fieldId);
        if (retCode == DDS_RETCODE_OK) {
            fprintf(file, "%s=%c", field, (char) charValue);
        }
        break;
    case DDS_TK_OCTET:
        retCode = DDS_DynamicData_get_octet(
            sample, &octetValue, NULL, fieldId);
        if (retCode == DDS_RETCODE_OK) {
            fprintf(file, "%s=%d", field, (int) octetValue);
        }
        break;
    case DDS_TK_STRING:
        /* The middleware will allocate the string for us */
        stringValue = NULL;
        ulongValue = 0;
        retCode = DDS_DynamicData_get_string(
            sample, &stringValue, &ulongValue, NULL, fieldId);
        if (retCode == DDS_RETCODE_OK) {
            fprintf(file, "%s=%s", field, stringValue);
            /* Free the allocated string */
            DDS_String_free(stringValue);
        }
        break;
    case DDS_TK_ALIAS:
        RTI_RoutingServiceEnvironment_set_error(
                env, "Type of field %s not supported (alias)", field);
        return 0;
    case DDS_TK_LONGLONG:
        RTI_RoutingServiceEnvironment_set_error(
                env, "Type of field %s not supported (long long)", field);
        return 0;
    case DDS_TK_ULONGLONG:
        RTI_RoutingServiceEnvironment_set_error(
                env, "Type of field %s not supported (ulong long)", field);
        return 0;
    case DDS_TK_WCHAR:
        RTI_RoutingServiceEnvironment_set_error(
                env, "Type of field %s not supported (wstring)", field);
        return 0;
    case DDS_TK_WSTRING:
        RTI_RoutingServiceEnvironment_set_error(
                env, "Type of field %s not supported (wstring)", field);
        return 0;
    case DDS_TK_STRUCT:
        RTI_RoutingServiceEnvironment_set_error(
                env, "Type of field %s not supported (struct)", field);
        return 0;
    case DDS_TK_UNION:
        RTI_RoutingServiceEnvironment_set_error(
                env, "Type of field %s not supported (union)", field);
        return 0;
    case DDS_TK_SEQUENCE:
        RTI_RoutingServiceEnvironment_set_error(
                env, "Type of field %s not supported (sequence)", field);
        return 0;
    case DDS_TK_ARRAY:
        RTI_RoutingServiceEnvironment_set_error(
                env, "Type of field %s not supported (array)", field);
        return 0;
    case DDS_TK_LONGDOUBLE:
        RTI_RoutingServiceEnvironment_set_error(
                env, "Type of field %s not supported (long double)", field);
        return 0;
    case DDS_TK_NULL:
        RTI_RoutingServiceEnvironment_set_error(
                env, "Type of field %s not supported (NULL)", field);
        return 0;
    case DDS_TK_VALUE:
        RTI_RoutingServiceEnvironment_set_error(
                env, "Type of field %s not supported (value type)", field);
        return 0;
    case DDS_TK_SPARSE:
        RTI_RoutingServiceEnvironment_set_error(
                env, "Type of field %s not supported (sparse type)", field);
        return 0;
    default:
        RTI_RoutingServiceEnvironment_set_error(
                env, "Type of field %s not supported (%d)", field, 
                (int) info->member_kind);
        return 0;
    }

    if (retCode != DDS_RETCODE_OK) {
        RTI_RoutingServiceEnvironment_set_error(
                env, "Error writing field %s", field);
        return 0;
    }

    return 1;

}
