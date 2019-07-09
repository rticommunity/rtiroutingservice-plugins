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
/* This a pluggable adapter that reads lines from a file                     */
/* providing them to Routing Service as DynamicData samples                  */
/* and receives samples from Routing Service to write them in a file         */
/*                                                                           */
/* To customize to your data format, edit LineConversion.c                   */
/*                                                                           */
/* ========================================================================= */


#include <stdio.h>
#include <string.h>

#ifdef RTI_WIN32
  /* strtok, fopen warnings */
  #pragma warning( disable : 4996 )
#endif 

#include "rtiadapt_file.h"

/*
 * The mapping between samples and file lines is implemented
 * in LineConversion.c
 */
#include "LineConversion.h"

#ifdef RTI_WIN32
  #define DllExport __declspec( dllexport )
  #include <Winsock2.h>
  #include <process.h>
#else
  #define DllExport
  #include <sys/select.h>
  #include <semaphore.h>
  #include <pthread.h> 
#endif


/* ========================================================================= */
/*                                                                           */
/* Data types                                                                */
/*                                                                           */
/* ========================================================================= */


struct RTIRS_FileAdapterPlugin {
    struct RTI_RoutingServiceAdapterPlugin _base;
};

/*****************************************************************************/

struct RTIRS_FileConnection {
    struct RTIRS_FileAdapterPlugin * adapter;
};

/*****************************************************************************/

struct RTIRS_FileStreamWriter {
    FILE * file;
    int flushEnabled;
};

/*****************************************************************************/

struct RTIRS_FileStreamReader {
    struct RTI_RoutingServiceStreamReaderListener listener;
    const struct RTI_RoutingServiceStreamInfo * info;

    const char * promptText;

    struct DDS_TypeCode * _typeCode;
    struct DDS_DynamicDataTypeSupport * _typeSupport;
    char * _buffer;

    int _run;
    
  #ifdef RTI_WIN32
    HANDLE _thread;
  #else 
    pthread_t _thread;
  #endif
    
    int loop;
    struct DDS_Duration_t readPeriod;
    int samplesPerRead;
    int maxSampleSize;

    int samplesPerDisposedSample;
    int samplesPerUnregisteredSample;


    struct DDS_DynamicData     ** _sample_list;
    struct DDS_SampleInfo      ** _info_list;
    int samplesReadCount;
  
  FILE * file;
};

/* ========================================================================= */
/*                                                                           */
/* Stream reader methods                                                     */
/*                                                                           */
/* ========================================================================= */

void * RTIRS_FileStreamReader_run(void * threadParam) {

    struct RTIRS_FileStreamReader * self = 
        (struct RTIRS_FileStreamReader *) threadParam;

    /*
     * This thread will notify of data availability in the file
     */
    printf("RTIRS_FileStreamReader_run. Period: {%d,%u}\n", self->readPeriod.sec + self->readPeriod.nanosec);

    while (self->_run) {

        NDDS_Utility_sleep(&self->readPeriod);
        printf("RTIRS_FileStreamReader_run.\n");

        if (!feof(self->file)) {
            self->listener.on_data_available(
                self, self->listener.listener_data);
        } else if (self->loop) {
            fseek(self->file, 0, SEEK_SET);
            self->listener.on_data_available(
                self, self->listener.listener_data);
        }

    }

    return NULL;
}

/*****************************************************************************/

void RTIRS_FileStreamReader_freeDynamicDataArray(
        struct DDS_DynamicData ** samples,
        int count)
{
    int i;
    for(i = 0; i < count; i++) {
        DDS_DynamicData_delete(samples[i]);
    }
    free(samples);
}

/*****************************************************************************/

