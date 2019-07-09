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
/* See LineConversion.c                                                      */
/*                                                                           */
/* ========================================================================= */

#ifndef _lineconversion_h_
#define _lineconversion_h_

#include <stdio.h>
#include <string.h>
#include "rtiadapt_file.h"

/* ========================================================================= */
/*                                                                           */
/* Read line                                                                 */
/*                                                                           */
/* ========================================================================= */
enum RTIRS_FileAdapter_READ_ACTION {
	READ_ACTION_ERROR       = 0,
	READ_ACTION_SEND_SAMPLE = 1,
	READ_ACTION_SKIP_SAMPLE = 2
};

enum RTIRS_FileAdapter_READ_ACTION RTIRS_FileAdapter_read_sample(
    struct DDS_DynamicData * sampleOut, 
    FILE * file,
    char * buffer, 
    int maxSampleSize,
    RTI_RoutingServiceEnvironment * env);


/* ========================================================================= */
/*                                                                           */
/* Write line                                                                */
/*                                                                           */
/* ========================================================================= */

int RTIRS_FileAdapter_write_sample(
	struct DDS_SampleInfo  * sample_info,
    struct DDS_DynamicData * sample, 
    FILE * file,
    RTI_RoutingServiceEnvironment * env);

/* ========================================================================= */
/*                                                                           */
/* Utility                                                                   */
/*                                                                           */
/* ========================================================================= */

char * RTIRS_FileAdapter_trim(char * str);

/*****************************************************************************/

int RTIRS_FileAdapter_assign(
    struct DDS_DynamicData * sample,
    const char * field,
    const char * value,
    RTI_RoutingServiceEnvironment * env);

/*****************************************************************************/

int RTIRS_FileAdapter_write_member(
    const struct DDS_DynamicData * sample,
    const struct DDS_DynamicDataMemberInfo * info,
    FILE * file,
    RTI_RoutingServiceEnvironment * env);

#endif
