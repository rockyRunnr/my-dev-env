" ==========================================================================
" .vimrc - Vim 설정 (Vundle 기반)
" ==========================================================================
"
" 사용법:
"   1. Vundle 설치:
"      git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
"   2. 이 파일을 ~/.vimrc 에 복사
"   3. vim 실행 후 :PluginInstall 또는 커맨드라인에서:
"      vim +PluginInstall +qall
"
" 참고: Neovim(Lua 기반) 모던 설정은 nvim/ 디렉토리 참조
" ==========================================================================

" Vim이 sh가 아닌 bash를 셸로 사용하도록 설정
" (플러그인 설치 등에서 bash 문법이 필요할 수 있음)
set shell=/bin/bash

" Vi 호환 모드 비활성화 (Vim의 확장 기능을 모두 사용하기 위해 필요)
" 반드시 다른 설정보다 먼저 와야 함
set nocompatible

" ==========================================================================
" Vundle 플러그인 매니저
" ==========================================================================
" Vundle은 Vim 플러그인을 GitHub에서 자동으로 설치/관리하는 도구.
" 아래 vundle#begin()과 vundle#end() 사이에 원하는 플러그인을 나열하면
" :PluginInstall 명령으로 한 번에 설치됨.

set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

" Vundle 자기 자신 (필수)
Plugin 'gmarik/Vundle.vim'

" --- 에디터 기본 ---

" vim-sensible: 대부분의 사람이 동의하는 기본 설정을 자동 적용
" (backspace, incsearch, listchars 등 - 일일이 설정할 필요 없어짐)
Plugin 'tpope/vim-sensible'

" jellybeans: 어두운 배경의 컬러스킴. 가독성이 좋고 눈이 편함
Plugin 'nanotech/jellybeans.vim'

" --- 파일 탐색 ---

" NERDTree: 화면 왼쪽에 디렉토리 트리를 표시하는 파일 탐색기
" 사용: :NERDTreeToggle 또는 직접 키맵 설정
Plugin 'scrooloose/nerdtree'

" Tagbar: 현재 파일의 함수/변수/클래스 목록을 오른쪽에 표시
" ctags 기반. C/C++ 코드 구조 파악에 유용. F8로 토글
Plugin 'majutsushi/tagbar'

" --- 상태바 ---

" vim-airline: 하단 상태바를 예쁘고 유용하게 교체
" 현재 모드, 파일명, 인코딩, git 브랜치 등을 표시
Plugin 'vim-airline/vim-airline'

" vim-airline-themes: airline의 컬러 테마 모음
" 현재 'hybrid' 테마 사용 중 (아래 설정 참고)
Plugin 'vim-airline/vim-airline-themes'

" --- Git 연동 ---

" vim-gitgutter: 편집기 왼쪽에 git 변경 상태를 실시간 표시
" + (추가), ~ (수정), - (삭제) 표시가 줄 번호 옆에 나타남
Plugin 'airblade/vim-gitgutter'

" vim-fugitive: Vim 안에서 git 명령어 실행
" :Git status, :Git diff, :Git blame, :Gdiffsplit 등
Plugin 'tpope/vim-fugitive'

" --- 들여쓰기 ---

" vim-indent-guides: 들여쓰기 레벨마다 배경색/세로줄로 시각화
" 깊은 중첩에서 어떤 블록에 속하는지 한눈에 파악 가능
Plugin 'nathanaelkane/vim-indent-guides'

" --- LSP (Language Server Protocol) ---
" LSP는 에디터에서 IDE 수준의 코드 분석 기능을 제공하는 프로토콜.
" clangd(C/C++), pyls(Python) 등 언어 서버와 연동하여
" 자동완성, 정의 이동(gd), 참조 찾기(gr), 호버 정보(K) 등을 사용할 수 있음.

" async.vim: 비동기 작업 라이브러리 (vim-lsp의 필수 의존성)
Plugin 'prabirshrestha/async.vim'

" vim-lsp: LSP 클라이언트. 언어 서버와 통신하는 핵심 플러그인
Plugin 'prabirshrestha/vim-lsp'

" vim-lsp-settings: 언어 서버 자동 설치/설정 도우미
" :LspInstallServer 명령으로 현재 파일 타입에 맞는 서버를 자동 설치
Plugin 'mattn/vim-lsp-settings'

