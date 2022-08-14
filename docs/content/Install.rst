Installation
================

Docker image is available at `DockerHub <https://hub.docker.com/r/rnakato/churros>`_.

**Churros** internally uses the tools including:

- FastQC v0.11.9
- MultiQC v1.12
- Bowtie2 version 2.4.5
- BWA version 0.7.17
- MACS2 version 2.2.6
- SAMtools version 1.15.1
- DROMPA+ version 1.15.1
- SSP version 1.2.5
- ChromHMM version 1.23
- ChromImpute version 1.0.3

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
