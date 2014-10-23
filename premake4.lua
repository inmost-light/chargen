solution 'RockApp'
  configurations { 'Debug', 'Release' }
  location 'build'

  include 'librocket'
  include 'shell'
  include 'lua'
  include 'app'

  configuration 'Debug'
    postbuildcommands {
      [[xcopy ..\assets bin\debug\assets /iqy]],
      [[xcopy ..\scripts bin\debug\scripts /iqy]],
      [[xcopy ..\data bin\debug\data /iqy]],
      [[copy ..\freetype\bin\freetype6.dll bin\debug /Y]],
    }
  configuration 'Release'
    postbuildcommands {
      [[xcopy ..\assets bin\release\assets /iqy]],
      [[xcopy ..\scripts bin\release\scripts /iqy]],
      [[xcopy ..\data bin\release\data /iqy]],
      [[copy ..\freetype\bin\freetype6.dll bin\release /Y]],
    }