void RTIRS_FileStreamReader_read(
    RTI_RoutingServiceStreamReader stream_reader,
    RTI_RoutingServiceSample ** sample_list,
    RTI_RoutingServiceSampleInfo ** info_list,
    int * count,
    RTI_RoutingServiceEnvironment * env) 
{
    int i;
    enum RTIRS_FileAdapter_READ_ACTION result;
    int index = 0;

    struct RTIRS_FileStreamReader * self =
        (struct RTIRS_FileStreamReader *) stream_reader;

    printf("%s\n", __func__);

    *sample_list = NULL;
    *info_list   = NULL;
    *count = 0;
    
    struct DDS_DynamicData * sample = NULL;
    struct DDS_SampleInfo  * info   = NULL;
    
    printf("RTIRS_FileStreamReader_read...\n");

    /*
     * Read as many as samplesPerRead (or less if we encounter the end of file)
     */
    for (i=0; i<self->samplesPerRead && !feof(self->file); ++i) {

        /*
         * Create a dynamic data sample for every buffer we read. We use
         * the type we received when the stream reader was created
         */
        sample = self->_sample_list[index];
        info   = self->_info_list[index];

        /*
         * Fill the dynamic data sample fields
         * with the buffer read from the file.
         *
         * This function is meant to be customized to specific
         * file formats
         */
        result = RTIRS_FileAdapter_read_sample(
                    sample, self->file, 
                    self->_buffer, self->maxSampleSize, env);

        /* Set instance state according to parameters */
        if ( (self->samplesReadCount % self->samplesPerDisposedSample) == 1 ) {
        	info->instance_state = DDS_NOT_ALIVE_DISPOSED_INSTANCE_STATE;
        	info->valid_data     = DDS_BOOLEAN_FALSE;
        }
        else if ( (self->samplesReadCount % self->samplesPerUnregisteredSample) == 2 ) {
        	info->instance_state = DDS_NOT_ALIVE_NO_WRITERS_INSTANCE_STATE;
        	info->valid_data     = DDS_BOOLEAN_FALSE;
        }
        else {
            printf("RTIRS_FileStreamReader_read...\n");
       	    info->instance_state = DDS_ALIVE_INSTANCE_STATE;
        	info->valid_data     = DDS_BOOLEAN_FALSE;
        }


        switch ( result ) {
        case READ_ACTION_ERROR :
            RTI_RoutingServiceEnvironment_set_error( env, "Incorrect file");
        	*count = 0;
            return;
        case READ_ACTION_SKIP_SAMPLE :
            printf("RTIRS_FileStreamReader_read skipped sample\n");
        	continue;
        case READ_ACTION_SEND_SAMPLE :
        	if ( info->instance_state == DDS_ALIVE_INSTANCE_STATE ) {
        		printf("RTIRS_FileStreamReader_read: Returning regular sample:\n");
        		DDS_DynamicDataTypeSupport_print_data(self->_typeSupport, sample);
        	}
        	else if ( info->instance_state == DDS_NOT_ALIVE_DISPOSED_INSTANCE_STATE ) {
        		printf("RTIRS_FileStreamReader_read Returning disposed sample: \n");
        	}
           	else if ( info->instance_state == DDS_NOT_ALIVE_NO_WRITERS_INSTANCE_STATE ) {
            	printf("RTIRS_FileStreamReader_read Returning unregistered sample: \n");
            }

        	++index;
        	*count += 1;
            ++self->samplesReadCount;
            break;
        }
    }

    if (*count != 0) {
        *sample_list = (RTI_RoutingServiceSample *)self->_sample_list;
        *info_list   = (RTI_RoutingServiceSampleInfo *)self->_info_list;
    }
    
    /*
     * We don't provide sample info in this adapter, which
     * is an optional feature
     */
}


/*****************************************************************************/

void RTIRS_FileStreamReader_return_loan(
        RTI_RoutingServiceStreamReader stream_reader,
        RTI_RoutingServiceSample * sample_list,
        RTI_RoutingServiceSampleInfo * info_list,
        int count,
        RTI_RoutingServiceEnvironment * env) 
{
    printf("%s\n", __func__);

    /*
     * Nothing to do here since the samples and sample list are
     * only used by the session thread
     */
}


/*****************************************************************************/
int RTIRS_FileStreamReader_parsePositiveIntProperty(
    int *outPropertyValue,
    int defaultPropertyValue,
    const char *propertyName,
    const struct RTI_RoutingServiceProperties * properties,
    RTI_RoutingServiceEnvironment * env)
{
	const char *propertyValueString =
			RTI_RoutingServiceProperties_lookup_property(properties, propertyName);

    if (propertyValueString == NULL) {
    	*outPropertyValue = defaultPropertyValue;
    } else {
    	*outPropertyValue = atoi(propertyValueString);
        if ( *outPropertyValue <= 0 ) {
            RTI_RoutingServiceEnvironment_set_error(
                env, "Non-positive value for property '%s'", propertyName);
            return 0;
        }
    }

    return 1;
}

