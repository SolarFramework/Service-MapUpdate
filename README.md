# Service-MapUpdate
[![License](https://img.shields.io/github/license/SolARFramework/SolARModuleTools?style=flat-square&label=License)](https://www.apache.org/licenses/LICENSE-2.0)

These services integrate map update pipelines to make them deployable on cloud architecture.

The services for map update are open-source, designed by [b<>com](https://b-com.com/en), under [Apache v2 licence](https://www.apache.org/licenses/LICENSE-2.0).

## How to run (Linux only)

### Install required data

Before running the services, you need to download data such as Hololens captures, maps and the vocabulary of the bag of word used for image retrieval.
To install the required data, just launch the following script:

	./installData.sh

This script will install the following data into the `./data` folder:
- The bag of words downloaded from our [GitHub releases](https://github.com/SolarFramework/binaries/releases/download/fbow%2F0.0.1%2Fwin/fbow_voc.zip) and unzipped in the `./data` folder.
- Maps produced from the previous captures and downloaded from our Artifactory ([mapA](https://repository.solarframework.org/generic/maps/hololens/bcomLab/loopDesktopA.zip) and [mapB](https://repository.solarframework.org/generic/maps/hololens/bcomLab/loopDesktopB.zip)) and copied into the `./data/maps` folder.

### Install required modules

Some samples require several SolAR modules such as OpenGL, OpenCV, FBOW and G20. If they are not yet installed on your machine, please run the following command from the test folder:

<pre><code>remaken install packagedependencies.txt</code></pre>

and for debug mode:

<pre><code>remaken install packagedependencies.txt -c debug</code></pre>

For more information about how to install remaken on your machine, visit the [install page](https://solarframework.github.io/install/) on the SolAR website.

## Run the services (Linux only)

### Map Update service

This service is based on the Map Update pipeline.

in the "./bin/Release" or "./bin/Debug" folder:

	./start_mapupdate_service.sh
	
## Build Docker images (Linux only)

To make these services deployable on a cloud architecture, you need first to integrate them in a Docker image.

For this, you need to install the Docker environment on your computer: https://www.docker.com/

Then, all the necessary files are provided in the "docker" subfolder of each project:
- *build.sh* : to build the Docker image
- *launch.sh* to launch the Docker container (to test it on your computer)
- ".dockerfile" used by the build script to construct the image
- "start_server.sh" used by the Docker container to start the service

To use the "build" and "launch" script files, you must first bundle your service by creating a folder with the following structure:
- service bundle folder
	-- the service executable file (built previously with QT creator or Visual Studio)
	-- the service configuration files for modules (xxx_modules.xml) and for properties (xxx_properties.xml)
	-- *data* folder: containing all the data needed by the service (see "Install required data")
	-- *modules* folder: containing all the modules needed by the service (you can use *remaken bundleXpcf* to copy all needed modules here)
    -- *docker* folder: containing all the files of the "docker" subfolder of the project	

## Deploy the service on a cloud architecture

To help you to deploy SolAR services, a *kubernetes* manifest file is provided as an example for each project, in the "docker" subfolder (YAML format).

## Run the test applications

Two test applications are provided with the Map Update services:
- SolARServiceTest_MapUpdate: send test maps (Map1 and Map2) to the service for fusion, and display each time the result
- SolARServiceTest_MapUpdate_DisplayMap: request the Map Update service for the current sparse map and display it
  
To run these applications, you can use the "run.sh" scripts provided with the projects:

in the "./bin/Release" or "./bin/Debug" folder:

    ./run.sh ./test_application_exe_name -f configuration_file.xml

exemple:

    ./run.sh ./SolARServiceTest_MapUpdate -f SolARServiceTest_MapUpdate_conf.xml
	
Important: *Before running a test application, you must set the services URL in the xml configuration file*
           (and the services must be running of course)

        <!-- gRPC proxy configuration-->
        <configure component="IMapUpdatePipeline_grpcProxy">
            <property name="channelUrl" access="rw" type="string" value="0.0.0.0:50053"/>
