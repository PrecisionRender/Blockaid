# Blockaid
### A replay analysis, note-taker, and studying tool for block stacker games.

## About
Blockaid is a tool that allows you to **extract**, **store**, and **analyze** board states and player actions from block stacker replays. Blockaid can help you improve your block stacker skills by helping you **study how the best players stack** and by helping you **learn from your own mistakes** and see how you can **improve your strategy and technique**.

Blockaid is not meant as a replacement to [four-tris](https://github.com/fiorescarlatto/four-tris), but rather as a complimentary tool designed to be used with it. 

## Downloading
To download the latest version of Blockaid, check out the [Releases](https://github.com/PrecisionRender/Blockaid/releases) page.

### What platforms does Blockaid support?
Theoretically, it *should* support all 3 desktop platforms. However, as a Windows user, I am unable to build and test for the other platforms at the moment. If you want to use Blockaid on macOS or Linux, you'll have to build it yourself (see below). Please report any platform-specific issues you encounter!

## Custom skins

Blockaid supports the use of custom skins. Skin images should:
- Be `270 x 30` exactly
- Be `.png`, `.jpg`, `.jpeg`, or `.bmp` files
- Follow a `Z-L-O-S-I-J-T-Garbage-Empty` pattern

To use a custom skin, Go to `Options > Custom skin > Choose skin` and select a skin image.

When creating a custom skin, you can use this image as a reference:

<img width="300" alt="skin" src="https://github.com/PrecisionRender/Blockaid/assets/89754713/446838d8-4e8a-449c-983f-2b62f33ee9b6">

## Building
Blockaid is built using [Godot Engine](https://github.com/godotengine/godot). Unfortunately, Blockaid depends on [a bugfix](https://github.com/godotengine/godot/pull/81782) not yet merged in Godot. If you want to contribute to this project, you'll have to build [this custom fork of Godot](https://github.com/PrecisionRender/godot/tree/fix-windows-file-dialogue-file-seperators) from source. See [this guide](https://docs.godotengine.org/en/stable/contributing/development/compiling/index.html) to learn how to build Godot.

After you build Godot, clone the repository: `git clone https://github.com/PrecisionRender/Blockaid.git`

Once cloned, you can open the project in Godot. To be able to build binaries of Blockaid, you'll once again have to use that custom fork of Godot, this time to [build export templates](https://docs.godotengine.org/en/stable/contributing/development/compiling/introduction_to_the_buildsystem.html#export-templates).

## Contributing
First off, if you want to contribute to Blockaid, thanks!

Before opening a pull request, you should generally do the following:

- Open an issue or feature suggestion regarding the functionality you want changed. That way, we can discuss if and how it should be implemented.
- Make sure you have a basic understanding of the code you are changing
- Follows the project's style guide and coding conventions (see below)

Even if your pull request meets all of these recommendations, there is no guarantee it'll get merged. If I feel like your PR doesn't add any significant value to the project, it may be dismissed or given new requirements before it can be merged.

### Coding conventions
In order to maintain clean, readable, and maintainable code, all pull requests should follow these conventions. Spending a little extra effort to keep code clean in the short term saves hours of work in the future.

- The code should always follow the official [GDScript Style Guide](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_styleguide.html), with the only exception being [line length](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_styleguide.html#line-length) (still try to follow it, though)
- Always use [static typing](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/static_typing.html) when possible
- The code should follow the the recommended [best practices](https://docs.godotengine.org/en/stable/tutorials/best_practices/index.html) set out by the Godot Engine team
- The code should follow the the [GDQuest guide on code cleanliness](https://www.gdquest.com/tutorial/godot/best-practices/code-cleanliness/)
- Avoid creating new Autoloads. In Godot, they normally act as singletons, which are infamous for creating messy code.
- Application code should **only** be written in GDScript. The use of GDExtension is allowed when using third-party libraries.
- If you want to go the extra mile, document your code using `#comments` if necessary.

Pull requests that follow these guidelines are much more likely to be accepted.

## License
Blockaid is available under the `Apache 2.0 license`. Copyright © 2023 PrecsionRender.