/*****************************************************************************/
int RTIRS_FileStreamReader_parseUpdateableProperties(
	    RTI_RoutingServiceAdapterEntity stream_reader,
	    const struct RTI_RoutingServiceProperties * properties,
	    RTI_RoutingServiceEnvironment * env)
{
    struct RTIRS_FileStreamReader * self =
        (struct RTIRS_FileStreamReader *) stream_reader;

    const char * loopProp = NULL;
    int loop = 0;
    int readPeriodIntProp;
    int samplesPerReadIntProp;
    int samplesPerDisposedSampleIntProp;
    int samplesPerUnregisteredSampleIntProp;
    int maxSampleSizeIntProp;

    loopProp = RTI_RoutingServiceProperties_lookup_property(
        properties, "Loop");
    if (loopProp != NULL) {
        if (!strcmp(loopProp, "yes") || !strcmp(loopProp, "true") ||
            !strcmp(loopProp, "1")) {
            loop = 1;
        }
    }

    if ( !RTIRS_FileStreamReader_parsePositiveIntProperty(
    			&readPeriodIntProp, 1000, "ReadPeriod", properties, env) ) {
        return 0;
    }
    if ( !RTIRS_FileStreamReader_parsePositiveIntProperty(
    			&samplesPerReadIntProp, 1, "SamplesPerRead", properties, env) ) {
        return 0;
    }
    if ( !RTIRS_FileStreamReader_parsePositiveIntProperty(
    			&samplesPerDisposedSampleIntProp, 0, "SamplesPerDisposedSample", properties, env) ) {
        return 0;
    }
    if ( !RTIRS_FileStreamReader_parsePositiveIntProperty(
    			&samplesPerUnregisteredSampleIntProp, 0, "SamplesPerUnregisteredSample", properties, env) ) {
        return 0;
    }
    if ( !RTIRS_FileStreamReader_parsePositiveIntProperty(
    			&maxSampleSizeIntProp, 4096, "MaxSampleSize", properties, env) ) {
        return 0;
    }

    if ( self->maxSampleSize == 0 ) {
    	self->maxSampleSize = maxSampleSizeIntProp;
    }
    else if ( maxSampleSizeIntProp != self->maxSampleSize ) {
    	RTI_RoutingServiceEnvironment_set_error(
    			env, "Property MaxSampleSize immutable while running");
    	return 0;
    }

    self->samplesPerRead     = samplesPerReadIntProp;
    self->readPeriod.sec     =  readPeriodIntProp / 1000;
    self->readPeriod.nanosec = (readPeriodIntProp % 1000) * 1000000;
    self->loop = loop;

    self->samplesPerDisposedSample     = samplesPerDisposedSampleIntProp;
    self->samplesPerUnregisteredSample = samplesPerUnregisteredSampleIntProp;

    return 1;
}

/*****************************************************************************/

void RTIRS_FileStreamReader_update(
    RTI_RoutingServiceAdapterEntity stream_reader,
    const struct RTI_RoutingServiceProperties * properties,
    RTI_RoutingServiceEnvironment * env)
{
    printf("%s\n", __func__);
    RTIRS_FileStreamReader_parseUpdateableProperties(stream_reader, properties, env);
}

/* ========================================================================= */
/*                                                                           */
/* Stream stream_writer methods                                              */
/*                                                                           */
/* ========================================================================= */


int RTIRS_FileStreamWriter_write(
    RTI_RoutingServiceStreamWriter stream_writer,
    const RTI_RoutingServiceSample * sample_list,
    const RTI_RoutingServiceSampleInfo * info_list,
    int count,
    RTI_RoutingServiceEnvironment * env) 
{
    struct RTIRS_FileStreamWriter * self = 
        (struct RTIRS_FileStreamWriter *) stream_writer;
    struct DDS_DynamicData * sample = NULL;
    struct DDS_SampleInfo  * sample_info = NULL;

    int i;

    printf("%s\n", __func__);

    for(i=0; i<count; i++) {

        sample = (struct DDS_DynamicData *) sample_list[i];
        sample_info = (struct DDS_SampleInfo  *)info_list[i];

        if (!RTIRS_FileAdapter_write_sample(
                sample_info, sample, self->file, env)) {
            return i;
        }

        if (self->flushEnabled) {
            fflush(self->file);
        }

    }

    return count;

}

