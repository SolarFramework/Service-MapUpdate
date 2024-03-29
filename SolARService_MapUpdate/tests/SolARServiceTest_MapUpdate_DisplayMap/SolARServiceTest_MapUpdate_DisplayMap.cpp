/**
 * @copyright Copyright (c) 2021 B-com http://www.b-com.com/
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#include <iostream>

#include <cxxopts.hpp>

#include <xpcf/xpcf.h>
#include <xpcf/api/IComponentManager.h>
#include <xpcf/core/helpers.h>
#include <boost/log/core.hpp>
#include <signal.h>

#include "core/Log.h"
#include "api/pipeline/IMapUpdatePipeline.h"
#include "api/storage/IMapManager.h"
#include "api/display/I3DPointsViewer.h"
#include "api/input/devices/IARDevice.h"

using namespace std;
using namespace SolAR;
using namespace SolAR::api;
using namespace SolAR::datastructure;
namespace xpcf=org::bcom::xpcf;

// print help options
void print_help(const cxxopts::Options& options)
{
    cout << options.help({""}) << std::endl;
}

// print error message
void print_error(const string& msg)
{
    cerr << msg << std::endl;
}

int main(int argc, char* argv[])
{
    #if NDEBUG
        boost::log::core::get()->set_logging_enabled(false);
    #endif

    LOG_ADD_LOG_TO_CONSOLE();

    cxxopts::Options option_list("SolARServiceTest_MapUpdate_DisplayMap",
                                 "SolARServiceTest_MapUpdate_DisplayMap - The commandline interface to the xpcf grpc client test application.\n");
    option_list.add_options()
            ("h,help", "display this help and exit")
            ("v,version", "display version information and exit")
            ("f,file", "xpcf grpc client configuration file", cxxopts::value<string>())
            ("b,backup", "Backup current global map to specified local folder", cxxopts::value<string>())
            ("r,restore", "Restore global map from specified local folder", cxxopts::value<string>());

    auto options = option_list.parse(argc, argv);
    if (options.count("help")) {
        print_help(option_list);
        return 0;
    }
    else if (options.count("version"))
    {
        std::cout << "SolARServiceTest_MapUpdate_DisplayMap version " << MYVERSION << std::endl << std::endl;
        return 0;
    }
    else if (!options.count("file") || options["file"].as<string>().empty()) {
        print_error("missing one of file or database dir argument");
        return -1;
    }

    try {

        // Check if log level is defined in environment variable SOLAR_LOG_LEVEL
        char * log_level = getenv("SOLAR_LOG_LEVEL");
        std::string str_log_level = "INFO(default)";

        if (log_level != nullptr) {
            str_log_level = std::string(log_level);

            if (str_log_level == "DEBUG"){
                LOG_SET_DEBUG_LEVEL();
            }
            else if (str_log_level == "CRITICAL"){
                LOG_SET_CRITICAL_LEVEL();
            }
            else if (str_log_level == "ERROR"){
                LOG_SET_ERROR_LEVEL();
            }
            else if (str_log_level == "INFO"){
                LOG_SET_INFO_LEVEL();
            }
            else if (str_log_level == "TRACE"){
                LOG_SET_TRACE_LEVEL();
            }
            else if (str_log_level == "WARNING"){
                LOG_SET_WARNING_LEVEL();
            }
            else {
                LOG_ERROR ("'SOLAR_LOG_LEVEL' environment variable: invalid value");
                LOG_ERROR ("Expected values are: DEBUG, CRITICAL, ERROR, INFO, TRACE or WARNING");
            }

            LOG_DEBUG("Environment variable SOLAR_LOG_LEVEL={}", str_log_level);
        }

        LOG_INFO("Get component manager instance");
        SRef<xpcf::IComponentManager> componentManager = xpcf::getComponentManagerInstance();

        string file = options["file"].as<string>();
        LOG_INFO("Load Client Remote Map Update Pipeline configuration file: {}", file);

        if (componentManager->load(file.c_str()) != org::bcom::xpcf::_SUCCESS)
        {
            LOG_ERROR("Failed to load Client Remote Map Update Pipeline configuration file: {}", file);
            return -1;
        }

        LOG_INFO("Resolve IMapUpdatePipeline interface");
        SRef<pipeline::IMapUpdatePipeline> mapUpdatePipeline = componentManager->resolve<SolAR::api::pipeline::IMapUpdatePipeline>();

        SRef<storage::IMapManager> mapManager = componentManager->resolve<SolAR::api::storage::IMapManager>();

        string backup_folder = "", restore_folder = "";

        // Check  backup/restore options
        if ((options.count("backup")) && (!options["backup"].as<string>().empty()))
        {
            backup_folder = options["backup"].as<string>();
            LOG_INFO("Backup option set to folder: {}", backup_folder);
        }
        if ((options.count("restore")) && (!options["restore"].as<string>().empty()))
        {
            restore_folder = options["restore"].as<string>();
            LOG_INFO("Restore option set from folder: {}", restore_folder);
        }

        LOG_INFO("Load Client Remote Map Update Pipeline configuration file: {}", file);

        LOG_INFO("Client components loaded");

        // Initialize Map Update service
        if (mapUpdatePipeline->init() != FrameworkReturnCode::_SUCCESS)
        {
            LOG_ERROR("Failed to initialize Map Update service");
            return -1;
        }

        // Reset global map if option "restore" is specified
        if (restore_folder != "")
        {
            LOG_INFO("Reset global map before restore");
            mapUpdatePipeline->resetMap();
        }

        // Start Map Update service
        if (mapUpdatePipeline->start() != FrameworkReturnCode::_SUCCESS)
        {
            LOG_ERROR("Failed to start Map Update service");
            return -1;
        }

        // Restore global map if option specified
        if (restore_folder != "")
        {
            LOG_INFO("Restore global map from local folder: {}", restore_folder);

            mapManager->bindTo<xpcf::IConfigurable>()->getProperty("directory")->setStringValue(restore_folder.c_str());

            if (mapManager->loadFromFile() == FrameworkReturnCode::_SUCCESS)
            {
                SRef<Map> global_map;
                mapManager->getMap(global_map);
                if (mapUpdatePipeline->mapUpdateRequest(global_map) == FrameworkReturnCode::_SUCCESS)
                {
                    LOG_INFO("Global map restored from backup");
                }
                else
                {
                    LOG_ERROR("Failed to restore global map");
                }
            }
            else
            {
                LOG_ERROR("Failed to load global map from files");
            }
        }

        // Display the current global map

        auto gViewer3D = componentManager->resolve<display::I3DPointsViewer>();

        LOG_INFO("Try to get current global map from Map Update remote service");

        SRef<Map> globalMap;
        std::vector<SRef<Keyframe>> globalKeyframes;
        std::vector<SRef<CloudPoint>> globalPointCloud;
        std::vector<Transform3Df> globalKeyframesPoses;

        if (mapUpdatePipeline->getMapRequest(globalMap) == FrameworkReturnCode::_SUCCESS) {

            LOG_INFO("Map Update request terminated");

            // Backup global map if option specified
            if (backup_folder != "")
            {
                LOG_INFO("Store global map on local folder: {}", backup_folder);
                mapManager->bindTo<xpcf::IConfigurable>()->getProperty("directory")->setStringValue(backup_folder.c_str());
                mapManager->setMap(globalMap);
                mapManager->saveToFile();
            }

            globalMap->getConstKeyframeCollection()->getAllKeyframes(globalKeyframes);
            globalMap->getConstPointCloud()->getAllPoints(globalPointCloud);
            LOG_INFO("Number of keyframes: {}", globalKeyframes.size());
            LOG_INFO("Number of cloud points: {}", globalPointCloud.size());
            if (globalPointCloud.size() > 0) {
                for (const auto &it : globalKeyframes)
                    globalKeyframesPoses.push_back(it->getPose());

                LOG_INFO("==> Display current global map: press ESC on the map display window to end test");

                while (true)
                {
                    if (gViewer3D->display(globalPointCloud, {}, {}, {}, {}, globalKeyframesPoses) == FrameworkReturnCode::_STOP)
                        break;
                }
            }
            else {
                LOG_INFO("Current global map is empty!");
            }
        }
        else {
            LOG_INFO("No current global map!");
        }

        // Stop Map Update service
        if (mapUpdatePipeline->stop() != FrameworkReturnCode::_SUCCESS)
        {
            LOG_ERROR("Failed to stop Map Update service");
            return -1;
        }
    }
    catch (xpcf::Exception & e) {
        LOG_INFO("The following exception has been caught: {}", e.what());
        return -1;
    }

    return 0;
}
