project 'Shell'
  kind 'StaticLib'
  language 'C++'
  location '../build'
  includedirs { 'include', '../librocket/Include' }
  files { 'include/*.h', 'src/*.cpp', 'src/win32/*.cpp' }

  configuration 'Debug'
    targetdir '../build/lib/debug'
    defines { 'DEBUG', 'STATIC_LIB' }
  configuration 'Release'
    targetdir '../build/lib/release'
    defines { 'NDEBUG', 'STATIC_LIB' }
    flags { 'Optimize' }