/* ========================================================================= */
/*                                                                           */
/* Connection methods                                                        */
/*                                                                           */
/* ========================================================================= */

RTI_RoutingServiceSession 
RTIRS_FileConnection_create_session(
    RTI_RoutingServiceConnection connection,
    const struct RTI_RoutingServiceProperties * properties,
    RTI_RoutingServiceEnvironment * env) 
{

    /* We don't need sessions in this example, 
     * we can just return the connection
     * or we could not have implemented this function 
     */
    printf("%s\n", __func__);
    
    return connection;
}

/*****************************************************************************/

void RTIRS_FileConnection_delete_session(
    RTI_RoutingServiceConnection connection,
    RTI_RoutingServiceSession session,
    RTI_RoutingServiceEnvironment * env) 
{
    printf("%s\n", __func__);
    /* We don't need sessions in this example */
}

/*****************************************************************************/

void RTIRS_FileStreamReader_delete(
    struct RTIRS_FileStreamReader * self)
{
    printf("%s\n", __func__);

    if (self->file != stdin) {
        fclose(self->file);
    }

    if (self->_buffer != NULL) {
        free(self->_buffer);
        self->_buffer = NULL;
    }
    
    if ( self->_sample_list != NULL ) {
        free(self->_sample_list);
        self->_sample_list = NULL;
    }

    if ( self->_info_list != NULL ) {
        free(self->_info_list);
        self->_info_list = NULL;
    }
    
    free(self);
}

/*****************************************************************************/

