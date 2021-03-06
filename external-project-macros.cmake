
#
# force build macro
# 
macro(force_build proj)
  ExternalProject_Add_Step(${proj} forcebuild
    COMMAND ${CMAKE_COMMAND} -E remove ${base}/Stamp/${proj}/${proj}-build
    DEPENDEES configure
    DEPENDERS build
    ALWAYS 1
  )
endmacro()

macro(get_toolchain_file tag)
  string(REPLACE "-" "_" tag_with_underscore ${tag})
  set(toolchain_file ${toolchain_${tag_with_underscore}})
endmacro()

macro(get_try_run_results_file tag)
  string(REPLACE "-" "_" tag_with_underscore ${tag})
  set(try_run_results_file ${try_run_results_${tag_with_underscore}})
endmacro()

#
# Eigen fetch and install
# 
macro(install_eigen)
  set(eigen_url http://www.vtk.org/files/support/eigen-3.1.0-alpha1.tar.gz)
  set(eigen_md5 c04dedf4ae97b055b6dd2aaa01daf5e9)
  ExternalProject_Add(
    eigen
    SOURCE_DIR ${source_prefix}/eigen
    URL ${eigen_url}
    URL_MD5 ${eigen_md5}
    CONFIGURE_COMMAND ""
    BUILD_COMMAND ""
    INSTALL_COMMAND ${CMAKE_COMMAND} -E copy_directory "${source_prefix}/eigen/Eigen" "${install_prefix}/eigen/Eigen" && ${CMAKE_COMMAND} -E copy_directory "${source_prefix}/eigen/unsupported" "${install_prefix}/eigen/unsupported"
  )
endmacro()

#
# VTK fetch
# 
macro(fetch_vtk)
  ExternalProject_Add(
    vtk-fetch
    SOURCE_DIR ${source_prefix}/vtk
    GIT_REPOSITORY https://github.com/Nom1vk/VTK.git
    GIT_TAG origin/6.2Android-Kiwi
    CONFIGURE_COMMAND ""
    BUILD_COMMAND ""
    INSTALL_COMMAND ""
  )
endmacro()

#
# VTK compile
# 
macro(compile_vtk)
  set(proj vtk-host)
  ExternalProject_Add(
    ${proj}
    SOURCE_DIR ${source_prefix}/vtk
    DOWNLOAD_COMMAND ""
    INSTALL_COMMAND ""
    DEPENDS vtk-fetch
    CMAKE_ARGS
      -DCMAKE_INSTALL_PREFIX:PATH=${install_prefix}/${proj}
      -DCMAKE_BUILD_TYPE:STRING=${build_type}
      -DBUILD_SHARED_LIBS:BOOL=ON
      -DBUILD_TESTING:BOOL=OFF
      ${vtk_module_defaults}
  )
endmacro()

#
# VTK crosscompile
# 
macro(crosscompile_vtk tag)
  set(proj vtk-${tag})
  get_toolchain_file(${tag})
  get_try_run_results_file(${proj})
  ExternalProject_Add(
    ${proj}
    SOURCE_DIR ${source_prefix}/vtk
    DOWNLOAD_COMMAND ""
    INSTALL_COMMAND ${CMAKE_COMMAND} -E copy_directory "${build_prefix}/vtk-android/CMakeExternals/Install/vtk-android/" "${install_prefix}/vtk-android/"
    DEPENDS vtk-fetch
    CMAKE_ARGS
      -DCMAKE_INSTALL_PREFIX:PATH=${install_prefix}/${proj}
      -DCMAKE_BUILD_TYPE:STRING=${build_type}
      -DBUILD_SHARED_LIBS:BOOL=OFF
      -DBUILD_TESTING:BOOL=OFF
      -DCMAKE_TOOLCHAIN_FILE:FILEPATH=${toolchain_file}
      #-DVTKCompileTools_DIR:PATH=${build_prefix}/vtk-host
      ${vtk_module_defaults}
      #-C ${try_run_results_file}
  )
endmacro()

#
# FLANN fetch
# 
macro(fetch_flann)
  ExternalProject_Add(
    flann-fetch
    SOURCE_DIR ${source_prefix}/flann
    GIT_REPOSITORY https://github.com/Nom1vk/flann
    GIT_TAG cee08ec38a8df7bc70397f10a4d30b9b33518bb4
    CONFIGURE_COMMAND ""
    BUILD_COMMAND ""
    INSTALL_COMMAND ""
  )
endmacro()

#
# FLANN crosscompile
# 
macro(crosscompile_flann tag)
  set(proj flann-${tag})
  get_toolchain_file(${tag})
  ExternalProject_Add(
    ${proj}
    SOURCE_DIR ${source_prefix}/flann
    DOWNLOAD_COMMAND ""
    DEPENDS flann-fetch
    CMAKE_ARGS
      -DCMAKE_INSTALL_PREFIX:PATH=${install_prefix}/${proj}
      -DCMAKE_BUILD_TYPE:STRING=${build_type}
      -DCMAKE_TOOLCHAIN_FILE:FILEPATH=${toolchain_file}
      -DBUILD_SHARED_LIBS:BOOL=OFF
      -DBUILD_EXAMPLES:BOOL=OFF
      -DBUILD_PYTHON_BINDINGS:BOOL=OFF
      -DBUILD_MATLAB_BINDINGS:BOOL=OFF
      ${android_cmake_vars}
  )

  #force_build(${proj})
endmacro()

########################## NEW BOOST MACROS ############################
#
# Boost fetch
# 
macro(fetch_boost)
  ExternalProject_Add(
    boost-fetch
    SOURCE_DIR ${source_prefix}/boost
    GIT_REPOSITORY https://github.com/Nom1vk/Boost-for-Android.git
    GIT_TAG origin/master
    UPDATE_COMMAND ""
    CONFIGURE_COMMAND ""
    BUILD_COMMAND ""
    INSTALL_COMMAND ""
  )
endmacro()

#
# Boost crosscompile
# 
macro(crosscompile_boost tag)
  set(proj boost-${tag})
  get_toolchain_file(${tag})
  ExternalProject_Add(
    ${proj}
    SOURCE_DIR ${source_prefix}/boost
    CONFIGURE_COMMAND ""
    DOWNLOAD_COMMAND ""
    DEPENDS boost-fetch
    BUILD_COMMAND COMMAND cd ${source_prefix}/boost/ && bash build-android2.sh -t ${ANDROID_TOOLCHAIN} -b ${BOOST_VERSION} -a ${ANDROID_ABI} -o "linux-x86_64" -e python -p "${build_prefix}/boost-android/"
    INSTALL_COMMAND ${CMAKE_COMMAND} -E copy_directory "${build_prefix}/boost-android/build_1_55_0/${ANDROID_ABI}/" "${install_prefix}/boost-android/"
	)
endmacro()

#
# PCL Fetch
# 
macro(fetch_pcl)
  ExternalProject_Add(
    pcl-fetch
    SOURCE_DIR ${source_prefix}/pcl
    GIT_REPOSITORY https://github.com/Nom1vk/pcl.git
    GIT_TAG origin/master
    CONFIGURE_COMMAND ""
    BUILD_COMMAND ""
    INSTALL_COMMAND ""
  )
endmacro()

#
# PCL crosscompile
# 
macro(crosscompile_pcl tag)
  set(proj pcl-${tag})
  get_toolchain_file(${tag})
  get_try_run_results_file(${proj})

  # copy the toolchain file and append the boost install dir to CMAKE_FIND_ROOT_PATH
  set(original_toolchain_file ${toolchain_file})
  get_filename_component(toolchain_file ${original_toolchain_file} NAME)
  set(toolchain_file ${build_prefix}/${proj}/${toolchain_file})
  configure_file(${original_toolchain_file} ${toolchain_file} COPYONLY)
  file(APPEND ${toolchain_file}
    "\nlist(APPEND CMAKE_FIND_ROOT_PATH ${install_prefix}/boost-${tag})\n")

  ExternalProject_Add(
    ${proj}
    SOURCE_DIR ${source_prefix}/pcl
    DOWNLOAD_COMMAND ""
    DEPENDS pcl-fetch boost-${tag} flann-${tag} eigen vtk-${tag}
    CMAKE_ARGS
      -DCMAKE_INSTALL_PREFIX:PATH=${install_prefix}/${proj}
      -DCMAKE_BUILD_TYPE:STRING=${build_type}
      -DCMAKE_TOOLCHAIN_FILE:FILEPATH=${toolchain_file}
       ${android_cmake_vars}
      -DBUILD_SHARED_LIBS:BOOL=OFF
      -DPCL_SHARED_LIBS:BOOL=OFF
      -DBUILD_visualization:BOOL=OFF
      -DBUILD_examples:BOOL=OFF
      -DVTK_DIR=${install_prefix}/vtk-${tag}/lib/cmake/vtk-6.2/
      -DEIGEN_INCLUDE_DIR=${install_prefix}/eigen
      -DFLANN_INCLUDE_DIR=${install_prefix}/flann-${tag}/include
      -DFLANN_LIBRARY=${install_prefix}/flann-${tag}/lib/libflann_cpp_s.a
      -DBOOST_ROOT=${install_prefix}/boost-${tag}
      -DBOOST_LIBRARYDIR=${install_prefix}/boost-${tag}/lib/
      -C ${try_run_results_file}
  )
  #force_build(${proj})
endmacro()

######### Added VES and Kiwi ##########################################
macro(fetch_ves)
  ExternalProject_Add(
    ves-fetch
    SOURCE_DIR ${source_prefix}/ves
    GIT_REPOSITORY https://github.com/Nom1vk/VES.git
    GIT_TAG origin/Android-patched
    CONFIGURE_COMMAND ""
    BUILD_COMMAND ""
    INSTALL_COMMAND ""
  )
endmacro()

macro(crosscompile_ves tag)
  set(proj ves-${tag})
  get_toolchain_file(${tag})
  ExternalProject_Add(
    ${proj}
    SOURCE_DIR ${source_prefix}/ves
    DOWNLOAD_COMMAND ""
    DEPENDS ves-fetch vtk-${tag} eigen
    CMAKE_ARGS
      -DCMAKE_INSTALL_PREFIX:PATH=${install_prefix}/${proj}
      -DCMAKE_BUILD_TYPE:STRING=${build_type}
      -DCMAKE_TOOLCHAIN_FILE:FILEPATH=${toolchain_file}
      ${android_cmake_vars}
      -DCMAKE_CXX_FLAGS:STRING=${VES_CXX_FLAGS}
      -DBUILD_SHARED_LIBS:BOOL=OFF
      -DVES_USE_VTK:BOOL=ON
      -DVES_NO_SUPERBUILD:BOOL=ON
      -DVTK_DIR:PATH=${install_prefix}/vtk-${tag}/lib/cmake/vtk-6.2/
      -DEIGEN_INCLUDE_DIR:PATH=${install_prefix}/eigen
      -DPYTHON_EXECUTABLE:FILEPATH=${PYTHON_EXECUTABLE}      
  )
  #force_build(${proj})
endmacro()

macro(create_pcl_framework)
    add_custom_target(pclFramework ALL
      COMMAND ${CMAKE_SOURCE_DIR}/makeFramework.sh pcl
      WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
      DEPENDS pcl-ios-device pcl-ios-simulator
      COMMENT "Creating pcl.framework")
endmacro()

########## Added PCL Hello World #######################################
macro(crosscompile_pcl_hello_world tag)
  set(proj PCLHelloWorld-${tag})
  get_toolchain_file(${tag})
  get_try_run_results_file(pcl-${tag})
  
  # copy the toolchain file and append the boost install dir to CMAKE_FIND_ROOT_PATH
  set(original_toolchain_file ${toolchain_file})
  get_filename_component(toolchain_file ${original_toolchain_file} NAME)
  set(toolchain_file_new ${build_prefix}/${proj}/${toolchain_file})
  configure_file(${original_toolchain_file} ${toolchain_file_new} COPYONLY)
  file(APPEND ${toolchain_file_new}
    "\nlist(APPEND CMAKE_FIND_ROOT_PATH ${install_prefix}/boost-${tag})\n")
  file(APPEND ${toolchain_file_new}
    "\nlist(APPEND CMAKE_FIND_ROOT_PATH ${install_prefix}/pcl-${tag})\n")
  file(APPEND ${toolchain_file_new}
    "\nlist(APPEND CMAKE_FIND_ROOT_PATH ${install_prefix}/flann-${tag})\n")
  
  ExternalProject_Add(
    ${proj}
    SOURCE_DIR ${source_prefix}/pcl/Android/apps/android/PCLAndroidSample
    DOWNLOAD_COMMAND ""
    DEPENDS boost-${tag}
    CMAKE_ARGS
      -DCMAKE_INSTALL_PREFIX:PATH=${install_prefix}/${proj}
      -DCMAKE_BUILD_TYPE:STRING=${build_type}
      -DCMAKE_TOOLCHAIN_FILE:FILEPATH=${toolchain_file_new}
      ${android_cmake_vars}
      -DPCL_DIR=${install_prefix}/pcl-${tag}
      -DEIGEN_INCLUDE_DIRS=${install_prefix}/eigen
      -DFLANN_INCLUDE_DIR=${install_prefix}/flann-${tag}/include
      -DFLANN_LIBRARY=${install_prefix}/flann-${tag}/lib/libflann_cpp_s.a
      -DBOOST_ROOT=${install_prefix}/boost-${tag}
      -DBOOST_LIBRARYDIR=${install_prefix}/boost-${tag}/lib/
      -C ${try_run_results_file}
  )
  force_build(${proj})
endmacro()

######### Added momiras-modules ########################################
macro(fetch_momiras)
  ExternalProject_Add(
    momiras-fetch
    SOURCE_DIR ${source_prefix}/momiras-modules
    GIT_REPOSITORY https://vkyriazakos@bitbucket.org/vkyriazakos/momiras-modules.git
    GIT_TAG origin/master
    CONFIGURE_COMMAND ""
    BUILD_COMMAND ""
    INSTALL_COMMAND ""
  )
endmacro()

macro(crosscompile_momiras tag)
set(proj momiras-${tag})
  get_toolchain_file(${tag})
  #get_try_run_results_file(pcl-${tag})
  
  # copy the toolchain file and append the boost install dir to CMAKE_FIND_ROOT_PATH
  set(original_toolchain_file ${toolchain_file})
  get_filename_component(toolchain_file ${original_toolchain_file} NAME)
  set(toolchain_file_new ${build_prefix}/${proj}/${toolchain_file})
  configure_file(${original_toolchain_file} ${toolchain_file_new} COPYONLY)
  file(APPEND ${toolchain_file_new}
    "\nlist(APPEND CMAKE_FIND_ROOT_PATH ${install_prefix}/boost-${tag})\n")
  file(APPEND ${toolchain_file_new}
    "\nlist(APPEND CMAKE_FIND_ROOT_PATH ${install_prefix}/pcl-${tag})\n")
  file(APPEND ${toolchain_file_new}
    "\nlist(APPEND CMAKE_FIND_ROOT_PATH ${install_prefix}/flann-${tag})\n")
  file(APPEND ${toolchain_file_new}
    "\nlist(APPEND CMAKE_FIND_ROOT_PATH ${NVPACK_ROOT}/OpenCV-2.4.8.2-Tegra-sdk/sdk/native/jni) \n")
    
  
  ExternalProject_Add(
    ${proj}
    SOURCE_DIR ${source_prefix}/momiras-modules
    DOWNLOAD_COMMAND ""
    DEPENDS boost-${tag}
    CMAKE_ARGS
      -DCMAKE_INSTALL_PREFIX:PATH=${install_prefix}/${proj}
      -DCMAKE_BUILD_TYPE:STRING=${build_type}
      -DCMAKE_TOOLCHAIN_FILE:FILEPATH=${toolchain_file_new}
      ${android_cmake_vars}     
	  -DMOMIRAS_BUILD_SHARED_LIBS=ON
	  -DMOMIRAS_BUILD_SOUND_GENERATOR=OFF
	  -DMOMIRAS_BUILD_LIGHT_ESTIMATION=ON
      -DPCL_DIR=${install_prefix}/pcl-${tag}
      -DEIGEN_INCLUDE_DIRS=${install_prefix}/eigen
      -DFLANN_INCLUDE_DIR=${install_prefix}/flann-${tag}/include
      -DFLANN_LIBRARY=${install_prefix}/flann-${tag}/lib/libflann_cpp_s.a
      -DBOOST_ROOT=${install_prefix}/boost-${tag}
      -DBOOST_LIBRARYDIR=${install_prefix}/boost-${tag}/lib/
      -C ${try_run_results_file}
  )
  force_build(${proj})
endmacro()


######### Added CMAKE Minimal example of NVIDIA FXAA ########################################
macro(fetch_FXAA)
  ExternalProject_Add(
    FXAA-fetch
    SOURCE_DIR ${source_prefix}/FXAA
    GIT_REPOSITORY https://vkyriazakos@bitbucket.org/vkyriazakos/androidcmakeminimalexample.git
    GIT_TAG origin/master
    CONFIGURE_COMMAND ""
    BUILD_COMMAND ""
    INSTALL_COMMAND ""
  )
endmacro()

macro(crosscompile_FXAA tag)
set(proj FXAA-${tag})
  get_toolchain_file(${tag})
  #get_try_run_results_file(pcl-${tag})
  
  # copy the toolchain file and append the boost install dir to CMAKE_FIND_ROOT_PATH
  set(original_toolchain_file ${toolchain_file})
  get_filename_component(toolchain_file ${original_toolchain_file} NAME)
  set(toolchain_file_new ${build_prefix}/${proj}/${toolchain_file})
  configure_file(${original_toolchain_file} ${toolchain_file_new} COPYONLY)
  
  ## Unecessary but OK ##
  file(APPEND ${toolchain_file_new}
    "\nlist(APPEND CMAKE_FIND_ROOT_PATH ${install_prefix}/boost-${tag})\n")
  file(APPEND ${toolchain_file_new}
    "\nlist(APPEND CMAKE_FIND_ROOT_PATH ${install_prefix}/pcl-${tag})\n")
  file(APPEND ${toolchain_file_new}
    "\nlist(APPEND CMAKE_FIND_ROOT_PATH ${install_prefix}/flann-${tag})\n")
  file(APPEND ${toolchain_file_new}
    "\nlist(APPEND CMAKE_FIND_ROOT_PATH ${NVPACK_ROOT}/OpenCV-2.4.8.2-Tegra-sdk/sdk/native/jni) \n")
    
  
  ExternalProject_Add(
    ${proj}
    SOURCE_DIR ${source_prefix}/FXAA
    DOWNLOAD_COMMAND ""
    #DEPENDS boost-${tag}
    CMAKE_ARGS
      -DCMAKE_INSTALL_PREFIX:PATH=${install_prefix}/${proj}
      -DCMAKE_BUILD_TYPE:STRING=Debug
      -DCMAKE_TOOLCHAIN_FILE:FILEPATH=${toolchain_file_new}
      ${android_cmake_vars}     
  )
  force_build(${proj})
endmacro()
