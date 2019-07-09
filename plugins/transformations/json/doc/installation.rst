.. include:: vars.rst

.. _section-install:

************
Installation
************

|RSTSFM| is distributed in source format. A source repository can be cloned
using ``git``:

.. code-block:: sh

    git clone --recurse-submodule https://bitbucket.rti.com/scm/~asorbini/rtiroutingservice-transform.git


The ``--recurse-submodule`` option is required to clone an additional
repository as submodules:

:plugin-helper: |RTI_HELPER| is a collection of helper scripts for CMake and
                Make to facilitate the implementation of plugins for |RS|
                using C.

