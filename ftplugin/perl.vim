" Tagma Tags Perl File Type Plugin
" vim:foldmethod=marker
" File:         ftplugin/perl.vim
" Last Changed: Sun, Jan 1, 2012
" Maintainer:   Lorance Stinson @ Gmail ...
" Home:         https://github.com/LStinson/TagmaTags
" License:      Public Domain
"
" Description:
" Adds the tags file in perl/ to the tags list for all Perl files.
" This allows lookup of documentation using Vims tag navigation commands.

" The location of the Perl tags file.
let s:PerlTagsFile = expand('<sfile>:p:h:h') . '/perldocs/tags'

" Add the tags file to the local tags list.
execute 'setlocal tags+=' . substitute(s:PerlTagsFile, ' ', '\\ ', 'g')
