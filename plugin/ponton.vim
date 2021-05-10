" This Source Code Form is subject to the terms of the Mozilla Public
" License, v. 2.0. If a copy of the MPL was not distributed with this
" file, You can obtain one at https://mozilla.org/MPL/2.0/.

if exists('g:ponton_loaded')
  finish
endif
let g:ponton_loaded = 1

let s:save_cpo = &cpo
set cpo&vim

lua require'ponton'.augroup()

let &cpo = s:save_cpo
unlet s:save_cpo