" asyncomplete: 비동기 자동완성 엔진. 타이핑 중 팝업으로 후보 표시
Plugin 'prabirshrestha/asyncomplete.vim'

" asyncomplete-lsp: asyncomplete과 vim-lsp를 연결하는 브릿지
" 이것이 있어야 LSP가 제공하는 완성 후보가 자동완성 팝업에 나타남
Plugin 'prabirshrestha/asyncomplete-lsp.vim'

" --- 스니펫 (코드 조각 템플릿) ---
" 예: "for" + Tab → for 루프 템플릿이 자동 생성됨

" UltiSnips: 스니펫 엔진 (트리거 입력 → 코드 조각으로 확장)
Plugin 'SirVer/ultisnips'

" vim-lsp-snippets / vim-lsp-ultisnips: LSP 스니펫과 UltiSnips를 연결
" LSP 서버가 제공하는 스니펫도 UltiSnips로 확장할 수 있게 해줌
Plugin 'thomasfaingnaert/vim-lsp-snippets'
Plugin 'thomasfaingnaert/vim-lsp-ultisnips'

" --- 파일 형식 지원 ---

" vim-markdown: Markdown 파일 구문 강조 및 접기, TOC 등 지원
Plugin 'plasticboy/vim-markdown'

" --- 화면 효과 ---

" vim-diminactive: 비활성 분할 창의 배경을 어둡게 처리
" 여러 창을 열어놓았을 때 현재 작업 중인 창이 어디인지 한눈에 구분됨
Plugin 'blueyed/vim-diminactive'

call vundle#end()

" ==========================================================================
" 기본 설정
" ==========================================================================

" 구문 강조 활성화 (키워드, 문자열, 주석 등에 색상 적용)
syntax enable

" 파일 타입별 들여쓰기 규칙 활성화 (C는 cindent, Python은 PEP8 등)
filetype indent on

" --- 줄 번호 / 들여쓰기 ---

set nu                          " 줄 번호 표시
set autoindent                  " 새 줄에서 이전 줄의 들여쓰기 유지
set smartindent                 " 중괄호 등 문법 구조를 고려한 자동 들여쓰기
set cindent                     " C/C++ 전용 들여쓰기 규칙 적용

" 탭을 4칸 스페이스로 변환
" (HANA 코드 스타일에 맞춤. CheckBot에서도 탭 대신 스페이스 사용을 요구함)
set tabstop=4                   " 탭 문자의 화면 표시 너비 = 4칸
set shiftwidth=4                " >> 또는 << 들여쓰기 시 4칸 이동
set expandtab                   " 실제 탭 문자 대신 스페이스로 입력

" --- 인코딩 (한글 지원) ---

set encoding=utf-8              " Vim 내부 인코딩을 UTF-8로 설정
set fileencodings=ucs-bom,utf-8,euc-kr,latin1
"   파일을 열 때 인코딩을 자동 감지하는 순서:
"   BOM 마크 → UTF-8 → EUC-KR(한글 레거시) → Latin1(폴백)

" --- 검색 ---

set hlsearch                    " 검색 결과를 노란색으로 하이라이트
set incsearch                   " 검색어 입력 중 실시간으로 매칭 위치 이동
set ignorecase                  " 검색 시 대소문자 구분 안 함 (set ic와 동일)
set nowrapscan                  " 파일 끝에 도달하면 처음으로 되돌아가지 않음

" --- 화면 표시 ---

set cursorline                  " 현재 커서가 있는 줄의 배경을 강조
set showmatch                   " 괄호 입력 시 매칭되는 반대쪽 괄호를 잠깐 강조
set title                       " 터미널 타이틀 바에 현재 파일명 표시
set ruler                       " 우측 하단에 현재 커서 위치(줄:열) 표시
set linebreak                   " 긴 줄이 화면을 넘길 때 단어 중간이 아닌 단어 경계에서 줄바꿈
set visualbell                  " 에러 시 '삐' 소리 대신 화면 깜빡임으로 알림

" --- 파일/백업 ---

set nobackup                    " 저장 시 백업 파일(filename~) 생성하지 않음
set noswapfile                  " 편집 중 스왑 파일(.filename.swp) 생성하지 않음
set nofoldenable                " 코드 접기(folding) 비활성화 (모든 코드를 펼쳐서 표시)

" --- 편집 편의 ---

