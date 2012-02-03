
translit.vim
============


Author:  Einar Lielmanis <einars@gmail.com>
Home:    http://github.com/einars/translit.vim

About
-----

This plugin allows you to write texts in transliterated russian (or any
other language you'll write a definition for). That means, you write
"Cheburashka" and it gets automagically converted to "Чебурашка", or
write "Ellada" and it converts to "Ελλαδα"

This plugin is loosely based on russian_plansliterated.vim plugin by
Krzystof Goj (http://www.vim.org/scripts/script.php?script_id=2401) and was
used as my playground for learning vimscript.


Configuration
-------------

g:translit_cursor_bg <color>
Cursor color for gvim when in the transliteration mode. Default = red.

g:translit_map "translit.ru"
Sets the initial keyboard mapping scheme. Currently "translit.ru",
"PLanslit" and "greek" are supported.

g:translit_toggle_keymap "<C-T>"
Default keybinding to toggle translit mode, Ctrl-Shift-t.

Set up multiple transliteration maps in .vimrc, for example:

      inoremap <C-G> <C-r>=Translit('greek')<cr>
      nnoremap <C-G> :exec Translit('greek')<cr>


Basic Usage
-----------

Drop plugin under ~/.vim/plugins and switch translit mode on/off with
Ctrl-Shift-t.


Custom Translit Maps
--------------------

use TranslitAddMap(name, table) to set up your own translit mode. The
mapping is in format "key1:result1, key2:result2", whitespace is stripped.