RTI_RoutingServiceStreamReader 
RTIRS_FileConnection_create_stream_reader(
    RTI_RoutingServiceConnection connection,
    RTI_RoutingServiceSession session,
    const struct RTI_RoutingServiceStreamInfo * stream_info,
    const struct RTI_RoutingServiceProperties * properties,
    const struct RTI_RoutingServiceStreamReaderListener * listener,
    RTI_RoutingServiceEnvironment * env) 
{
    struct RTIRS_FileStreamReader * stream_reader = NULL;
    const char * fileNameProp = NULL;
    FILE * file = NULL;
    int error = 0;
    int i;

    struct DDS_DynamicDataProperty_t dynamicDataProps =
        DDS_DynamicDataProperty_t_INITIALIZER;

    struct DDS_DynamicDataTypeProperty_t dynamicDataTypeProp =
    	DDS_DynamicDataTypeProperty_t_INITIALIZER;
    	
  #ifndef RTI_WIN32
    pthread_attr_t threadAttr;
  #endif

    printf("%s...\n", __func__);

    /*
     * Create the stream reader object
     */

    stream_reader = calloc(
        1, sizeof(struct RTIRS_FileStreamReader));
    if (stream_reader == NULL) {
        RTI_RoutingServiceEnvironment_set_error(
            env, "Memory allocation error");
        return NULL;
    }

    /*
     * Get the configuration properties in <route>/<input>/<property>
     */

    /* maxSampleSize==0 indicates it is not initialized */
    stream_reader->maxSampleSize = 0;
    if ( !RTIRS_FileStreamReader_parseUpdateableProperties(stream_reader, properties, env) ) {

        RTIRS_FileStreamReader_delete(stream_reader);
        return NULL;
    }

    fileNameProp = RTI_RoutingServiceProperties_lookup_property(
        properties, "FileName");
    if (fileNameProp == NULL) {
        RTI_RoutingServiceEnvironment_set_error(
            env, "Missing property FileName");
        return NULL;
    }

    if ( strcmp("stdin", fileNameProp) == 0 ) {
        file = stdin;
    }
    else {
        file = fopen(fileNameProp, "r");

        if (file == NULL) {
            RTI_RoutingServiceEnvironment_set_error(
                env, "Could not open file for read: %s", fileNameProp);

           RTIRS_FileStreamReader_delete(stream_reader);
           return NULL;
        }
    }

    /*
     * Check that the type representation is DDS type code
     */

    if (stream_info->type_info.type_representation_kind != 
        RTI_ROUTING_SERVICE_TYPE_REPRESENTATION_DYNAMIC_TYPE) {

        RTI_RoutingServiceEnvironment_set_error(
            env, "Unsupported type format");

        RTIRS_FileStreamReader_delete(stream_reader);
        return NULL;
    }

    stream_reader->_buffer = 
        calloc(stream_reader->maxSampleSize+1, sizeof(char));

    if (stream_reader->_buffer == NULL) {
        RTI_RoutingServiceEnvironment_set_error(
            env, "Memory allocation error");


        return NULL;
    }

    stream_reader->file = file;
    stream_reader->listener = *listener;    
    stream_reader->_typeCode = 
        (struct DDS_TypeCode *) stream_info->type_info.type_representation;
    stream_reader->_run = 1;

    stream_reader->_sample_list = calloc(stream_reader->samplesPerRead, sizeof(DDS_DynamicData *));
    stream_reader->_info_list   = calloc(stream_reader->samplesPerRead, sizeof(struct DDS_SampleInfo *));
    stream_reader->samplesReadCount = 0;

    if ( stream_reader->_sample_list == NULL ) {
        RTI_RoutingServiceEnvironment_set_error(
             env, "Memory allocation error (sample_list)");

        RTIRS_FileStreamReader_delete(stream_reader);
        return NULL;
    }
    if ( stream_reader->_info_list == NULL ) {
        RTI_RoutingServiceEnvironment_set_error(
             env, "Memory allocation error (info_list)");

        RTIRS_FileStreamReader_delete(stream_reader);
        return NULL;
    }


    stream_reader->_typeSupport =
        DDS_DynamicDataTypeSupport_new(stream_reader->_typeCode, &dynamicDataTypeProp);

    for (i=0; i<stream_reader->samplesPerRead; i++) {
        /*
         * Create a dynamic data sample for every buffer we read. We use
         * the type we received when the stream reader was created
         */
    	stream_reader->_sample_list[i] =
    			DDS_DynamicData_new(stream_reader->_typeCode, &dynamicDataProps);

        if (stream_reader->_sample_list[i] == NULL) {
            RTI_RoutingServiceEnvironment_set_error(
                env, "Failure creating dynamic data sample");
            error = 1;
            break;
        }

        stream_reader->_info_list[i] =
        		(struct DDS_SampleInfo *)calloc(1, sizeof(struct DDS_SampleInfo));
        if ( stream_reader->_info_list[i] == NULL ) {
            RTI_RoutingServiceEnvironment_set_error(
                env, "Failure creating sample info");
            error = 1;
            break;
        }
        *(stream_reader->_info_list[i]) = DDS_SAMPLEINFO_DEFAULT;
        stream_reader->_info_list[i]->instance_handle = DDS_HANDLE_NIL;
        stream_reader->_info_list[i]->valid_data      = 1;
        stream_reader->_info_list[i]->instance_state  = DDS_ALIVE_INSTANCE_STATE;
    }

    if (error) {
        RTI_RoutingServiceEnvironment_set_error(
            env, "Error initializing samples and sample_info thread");

        RTIRS_FileStreamReader_delete(stream_reader);
        return NULL;
    }

  #ifdef RTI_WIN32
    stream_reader->_thread = (HANDLE) _beginthread(
        (void(__cdecl*)(void*))RTIRS_FileStreamReader_run,
        0, (void*)stream_reader);
    error = !stream_reader->_thread;
  #else
    pthread_attr_init(&threadAttr);
    pthread_attr_setdetachstate(&threadAttr, PTHREAD_CREATE_JOINABLE);
    error = pthread_create(
                &stream_reader->_thread, 
                &threadAttr, 
                RTIRS_FileStreamReader_run,
                (void *)stream_reader);
    pthread_attr_destroy(&threadAttr);
  #endif

    if(error) {
        RTI_RoutingServiceEnvironment_set_error(
            env, "Error creating thread");

        RTIRS_FileStreamReader_delete(stream_reader);
        return NULL;
    }

    printf("%s... OK\n", __func__);
    return (RTI_RoutingServiceStreamReader) stream_reader;
}

/*****************************************************************************/

void RTIRS_FileConnection_delete_stream_reader(
        RTI_RoutingServiceConnection connection,
	RTI_RoutingServiceStreamReader stream_reader,
	RTI_RoutingServiceEnvironment * env) {

    struct RTIRS_FileStreamReader * self =
        (struct RTIRS_FileStreamReader *) stream_reader;
  #ifndef RTI_WIN32
    void * value = NULL;
  #endif
    
    printf("%s\n", __func__);
    self->_run = 0;

  #ifdef RTI_WIN32
    WaitForSingleObject(self->_thread, INFINITE);
  #else
    pthread_join(self->_thread, &value);
  #endif

    RTIRS_FileStreamReader_delete(self);

}

