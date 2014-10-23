project 'Lua'
  kind 'StaticLib'
  language 'C'
  location '../build'
  includedirs { './' }
  files { '*.c', '*.h' }

  configuration 'Debug'
    targetdir '../build/lib/debug'
    defines { 'DEBUG' }
  configuration 'Release'
    targetdir '../build/lib/release'
    defines { 'NDEBUG' }


