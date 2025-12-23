markdown


```mermaid
graph TD
    Desktop["Desktop"]
    Application["Application"]
    Documentation_Site["Documentation_Site"]
    Component["Component"]
    Target["Target"]
    Web["Web"]
    Bridge["Bridge"]
    Primary["Primary"]
    Purpose["Purpose"]
    External_TargetsBuild_SystemCore_PackagesWeb_Platformstrudel["External_TargetsBuild_SystemCore_PackagesWeb_Platformstrudel"]
    Web_BrowsersMIDI_HardwareDesktop_Applications["Web_BrowsersMIDI_HardwareDesktop_Applications"]
    Environment["Environment"]
    Cross["Cross"]
    External_TargetsBuild_SystemCore_PackagesWeb_Platformstrudel --> Documentation_Site
    Documentation_Site --> Web_BrowsersMIDI_HardwareDesktop_Applications
    Web_BrowsersMIDI_HardwareDesktop_Applications --> Component
    Component --> Purpose
    Purpose --> Target
    Target --> Environment
    Environment --> Web
    Web --> Application
    Application --> Primary
    Primary --> Web
    Web --> Desktop
    Desktop --> Bridge
    Bridge --> Cross
    Cross --> Desktop
```