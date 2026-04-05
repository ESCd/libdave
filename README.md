# libdave

[![Version](https://img.shields.io/nuget/vpre/libdave)](https://www.nuget.org/packages/libdave)

Native library assets for [libdave](https://github.com/discord/libdave).

## Features

| Property                         | Default                                                  | Description                                                                                           |
| -------------------------------- | -------------------------------------------------------- | ----------------------------------------------------------------------------------------------------- |
| `$(LibDaveEnableRuntimeLinking)` | `true`                                                   | Toggle whether shared libraries are copied to the output directory.                                   |
| `$(LibDaveEnableStaticLinking)`  | `$(PublishAot) == 'true' AND $(RuntimeIdentifier) != ''` | Toggle whether `DirectPInvoke`+`NativeLibrary` items are included in the project (for Static Linking) |