set backspace=eol,start,indent  " 백스페이스로 줄 끝/시작/들여쓰기를 넘어서 삭제 가능
                                " (이 설정 없으면 Insert 모드 진입 전에 입력한 글자를 지울 수 없음)
set history=1000                " 명령어(:) 및 검색(/) 히스토리를 1000개까지 저장
set mouse=a                     " 모든 모드에서 마우스 사용 가능 (클릭으로 커서 이동, 스크롤 등)
set t_Co=256                    " 터미널이 256색을 지원하도록 설정 (컬러스킴이 제대로 표시되려면 필요)
set clipboard=unnamedplus,autoselect
"   unnamedplus: yank/delete가 시스템 클립보드(+)에도 복사됨
"   autoselect:  Visual 모드에서 선택하면 자동으로 클립보드에 복사
set laststatus=2                " 상태바를 항상 표시 (0=안함, 1=창2개이상일때, 2=항상)

" --- 배경/컬러 ---

set background=dark             " 어두운 배경 기준으로 색상 최적화
colorscheme jellybeans          " 컬러스킴 적용
highlight Comment term=bold cterm=bold ctermfg=4
"   주석을 굵은 파란색으로 표시 (기본 회색보다 가독성이 나음)
"   term=bold: 일반 터미널에서 굵게 / cterm=bold: 컬러 터미널에서 굵게
"   ctermfg=4: 글자색을 파란색(4)으로

" ==========================================================================
" 키 매핑
" ==========================================================================
" Leader 키: 사용자 정의 단축키의 접두사.
" 예: Leader가 ","이면 ",q"로 이전 버퍼 이동
let mapleader = ","

" --- 버퍼(파일) 이동 ---
" 여러 파일을 열었을 때(:e file1 :e file2) 버퍼 사이를 이동
nnoremap <leader>q :bp<CR>      " ,q → 이전 버퍼 (buffer previous)
nnoremap <leader>w :bn<CR>      " ,w → 다음 버퍼 (buffer next)

" --- 붙여넣기 모드 ---
" 외부에서 복사한 텍스트를 붙여넣을 때 자동 들여쓰기가 꼬이는 것을 방지
" F2를 눌러 paste 모드를 켜고, 붙여넣은 후 다시 F2로 끔
nnoremap <F2> :set invpaste paste?<CR>
set pastetoggle=<F2>

" --- Tagbar ---
" F8: 현재 파일의 함수/클래스/변수 목록을 오른쪽 패널에 표시/숨김
" ctags가 시스템에 설치되어 있어야 동작함
nmap <F8> :Tagbar<CR>

" --- 매크로 녹화 비활성화 ---
" q를 누르면 매크로 녹화가 시작되는데, 실수로 누르는 경우가 많아서 비활성화
" (매크로가 필요하면 이 줄을 주석처리)
map q <Nop>

" ==========================================================================
" 플러그인 설정
" ==========================================================================

" --- vim-airline (상태바) ---
let g:airline#extensions#tabline#enabled = 1    " 상단에 열린 버퍼 목록을 탭처럼 표시
let g:airline_theme='hybrid'                    " airline 컬러 테마

" --- vim-indent-guides (들여쓰기 가이드) ---
let g:indentguides_spacechar = '┆'              " 스페이스 들여쓰기에 표시할 문자
let g:indentguides_tabchar = '|'                " 탭 들여쓰기에 표시할 문자
let g:indent_guides_enable_on_vim_startup = 1   " Vim 시작 시 자동 활성화
let g:indent_guides_start_level = 2             " 2단계 들여쓰기부터 가이드 표시
let g:indent_guides_guide_size = 1              " 가이드 너비 = 1칸

" --- vim-diminactive (비활성 창 표시) ---
let g:diminactive_enable_focus = 1              " 비활성 창의 배경을 어둡게 처리

" --- UltiSnips (스니펫) ---
" 스니펫: 짧은 트리거를 입력하고 키를 누르면 코드 조각으로 확장됨
" 예: "for" + Tab → for 루프 템플릿 생성, Ctrl+b로 다음 입력 위치로 이동
let g:UltiSnipsExpandTrigger="<tab>"            " Tab: 스니펫 확장
let g:UltiSnipsJumpForwardTrigger="<c-b>"       " Ctrl+b: 스니펫 내 다음 위치로
let g:UltiSnipsJumpBackwardTrigger="<c-z>"      " Ctrl+z: 스니펫 내 이전 위치로

