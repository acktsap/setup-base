# Neovim

This setup uses LazyVim as the base and keeps local overrides under `neovim/config`.

## Source

- Runtime config source: [config](config)
- Installed config path: `$HOME/.config/nvim`
- Setup link: [setup.sh](setup.sh) links [config](config) to `$HOME/.config/nvim`
- Entrypoint: [config/init.lua](config/init.lua)
- LazyVim imports and plugin order: [config/lua/config/lazy.lua](config/lua/config/lazy.lua)
- General options: [config/lua/config/options.lua](config/lua/config/options.lua)
- Local IntelliJ Darcula colorscheme: [config/colors/intellij-islands-darcula.lua](config/colors/intellij-islands-darcula.lua)

## Keymap Sources

- General keymaps: [config/lua/config/keymaps.lua](config/lua/config/keymaps.lua)
- Java LSP and Java-only keymaps: [config/lua/plugins/java.lua](config/lua/plugins/java.lua)
- Neo-tree keymaps and explorer behavior: [config/lua/plugins/editor.lua](config/lua/plugins/editor.lua)

Use `:WhichKey` or `Space ?` inside Neovim to inspect the active keymaps.