/*****************************************************************************/

RTI_RoutingServiceStreamWriter 
RTIRS_FileConnection_create_stream_writer(
        RTI_RoutingServiceConnection connection,
	RTI_RoutingServiceSession session,
	const struct RTI_RoutingServiceStreamInfo * stream_info,
	const struct RTI_RoutingServiceProperties * properties,
	RTI_RoutingServiceEnvironment * env) {

    struct RTIRS_FileStreamWriter * stream_writer = NULL;
    const char * fileNameProp = NULL;
    const char * modeProp = NULL;
    const char * flushProp = NULL;
    int flushEnabled = 0;
    char * fileName = NULL;
    FILE * file = NULL;
    char * pos;
    int error = 0;
    

    printf("%s\n", __func__);

    modeProp = RTI_RoutingServiceProperties_lookup_property(
        properties, "WriteMode");
    if (modeProp != NULL) {
        if (strcmp(modeProp, "overwrite") && 
            strcmp(modeProp, "append") &&
            strcmp(modeProp, "keep") ) {
            RTI_RoutingServiceEnvironment_set_error(
                env, "Invalid value for WriteMode (%s). Allowed values: keep (default), overwrite, append",
                modeProp);
            return NULL;
        }
    } else {
        modeProp = "keep";
    }

    /*
     * Get the configuration properties in <route>/<input>/<property>
     */

    fileNameProp = RTI_RoutingServiceProperties_lookup_property(
        properties, "FileName");
    if (fileNameProp == NULL) {
        RTI_RoutingServiceEnvironment_set_error(
            env, "Missing property FileName");
        return NULL;
    }

    flushProp = RTI_RoutingServiceProperties_lookup_property(
        properties, "Flush");
    if (flushProp != NULL) {
        if (!strcmp(flushProp, "yes") || !strcmp(flushProp, "true") ||
            !strcmp(flushProp, "1")) {
            flushEnabled = 1;
        }
    }

    /*
     * Replace (stream_name) in the file name with the stream name of this writer
     */
    
    pos = strstr(fileNameProp, "(stream_name)");
    if (pos != NULL) {
        fileName = calloc(strlen(fileNameProp) + 
                          strlen(stream_info->stream_name) + 1, sizeof(char));

        strcpy(fileName, fileNameProp);
        strcpy(fileName + (pos - fileNameProp), 
               stream_info->stream_name);
        strcpy(fileName + (pos - fileNameProp) + 
               strlen(stream_info->stream_name),
               pos + strlen("(stream_name)"));
    } else {
        fileName = (char *) fileNameProp;
    }

    if (strcmp("stdout", fileName)) {
        if (!strcmp(modeProp, "keep")) {
            file = fopen(fileName, "r");
            if (file != NULL) {
                RTI_RoutingServiceEnvironment_set_error(
                    env, "File exists and WriteMode is keep");
                fclose(file);
                file = NULL;
                error = 1;
            }
        }
        file = fopen(fileName, !strcmp(modeProp, "append") ? "a" : "w");
        if (file == NULL) {
            RTI_RoutingServiceEnvironment_set_error(
                env, "Could not open file for write: %s", fileName);
            error = 1;
        }
    } else {
        file = stdout;
    }

    if (fileName != fileNameProp) {
        free(fileName);
    }

    if (error) {
        if (file != NULL && file != stdout) {
            fclose (file);
            file = NULL;
        }
        return NULL;
    }

    stream_writer = calloc(
        1, sizeof(struct RTIRS_FileStreamWriter));

    if (stream_writer == NULL) {
        RTI_RoutingServiceEnvironment_set_error(
            env, "Memory allocation error");
        if (file != NULL && file != stdout) {
            fclose (file);
            file = NULL;
        }
        return NULL;
    }

    stream_writer->file = file;
    stream_writer->flushEnabled = flushEnabled;

    return stream_writer;
}



/*****************************************************************************/

void RTIRS_FileConnection_delete_stream_writer(
        RTI_RoutingServiceConnection connection,
	RTI_RoutingServiceStreamWriter stream_writer,
	RTI_RoutingServiceEnvironment * env) 
{

    struct RTIRS_FileStreamWriter * self = 
        (struct RTIRS_FileStreamWriter *) stream_writer;

    printf("%s\n", __func__);

    if (self->file != stdout) {
        fclose(self->file);
    }
    
    free(self);
}