" ==========================================================================
" LSP 설정 (clangd, pyls)
" ==========================================================================
" LSP(Language Server Protocol)는 에디터와 언어 서버 사이의 통신 프로토콜.
" 이를 통해 자동완성, 정의 이동, 참조 찾기, 에러 표시 등 IDE 기능을 사용할 수 있음.
"
" clangd: C/C++ 언어 서버 (LLVM 프로젝트). HANA C++ 개발의 핵심 도구.
"         동작하려면 빌드 디렉토리에 compile_commands.json이 필요함.
" pyls:   Python 언어 서버 (pip install python-language-server로 설치)

" 커서가 에러/경고 줄에 있으면 하단에 진단 메시지를 자동 표시
let g:lsp_diagnostics_echo_cursor = 1

" --- clangd 등록 (C/C++) ---
" clangd가 시스템에 설치되어 있을 때만 등록
" --background-index: 백그라운드에서 프로젝트 전체를 인덱싱 (대규모 프로젝트에서 유용)
if executable('clangd')
    au User lsp_setup call lsp#register_server({
        \ 'name': 'clangd',
        \ 'cmd': {server_info->['clangd', '-background-index']},
        \ 'whitelist': ['c', 'cpp', 'objc', 'objcpp'],
        \ })
endif

" --- pyls 등록 (Python) ---
" pyls가 설치되어 있을 때만 등록 (pip install python-language-server)
if executable('pyls')
    au User lsp_setup call lsp#register_server({
        \ 'name': 'pyls',
        \ 'cmd': {server_info->['pyls']},
        \ 'whitelist': ['python'],
        \ })
endif

" --- LSP 버퍼 키맵 ---
" LSP 서버가 연결된 버퍼에서만 활성화되는 키 매핑
function! s:on_lsp_buffer_enabled() abort
    setlocal omnifunc=lsp#complete     " Ctrl+x Ctrl+o 로 LSP 자동완성 사용 가능
    setlocal signcolumn=yes            " 왼쪽에 기호 열 표시 (에러/경고 아이콘용)
    nmap <buffer> gd <plug>(lsp-definition)     " gd: 커서 아래 심볼의 정의로 이동
    nmap <buffer> gr <plug>(lsp-references)     " gr: 커서 아래 심볼을 참조하는 모든 곳 찾기
    nmap <buffer> K <plug>(lsp-hover)           " K:  커서 아래 심볼의 타입 정보/문서 팝업
    nmap <buffer> <f2> <plug>(lsp-rename)       " F2: 커서 아래 심볼의 이름을 일괄 변경
endfunction

" LSP 서버가 버퍼에 연결되면 위 함수를 자동 실행
augroup lsp_install
    au!
    autocmd User lsp_buffer_enabled call s:on_lsp_buffer_enabled()
augroup END

" LSP 글로벌 키맵 (버퍼 키맵이 안 먹힐 때의 폴백)
nnoremap <Leader>d :LspDefinition<CR>   " ,d → 정의로 이동
nnoremap <Leader>r :LspReferences<CR>   " ,r → 참조 찾기

" ==========================================================================
" fzf (퍼지 파일 검색)
" ==========================================================================
" fzf가 설치되어 있으면 Vim에서 파일을 퍼지 검색으로 빠르게 열 수 있음
" 사전 설치 필요:
"   git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
"   ~/.fzf/install
set rtp+=~/.fzf

" ==========================================================================
" 후행 공백 하이라이트
" ==========================================================================
" 줄 끝에 불필요한 공백이 있으면 빨간 배경으로 강조 표시
" HANA CheckBot에서 후행 공백은 에러로 잡히므로 미리 확인할 수 있어 유용함
" Insert 모드에서 타이핑 중인 커서 뒤의 공백은 무시 (타이핑 방해 방지)
highlight ExtraWhitespace ctermbg=red guibg=red
match ExtraWhitespace /\s\+$/
autocmd BufWinEnter * match ExtraWhitespace /\s\+$/
autocmd InsertEnter * match ExtraWhitespace /\s\+\%#\@<!$/
autocmd InsertLeave * match ExtraWhitespace /\s\+$/
autocmd BufWinLeave * call clearmatches()
