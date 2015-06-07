CMake build scripts for cross compiling PCL and its dependencies for Android and (iOS).

Known Issues
-----

Problem with ‘isnan‘ or ‘isfinite’

Conflict between C99 and C++11 support. Edit ./build/CMakeCache.txt and set below flags will fix it.
./build/CMakeCache.txt

`//c++ flags
CMAKE_CXX_FLAGS:STRING=-std=c++11`

This will crash all move constructors of deprecated boost 1.45

Need to take weak/shared_ptr from 1.48.03 where they fixed the implicit move
constructor semantics.

**TBD** Change fetched Boost library 

Pthread related problem on compiling boost library

If there is some kind of #error “Sorry, no boost threads are available for this platform.” occurs, that probably be the conflict between boost and gcc 4.7. An old version of boost (1.45) is used here and in header file, it has no idea to proceed changed macro.

Add a flag in ./build/CMakeExternals/Source/boost/boost_1_45_0/boost/config/stdlib/libstdcpp3.hpp :

`ifdef __GLIBCXX__ // gcc 3.4 and greater:
#  if defined(_GLIBCXX_HAVE_GTHR_DEFAULT) \
        || defined(_GLIBCXX__PTHREADS) \
        || defined(_GLIBCXX_HAS_GTHREADS) // gcc 4.7
      //
      // If the std lib has thread support turned on, then turn it on in Boost
      // as well.  We do this because some gcc-3.4 std lib headers define _REENTANT
      // while others do not...
      //`

PCL region_growing_rgb.hpp : crashed from failed template deduction and conversion
from float to float&&
line ~380 change
`std::make_pair<int, float>(distances[i_seg], i_seg)`
to
`std::make_pair(distances[i_seg], i_seg)

Last error on .png image

**TBD** give new pcl and new boost to fetch feeds