/* ========================================================================= */
/*                                                                           */
/* AdapterPlugin methods                                                     */
/*                                                                           */
/* ========================================================================= */

RTI_RoutingServiceConnection 
RTIRS_FileAdapterPlugin_create_connection(
    struct RTI_RoutingServiceAdapterPlugin * adapter,
    const char * routing_service_name,
    const char * routing_service_group_name,
    const struct RTI_RoutingServiceStreamReaderListener * input_disc_listener,
    const struct RTI_RoutingServiceStreamReaderListener * output_disc_listener,
    const struct RTI_RoutingServiceTypeInfo ** registeredTypes,
    int registeredTypeCount,
    const struct RTI_RoutingServiceProperties * properties,
    RTI_RoutingServiceEnvironment * env) 
{

    struct RTIRS_FileConnection * connection;

    printf("%s\n", __func__);

    connection = calloc(1, sizeof(struct RTIRS_FileConnection));

    if (connection == NULL) {
        RTI_RoutingServiceEnvironment_set_error(
            env, "Memory allocation error");
        return NULL;
    }

    connection->adapter = (struct RTIRS_FileAdapterPlugin *) adapter;

    return connection;
}

/*****************************************************************************/

void RTIRS_FileAdapterPlugin_delete_connection(
    struct RTI_RoutingServiceAdapterPlugin * adapter,
    RTI_RoutingServiceConnection connection,
    RTI_RoutingServiceEnvironment * env) 
{
    printf("%s\n", __func__);
    
    free(connection);
}

/*****************************************************************************/

void RTIRS_FileAdapterPlugin_delete(
    struct RTI_RoutingServiceAdapterPlugin * adapter,
    RTI_RoutingServiceEnvironment * env) 
{
    printf("%s\n", __func__);
    
    free(adapter);
}

/*****************************************************************************/

/*
 * Entry point to the adapter plugin
 */
DllExport
struct RTI_RoutingServiceAdapterPlugin * 
RTI_RS_File_AdapterPlugin_create(
    const struct RTI_RoutingServiceProperties * properties,
    RTI_RoutingServiceEnvironment * env) 
{

    struct RTIRS_FileAdapterPlugin * adapter = NULL;
    struct RTI_RoutingServiceVersion version = {1,0,0,0};

    printf("%s\n", __func__);
    adapter = calloc(1, sizeof(struct RTIRS_FileAdapterPlugin));

    if (adapter == NULL) {
        RTI_RoutingServiceEnvironment_set_error(
            env, "Memory allocation error");
        return NULL;
    }

    RTI_RoutingServiceAdapterPlugin_initialize(&adapter->_base);

    adapter->_base.plugin_version = version;

    /*
     * Assign the function pointers
     */

    adapter->_base.adapter_plugin_delete = 
        RTIRS_FileAdapterPlugin_delete;

    adapter->_base.adapter_plugin_create_connection = 
        RTIRS_FileAdapterPlugin_create_connection;
    adapter->_base.adapter_plugin_delete_connection = 
        RTIRS_FileAdapterPlugin_delete_connection;

    adapter->_base.connection_create_session = 
        RTIRS_FileConnection_create_session;
    adapter->_base.connection_delete_session = 
        RTIRS_FileConnection_delete_session;
    adapter->_base.connection_create_stream_reader = 
        RTIRS_FileConnection_create_stream_reader;
    adapter->_base.connection_delete_stream_reader = 
        RTIRS_FileConnection_delete_stream_reader;

    adapter->_base.connection_create_stream_writer = 
        RTIRS_FileConnection_create_stream_writer;
    adapter->_base.connection_delete_stream_writer = 
        RTIRS_FileConnection_delete_stream_writer;

    adapter->_base.stream_writer_write = 
        RTIRS_FileStreamWriter_write;

    adapter->_base.stream_reader_read = 
        RTIRS_FileStreamReader_read;
    adapter->_base.stream_reader_return_loan = 
        RTIRS_FileStreamReader_return_loan;
    adapter->_base.stream_reader_update = 
        RTIRS_FileStreamReader_update;


    return (struct RTI_RoutingServiceAdapterPlugin *) adapter;
}

#undef ROUTER_CURRENT_SUBMODULE

