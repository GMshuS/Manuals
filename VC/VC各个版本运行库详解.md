以下是各VC版本（对应Visual Studio版本）对应的RunTime（运行库）、Redistribuable（可再发行组件）、平台工具集（MSVC Toolset）完整对应关系，适配VSCode+QT开发场景，兼顾实用性和准确性，核心信息如下：

| VC版本（内部） | 对应VS版本       | RunTime（运行库）                          | Redistribuable（可再发行组件）                          | 平台工具集（MSVC Toolset） | 备注（QT开发适配）                     |
|----------------|------------------|--------------------------------------------|-------------------------------------------------------|----------------------------|----------------------------------------|
| VC6.0          | VS 6.0 (1998)    | MSVCR60.dll、MSVCIRT.dll                   | Microsoft Visual C++ 6.0 Redistributable              | -                          | 老旧版本，QT基本不再适配               |
| VC7.0          | VS .NET 2002 (7.0)| MSVCR70.dll                                | Microsoft Visual C++ .NET 2002 Redistributable        | -                          | 少见，不推荐用于QT开发                 |
| VC7.1          | VS .NET 2003 (7.1)| MSVCR71.dll                                | Microsoft Visual C++ .NET 2003 Redistributable        | -                          | 少见，不推荐用于QT开发                 |
| VC8.0          | VS 2005 (8.x)    | MSVCR80.dll、MSVCP80.dll                   | Microsoft Visual C++ 2005 SP1 Redistributable         | -                          | QT5及以上版本基本不支持                |
| VC9.0          | VS 2008 (9.x)    | MSVCR90.dll、MSVCP90.dll                   | Microsoft Visual C++ 2008 SP1 Redistributable         | -                          | QT5早期版本可适配，现已淘汰            |
| VC10.0         | VS 2010 (10.x)   | MSVCR100.dll、MSVCP100.dll                 | Microsoft Visual C++ 2010 SP1 Redistributable         | -                          | QT5部分版本支持，多用于旧项目维护      |
| VC11.0         | VS 2012 (11.x)   | MSVCR110.dll、MSVCP110.dll                 | Microsoft Visual C++ 2012 UP4 Redistributable         | -                          | QT5.0及以上部分版本支持                |
| VC12.0         | VS 2013 (12.x)   | MSVCR120.dll、MSVCP120.dll                 | Microsoft Visual C++ 2013 Redistributable             | -                          | QT5.2及以上版本支持，旧项目常用        |
| VC14.0         | VS 2015 (14.x)   | MSVCR140.dll、MSVCP140.dll                 | Microsoft Visual C++ 2015 Redistributable             | v140                       | QT5.6及以上版本主流适配，常用          |
| VC14.1x        | VS 2017 (15.x)   | MSVCR140.dll、MSVCP140.dll（兼容VC14.0）   | Microsoft Visual C++ 2015-2022 Redistributable        | v141（14.10~14.16）        | QT5.12及以上版本适配，兼容VC14.0       |
| VC14.2x        | VS 2019 (16.x)   | MSVCR140.dll、MSVCP140.dll（兼容VC14.0）   | Microsoft Visual C++ 2015-2022 Redistributable        | v142（14.20~14.29）        | QT5.15及以上、QT6主流适配，推荐使用    |
| VC14.3x        | VS 2022 (17.x)   | MSVCR140.dll、MSVCP140.dll（兼容VC14.0）   | Microsoft Visual C++ 2015-2022 Redistributable        | v143（14.30~14.39）        | QT6.2及以上版本适配，最新主流          |

### 关键补充说明
1.  从VS2015（VC14.0）开始，VC++内部版本号固定为14.x，后续VS版本仅更新小版本，RunTime保持向下兼容，Redistribuable统一为「2015-2022」版本，安装后可适配所有VC14.0及以上版本的程序。
2.  平台工具集（v140/v141/v142/v143）是VS/VSCode编译配置的核心参数，在QT配置中需与QT安装时选择的「MSVC版本」一致（如QT安装时选择msvc2019，对应平台工具集v142）。
3.  RunTime核心文件为msvcrxxx.dll（C运行库）和msvcpxxx.dll（C++运行库），缺失时会导致QT程序无法启动，需安装对应Redistribuable修复。

需要我结合你当前的**QT版本**，补充对应的VC版本及配置注意事项吗？