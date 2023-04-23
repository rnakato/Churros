Installation
================

Docker image is available at `DockerHub <https://hub.docker.com/r/rnakato/churros>`_.

Docker
++++++++++++++

To use docker command, type:

.. code-block:: bash

   # pull docker image
   docker pull rnakato/churros
   # execute a command
   docker run -it --rm rnakato/churros <command>

Singularity
+++++++++++++++++++++++

Singularity can also be used to execute the docker image:

.. code-block:: bash

   # build image
   singularity build churros.sif docker://rnakato/churros
   # execute a command
   singularity exec churros.sif <command>

Singularity mounts the current directory automatically. If you access the files in the other directory,
mount it by ``--bind`` option:

.. code-block:: bash

   singularity exec --bind /work churros.sif <command>

This command mounts ``/work`` directory.
