project 'CharGen'
  location '../build'
  language 'C++'
  files { 'main.cpp' }
  includedirs {
    '../lua',
    '../shell/include',
    '../librocket/Include'
  }
  buildoptions { '--std=c++1y' }

  links { 
    'Shell', 'Lua',
    'opengl32', 'glu32', 'gdi32', 
    'RocketCore', 'RocketDebugger',
    'freetype.dll'
  }
  libdirs { '../freetype/lib' }

  configuration 'Debug'
    kind 'ConsoleApp'
    defines { 'DEBUG', 'STATIC_LIB' }
    targetdir '../build/bin/debug'

  configuration 'release'
    kind 'WindowedApp'
    flags { 'WinMain', 'Optimize' }
    defines { 'NDEBUG', 'STATIC_LIB' }
    targetdir '../build/bin/release'
