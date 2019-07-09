.. include:: vars.rst

.. _section-install:

************
Installation
************

|RSMQTT| is distributed in source format. A source repository can be cloned
using ``git``:

.. code-block:: sh

    git clone --recurse-submodule https://github.com/rticommunity/rtiroutingservice-plugins.git


The ``--recurse-submodule`` option is required to clone three additional
repositories as submodules:

:paho.mqtt.c: The :link_paho_c:`Paho C Client <>` library is used as
              implementation of the client side of the MQTT protocol.

:cmocka: The :link_cmocka:`cmocka <>` library is used to implement and run
         tests.

