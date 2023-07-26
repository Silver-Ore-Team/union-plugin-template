# union-plugin-template

Template for creating Union plugins based on [union-api](https://gitlab.com/union-framework/union-api) and CMake as the buildsystem generator.

## Setting up the project

Clone this repository and update submodules to fetch the dependencies.

```sh
git clone git@github.com:Silver-Ore-Team/union-plugin-template.git MyUnionPlugin
cd MyUnionPlugin
git submodule update --remote --recursive
```

If you'd like to push it to other Git repository, you can remove remote origin and add your own:
```sh
git remote rm origin
git remote add origin <YOUR_REPOSITORY_LINK>
```

Change `CMakeLists.txt` project name to your plugin name, like:

```cmake
cmake_minimum_required(VERSION 3.26)

# Project Settings
project(MyUnionPlugin)

# ...
```

The project name is used as DLL file name.

## Code structure

Plugin code is created in `plugin/src/`.
This template is designed for multiplatform plugin development, so it contains some non-standard includes trickery. 

`Plugin.cpp` is a compiled file, so it's the entrypoint fof compilation. 
It includes `Plugin.hpp` for each engine version and provides defines of it.

`Plugin.hpp` contains the code that's the same for each engine by using `GOTHIC_NAMESPACE` define that's correspond to one of engine namespaces.
If you need to write some part of code specifically for single engine, you can put it into a separate file and include in `Plugin.cpp`.

`Game.hpp` is also included by the  entrypoint, but only once and it contains plugin exports for Union game events.

### Adding additional .cpp files

List of `.cpp` to compile is available at the start of `plugin/CMakeLists.txt` and you can add it there:

```cmake
# Sources to compile
set(UNION_PLUGIN_SOURCES "${CMAKE_CURRENT_SOURCE_DIR}/src/Plugin.cpp"
	"${CMAKE_CURRENT_SOURCE_DIR}/src/MyNewCppFile.cpp")

add_library(${CMAKE_PROJECT_NAME} SHARED)
# ...
```

### Calling into GOTHIC_NAMESPACE from outside

`GOTHIC_NAMESPACE` is a compile-time definition for `Plugin.hpp` to generate same code for different namespaces. 
During the runtime we have the code for all 4 engines, so we need to use `GetGameVersion()` function and dispatch our call dynamically, like:

```cpp
__declspec(dllexport) void Game_Entry() {
	int virtualPos = 42;
	int pixelPos;

	switch(GetGameVersion())
	{
	case Engine_G1:
		pixelPos = Gothic_I_Classic::VirtualToPixelX(virtualPos);
		break;
	case Engine_G1A:
		pixelPos = Gothic_I_Addon::VirtualToPixelX(virtualPos);
		break;
	case Engine_G2:
		pixelPos = Gothic_II_Classic::VirtualToPixelX(virtualPos);
		break;
	case Engine_G2A:
		pixelPos = Gothic_II_Addon::VirtualToPixelX(virtualPos);
		break;
	}

	// pixelPos = GOTHIC_NAMESPACE::VirtualToPixelX(virtualPos)
}
```

### Gothic_UserAPI

[gothic-api](https://gitlab.com/union-framework/gothic-api) includes an inline file for every ZenGin class and let us define additional methods that are handly for hooks on `__thiscall` functions.
The template holds all these inline files in `gothic-userapi` and dynamically overlays them on original `gothic-api` files copied to working directory during a build.
This way we can make us of them without editing anything in `gothic-api` submodule.

## Building

The simplest way to build the project is to open it inside Visual Studio 2022. It will automatically parse and configure CMake.

### Manual CMake

To build the project we have to configure buildsystem using CMake and execute Ninja on it. 
We define presets for Debug and Release targets as `x86-debug` and `x86-release`.

```sh
# Debug
cmake --preset x86-debug
ninja -C out/build/x86-debug -j 20
cmake --install out/build/x86-debug --prefix out/install/x86-debug

# Release
cmake --preset x86-release
ninja -C out/build/x86-release -j 20
cmake --install out/build/x86-release --prefix out/install/x86-release
```

Then we should have UnionAPI.dll and our plugin DLL inside `out/install/x86-debug` or `out/install/x86-release` depending on selected target.
 
### Linking other dependencies

You can easily link external libraries to the project with CMake. Libraries may provide a `.cmake` file to include or be configured using a package manager like vcpkg or Conan.
After you get the dependency to expose a CMake target, you can link the plugin against it in `plugin/CMakeLists.txt`.

```cmake
# ...
target_link_libraries(${CMAKE_PROJECT_NAME} PRIVATE union-api gothic-api MyDependency::MyDependency)
# ...
```
