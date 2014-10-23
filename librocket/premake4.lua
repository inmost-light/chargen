local function libRocket(part)
  project('Rocket' .. part)
    kind 'StaticLib'
    language 'C++'
    location '../build'
    includedirs { 'Include', '../freetype/include', '../freetype/include/freetype2' }
    files { 'Source/' .. part .. '/*.cpp' }
  
    configuration 'Debug'
      targetdir '../build/lib/debug'
      defines { 'DEBUG', 'STATIC_LIB' }
    configuration 'Release'
      targetdir '../build/lib/release'
      defines { 'NDEBUG', 'STATIC_LIB' }
      flags { 'Optimize' }
end

libRocket 'Core'
libRocket 'Debugger'


