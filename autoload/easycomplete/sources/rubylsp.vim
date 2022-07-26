if exists('g:easycomplete_rubylsp')
  finish
endif
let g:easycomplete_rubylsp = 1

function! easycomplete#sources#rubylsp#constructor(opt, ctx)
  call easycomplete#RegisterLspServer(a:opt, {
      \ 'name': 'ruby-lsp',
      \ 'cmd': {server_info->[easycomplete#installer#GetCommand(a:opt['name']), 'stdio']},
      \ 'initialization_options':  {
      \     'diagnostics': 'true'
      \ },
      \ 'allowlist': a:opt["whitelist"],
      \ })
endfunction

function! easycomplete#sources#rubylsp#completor(opt, ctx) abort
  return easycomplete#DoLspComplete(a:opt, a:ctx)
endfunction

function! easycomplete#sources#rubylsp#GotoDefinition(...)
  return easycomplete#DoLspDefinition(["rb"])
endfunction

