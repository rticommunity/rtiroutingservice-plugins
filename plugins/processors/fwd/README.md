# RTI Routing Service Forwarding Engine Plugin

This repository contains multiple Processor Plugins for RTI Routing Service which can be
used to propagate data within a Route, from Inputs to Outputs, based on different criteria.

The library built by the repository (`rtirsfwdprocessor`) provides two plugins:

  - **ByInputNameForwardingEnginePlugin**

    - Forwards samples based on the name of the Input that produced them.

    - Created by registering function
     `RTI_PRCS_FWD_ByInputNameForwardingEnginePlugin_create`.

 - **ByInputValueForwardingEnginePlugin**

   - Forwards samples based on the contents of one of their members.

   - Created by registering function
    `RTI_PRCS_FWD_ByInputValueForwardingEnginePlugin_create`
